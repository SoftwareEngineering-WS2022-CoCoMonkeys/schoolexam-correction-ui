import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:path_provider/path_provider.dart';
import 'package:schoolexam/exams/exams.dart';
import 'package:schoolexam_correction_ui/repositories/correction_overlay/correction_overlay.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'correction.dart';
import 'package:path/path.dart' as p;

/// This helper class is responsible for handling the interaction between the PDF data obtained from the [Submission] model and the local file system.
/// It initializes local files, if necessary, uniquely associates files within the file system to a submission and loads them upon request.
class RemarkPdfHelper {
  const RemarkPdfHelper();

  /// Loads the correction pdf from [path].
  /// If no pdf file exists at [path] the base64 encoded [data] is written to the file
  Future<Uint8List> _initPdfFile(
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

  /// Determines the path to the correction pdf for the [submissionId].
  Future<String> _getCorrectionPath({required String submissionId}) async {
    final directory = (await getApplicationDocumentsDirectory()).path;
    return p.join(directory, "corrections", submissionId, ".pdf");
  }

  /// Determines the path to the submission pdf for the [submissionId].
  Future<String> _getSubmissionPath({required String submissionId}) async {
    final directory = (await getApplicationDocumentsDirectory()).path;
    return p.join(directory, "submissions", submissionId, ".pdf");
  }

  /// Retrieves an existing correction for [submission], if given.
  /// Otherwise a correction is initialized.
  Future<Correction> loadCorrection({required Submission submission}) async {
    final submissionPath =
        await _getSubmissionPath(submissionId: submission.id);
    final correctionPath =
        await _getCorrectionPath(submissionId: submission.id);

    final sRes =
        await _initPdfFile(path: submissionPath, data: submission.data);
    final cRes =
        await _initPdfFile(path: correctionPath, data: submission.data);

    return Correction(
        correctionData: cRes,
        correctionPath: correctionPath,
        submissionData: sRes,
        submissionPath: submissionPath,
        submission: submission,
        currentAnswer: Answer.empty);
  }

  /// Merges the supplied [CorrectionOverlayDocument] with the pdf stored for the associated submission into a separate pdf file.
  Future<Uint8List> merge({required CorrectionOverlayDocument document}) async {
    if (document.isEmpty) {
      log("The document provided is invalid.");
      return Uint8List.fromList([]);
    }

    final path = await _getCorrectionPath(submissionId: document.submissionId);
    final file = File(path);

    if (!(await file.exists())) {
      log("There exists no pdf for ${document.submissionId}");
      return Uint8List.fromList([]);
    }

    final pdfDocument = PdfDocument(inputBytes: await file.readAsBytes());
    assert(document.pages.length == pdfDocument.pages.count);

    for (int pageNr = 0; pageNr < pdfDocument.pages.count; pageNr++) {
      // 1. Cleanup old overlay - This is saved in a separate layer
      pdfDocument.pages[pageNr].layers.remove(name: "correction");

      // 2. Create new layer for correction inputs
      final layer = pdfDocument.pages[pageNr].layers
          .add(name: "correction", visible: true);

      // 3. Convert correction inputs
      for (int i = 0; i < document.pages[pageNr].inputs.length; ++i) {
        final input = document.pages[pageNr].inputs[i];
        final brush = PdfSolidBrush(PdfColor(input.color.red, input.color.green,
            input.color.blue, input.color.alpha));

        final points = input.points
            .map((e) => e.toAbsolutePoint(size: pdfDocument.pages[pageNr].size))
            .toList();
        // Empty
        if (points.isEmpty) {
          continue;
        }
        // Dot
        else if (points.length < 2) {
          layer.graphics.drawEllipse(
              Rect.fromCircle(
                  center: Offset(points[0].x, points[0].y), radius: 1),
              brush: brush);
        }
        // Path
        else {
          layer.graphics.drawPolygon(
              points.map((e) => Offset(e.x, e.y)).toList(),
              brush: brush);
        }
      }
    }

    final res = Uint8List.fromList(pdfDocument.save());
    pdfDocument.dispose();

    log("Writing out correction to ${file.path}");
    await file.writeAsBytes(res);

    return res;
  }
}
