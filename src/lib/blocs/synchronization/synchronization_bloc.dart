import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schoolexam/exams/exams.dart';
import 'package:schoolexam_correction_ui/blocs/overlay/correction_overlay.dart';
import 'package:schoolexam_correction_ui/blocs/remark/remark.dart';
import 'package:schoolexam_correction_ui/blocs/synchronization/synchronization_state.dart';
import 'package:schoolexam_correction_ui/repositories/correction_overlay/correction_overlay.dart';

class SynchronizationCubit extends Cubit<SynchronizationState> {
  final CorrectionOverlayCubit _correctionOverlayCubit;
  final RemarkCubit _remarkCubit;
  final CorrectionOverlayRepository _correctionOverlayRepository;
  final ExamsRepository _examsRepository;

  late final StreamSubscription _remarkSubscription;
  late final StreamSubscription _correctionSubscription;

  SynchronizationCubit(
      {required CorrectionOverlayRepository correctionOverlayRepository,
      required ExamsRepository examsRepository,
      required RemarkCubit remarkCubit,
      required CorrectionOverlayCubit correctionOverlayCubit})
      : _remarkCubit = remarkCubit,
        _correctionOverlayCubit = correctionOverlayCubit,
        _correctionOverlayRepository = correctionOverlayRepository,
        _examsRepository = examsRepository,
        super(const InitSynchronizationState()) {
    _remarkSubscription = _remarkCubit.stream.listen(_onRemarkStateChanged);
    _correctionSubscription =
        _correctionOverlayCubit.stream.listen(_onCorrectionChanged);
  }

  void _onRemarkStateChanged(RemarksState state) async {
    // -- Answers...
  }

  /// TODO : This needs to have proper logic for failures etc.
  /// TODO : Additionally, the synchronization logic should run in a separate process, with these events only adding data to a queue.
  /// TODO : Use the versioning to only save when necessary... This is just a very basic implementation
  void _onCorrectionChanged(CorrectionOverlayState state) async {
    if (state is UpdatedNavigationState) {
      log("Saving document ${state.documentNumber} out of ${state.overlays.length} total due to page swap.");
      await _correctionOverlayRepository.saveDocument(
          document: state.overlays[state.documentNumber]);
    } else if (state is RemovedCorrectionOverlayState) {
      final document = state.removed;
      log("Saving document ${document.submissionId} due to removal.");
      await _correctionOverlayRepository.saveDocument(document: document);

      // Merge & Upload
      emit(this.state.copyWith(remarkStatus: PushStatus.ongoing));
      final res = await _remarkCubit.merge(document: document);
      await _examsRepository.uploadRemark(
          submissionId: state.removed.submissionId, data: base64.encode(res));
      emit(this.state.copyWith(remarkStatus: PushStatus.succeeded));
    }
  }

  @override
  Future<void> close() async {
    await super.close();
    await _remarkSubscription.cancel();
    await _correctionSubscription.cancel();
  }
}
