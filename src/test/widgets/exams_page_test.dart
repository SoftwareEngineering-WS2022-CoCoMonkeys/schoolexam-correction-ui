import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:schoolexam/exams/exams.dart';
import 'package:schoolexam_correction_ui/blocs/exams/exams.dart';
import 'package:schoolexam_correction_ui/components/exams/exam_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';
import 'package:schoolexam_correction_ui/components/exams/exams_search_view.dart';
import 'package:schoolexam_correction_ui/components/exams/new_exam_card.dart';

class MockExamsCubit extends MockCubit<ExamsState> implements ExamsCubit {}

void main() {
  testWidgets('No exam card with non existent data..',
      (WidgetTester tester) async {
    final cubit = MockExamsCubit();

    /// Fake stream
    when(cubit.loadExams).thenAnswer((_) => Future(() {}));
    whenListen(cubit, Stream<ExamsState>.fromIterable([]),
        initialState: ExamsInitial.empty());

    await tester.pumpWidget(BlocProvider<ExamsCubit>(
      create: (_) => cubit,
      child: Builder(
          builder: (context) => CupertinoApp(
                home: Localizations(
                    delegates: AppLocalizations.localizationsDelegates,
                    locale: const Locale('de'),
                    child: const ExamsSearchView()),
              )),
    ));

    await tester.pump(const Duration(seconds: 5));

    expect(find.byType(ExamCard), findsNothing);
    expect(find.byType(NewExamCard), findsOneWidget);
  });

  testWidgets('Correct card lists.', (WidgetTester tester) async {
    final cubit = MockExamsCubit();

    final exams = [Exam.empty, Exam.empty, Exam.empty, Exam.empty, Exam.empty];
    final filtered = exams.sublist(0, 2);

    final init = ExamsLoadSuccess(
        exams: exams,
        filtered: filtered,
        search: "",
        states: const [ExamStatus.corrected]);

    /// Fake stream
    when(cubit.loadExams).thenAnswer((_) => Future(() {}));
    whenListen(
        cubit,
        Stream<ExamsState>.fromIterable([
          ExamsLoadInProgress(
              search: init.search,
              states: init.states,
              exams: init.exams,
              filtered: init.filtered)
        ]),
        initialState: init);

    await tester.pumpWidget(BlocProvider<ExamsCubit>(
      create: (_) => cubit,
      child: Builder(
          builder: (context) => CupertinoApp(
                home: Localizations(
                    delegates: AppLocalizations.localizationsDelegates,
                    locale: const Locale('de'),
                    child: const ExamsSearchView()),
              )),
    ));

    await tester.pump(const Duration(seconds: 5));

    expect(find.byType(NewExamCard), findsOneWidget);
    expect(find.byType(ExamCard), findsNWidgets(filtered.length));
  });
}
