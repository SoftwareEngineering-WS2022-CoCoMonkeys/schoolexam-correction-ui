import 'dart:developer';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:schoolexam/exams/exams.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

/// This class contains all necessary data for an ongoing correction of a single submission instance
class Correction {
  /// Contains the pdf of the ongoing remark
  /// Importantly, we store the submission pdf as lowest layer
  final String correctionPath;

  final Submission submission;

  final Answer currentAnswer;

  Correction._(
      {required this.correctionPath,
      required this.submission,
      required this.currentAnswer});

  static Future<Correction> start({required Submission submission}) async {
    // TODO : ensure that local changes are not just simply lost
    final directory = (await getApplicationDocumentsDirectory()).path;
    final PdfDocument document = PdfDocument.fromBase64String(submission.data);

    final path =
        p.join(directory, "corrections", submission.exam.id, submission.id);
    log("Trying to start submission with file located at $path");

    final file = await File(path).create(recursive: true);
    await file.writeAsBytes(document.save());

    return Correction._(
        correctionPath: file.path,
        submission: submission,
        currentAnswer: Answer.empty);
  }

  Correction copyWith({Answer? currentAnswer}) {
    return Correction._(
        correctionPath: correctionPath,
        submission: submission,
        currentAnswer: currentAnswer ?? this.currentAnswer);
  }
}
