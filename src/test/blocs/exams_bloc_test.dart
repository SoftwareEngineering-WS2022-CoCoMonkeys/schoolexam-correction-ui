import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:schoolexam/exams/exams.dart';
import 'package:schoolexam_correction_ui/blocs/authentication/authentication.dart';
import 'package:schoolexam_correction_ui/blocs/exam_details/exam_details.dart';
import 'package:schoolexam_correction_ui/blocs/exams/exams.dart';
import 'package:schoolexam_correction_ui/blocs/language/language.dart';
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
