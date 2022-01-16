import 'dart:convert';

import 'package:schoolexam/authentication/authentication_repository.dart';
import 'package:schoolexam/exams/dto/exam_dto.dart';
import 'package:schoolexam/exams/dto/new_exam_dto.dart';
import 'package:schoolexam/exams/exams.dart';
import 'package:schoolexam/utils/api_provider.dart';

class OnlineExamsRepository extends ExamsRepository {
  final AuthenticationRepository authenticationRepository;
  final ApiProvider provider;

  OnlineExamsRepository({required this.authenticationRepository})
      : provider = ApiProvider();

  @override
  Future<Exam> getExam(String examId) async {
    // TODO : ID based request
    return (await getExams()).firstWhere((element) => element.id == examId,
        orElse: () => Exam.empty);
  }

  @override
  Future<List<Exam>> getExams() async {
    var res = await provider.query(
        path: "/exam/byteacher",
        method: HTTPMethod.GET,
        key: await authenticationRepository.getKey());
    print(res);
    var exams = List<Map<String, dynamic>>.from(res);
    return exams.map((e) => ExamDTO.fromJson(e).toModel()).toList();
  }

  @override
  Future<List<Submission>> getSubmissions({required String examId}) {
    // TODO: implement getSubmissions
    throw UnimplementedError();
  }

  @override
  Future<void> uploadExam({required NewExamDTO exam}) async {
    await provider.query(
        path: "/exam/create",
        method: HTTPMethod.POST,
        body: exam.toJson(),
        key: await authenticationRepository.getKey());
  }

  @override
  Future<void> updateExam(
      {required NewExamDTO exam, required String examId}) async {
    await provider.query(
        path: "/exam/$examId/update",
        method: HTTPMethod.PUT,
        body: exam.toJson(),
        key: await authenticationRepository.getKey());
  }

  @override
  Future<void> setPoints({required String submissionId,
    required String taskId,
    required double achievedPoints}) async {
    await provider.query(
        path: "/submission/$submissionId/setpoints",
        method: HTTPMethod.POST,
        body: {"taskId": taskId, "achievedPoints": achievedPoints},
        key: await authenticationRepository.getKey());
  }

  @override
  Future<void> setGradingTable({required Exam exam}) async {
    await provider.query(
        path: "/Exam/${exam.id}/SetGradingTable",
        method: HTTPMethod.POST,
        body: exam.gradingTable.toDTO(),
        key: await authenticationRepository.getKey());
  }
}
