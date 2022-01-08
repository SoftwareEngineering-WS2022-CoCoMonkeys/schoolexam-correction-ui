import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schoolexam/schoolexam.dart';
import 'package:schoolexam_correction_ui/blocs/authentication/authentication.dart';

import 'exams_state.dart';

class ExamsCubit extends Cubit<ExamsState> {
  late final StreamSubscription _authenticationSubscription;

  final ExamsRepository _examsRepository;

  ExamsCubit(
      {required ExamsRepository examsRepository,
      required AuthenticationBloc authenticationBloc})
      : _examsRepository = examsRepository,
        super(ExamsState.empty()) {
    _authenticationSubscription =
        authenticationBloc.stream.listen(_onAuthenticationStateChanged);
  }

  void _onAuthenticationStateChanged(AuthenticationState state) async {
    switch (state.status) {
      case AuthenticationStatus.authenticated:
        await loadExams();
        break;
      case AuthenticationStatus.unauthenticated:
        emit(ExamsState.empty());
        break;
      case AuthenticationStatus.unknown:
        break;
    }
  }

  Future<void> loadExams() async {
    final exams = await _examsRepository.getExams();
    emit(ExamsState.unfiltered(exams: exams));
  }

  Future<void> filterExams(String title, List<ExamStatus> states) async {
    late final List<Exam> exams;
    if (state.exams.isEmpty) {
      exams = await _examsRepository.getExams();
    } else {
      exams = state.exams;
    }

    final filtered = exams
        .where((element) =>
            element.title.startsWith(title) && states.contains(element.status))
        .toList(growable: false);
    // TODO : Improve filter mechanism
    emit(ExamsState.filtered(exams: exams, filtered: filtered));
  }

  @override
  Future<void> close() {
    _authenticationSubscription.cancel();
    return super.close();
  }
}
