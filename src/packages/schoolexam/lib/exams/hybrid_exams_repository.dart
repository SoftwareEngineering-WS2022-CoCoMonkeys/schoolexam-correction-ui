import 'dart:developer';

import 'package:schoolexam/authentication/authentication_repository.dart';
import 'package:schoolexam/exams/dto/new_exam_dto.dart';
import 'package:schoolexam/exams/exams.dart';
import 'package:schoolexam/exams/local_exams_repository.dart';
import 'package:schoolexam/exams/online_exams_repository.dart';
import 'package:schoolexam/utils/network_exceptions.dart';
import 'package:tuple/tuple.dart';

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
    } on NetworkException catch (e) {
      log("Falling back to offline repository because of error $e");
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
    } on NetworkException catch (e) {
      log("Falling back to offline repository because of error $e");
      exams = await local.getExams();
    }

    return exams;
  }

  @override
  Future<List<SubmissionOverview>> getSubmissions(
      {required String examId}) async {
    late final submissions;
    try {
      log("Trying to retrieve submissions from online repository");
      submissions = await online.getSubmissions(examId: examId);
    } on NetworkException catch (e) {
      log("Falling back to offline repository because of error $e");
      submissions = await local.getSubmissions(examId: examId);
    }

    return submissions;
  }

  @override
  Future<List<Submission>> getSubmissionDetails(
      {required String examId, required List<String> submissionIds}) async {
    // <submissionId, [old, current]>
    final data = <String, Tuple2<SubmissionOverview, SubmissionOverview>>{};

    // a) (pot.) old
    for (final submission in (await local.getSubmissions(examId: examId))) {
      data[submission.id] = Tuple2(submission, Submission.empty);
    }

    // b) current
    for (final submission in (await getSubmissions(examId: examId))) {
      data.putIfAbsent(
          submission.id, () => Tuple2(Submission.empty, Submission.empty));
      data[submission.id] = Tuple2(data[submission.id]!.item1, submission);
    }

    // c) Difference
    // TODO : Current empty! => Deletion?

    // c1) Retrieve outdated
    // The data class only saves with ms granularity.
    final outdated = data.entries
        .where((element) =>
            element.value.item2.updatedAt.millisecondsSinceEpoch >
            element.value.item1.updatedAt.millisecondsSinceEpoch)
        .map((e) => e.key)
        .toList();

    if (outdated.isNotEmpty) {
      try {
        log("Trying to retrieve outdated submissions ${outdated} from online repository");
        final updated = await online.getSubmissionDetails(
            examId: examId, submissionIds: outdated);
        log("Inserting updated submission into local repository.");
        await local.insertSubmissions(submissions: updated);
      } on NetworkException catch (e) {
        log("Could not retrieve updated submissions because of $e");
      }
    }

    final res = await local.getSubmissionDetails(
        examId: examId, submissionIds: submissionIds);
    return res;
  }

  @override
  Future<void> uploadExam({required NewExamDTO exam}) async {
    try {
      log("Trying to upload new exam to online repository");
      return await online.uploadExam(exam: exam);
    } on NetworkException catch (e) {
      log("Falling back to offline repository because of error $e");
      return await local.uploadExam(exam: exam);
    }
  }

  @override
  Future<void> updateExam(
      {required NewExamDTO exam, required String examId}) async {
    try {
      log("Trying to update exam using online repository");
      return await online.updateExam(exam: exam, examId: examId);
    } on NetworkException catch (e) {
      log("Falling back to offline repository because of error $e");
      return await local.updateExam(exam: exam, examId: examId);
    }
  }

  @override
  Future<void> setPoints(
      {required String submissionId,
      required String taskId,
      required double achievedPoints}) async {
    // TODO: implement setPoints in local with synchronization after a while
    log("Trying to set $achievedPoints for the task $taskId within $submissionId");
    await online.setPoints(
        submissionId: submissionId,
        taskId: taskId,
        achievedPoints: achievedPoints);
  }
}
