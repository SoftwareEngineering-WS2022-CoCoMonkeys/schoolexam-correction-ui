import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:intl/intl.dart';
import 'package:schoolexam/exams/exams.dart';
import 'package:schoolexam/exams/models/course.dart';
import 'package:schoolexam/exams/online_exams_repository.dart';
import 'package:schoolexam_correction_ui/blocs/authentication/authentication.dart';
import 'package:schoolexam_correction_ui/blocs/exam_details/exam_details.dart';
import 'package:schoolexam_correction_ui/blocs/exam_details/exam_details_form_input.dart';
import 'package:schoolexam_correction_ui/blocs/exams/exams.dart';
import 'package:schoolexam_correction_ui/blocs/language/language.dart';
import 'package:schoolexam_correction_ui/components/exams/exam_details_dialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthenticationBloc
    extends MockBloc<AuthenticationEvent, AuthenticationState>
    implements AuthenticationBloc {}

class MockExamDetailsCubit extends MockCubit<ExamDetailsState>
    implements ExamDetailsCubit {}

class MockExamsRepository extends Mock implements ExamsRepository {}

class MockLanguageCubit extends Mock implements LanguageCubit {}

void main() {
  group('ExamsBloc', () {
    blocTest('emits [], when nothing is input.',
        build: () {
          final authBloc = MockAuthenticationBloc();
          whenListen(authBloc,
              Stream.fromIterable([const AuthenticationState.unknown()]));

          final examsCubit = MockExamDetailsCubit();
          whenListen(
              examsCubit, Stream.fromIterable([ExamDetailsInitial.empty()]));

          final examsRepo = MockExamsRepository();

          return ExamsCubit(
              authenticationBloc: authBloc,
              examsDetailBloc: examsCubit,
              examsRepository: examsRepo,
              languageCubit: MockLanguageCubit());
        },
        expect: () => []);
  });
}
