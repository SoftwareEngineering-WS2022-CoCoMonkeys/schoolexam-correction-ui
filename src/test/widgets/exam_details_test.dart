import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:intl/intl.dart';
import 'package:schoolexam/exams/models/course.dart';
import 'package:schoolexam_correction_ui/blocs/exam_details/exam_details.dart';
import 'package:schoolexam_correction_ui/blocs/exam_details/exam_details_form_input.dart';
import 'package:schoolexam_correction_ui/components/exams/exam_details_dialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockExamDetailsCubit extends MockCubit<ExamDetailsState>
    implements ExamDetailsCubit {}

void main() {
  testWidgets('Valid Update', (WidgetTester tester) async {
    final examDetailsCubit = MockExamDetailsCubit();

    /// Fake stream
    final date = DateTime.now();
    const courses = [
      Course(displayName: "Test 1", id: "c01", children: []),
      Course(displayName: "Test 2", id: "c02", children: [])
    ];

    whenListen(
      examDetailsCubit,
      Stream<ExamDetailsState>.fromIterable([]),
      initialState: ExamDetailsCreationInProgress(
          status: FormzStatus.pure,
          examTitle: const ExamTitle.dirty(value: "Meine Klausur"),
          examTopic: const ExamTopic.dirty(value: "Mein Bereich"),
          examCourse: ExamCourse.dirty(value: courses[0]),
          examDate: ExamDate.dirty(date),
          validCourses: courses),
    );

    await tester.pumpWidget(BlocProvider<ExamDetailsCubit>(
      lazy: false,
      create: (_) => examDetailsCubit,
      child: Builder(
          builder: (context) => CupertinoApp(
                home: Localizations(
                    delegates: AppLocalizations.localizationsDelegates,
                    locale: const Locale('de'),
                    child: const ExamDetailsDialog()),
              )),
    ));

    /// Alle notwendigen Informationen werden in irgendeiner Art und Weise dargestellt.
    expect(find.text("Meine Klausur"), findsWidgets);
    expect(find.text("Mein Bereich"), findsWidgets);
    expect(find.text("Test 1"), findsWidgets);
    expect(find.text(DateFormat("dd.MM.yyyy").format(date)), findsWidgets);
  });
}
