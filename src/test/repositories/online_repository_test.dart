import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:schoolexam/authentication/authentication_repository.dart';
import 'package:schoolexam/configuration.dart';
import 'package:schoolexam/exams/dto/exam_dto.dart';
import 'package:schoolexam/exams/exams.dart';
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
    final authRepository = MockAuthenticationRepository();
    when(authRepository.getKey()).thenAnswer((_) async => "kek:kek:kek");

    test('getExams for valid response', () async {
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
    });
  });
}
