import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schoolexam/authentication/authentication_repository.dart';
import 'package:schoolexam_correction_ui/blocs/authentication/authentication.dart';

import 'navigation_state.dart';

class NavigationCubit extends Cubit<AppNavigationState> {
  late final StreamSubscription _authenticationSubscription;

  NavigationCubit({required AuthenticationBloc authenticationBloc})
      : super(const AppNavigationState.initial()) {
    _authenticationSubscription =
        authenticationBloc.stream.listen(_onAuthenticationStateChanged);
  }

  void _onAuthenticationStateChanged(AuthenticationState state) async {
    emit(this.state.copyWith(
        requiresAuthentication:
            state.status != AuthenticationStatus.authenticated));
  }

  // The following functions are used for navigation
  void toExams() => emit(state.copyWith(context: AppNavigationContext.exams));

  void toAnalysis() =>
      emit(state.copyWith(context: AppNavigationContext.analysis));

  void toCorrection(String examId) =>
      emit(state.copyWith(context: AppNavigationContext.exams, examId: examId));

  void toLogin() => emit(state.copyWith(requiresAuthentication: true));

  @override
  Future<void> close() {
    _authenticationSubscription.cancel();
    return super.close();
  }
}
