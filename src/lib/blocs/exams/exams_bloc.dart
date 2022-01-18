import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:schoolexam/schoolexam.dart';
import 'package:schoolexam_correction_ui/blocs/authentication/authentication.dart';
import 'package:schoolexam_correction_ui/blocs/exam_details/exam_details_bloc.dart';
import 'package:schoolexam_correction_ui/blocs/exam_details/exam_details_state.dart';

import 'exams_state.dart';

class ExamsCubit extends Cubit<ExamsState> {
  late final StreamSubscription _authenticationSubscription;
  late final StreamSubscription _examSubscription;

  final ExamsRepository _examsRepository;

  ExamsCubit(
      {required ExamsRepository examsRepository,
      required AuthenticationBloc authenticationBloc,
      required ExamDetailsCubit examsDetailBloc})
      : _examsRepository = examsRepository,
        super(LoadedExamsState.initial()) {
    _examSubscription =
        examsDetailBloc.stream.listen(_onExamDetailsStateChanged);
    _authenticationSubscription =
        authenticationBloc.stream.listen(_onAuthenticationStateChanged);
  }

  void _onExamDetailsStateChanged(ExamDetailsState state) async {
    switch (state.status) {
      case FormzStatus.submissionSuccess:
        await loadExams();
        break;
      default:
        return;
    }
  }

  void _onAuthenticationStateChanged(AuthenticationState state) async {
    switch (state.status) {
      case AuthenticationStatus.authenticated:
        await loadExams();
        break;
      case AuthenticationStatus.unauthenticated:
        emit(LoadedExamsState.initial());
        break;
      case AuthenticationStatus.unknown:
        break;
    }
  }

  Future<void> _searchExams(
      {String? search, List<ExamStatus>? states, bool? refresh}) async {
    final fSearch = search ?? state.search;
    final fStates = states ?? state.states;

    late final List<Exam> exams;
    if (state.exams.isEmpty || (refresh != null && refresh)) {
      emit(LoadingExamsState.loading(
          old: state, search: fSearch, states: fStates));
      exams = await _examsRepository.getExams();
    } else {
      exams = state.exams;
    }

    final filtered = exams
        .where((element) =>
            element.title.toLowerCase().startsWith(fSearch) &&
            fStates.contains(element.status))
        .toList(growable: false);
    emit(LoadedExamsState.loaded(
        exams: exams, filtered: filtered, search: fSearch, states: fStates));
  }

  /// The user changed the search word to [search].
  Future<void> onSearchChanged(String search) async =>
      await _searchExams(search: search);

  /// The user changed the status [status] to be either desired or undesired.
  Future<void> onStatusChanged(
      {required ExamStatus status, required bool added}) async {
    final states = Set<ExamStatus>.from(state.states);
    if (added) {
      states.add(status);
    } else {
      states.removeWhere((element) => element.name == status.name);
    }

    await _searchExams(states: states.toList());
  }

  /// The user requested a reload of the exams using the current search parameters.
  Future<void> loadExams() async => _searchExams(refresh: true);

  @override
  Future<void> close() async {
    await super.close();
    await _authenticationSubscription.cancel();
    await _examSubscription.cancel();
  }
}
