import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schoolexam/schoolexam.dart';
import 'package:schoolexam_correction_ui/blocs/navigation/navigation.dart';
import 'package:schoolexam_correction_ui/blocs/overlay/correction_overlay_document.dart';
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

  Future<void> correct(Exam exam) async {
    final submissions = await _examsRepository.getSubmissions(examId: exam.id);

    log("Determined submissions : $submissions");

    var state =
        StartedCorrectionState.start(exam: exam, submissions: submissions);

    emit(state);
  }

  Future<void> open(Submission submission) async {
    log("Requested to correct submission $submission");

    // Switch active pdf
    var newState = AddedCorrectionState.add(
        initial: state, added: await Correction.start(submission: submission));

    emit(newState);
  }

  /// Combines overlay documents with submission documents
  Future<void> merge({required CorrectionOverlayDocument document}) async {
    final remarkState = state;

    final correction = remarkState.corrections.firstWhere(
        (element) => element.submissionPath == document.path,
        orElse: () => Correction.empty);

    if (correction.isEmpty) {
      log("There is no ongoing correction present for ${document.path}");
      return;
    }

    log("Merging correction for ${document.path}");
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

  // TODO : THIS IS NOT WORKING
  void moveTo(Task task) {
    log("Requested to move to $task");

    if (state.corrections.isEmpty) {
      log("No corrections currently present.");
      return;
    }

    // TODO : Ensures state change. However, this copy seems rather ugly
    var corrections = <Correction>[...state.corrections];
    corrections[state.selectedCorrection] =
        corrections[state.selectedCorrection].copyWith(
            currentAnswer: corrections[state.selectedCorrection]
                .submission
                .answers
                .firstWhere((element) => element.task.id == task.id,
                    orElse: () => Answer.empty));
  }

  @override
  Future<void> close() async {
    _navigationSubscription.cancel();
    return super.close();
  }
}
