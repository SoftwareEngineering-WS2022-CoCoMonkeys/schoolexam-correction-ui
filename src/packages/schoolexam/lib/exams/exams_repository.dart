import 'package:schoolexam/exams/dto/new_exam_dto.dart';
import 'package:schoolexam/exams/exams.dart';

import 'models/exam.dart';

abstract class ExamsRepository {
  const ExamsRepository();

  /// Returns the details of the desired exam with the identification [examId]
  Future<Exam> getExam(String examId);

  /// Returns all the exams a teacher is allowed to retrieve
  Future<List<Exam>> getExams();

  /// Returns all the submissions overviews currently uploaded for the [examId]
  Future<List<SubmissionOverview>> getSubmissions({required String examId});

  /// Returns the details for the requested submissions [submissionIds] belonging to the exam [examId].
  Future<List<Submission>> getSubmissionDetails(
      {required String examId, required List<String> submissionIds});

  /// Set the achieved points for a task
  Future<void> setPoints(
      {required String submissionId,
      required String taskId,
      required double achievedPoints});

  /// Uploads the base64 encoded remark pdf [data] for the submission [submission].
  Future<void> uploadRemark(
      {required String submissionId, required String data});

  /// Upload the newly created [exam]
  Future<void> uploadExam({required NewExamDTO exam});

  /// Update the [exam]
  Future<void> updateExam({required NewExamDTO exam, required String examId});

  /// Set the grading table for the [exam]
  Future<void> setGradingTable({required Exam exam});

}
