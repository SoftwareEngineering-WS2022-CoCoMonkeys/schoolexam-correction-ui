import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:schoolexam/exams/models/grading_table.dart';
import 'package:schoolexam/exams/models/grading_table_lower_bound.dart';
import 'package:schoolexam/schoolexam.dart';
import 'package:schoolexam_correction_ui/blocs/navigation/navigation.dart';
import 'package:schoolexam_correction_ui/blocs/remark/remark.dart';
import 'package:schoolexam_correction_ui/repositories/correction_overlay/correction_overlay.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'correction.dart';
import 'remark_state.dart';

/// This cubit is responsible for managing the currently active corrections.
/// It therefore has to provide knowledge about the underlying submissions and corresponding students.
class RemarkCubit extends Cubit<RemarkState> {
  late final StreamSubscription _navigationSubscription;
  final ExamsRepository _examsRepository;

  RemarkCubit(
      {required ExamsRepository examsRepository,
      required NavigationCubit navigationCubit})
      : _examsRepository = examsRepository,
        super(LoadedRemarksState.none()) {
    _navigationSubscription = navigationCubit.stream.listen(_onNavigationState);
  }

  void _onNavigationState(AppNavigationState state) async {
    log("Observed navigation switch : $state");
    if (state.context != AppNavigationContext.exams) {
      return;
    }
    if (state.examId.isEmpty) {
      return;
    }

    await correct(await _examsRepository.getExam(state.examId));
  }

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

  /// Merges the current correction pdf [current] using the data currently stored for the submission [submissionId].
  /// The result are the bytes of the merged pdf file.
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

  /// Start the correction for the [exam].
  /// This includes the retrieval of the corresponding submissions.
  Future<void> correct(Exam exam) async {
    emit(LoadingRemarksState.loading(old: state));

    final submissions = await _examsRepository.getSubmissionDetails(
        examId: exam.id,
        submissionIds: (await _examsRepository.getSubmissions(examId: exam.id))
            .map((e) => e.id)
            .toList());

    log("Determined submissions : $submissions");

    emit(StartedCorrectionState.start(exam: exam, submissions: submissions));
  }

  /// Opens the [submission] for correction
  Future<void> open(Submission submission) async {
    log("Requested to correct submission $submission");

    // Switch active pdf
    var newState = AddedCorrectionState.add(
        initial: state, added: await loadCorrection(submission: submission));

    emit(newState);
  }

  /// Closes the [submission].
  Future<void> stop(Submission submission) async {
    log("Requested to close submission $submission");

    final correction = state.corrections.firstWhere(
        (element) => element.submission.id == submission.id,
        orElse: () => Correction.empty);

    // Switch active pdf
    var newState =
        RemovedCorrectionState.remove(initial: state, removed: correction);

    emit(newState);
  }

  /// Changes the active correction to match the desired [submission].
  Future<void> changeTo({required Submission submission}) async {
    log("Requested to change to $submission");

    if (state.corrections.isEmpty) {
      log("No corrections currently present.");
      return;
    }

    final selection = state.corrections
        .indexWhere((element) => element.submission.id == submission.id, -1);
    if (selection < 0) {
      log("Found no correction for ${submission.id}");
      return;
    }

    emit(SwitchedCorrectionState.change(
        initial: state, selectedCorrection: selection));
  }

  /// Moves the currently selected correction to the desired [task].
  void moveTo({required Task task}) {
    log("Requested to move to $task");

    if (state.corrections.isEmpty) {
      log("No corrections currently present.");
      return;
    }

    final correction = state.corrections[state.selectedCorrection].copyWith(
        currentAnswer: state
            .corrections[state.selectedCorrection].submission.answers
            .firstWhere((element) => element.task.id == task.id,
                orElse: () => Answer.empty));

    emit(NavigatedRemarkState.navigated(initial: state, navigated: correction));
  }

  /// Marks the [task] with [points].
  Future<void> mark(
      {required Submission submission,
      required Task task,
      required double achievedPoints}) async {
    log("Requested to set $task to $achievedPoints for ${submission.student.displayName}");

    final examSubmission = state.submissions.firstWhere(
        (element) => element.id == submission.id,
        orElse: () => Submission.empty);
    final answer = submission.answers.firstWhere(
        (element) => element.task.id == task.id,
        orElse: () => Answer.empty);

    if (answer.isEmpty) {
      log("Found no matching task or answer in exam.");
      return;
    }

    await _examsRepository.setPoints(
        submissionId: submission.id,
        taskId: answer.task.id,
        achievedPoints: achievedPoints);

    // TODO : Not working
    emit(UpdatedRemarksState.marked(
        initial: state,
        marked: examSubmission.copyWith(
            answers: List<Answer>.from(examSubmission.answers)
                .map((e) => (e.task.id == answer.task.id)
                    ? answer.copyWith(achievedPoints: achievedPoints)
                    : e)
                .toList())));
  }

  /// Create an empty grading table
  void initGradingTable() {
    emit(GradingTabledUpdatedState.updated(
        initial: state, gradingTable: state.exam.gradingTable));
  }

  /// Add a new lower bound to the existing grading table
  void addGradingTableBound() {
    final copy = state.exam.gradingTable.valueCopy();
    // Insert empty grading table bound
    copy.lowerBounds.add(GradingTableLowerBound.empty);
    emit(GradingTabledUpdatedState.updated(initial: state, gradingTable: copy));
  }

  /// Change the points on a lower bound in the existing grading table
  void changeGradingTableBoundPoints(int i, double points) {
    final copy = state.exam.gradingTable.valueCopy();

    final adjustedLowerBound = copy.lowerBounds[i].copyWith(points: points);
    // remove old bound
    copy.lowerBounds.removeAt(i);

    final maxPoints = state.exam.tasks.fold<double>(0.0, (p, c) => p + c.maxPoints);
    points = math.min(points, maxPoints);

    // insert updated bound at same index
    copy.lowerBounds.insert(i, adjustedLowerBound);

    // Ensure lower bound constraint
    for (int j = 0; j < copy.lowerBounds.length; j++) {
      final lb = state.exam.gradingTable.lowerBounds[j];
      if (j < i && lb.points < points || j > i && lb.points > points) {
        log("Adjusting lower bound in grading table");

        final nextLb = lb.copyWith(points: points);
        // remove old bound
        copy.lowerBounds.removeAt(j);

        // insert updated bound at same index
        copy.lowerBounds.insert(j, nextLb);
      }
    }
    emit(GradingTabledUpdatedState.updated(initial: state, gradingTable: copy));
  }

  /// Change the grade descriptor on a lower bound in the existing grading table
  void changeGradingTableBoundGrade(int i, String grade) {
    final copy = state.exam.gradingTable.valueCopy();
    final adjustedLowerBound = copy.lowerBounds[i].copyWith(grade: grade);
    // remove old bound
    copy.lowerBounds.removeAt(i);

    // insert updated bound at same index
    copy.lowerBounds.insert(i, adjustedLowerBound);
    emit(GradingTabledUpdatedState.updated(initial: state, gradingTable: copy));
  }

  /// Change the grading table to the default layout
  /// The two standard german grading schemes are available as presets
  void getDefaultGradingTable(int low, int high) {
    List<String> grades = [];
    List<double> points = [];
    if (low == 1 && high == 6) {
      grades = [
        "sehr gut",
        "gut",
        "befriedigend",
        "ausreichend",
        "mangelhaft",
        "ungenügend"
      ];
      points = [
        0.85,
        0.70,
        0.55,
        0.4,
        0.20,
        0.0
      ];
    } else if (low == 0 && high == 15) {
      grades = [
        "sehr gut (1+)",
        "sehr gut (1)",
        "sehr gut (1-)",
        "gut (2+)",
        "gut (2)",
        "gut (2-)",
        "befriedigend (3+)",
        "befriedigend (3)",
        "befriedigend (3-)",
        "ausreichend (4+)",
        "ausreichend (4)",
        "ausreichend (4-)",
        "mangelhaft (5+)",
        "mangelhaft (5)",
        "mangelhaft (5-)",
        "ungenügend (6)"
      ];
      points = [
        0.95,
        0.90,
        0.85,
        0.80,
        0.75,
        0.70,
        0.65,
        0.60,
        0.55,
        0.50,
        0.45,
        0.39,
        0.33,
        0.27,
        0.20,
        0.0
      ];
    }
    final maxPoints =
        state.exam.tasks.fold<double>(0.0, (p, c) => p + c.maxPoints);
    final lowerBounds = grades.mapIndexed((i, grade) {
      return GradingTableLowerBound(
          // round down to nearest half point
          points: (2 * (points[i] * maxPoints).floor().toDouble()) / 2,
          grade: grade);
    }).toList();

    emit(GradingTabledUpdatedState.updated(
        initial: state, gradingTable: GradingTable(lowerBounds: lowerBounds)));
  }

  /// Delete a grading table interval
  void deleteGradingTableBound(int index) {
    final copy = state.exam.gradingTable.valueCopy();
    copy.lowerBounds.removeAt(index);
    emit(GradingTabledUpdatedState.updated(initial: state, gradingTable: copy));
  }

  /// Save grading table
  Future<void> saveGradingTable() async {
    _examsRepository.setGradingTable(exam: state.exam);
  }

  @override
  Future<void> close() async {
    _navigationSubscription.cancel();
    return super.close();
  }
}
