import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
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

    /// Remove any corrections, if still present.
    if (state.examId.isEmpty) {
      // TODO : Provide bulk remnoval state
      var removalState = this.state;
      for (final correction in this.state.corrections) {
        removalState = RemovedCorrectionState.remove(
            initial: removalState, removed: correction);
        emit(removalState);
      }
    } else {
      await correct(await _examsRepository.getExam(state.examId));
    }
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

    final correction = await loadCorrection(submission: submission);

    /// Sort segments by page and y
    for (final answer in correction.submission.answers) {
      answer.segments.sort((s1, s2) => s1.compareTo(s2));
    }

    /// Sort answers by first segment
    correction.submission.answers
        .sort((a1, a2) => a1.segments[0].compareTo(a2.segments[0]));

    /// Sort tasks by answers
    submission.exam.tasks.sort((t1, t2) => correction.submission.answers
        .indexWhere((element) => element.task.id == t1.id)
        .compareTo(correction.submission.answers
            .indexWhere((element) => element.task.id == t2.id)));
    var newState = AddedCorrectionState.add(initial: state, added: correction);

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

    final correction = state.corrections.firstWhere(
        (element) => element.submission.id == submission.id,
        orElse: () => Correction.empty);
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

    final marked = correction.copyWith(
        submission: correction.submission.copyWith(
            answers: List<Answer>.from(correction.submission.answers)
                .map((e) => (e.task.id == answer.task.id)
                    ? answer.copyWith(
                        achievedPoints: achievedPoints,
                        status: CorrectableStatus.corrected)
                    : e)
                .toList()));

    emit(UpdatedRemarksState.marked(initial: state, marked: marked));
  }

  @override
  Future<void> close() async {
    _navigationSubscription.cancel();
    return super.close();
  }
}
