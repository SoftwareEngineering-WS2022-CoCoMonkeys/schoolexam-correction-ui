import 'package:schoolexam/authentication/authentication_repository.dart';
import 'package:schoolexam/exams/dto/exam_dto.dart';
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
  Future<List<Submission>> getSubmissions({required String examId}) {
    // TODO: implement getSubmissions
    throw UnimplementedError();
  }
}
