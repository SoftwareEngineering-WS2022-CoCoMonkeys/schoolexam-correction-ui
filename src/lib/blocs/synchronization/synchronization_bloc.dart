import 'dart:async';
import 'dart:convert';

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

  /// TODO : This needs to have proper logic for failures etc.
  /// TODO : Additionally, the synchronization logic should run in a separate process, with these events only adding data to a queue.
  void _onRemarkStateChanged(RemarkState state) async {
    if (state is RemovedCorrectionState) {
      emit(this.state.copyWith(remarkStatus: PushStatus.ongoing));
      final document = await _correctionOverlayRepository.getDocument(
          submissionId: state.removed.submission.id);
      final res = await _remarkCubit.merge(
          correction: state.removed, document: document);
      await _examsRepository.uploadRemark(
          submissionId: state.removed.submission.id, data: base64.encode(res));
      emit(this.state.copyWith(remarkStatus: PushStatus.succeeded));
    }
  }

  /// TODO : Use the versioning to only save when necessary... This is just a very basic implementation
  void _onCorrectionChanged(CorrectionOverlayState state) async {
    if (state is UpdatedNavigationState) {
      await _correctionOverlayRepository.saveDocument(
          document: state.overlays[state.documentNumber]);
    }
  }

  @override
  Future<void> close() async {
    super.close();
    await _remarkSubscription.cancel();
    await _correctionSubscription.cancel();
  }
}
