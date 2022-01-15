import 'package:schoolexam/authentication/authentication_repository.dart';
import 'package:schoolexam/exams/dto/exam_dto.dart';
import 'package:schoolexam/exams/dto/new_exam_dto.dart';
import 'package:schoolexam/exams/dto/submission_details_dto.dart';
import 'package:schoolexam/exams/dto/submission_dto.dart';
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
    var exams = List<Map<String, dynamic>>.from(res);
    return exams.map((e) => ExamDTO.fromJson(e).toModel()).toList();
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
  Future<void> setPoints(
      {required String submissionId,
      required String taskId,
      required double achievedPoints}) async {
    await provider.query(
        path: "/submission/$submissionId/setpoints",
        method: HTTPMethod.POST,
        body: {"taskId": taskId, "achievedPoints": achievedPoints},
        key: await authenticationRepository.getKey());
  }

  @override
  Future<List<SubmissionOverview>> getSubmissions(
      {required String examId}) async {
    final exam = await getExam(examId);

    var res = await provider.query(
        path: "/submission/byexam/$examId",
        method: HTTPMethod.GET,
        key: await authenticationRepository.getKey());

    var submissions = List<Map<String, dynamic>>.from(res);
    return submissions
        .map((e) => SubmissionDTO.fromJson(e).toModel(exam: exam))
        .toList();
  }

  @override
  Future<List<Submission>> getSubmissionDetails(
      {required String examId, required List<String> submissionIds}) async {
    final exam = await getExam(examId);

    // TODO : 16.01
    var res = await provider.query(
        path: "/submission/byidswithdetails",
        method: HTTPMethod.POST,
        body: {"ids": submissionIds},
        key: await authenticationRepository.getKey());

    var submissions = List<Map<String, dynamic>>.from(res);
    return submissions
        .map((e) => SubmissionDetailsDTO.fromJson(e).toModel(exam: exam))
        .toList();
  }
}
