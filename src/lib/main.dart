import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schoolexam/exams/hybrid_exams_repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:schoolexam/schoolexam.dart';
import 'package:schoolexam_correction_ui/blocs/authentication/authentication.dart';
import 'package:schoolexam_correction_ui/blocs/exams/exams.dart';
import 'package:schoolexam_correction_ui/blocs/login/login.dart';
import 'package:schoolexam_correction_ui/blocs/navigation/navigation.dart';
import 'package:schoolexam_correction_ui/blocs/synchronization/synchronization.dart';
import 'package:schoolexam_correction_ui/navigation/school_exam_route_information_parser.dart';
import 'package:schoolexam_correction_ui/navigation/school_exam_router_delegate.dart';
import 'package:schoolexam_correction_ui/repositories/correction_overlay/correction_overlay.dart';
import 'package:schoolexam_correction_ui/repositories/correction_overlay/database_correction_overlay_repository.dart';

import 'blocs/exam_details/exam_details_bloc.dart';
import 'blocs/overlay/correction_overlay.dart';
import 'blocs/remark/remark.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => AuthenticationRepository()),
        RepositoryProvider<ExamsRepository>(
            create: (context) => HybridExamsRepository(
                repository:
                    RepositoryProvider.of<AuthenticationRepository>(context))),
        RepositoryProvider<CorrectionOverlayRepository>(
            create: (context) => DatabaseCorrectionOverlayRepository())
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (context) => AuthenticationBloc(
                  authenticationRepository:
                      RepositoryProvider.of<AuthenticationRepository>(
                          context))),
          BlocProvider(
              create: (context) => LoginBloc(
                  authenticationRepository:
                      RepositoryProvider.of<AuthenticationRepository>(
                          context))),
          BlocProvider(
              create: (context) => NavigationCubit(
                  authenticationBloc:
                      BlocProvider.of<AuthenticationBloc>(context))),
          BlocProvider(
              lazy: false,
              create: (context) => ExamDetailsBloc(
                  examsRepository:
                      RepositoryProvider.of<ExamsRepository>(context))),
          BlocProvider(
              lazy: false,
              create: (context) => ExamsCubit(
                  examsRepository:
                      RepositoryProvider.of<ExamsRepository>(context),
                  authenticationBloc:
                      BlocProvider.of<AuthenticationBloc>(context),
                  examsDetailBloc: BlocProvider.of<ExamDetailsBloc>(context))),
          BlocProvider(
              lazy: false,
              create: (context) => RemarkCubit(
                  navigationCubit: BlocProvider.of<NavigationCubit>(context),
                  examsRepository:
                      RepositoryProvider.of<ExamsRepository>(context))),
          BlocProvider(
              lazy: false,
              create: (context) => CorrectionOverlayCubit(
                  correctionOverlayRepository:
                      RepositoryProvider.of<CorrectionOverlayRepository>(
                          context),
                  remarkCubit: BlocProvider.of<RemarkCubit>(context))),
          BlocProvider(
              lazy: false,
              create: (context) => SynchronizationCubit(
                    examsRepository:
                        RepositoryProvider.of<ExamsRepository>(context),
                    correctionOverlayRepository:
                        RepositoryProvider.of<CorrectionOverlayRepository>(
                            context),
                    correctionOverlayCubit:
                        BlocProvider.of<CorrectionOverlayCubit>(context),
                    remarkCubit: BlocProvider.of<RemarkCubit>(context),
                  ))
        ],
        child: const SchoolExamCorrectionUI(),
      )));
}

class SchoolExamCorrectionUI extends StatelessWidget {
  const SchoolExamCorrectionUI({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return CupertinoApp.router(
        title: "SchoolExam",
        debugShowCheckedModeBanner: false,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('de'),
        theme: const CupertinoThemeData(
            brightness: Brightness.light, primaryColor: Colors.blue),
        routeInformationParser: SchoolExamRouteInformationParser(
            navigationCubit: context.read<NavigationCubit>()),
        routerDelegate: SchoolExamRouterDelegate(
            navigationCubit: context.read<NavigationCubit>()));
  }
}
