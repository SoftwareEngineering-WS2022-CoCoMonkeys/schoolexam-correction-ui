import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schoolexam/schoolexam.dart';
import 'package:schoolexam/utils/network_exceptions.dart';
import 'package:schoolexam_correction_ui/blocs/authentication/authentication.dart';
import 'package:schoolexam_correction_ui/blocs/exam_details/exam_details_bloc.dart';
import 'package:schoolexam_correction_ui/blocs/exam_details/exam_details_state.dart';
import 'package:schoolexam_correction_ui/blocs/exams/exams_extensions.dart';
import 'package:schoolexam_correction_ui/blocs/language/language.dart';

import 'exams_state.dart';

class ExamsCubit extends Cubit<ExamsState> {
  late final StreamSubscription _authenticationSubscription;
  late final StreamSubscription _examSubscription;

  final LanguageCubit _languageCubit;

  final ExamsRepository _examsRepository;

  ExamsCubit(
      {required ExamsRepository examsRepository,
      required LanguageCubit languageCubit,
      required AuthenticationBloc authenticationBloc,
      required ExamDetailsCubit examsDetailBloc})
      : _languageCubit = languageCubit,
        _examsRepository = examsRepository,
        super(ExamsInitial.empty()) {
    _examSubscription =
        examsDetailBloc.stream.listen(_onExamDetailsStateChanged);
    _authenticationSubscription =
        authenticationBloc.stream.listen(_onAuthenticationStateChanged);
  }

  void _onExamDetailsStateChanged(ExamDetailsState state) async {
    if (state is ExamDetailsCreationSuccess ||
        state is ExamDetailsUpdateSuccess) {
      await loadExams();
    }
  }

  void _onAuthenticationStateChanged(AuthenticationState state) async {
    switch (state.status) {
      case AuthenticationStatus.authenticated:
        await loadExams();
        break;
      case AuthenticationStatus.unauthenticated:
        emit(ExamsInitial.empty());
        break;
      case AuthenticationStatus.unknown:
        break;
    }
  }

  /// Filters [exams] by using the word [search] and allowed states [states].
  /// In the end, an [ExamsLoadSuccess] is emitted with the filtered data.
  void _filterExams(
      {required List<Exam> exams,
      required String search,
      required List<ExamStatus> states}) {
    final filtered = exams
        .where((element) =>
            element.title.toLowerCase().startsWith(search) &&
            states.contains(element.status))
        .toList(growable: false);

    emit(ExamsLoadSuccess(
        states: states, filtered: filtered, search: search, exams: exams));
  }

  /// Searches for the desired exams.
  /// If [refresh] is required, the online repository is forcefully queried.
  Future<void> _searchExams(
      {String? search, List<ExamStatus>? states, bool? refresh}) async {
    final fSearch = search ?? state.search;
    final fStates = states ?? state.states;

    late final List<Exam> exams;
    if (state.exams.isEmpty || (refresh != null && refresh)) {
      /// Pass old data throug
      final loadState = ExamsLoadInProgress(
          states: fStates,
          search: fSearch,
          exams: state.exams,
          filtered: state.filtered);
      emit(loadState);
      try {
        exams = await _examsRepository.getExams();
        _filterExams(exams: exams, search: fSearch, states: fStates);
      } catch (e) {
        emit(ExamsLoadFailure(
            initial: loadState,
            description:
                'Es ist ein Fehler während dem Laden der Klausuren aufgetreten.'));
      }
    } else {
      exams = state.exams;
      _filterExams(exams: exams, search: fSearch, states: fStates);
    }
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
  Future<void> loadExams() async {
    log("Requested refresh of exams.");
    await _searchExams(refresh: true);
  }

  /// Using publish the user finalizes the correction of the [exam].
  /// When no [publishDate] is supplied, the publishing is instantaneously.
  Future<void> publish({required Exam exam, DateTime? publishDate}) async {
    final publish = state.exams.firstWhere((element) => element.id == exam.id,
        orElse: () => Exam.empty);

    if (publish.isEmpty) {
      log("Found no known exam for ${exam.id}.");
      return;
    }

    if (state is ExamTransitionInProgress) {
      log("Await completion of ongoing transition");
      return;
    }

    // TODO :Start by synchronizing the local submissions with the server
    final tState = ExamTransitionInProgress(
        description: exam.getPublishLoading(_languageCubit),
        transition: ExamTransition.publish,
        exams: state.exams,
        filtered: state.filtered,
        search: state.search,
        states: state.states,
        exam: publish.copyWith());
    emit(tState);

    try {
      await _examsRepository.publishExam(
          examId: publish.id, publishDate: publishDate);
      emit(ExamTransitionSuccess(
          initial: tState,
          description: exam.getPublishSuccess(_languageCubit)));
      log("Publishing was successful for ${exam.title}");
    } on NetworkException catch (e) {
      emit(ExamTransitionFailure(
          initial: tState,
          description: e.getPublishDescription(_languageCubit, publish)));
      log("Publishing failed for ${exam.title}");
    }
  }

  @override
  Future<void> close() async {
    await super.close();
    await _authenticationSubscription.cancel();
    await _examSubscription.cancel();
  }
}
