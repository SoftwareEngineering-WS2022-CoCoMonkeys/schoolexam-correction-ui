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
  final String correctionPath;
  final Uint8List correction;
  final int pageNumber;

  /// Contains possible meta data about the submission, like the corresponding student.
  final Submission submission;

  /// Contains meta data about the answers within the submission. This allows for task specific UI navigation.
  final Answer currentAnswer;

  Correction._(
      {required this.correction,
      required this.correctionPath,
      required this.submission,
      required this.currentAnswer,
      this.pageNumber = 0});

  static Future<Correction> start({required Submission submission}) async {
    final directory = (await getApplicationDocumentsDirectory()).path;
    final path =
        p.join(directory, "corrections", submission.exam.id, submission.id);
    final file = File(path);

    late final Uint8List res;
    if (await file.exists()) {
      log("Trying to start submission with file located at $path");
      final document = PdfDocument(inputBytes: await file.readAsBytes());
      res = Uint8List.fromList(document.save());
    } else {
      log("Writing file to $path");
      final document = PdfDocument.fromBase64String(submission.data);
      res = Uint8List.fromList(document.save());

      await file.create(recursive: true);
      await file.writeAsBytes(res);
    }

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
