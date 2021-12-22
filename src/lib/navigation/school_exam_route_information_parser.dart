import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:schoolexam_correction_ui/blocs/navigation/navigation.dart';
import 'package:schoolexam_correction_ui/navigation/paths/analysis_route_path.dart';
import 'package:schoolexam_correction_ui/navigation/paths/correction_route_path.dart';
import 'package:schoolexam_correction_ui/navigation/paths/exams_route_path.dart';
import 'package:schoolexam_correction_ui/navigation/paths/login_route_path.dart';
import 'package:schoolexam_correction_ui/navigation/paths/route_path.dart';
import 'package:schoolexam_correction_ui/navigation/paths/unknown_route_path.dart';

class SchoolExamRouteInformationParser
    extends RouteInformationParser<RoutePath> {
  final NavigationCubit _navigationCubit;

  SchoolExamRouteInformationParser({required NavigationCubit navigationCubit})
      : _navigationCubit = navigationCubit;

  @override

  /// Converts a URI to the corresponding internal navigation destination
  Future<RoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    var uri = Uri.parse(routeInformation.location!);

    if (_navigationCubit.state.requiresAuthentication) {
      return LoginRoutePath();
    }

    /// The user supplied a "/" -> Show home screen
    if (uri.pathSegments.isEmpty) {
      return ExamsRoutePath();
    }

    /// The user supplied a "/<parent>/" -> Show parent screen
    if (uri.pathSegments.length == 1) {
      /// "/analysis"
      if (uri.pathSegments[0] == 'analysis') {
        return AnalysisRoutePath();
      }

      /// "/exams"
      if (uri.pathSegments[0] == 'exams') {
        return ExamsRoutePath();
      }
    }

    /// The user supplied a "/<parent>/<child>"
    if (uri.pathSegments.length == 2) {
      /// "/correct/<id>"
      if (uri.pathSegments[0] == 'correct') {
        return CorrectionRoutePath.start(uri.pathSegments[1]);
      }
    }

    return UnknownRoutePath();
  }
}
