import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:schoolexam/exams/exams.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

/// This class contains all necessary data for an ongoing correction of a single submission instance
class Correction {
  /// Contains the pdf of the ongoing remark
  /// Importantly, we store the submission pdf as lowest layer
  final Uint8List correction;
  final String correctionPath;

  final Submission submission;

  final Answer currentAnswer;

  Correction._(
      {required this.correction,
      required this.correctionPath,
      required this.submission,
      required this.currentAnswer});

  static Future<Correction> start({required Submission submission}) async {
    final directory = (await getApplicationDocumentsDirectory()).path;
    final PdfDocument document = PdfDocument.fromBase64String(submission.data);

    final path =
        p.join(directory, "corrections", submission.exam.id, submission.id);
    log("Trying to start submission with file located at $path");

    // TODO : ensure that local changes are not just simply lost
    // TODO : this is going to be achieved by including a utc timestamp into the correction retrieved from the server
    final res = document.save();
    final file = await File(path).create(recursive: true);
    await file.writeAsBytes(res);

    return Correction._(
        correction: Uint8List.fromList(res),
        correctionPath: path,
        submission: submission,
        currentAnswer: Answer.empty);
  }

  Correction copyWith({Answer? currentAnswer, Uint8List? correction}) {
    return Correction._(
        correction: correction ?? this.correction,
        correctionPath: correctionPath,
        submission: submission,
        currentAnswer: currentAnswer ?? this.currentAnswer);
  }
}
