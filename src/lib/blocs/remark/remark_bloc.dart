import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schoolexam/schoolexam.dart';
import 'package:schoolexam_correction_ui/blocs/navigation/navigation.dart';
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
        super(RemarkState.none()) {
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

  /// Start the correction for the [exam].
  /// This includes the retrieval of the corresponding submissions.
  Future<void> correct(Exam exam) async {
    final submissions = await _examsRepository.getSubmissions(examId: exam.id);

    log("Determined submissions : $submissions");

    var state =
        StartedCorrectionState.start(exam: exam, submissions: submissions);

    emit(state);
  }

  /// Opens the [submission] for correction
  Future<void> open(Submission submission) async {
    log("Requested to correct submission $submission");

    // Switch active pdf
    var newState = AddedCorrectionState.add(
        initial: state, added: await Correction.start(submission: submission));

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

  /// Combines overlay documents with submission documents
  Future<void> merge({required CorrectionOverlayDocument document}) async {
    final remarkState = state;

    final correction = remarkState.corrections.firstWhere(
        (element) => element.submission.id == document.submissionId,
        orElse: () => Correction.empty);

    if (correction.isEmpty) {
      log("There is no ongoing correction present for ${document.submissionId}");
      return;
    }

    log("Merging correction for ${document.submissionId}");
    final file = File(correction.correctionPath);
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
        final points = document.pages[pageNr].inputs[i].points
            .map((e) => e.toAbsolutePoint(size: pdfDocument.pages[pageNr].size))
            .toList();
        // Empty
        if (points.isEmpty) {
          continue;
        }
        // Dot
        else if (points.length < 2) {
          layer.graphics.drawEllipse(Rect.fromCircle(
              center: Offset(points[0].x, points[0].y), radius: 1));
        }
        // Path
        else {
          // TODO : Respect color
          layer.graphics.drawPolygon(
              points.map((e) => Offset(e.x, e.y)).toList(),
              brush: PdfBrushes.black);
        }
      }
    }

    final res = Uint8List.fromList(pdfDocument.save());
    pdfDocument.dispose();

    log("Writing out correction to ${file.path}");
    await file.writeAsBytes(res);
    emit(MergedCorrectionState.merged(
        initial: state,
        merged: correction.copyWith(correctionData: Uint8List.fromList(res))));
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

    emit(UpdatedRemarksState.marked(
        initial: state,
        marked: examSubmission.copyWith(
            answers: List<Answer>.from(examSubmission.answers)
                .map((e) => (e.task.id == answer.task.id)
                    ? answer.copyWith(achievedPoints: achievedPoints)
                    : e)
                .toList())));
  }

  @override
  Future<void> close() async {
    _navigationSubscription.cancel();
    return super.close();
  }
}
