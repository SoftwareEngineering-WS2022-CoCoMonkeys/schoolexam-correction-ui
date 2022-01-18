import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schoolexam_correction_ui/blocs/language/language.dart';
import 'package:schoolexam_correction_ui/blocs/navigation/navigation.dart';
import 'package:schoolexam_correction_ui/navigation/paths/analysis_route_path.dart';
import 'package:schoolexam_correction_ui/navigation/paths/correction_route_path.dart';
import 'package:schoolexam_correction_ui/navigation/paths/exams_route_path.dart';
import 'package:schoolexam_correction_ui/navigation/paths/login_route_path.dart';
import 'package:schoolexam_correction_ui/navigation/paths/route_path.dart';
import 'package:schoolexam_correction_ui/navigation/paths/unknown_route_path.dart';
import 'package:schoolexam_correction_ui/pages/correction_page.dart';
import 'package:schoolexam_correction_ui/pages/exams_page.dart';
import 'package:schoolexam_correction_ui/pages/login_page.dart';

class SchoolExamRouterDelegate extends RouterDelegate<RoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RoutePath> {
  final NavigationCubit _navigationCubit;
  late final StreamSubscription _navigationSubscription;

  @override
  final GlobalKey<NavigatorState> navigatorKey;

  SchoolExamRouterDelegate({required NavigationCubit navigationCubit})
      : _navigationCubit = navigationCubit,
        navigatorKey = GlobalKey<NavigatorState>() {
    _navigationSubscription =
        _navigationCubit.stream.listen(_onAppNavigationStateChanged);
  }

  // TODO : Connect internal app state to router delegate
  void _onAppNavigationStateChanged(AppNavigationState state) {
    notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    final state = _navigationCubit.state;

    // Register current language within the cubit
    BlocProvider.of<LanguageCubit>(context).loadContext(context: context);

    return Navigator(
      key: navigatorKey,
      pages: [
        if (state.requiresAuthentication)
          const CupertinoPage(key: ValueKey("LoginPage"), child: LoginPage())
        else ...[
          if (state.context == AppNavigationContext.exams) ...[
            const CupertinoPage(key: ValueKey("ExamsPage"), child: ExamsPage()),
            if (state.examId.isNotEmpty)
              const CupertinoPage(
                  key: ValueKey("CorrectionPage"), child: CorrectionPage())
          ] else
            ...[]
        ]
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }

        if (_navigationCubit.state.examId.isNotEmpty) {
          _navigationCubit.back();
        }

        return true;
      },
    );
  }

  @override
  RoutePath get currentConfiguration {
    final state = _navigationCubit.state;

    if (state.requiresAuthentication) {
      return LoginRoutePath();
    }

    if (state.context == AppNavigationContext.exams) {
      if (state.examId.isEmpty) {
        return ExamsRoutePath();
      } else {
        return CorrectionRoutePath.start(state.examId);
      }
    } else if (state.context == AppNavigationContext.analysis) {
      // TODO
      return AnalysisRoutePath();
    }

    return UnknownRoutePath();
  }

  @override
  Future<void> setNewRoutePath(RoutePath configuration) async {
    if (configuration is ExamsRoutePath) {
      _navigationCubit.toExams();
    } else if (configuration is CorrectionRoutePath) {
      _navigationCubit.toCorrection(configuration.id);
    } else if (configuration is AnalysisRoutePath) {
      _navigationCubit.toAnalysis();
    } else if (configuration is LoginRoutePath) {
      _navigationCubit.toLogin();
    }
    // TODO : All route paths
  }

  @override
  void dispose() {
    _navigationSubscription.cancel();
    super.dispose();
  }
}
