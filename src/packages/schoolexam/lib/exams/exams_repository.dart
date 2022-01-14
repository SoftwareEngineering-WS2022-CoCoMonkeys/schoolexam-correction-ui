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

  /// Uploads a newly created exam
  //Future<void> insertExam({required Exam exam});
}
