import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:schoolexam/authentication/authentication_repository.dart';
import 'package:schoolexam/exams/dto/exam_dto.dart';
import 'package:schoolexam/exams/online_exams_repository.dart';
import 'package:schoolexam/utils/api_provider.dart';
import 'package:uuid/uuid.dart';

import 'online_repository_test.mocks.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io' as io;

Future<String> getBase() async => json.decode(
    await rootBundle.loadString("assets/cfg/api.json"))["Connection"]["Uri"];

@GenerateMocks([http.Client, AuthenticationRepository])
void main() {
  /// Required for global configuration
  TestWidgetsFlutterBinding.ensureInitialized();
  io.HttpOverrides.global = null;

  group('getExams', () {
    test('getExams for valid response', () async {
      final authRepository = MockAuthenticationRepository();
      when(authRepository.getKey()).thenAnswer((_) async => "kek:kek:kek");

      final client = MockClient();
      final provider = ApiProvider(client: client);

      final examsRepository = OnlineExamsRepository(
          authenticationRepository: authRepository, provider: provider);

      /// https://github.com/SoftwareEngineering-WS2022-CoCoMonkeys/schoolexam/blob/main/src/SchoolExam.Web/Models/Exam/ExamReadModelTeacher.cs
      final data = json.encode([
        {
          "id": const Uuid().v4().toString(),
          "status": "planned",
          "title": "Mock Exam 1",
          "date": DateTime.now().toUtc().toIso8601String(),
          "dueDate": DateTime.now().toUtc().toIso8601String(),
          "topic": "Politik",
          "quota": 0.469,
          "gradingTable": {},
          "participants": [],
          "tasks": []
        }
      ]);

      final base = await getBase();
      final path = Uri.https(base, '/exam/byteacher');

      when(client.get(path, headers: captureAnyNamed('headers')))
          .thenAnswer((_) async => http.Response(data, 200));

      final res = await examsRepository.getExams();

      /// Ensure key retrieval from auth repository
      verify(authRepository.getKey()).called(1);

      /// Verify minimal calls
      verify(client.get(any, headers: anyNamed('headers'))).called(1);

      /// validate result
      expect(res.length, 1);
      expect(
          res.map((e) => ExamDTO.fromModel(model: e)).toList(),
          List<Map<String, dynamic>>.from(json.decode(data))
              .map((e) => ExamDTO.fromJson(e))
              .toList());
    });

    test('getExams for invalid valid response', () async {
      final authRepository = MockAuthenticationRepository();
      when(authRepository.getKey()).thenAnswer((_) async => "kek:kek:kek");

      final client = MockClient();
      final provider = ApiProvider(client: client);

      final examsRepository = OnlineExamsRepository(
          authenticationRepository: authRepository, provider: provider);

      const data = '';

      final base = await getBase();
      final path = Uri.https(base, '/exam/byteacher');

      when(client.get(path, headers: captureAnyNamed('headers')))
          .thenAnswer((_) async => http.Response(data, 500));

      expect(() async => await examsRepository.getExams(), throwsException);

      /// Ensure key retrieval from auth repository
      verify(authRepository.getKey()).called(1);
    });
  });

  group('getExam', () {
    test('getExam for valid response', () async {
      final authRepository = MockAuthenticationRepository();
      when(authRepository.getKey()).thenAnswer((_) async => "kek:kek:kek");

      final client = MockClient();
      final provider = ApiProvider(client: client);

      final examsRepository = OnlineExamsRepository(
          authenticationRepository: authRepository, provider: provider);

      /// https://github.com/SoftwareEngineering-WS2022-CoCoMonkeys/schoolexam/blob/main/src/SchoolExam.Web/Models/Exam/ExamReadModelTeacher.cs
      final data = json.encode([
        {
          "id": "e001",
          "status": "planned",
          "title": "Mock Exam 1",
          "date": DateTime.now().toUtc().toIso8601String(),
          "dueDate": DateTime.now().toUtc().toIso8601String(),
          "topic": "Politik",
          "quota": 0.469,
          "gradingTable": {},
          "participants": [
            {"type": "course", "id": "c001", "displayName": "Mathe 1"}
          ],
          "tasks": [
            {"id": "t001", "displayName": "Aufgabe 1", "maxPoints": 0.5},
            {"id": "t002", "displayName": "Aufgabe 2", "maxPoints": 1.5}
          ]
        }
      ]);

      final base = await getBase();
      final path = Uri.https(base, '/exam/byteacher');

      when(client.get(path, headers: captureAnyNamed('headers')))
          .thenAnswer((_) async => http.Response(data, 200));

      final res = await examsRepository.getExam("e001");

      /// Ensure key retrieval from auth repository
      verify(authRepository.getKey()).called(1);

      /// Verify minimal calls
      verify(client.get(any, headers: anyNamed('headers'))).called(1);

      /// validate result
      expect(ExamDTO.fromModel(model: res),
          ExamDTO.fromJson(json.decode(data)[0]));
    });

    test('getExam for invalid valid response', () async {
      final authRepository = MockAuthenticationRepository();
      when(authRepository.getKey()).thenAnswer((_) async => "kek:kek:kek");

      final client = MockClient();
      final provider = ApiProvider(client: client);

      final examsRepository = OnlineExamsRepository(
          authenticationRepository: authRepository, provider: provider);

      const data = '';

      final base = await getBase();
      final path = Uri.https(base, '/exam/byteacher');

      when(client.get(path, headers: captureAnyNamed('headers')))
          .thenAnswer((_) async => http.Response(data, 500));

      expect(
          () async => await examsRepository.getExam("e001"), throwsException);

      /// Ensure key retrieval from auth repository
      verify(authRepository.getKey()).called(1);
    });
  });

  group('getSubmissions', () {
    test('getSubmissions for valid response', () async {
      final authRepository = MockAuthenticationRepository();
      when(authRepository.getKey()).thenAnswer((_) async => "kek:kek:kek");

      final client = MockClient();
      final provider = ApiProvider(client: client);

      final examsRepository = OnlineExamsRepository(
          authenticationRepository: authRepository, provider: provider);

      final submission = json.encode([
        {
          "id": "s001",
          "status": "inprogress",
          "achievedPoints": 25.5,
          "isComplete": true,
          "isMatchedToStudent": true,
          "updatedAt": DateTime.now().toUtc().toIso8601String(),
          "dueDate": DateTime.now().toUtc().toIso8601String(),
          "student": {
            "type": "student",
            "id": "st001",
            "displayName": "Müllermann, Max"
          }
        }
      ]);

      /// https://github.com/SoftwareEngineering-WS2022-CoCoMonkeys/schoolexam/blob/main/src/SchoolExam.Web/Models/Exam/ExamReadModelTeacher.cs
      final exam = json.encode([
        {
          "id": "e001",
          "status": "planned",
          "title": "Mock Exam 1",
          "date": DateTime.now().toUtc().toIso8601String(),
          "dueDate": DateTime.now().toUtc().toIso8601String(),
          "topic": "Politik",
          "quota": 0.469,
          "gradingTable": {},
          "participants": [
            {"type": "course", "id": "c001", "displayName": "Mathe 1"}
          ],
          "tasks": [
            {"id": "t001", "displayName": "Aufgabe 1", "maxPoints": 0.5},
            {"id": "t002", "displayName": "Aufgabe 2", "maxPoints": 1.5}
          ]
        }
      ]);

      final base = await getBase();

      final spath = Uri.https(base, '/submission/byexam/e001');
      when(client.get(spath, headers: captureAnyNamed('headers')))
          .thenAnswer((_) async => http.Response(submission, 200));

      final epath = Uri.https(base, '/exam/byteacher');
      when(client.get(epath, headers: captureAnyNamed('headers')))
          .thenAnswer((_) async => http.Response(exam, 200));

      final res = await examsRepository.getSubmissions(examId: "e001");

      /// Ensure key retrieval from auth repository
      verify(authRepository.getKey()).called(2);

      /// Verify minimal calls
      verify(client.get(spath, headers: anyNamed('headers'))).called(1);
      verify(client.get(epath, headers: anyNamed('headers'))).called(1);

      /// validate result
      expect(res.length, 1);
    });

    test('getSubmissions for invalid valid response', () async {
      final authRepository = MockAuthenticationRepository();
      when(authRepository.getKey()).thenAnswer((_) async => "kek:kek:kek");

      final client = MockClient();
      final provider = ApiProvider(client: client);

      final examsRepository = OnlineExamsRepository(
          authenticationRepository: authRepository, provider: provider);

      /// https://github.com/SoftwareEngineering-WS2022-CoCoMonkeys/schoolexam/blob/main/src/SchoolExam.Web/Models/Exam/ExamReadModelTeacher.cs
      final exam = json.encode([
        {
          "id": "e001",
          "status": "planned",
          "title": "Mock Exam 1",
          "date": DateTime.now().toUtc().toIso8601String(),
          "dueDate": DateTime.now().toUtc().toIso8601String(),
          "topic": "Politik",
          "quota": 0.469,
          "gradingTable": {},
          "participants": [
            {"type": "course", "id": "c001", "displayName": "Mathe 1"}
          ],
          "tasks": [
            {"id": "t001", "displayName": "Aufgabe 1", "maxPoints": 0.5},
            {"id": "t002", "displayName": "Aufgabe 2", "maxPoints": 1.5}
          ]
        }
      ]);

      final base = await getBase();

      final epath = Uri.https(base, '/exam/byteacher');
      when(client.get(epath, headers: captureAnyNamed('headers')))
          .thenAnswer((_) async => http.Response(exam, 200));

      final spath = Uri.https(base, '/submission/byexam/e001');
      when(client.get(spath, headers: captureAnyNamed('headers')))
          .thenAnswer((_) async => http.Response('', 500));

      expect(() async => await examsRepository.getSubmissions(examId: "e001"),
          throwsException);
    });
  });
}
