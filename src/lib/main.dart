import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schoolexam/schoolexam.dart';
import 'package:schoolexam_correction_ui/blocs/authentication/authentication.dart';
import 'package:schoolexam_correction_ui/blocs/login/login.dart';
import 'package:schoolexam_correction_ui/blocs/navigation/navigation.dart';
import 'package:schoolexam_correction_ui/navigation/school_exam_route_information_parser.dart';
import 'package:schoolexam_correction_ui/navigation/school_exam_router_delegate.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // cfg. await GlobalConfiguration().loadFromAsset("api");
  runApp(MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => AuthenticationRepository()),
        RepositoryProvider(create: (context) => const UserRepository())
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (context) => AuthenticationBloc(
                  authenticationRepository:
                      context.read<AuthenticationRepository>(),
                  userRepository: context.read<UserRepository>())),
          BlocProvider(
              create: (context) => LoginBloc(
                  authenticationRepository:
                      context.read<AuthenticationRepository>())),
          BlocProvider(
              create: (context) => NavigationCubit(
                  authenticationBloc: context.read<AuthenticationBloc>()))
        ],
        child: const SchoolExamCorrectionUI(),
      )));
}

class SchoolExamCorrectionUI extends StatelessWidget {
  const SchoolExamCorrectionUI({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
        title: "SchoolExam",
        routeInformationParser: SchoolExamRouteInformationParser(
            navigationCubit: context.read<NavigationCubit>()),
        routerDelegate: SchoolExamRouterDelegate(
            navigationCubit: context.read<NavigationCubit>()));
  }
}
