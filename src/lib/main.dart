import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schoolexam/exams/local_exams_repository.dart';
import 'package:schoolexam/schoolexam.dart';
import 'package:schoolexam_correction_ui/blocs/authentication/authentication.dart';
import 'package:schoolexam_correction_ui/blocs/exams/exams.dart';
import 'package:schoolexam_correction_ui/blocs/login/login.dart';
import 'package:schoolexam_correction_ui/blocs/navigation/navigation.dart';
import 'package:schoolexam_correction_ui/navigation/school_exam_route_information_parser.dart';
import 'package:schoolexam_correction_ui/navigation/school_exam_router_delegate.dart';

import 'blocs/overlay/correction_overlay.dart';
import 'blocs/remark/remark.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // cfg. await GlobalConfiguration().loadFromAsset("api");
  runApp(MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => AuthenticationRepository()),
        RepositoryProvider(create: (context) => const UserRepository()),
        RepositoryProvider<ExamsRepository>(
            create: (context) => LocalExamsRepository())
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (context) => AuthenticationBloc(
                  authenticationRepository:
                      RepositoryProvider.of<AuthenticationRepository>(context),
                  userRepository:
                      RepositoryProvider.of<UserRepository>(context))),
          BlocProvider(
              create: (context) => LoginBloc(
                  authenticationRepository:
                      RepositoryProvider.of<AuthenticationRepository>(
                          context))),
          BlocProvider(
              lazy: false,
              create: (context) => ExamsCubit(
                  examsRepository:
                      RepositoryProvider.of<ExamsRepository>(context),
                  authenticationBloc:
                      BlocProvider.of<AuthenticationBloc>(context))),
          BlocProvider(
              create: (context) => NavigationCubit(
                  authenticationBloc:
                      BlocProvider.of<AuthenticationBloc>(context))),
          BlocProvider(
              lazy: false,
              create: (context) => RemarkCubit(
                  navigationCubit: BlocProvider.of<NavigationCubit>(context),
                  examsRepository:
                      RepositoryProvider.of<ExamsRepository>(context))),
          BlocProvider(
              lazy: false,
              create: (context) => CorrectionOverlayCubit(
                  remarkCubit: BlocProvider.of<RemarkCubit>(context)))
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
        debugShowCheckedModeBanner: false,
        theme:
            ThemeData(brightness: Brightness.light, primaryColor: Colors.blue),
        routeInformationParser: SchoolExamRouteInformationParser(
            navigationCubit: context.read<NavigationCubit>()),
        routerDelegate: SchoolExamRouterDelegate(
            navigationCubit: context.read<NavigationCubit>()));
  }
}
