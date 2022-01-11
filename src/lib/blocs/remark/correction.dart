import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:schoolexam/exams/exams.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

/// This class contains all necessary data for an ongoing correction of a single submission instance
class Correction {
  /// The initial submission without any correction remarks
  final String submissionPath;
  final Uint8List submissionData;
  final int pageNumber;

  /// Contains the pdf of the ongoing remark
  /// Importantly, we store the submission pdf as lowest layer
  final String correctionPath;
  final Uint8List correctionData;

  /// Contains possible meta data about the submission, like the corresponding student.
  final Submission submission;

  /// Contains meta data about the answers within the submission. This allows for task specific UI navigation.
  final Answer currentAnswer;

  const Correction._(
      {required this.submissionData,
      required this.submissionPath,
      required this.correctionPath,
      required this.correctionData,
      required this.submission,
      required this.currentAnswer,
      this.pageNumber = 0});

  static Future<Uint8List> _ensurePersistence(
      {required String path, required String data}) async {
    final file = File(path);

    late final Uint8List res;
    if (await file.exists()) {
      log("Loading file located at $path");
      final document = PdfDocument(inputBytes: await file.readAsBytes());
      res = Uint8List.fromList(document.save());
    } else {
      log("Writing file to $path");
      final document = PdfDocument.fromBase64String(data);
      res = Uint8List.fromList(document.save());

      await file.create(recursive: true);
      await file.writeAsBytes(res);
    }

    return res;
  }

  static Future<Correction> start({required Submission submission}) async {
    final directory = (await getApplicationDocumentsDirectory()).path;
    final submissionPath =
        p.join(directory, "submissions", submission.exam.id, submission.id);
    final correctionPath =
        p.join(directory, "corrections", submission.exam.id, submission.id);

    final sRes =
        await _ensurePersistence(path: submissionPath, data: submission.data);
    final cRes =
        await _ensurePersistence(path: correctionPath, data: submission.data);

    return Correction._(
        correctionData: cRes,
        correctionPath: correctionPath,
        submissionData: sRes,
        submissionPath: submissionPath,
        submission: submission,
        currentAnswer: Answer.empty);
  }

  Correction copyWith(
      {Answer? currentAnswer,
      Uint8List? submissionData,
      Uint8List? correctionData}) {
    return Correction._(
        correctionData: correctionData ?? this.correctionData,
        correctionPath: correctionPath,
        submissionData: submissionData ?? this.submissionData,
        submissionPath: submissionPath,
        submission: submission,
        currentAnswer: currentAnswer ?? this.currentAnswer);
  }

  static final empty = Correction._(
      submissionPath: "",
      submissionData: Uint8List.fromList([]),
      pageNumber: 0,
      correctionPath: "",
      correctionData: Uint8List.fromList([]),
      submission: Submission.empty,
      currentAnswer: Answer.empty);

  bool get isEmpty => this == Correction.empty;
  bool get isNotEmpty => this != Correction.empty;
}
