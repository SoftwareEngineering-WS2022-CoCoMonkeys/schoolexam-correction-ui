import 'package:schoolexam/authentication/authentication_repository.dart';
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
  Future<Exam> getExam(String examId) {
    late final exam;
    try {
      exam = online.getExam(examId);
      // TODO : insert into local
    } on NetworkException catch (_) {
      exam = local.getExam(examId);
    }

    return exam;
  }

  @override
  Future<List<Exam>> getExams() {
    late final exams;
    try {
      exams = online.getExams();
      // TODO : insert into local
    } on NetworkException catch (_) {
      exams = local.getExams();
    }

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
}
