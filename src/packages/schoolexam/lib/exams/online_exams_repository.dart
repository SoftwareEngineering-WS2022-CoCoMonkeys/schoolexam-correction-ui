import 'package:schoolexam/authentication/authentication_repository.dart';
import 'package:schoolexam/exams/dto/exam_dto.dart';
import 'package:schoolexam/exams/dto/grading_table_dto.dart';
import 'package:schoolexam/exams/dto/new_exam_dto.dart';
import 'package:schoolexam/exams/dto/participant_dto.dart';
import 'package:schoolexam/exams/dto/submission_details_dto.dart';
import 'package:schoolexam/exams/dto/submission_dto.dart';
import 'package:schoolexam/exams/exams.dart';
import 'package:schoolexam/utils/api_provider.dart';

class OnlineExamsRepository extends ExamsRepository {
  final AuthenticationRepository authenticationRepository;
  final ApiProvider provider;

  OnlineExamsRepository(
      {required this.authenticationRepository, ApiProvider? provider})
      : provider = provider ?? ApiProvider();

  @override
  Future<Exam> getExam(String examId) async {
    // TODO : ID based request
    final exams = await getExams();
    return exams.firstWhere((element) => element.id == examId,
        orElse: () => Exam.empty);
  }

  @override
  Future<List<Exam>> getExams() async {
    var res = await provider.query(
        path: "/exam/byteacher",
        method: HTTPMethod.get,
        key: await authenticationRepository.getKey());
    var exams = List<Map<String, dynamic>>.from(res);
    return exams.map((e) => ExamDTO.fromJson(e).toModel()).toList();
  }

  Future<void> setCourses(
      {required String examId, required List<String> courseIds}) async {
    await provider.query(
        path: "/exam/$examId/setparticipants",
        method: HTTPMethod.post,
        body: {
          "participants":
              courseIds.map((e) => {"id": e, "type": "Course"}).toList()
        },
        key: await authenticationRepository.getKey());
  }

  @override
  Future<void> uploadExam({required NewExamDTO exam}) async {
    final res = await provider.query(
        path: "/exam/create",
        method: HTTPMethod.post,
        body: exam.toJson(),
        key: await authenticationRepository.getKey());

    final id = res["id"];
    await setCourses(examId: id, courseIds: [exam.course.id]);
  }

  @override
  Future<void> updateExam(
      {required NewExamDTO exam, required String examId}) async {
    await provider.query(
        path: "/exam/$examId/update",
        method: HTTPMethod.put,
        body: exam.toJson(),
        key: await authenticationRepository.getKey());
    await setCourses(examId: examId, courseIds: [exam.course.id]);
  }

  @override
  Future<void> setPoints(
      {required String submissionId,
      required String taskId,
      required double achievedPoints}) async {
    await provider.query(
        path: "/submission/$submissionId/setpoints",
        method: HTTPMethod.post,
        body: {"taskId": taskId, "achievedPoints": achievedPoints},
        key: await authenticationRepository.getKey());
  }

  @override
  Future<void> setGradingTable({required Exam exam}) async {
    await provider.query(
        path: "/Exam/${exam.id}/SetGradingTable",
        method: HTTPMethod.post,
        body: GradingTableDTO.fromModel(exam.gradingTable),
        key: await authenticationRepository.getKey());
  }

  @override
  Future<List<SubmissionOverview>> getSubmissions(
      {required String examId}) async {
    final exam = await getExam(examId);

    var res = await provider.query(
        path: "/submission/byexam/$examId",
        method: HTTPMethod.get,
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

    var res = await provider.query(
        path: "/submission/byidswithdetails",
        method: HTTPMethod.post,
        body: {"ids": submissionIds},
        key: await authenticationRepository.getKey());

    var submissions = List<Map<String, dynamic>>.from(res);

    return submissions
        .map((e) => SubmissionDetailsDTO.fromJson(e).toModel(exam: exam))
        .toList();
  }

  @override
  Future<void> uploadRemark(
      {required String submissionId, required String data}) async {
    await provider.query(
        path: "/submission/$submissionId/uploadremark",
        method: HTTPMethod.post,
        body: {"remarkPdf": data},
        key: await authenticationRepository.getKey());
  }

  @override
  Future<void> publishExam(
      {required String examId, DateTime? publishDate}) async {
    await provider.query(
        path: "/exam/$examId/publish",
        method: HTTPMethod.post,
        body: {"publishingDateTime": publishDate?.toUtc().toIso8601String()},
        key: await authenticationRepository.getKey());
  }

  @override
  Future<List<Course>> getCourses() async {
    final res = await provider.query(
        path: "/course/byteacher",
        key: await authenticationRepository.getKey());

    var courses = List<Map<String, dynamic>>.from(res);

    return courses.map((e) => CourseDTO.fromJson(e).toModel()).toList();
  }
}
