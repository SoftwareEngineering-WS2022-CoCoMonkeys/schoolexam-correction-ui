import 'dart:developer';
import 'dart:io';

import 'package:schoolexam_correction_ui/repositories/correction_overlay/correction_overlay.dart';
import 'package:path/path.dart' as p;
import 'package:schoolexam_correction_ui/repositories/correction_overlay/persistence/correction_overlay_input_data.dart';
import 'package:schoolexam_correction_ui/repositories/correction_overlay/persistence/correction_overlay_page_data.dart';
import 'package:schoolexam_correction_ui/repositories/correction_overlay/persistence/correction_overlay_point_data.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseCorrectionOverlayRepository extends CorrectionOverlayRepository {
  Database? database;

  Future<void> init() async {
    final path =
        p.join(await getDatabasesPath(), 'correction_overlay_repository.db');

    database = await openDatabase(path, onCreate: (db, version) {
      /// CorrectionOverlayPageData
      db.execute(
          'CREATE TABLE IF NOT EXISTS pages(id INTEGER PRIMARY KEY NOT NULL, submissionId TEXT NOT NULL, pageNumber INTEGER NOT NULL, width DOUBLE NOT NULL, height DOUBLE NOT NULL)');

      /// CorrectionOverlayInputData
      db.execute(
          'CREATE TABLE IF NOT EXISTS inputs(id INTEGER PRIMARY KEY NOT NULL, pageId INTEGER NOT NULL, color INTEGER NOT NULL, FOREIGN KEY(pageId) REFERENCES pages(id))');

      /// CorrectionOverlayPointData
      db.execute(
          'CREATE TABLE IF NOT EXISTS points(inputId INTEGER NOT NULL, relX DOUBLE NOT NULL, relY DOUBLE NOT NULL, p DOUBLE NOT NULL, FOREIGN KEY(inputId) REFERENCES inputs(id))');
    }, version: 1);
  }

  Future<List<CorrectionOverlayPageData>> _getPages(
          {required String submissionId}) async =>
      List<Map<String, dynamic>>.from(await database!.query('pages',
              where: 'submissionId = ?', whereArgs: [submissionId]))
          .map((e) => CorrectionOverlayPageData.fromMap(e))
          .toList();

  Future<void> _deleteDocument({required String submissionId}) async {
    final inputIds = List<Map<String, dynamic>>.from(await database!.rawQuery(
            'SELECT i.id'
            ' FROM inputs i'
            ' INNER JOIN pages p'
            ' ON'
            '	 p.id = i.pageId'
            ' WHERE'
            '	 p.submissionId = ?',
            [submissionId]))
        .map((e) => e["id"] as int)
        .toList();

    await database!.transaction((txn) async {
      // 1. Delete points
      txn.delete('points', where: 'inputId IN (${inputIds.join(",")})');
      // 2. Delete inputs
      txn.delete('inputs', where: 'id IN (${inputIds.join(",")})');
      // 3. Delete pages
      txn.delete('pages', where: 'submissionId = ?', whereArgs: [submissionId]);
    });
  }

  Future<void> _insertDocument(
      {required CorrectionOverlayDocument document}) async {
    await database!.transaction((txn) async {
      // 1. Insert Pages
      final pBatch = txn.batch();
      final pages = <CorrectionOverlayPageData>[];

      for (var i = 0; i < document.pages.length; i++) {
        final page = CorrectionOverlayPageData.fromModel(
            document: document, pageNumber: i);

        pages.add(page);
        pBatch.insert('pages', page.toMap());
      }

      final pageIds = (await pBatch.commit()).cast<int>();
      for (var i = 0; i < document.pages.length; i++) {
        pages[i] = pages[i].copyWith(id: pageIds[i]);
      }

      log("Inserted ${pageIds.length} pages into the database for the document ${document.submissionId}");

      // 2. Insert Inputs
      final iBatch = txn.batch();
      final inputs = <CorrectionOverlayInputData>[];

      for (var i = 0; i < document.pages.length; i++) {
        for (var j = 0; j < document.pages[i].inputs.length; j++) {
          final input = CorrectionOverlayInputData.fromModel(
              page: pages[i], input: document.pages[i].inputs[j]);

          inputs.add(input);
          iBatch.insert('inputs', input.toMap());
        }
      }

      final inputIds = (await iBatch.commit()).cast<int>();
      for (var i = 0; i < inputs.length; i++) {
        inputs[i] = inputs[i].copyWith(id: inputIds[i]);
      }

      log("Inserted ${inputIds.length} inputs into the database for the document ${document.submissionId}");

      // 3. Insert Points
      final poBatch = txn.batch();

      var dj = 0;
      for (var i = 0; i < document.pages.length; i++) {
        final page = document.pages[i];
        for (var j = 0; j < page.inputs.length; j++) {
          final input = inputs[dj++];
          for (var l = 0; l < page.inputs[j].points.length; l++) {
            final point = page.inputs[j].points[l];
            poBatch.insert(
                'points',
                CorrectionOverlayPointData.fromModel(input: input, point: point)
                    .toMap());
          }
        }
      }
      await poBatch.commit(noResult: true);
    });
  }

  @override
  Future<CorrectionOverlayDocument> getDocument(
      {required String submissionId}) async {
    if (database == null) {
      await init();
    }

    // 1. Get Pages
    final pages = await _getPages(submissionId: submissionId);
    pages.sort((a, b) => a.pageNumber.compareTo(b.pageNumber));

    if (pages.isEmpty) {
      return CorrectionOverlayDocument.empty;
    }

    // 2. Get Inputs and Points
    final inputs = <int, Map<int, CorrectionOverlayInputData>>{};
    final mPoints = <int, List<CorrectionOverlayPoint>>{};

    for (final e in List<Map<String, dynamic>>.from(
        await database!.rawQuery('SELECT i.*, p.*'
            ' FROM inputs i'
            ' INNER JOIN points p'
            ' ON'
            '	 p.inputId = i.id'
            ' WHERE'
            '  i.pageId IN (${pages.map((e) => e.id).join(",")})'))) {
      final point = CorrectionOverlayPointData.fromMap(e);
      mPoints.putIfAbsent(point.inputId, () => <CorrectionOverlayPoint>[]);
      mPoints[point.inputId]!.add(point.toModel());

      final input = CorrectionOverlayInputData.fromMap(e);
      inputs.putIfAbsent(
          input.pageId, () => <int, CorrectionOverlayInputData>{});
      inputs[input.pageId]![input.id!] = input;
    }

    // 3. Convert to models
    final mInputs = inputs.map((key, value) => MapEntry(
        key,
        value.values
            .map((e) => e.toModel(points: mPoints[e.id!] ?? []))
            .toList()));

    final mPages =
        pages.map((e) => e.toModel(inputs: mInputs[e.id!] ?? [])).toList();

    return CorrectionOverlayDocument(submissionId: submissionId, pages: mPages);
  }

  @override
  Future<bool> saveDocument(
      {required CorrectionOverlayDocument document}) async {
    if (database == null) {
      await init();
    }

    // TODO : transaction
    // TODO : Incremental update... for efficieny improvement
    await _deleteDocument(submissionId: document.submissionId);
    await _insertDocument(document: document);
    return true;
  }
}
