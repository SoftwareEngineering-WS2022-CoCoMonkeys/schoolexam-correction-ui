import 'dart:developer';

import 'package:schoolexam/authentication/authentication_repository.dart';
import 'package:schoolexam/exams/dto/new_exam_dto.dart';
import 'package:schoolexam/exams/exams.dart';
import 'package:schoolexam/exams/local_exams_repository.dart';
import 'package:schoolexam/exams/online_exams_repository.dart';
import 'package:schoolexam/utils/network_exceptions.dart';

class HybridExamsRepository extends ExamsRepository {
  final OnlineExamsRepository online;
  final LocalExamsRepository local;

  HybridExamsRepository({required AuthenticationRepository repository})
      : online = OnlineExamsRepository(authenticationRepository: repository),
        local = LocalExamsRepository();

  @override
  Future<Exam> getExam(String examId) async {
    late final exam;
    try {
      exam = await online.getExam(examId);
      await local.insertExams(exams: [exam]);
    } on NetworkException catch (_) {
      exam = await local.getExam(examId);
    }

    return exam;
  }

  @override
  Future<List<Exam>> getExams() async {
    late final exams;
    try {
      exams = await online.getExams();
      await local.insertExams(exams: exams);
    } on NetworkException catch (_) {
      exams = await local.getExams();
    }

    print(exams);

    return exams;
  }

  @override
  Future<List<Submission>> getSubmissions({required String examId}) {
    late final submissions;
    try {
      submissions = online.getSubmissions(examId: examId);
      // TODO : insert into local
    } on NetworkException catch (_) {
      submissions = local.getSubmissions(examId: examId);
    }

    return submissions;
  }

  @override
  Future<void> uploadExam({required NewExamDTO exam}) async {
    try {
      log("Trying to upload new exam to online repository");
      return await online.uploadExam(exam: exam);
    } on NetworkException catch (_) {
      return await local.uploadExam(exam: exam);
    }
  }

  @override
  Future<void> updateExam(
      {required NewExamDTO exam, required String examId}) async {
    try {
      log("Trying to update exam using online repository");
      return await online.updateExam(exam: exam, examId: examId);
    } on NetworkException catch (_) {
      return await local.updateExam(exam: exam, examId: examId);
    }
  }

  @override
  Future<void> setPoints(
      {required String submissionId,
      required String taskId,
      required double achievedPoints}) async {
    // TODO: implement setPoints in local with synchronization after a while
    log("Trying to set $achievedPoints for the task $taskId withint $submissionId");
    await online.setPoints(
        submissionId: submissionId,
        taskId: taskId,
        achievedPoints: achievedPoints);
  }
}
