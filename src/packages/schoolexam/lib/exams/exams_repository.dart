import 'package:schoolexam/exams/dto/new_exam_dto.dart';
import 'package:schoolexam/exams/exams.dart';

import 'models/exam.dart';

abstract class ExamsRepository {
  const ExamsRepository();

  /// Returns the details of the desired exam
  Future<Exam> getExam(String examId);

  /// Returns all the exams a teacher is allowed to retrieve
  Future<List<Exam>> getExams();

  /// Returns all the submissions currently uploaded for an exam
  Future<List<Submission>> getSubmissions({required String examId});

  /// Set the achieved points for a task
  Future<void> setPoints({required String submissionId, required String taskId, required double achievedPoints});

  /// Uploads a newly created exam
  Future<void> uploadExam({required NewExamDTO exam});

  /// Update an existing exam
  // TODO use ExamDTO
  Future<void> updateExam({required NewExamDTO exam, required String examId});
}
