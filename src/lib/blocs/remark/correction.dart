import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:schoolexam/exams/exams.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:tuple/tuple.dart';

/// This class contains all necessary data for an ongoing correction of a single submission instance
class Correction extends Equatable {
  /// The initial submission without any correction remarks
  final String submissionPath;
  final Uint8List submissionData;

  /// Contains the pdf of the ongoing remark
  /// Importantly, we store the submission pdf as lowest layer
  final String correctionPath;
  final Uint8List correctionData;

  /// Contains possible meta data about the submission, like the corresponding student.
  final Submission submission;

  /// Contains meta data about the answers within the submission. This allows for task specific UI navigation.
  final Answer currentAnswer;

  const Correction(
      {required this.submissionData,
      required this.submissionPath,
      required this.correctionPath,
      required this.correctionData,
      required this.submission,
      required this.currentAnswer});

  Correction copyWith(
      {Answer? currentAnswer,
      Uint8List? submissionData,
      Uint8List? correctionData}) {
    return Correction(
        correctionData: correctionData ?? this.correctionData,
        correctionPath: correctionPath,
        submissionData: submissionData ?? this.submissionData,
        submissionPath: submissionPath,
        submission: submission,
        currentAnswer: currentAnswer ?? this.currentAnswer);
  }

  static final empty = Correction(
      submissionPath: "",
      submissionData: Uint8List.fromList([]),
      correctionPath: "",
      correctionData: Uint8List.fromList([]),
      submission: Submission.empty,
      currentAnswer: Answer.empty);

  bool get isEmpty => this == Correction.empty;

  bool get isNotEmpty => this != Correction.empty;

  @override
  // TODO: implement props
  List<Object?> get props => [
        submissionPath,
        submissionData,
        correctionPath,
        correctionData,
        submission,
        currentAnswer
      ];
}
