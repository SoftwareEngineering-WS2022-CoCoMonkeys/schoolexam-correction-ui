import 'package:schoolexam/exams/dto/new_exam_dto.dart';
import 'package:schoolexam/exams/exams.dart';
import 'package:schoolexam/utils/network_exceptions.dart';
import 'package:schoolexam_correction_ui/blocs/language/language.dart';

extension ExamsNetworkExtensions on NetworkException {
  String getPublishDescription(LanguageCubit language, Exam exam) {
    if (this is ConnectionException) {
      return language.translate(
          callback: (dictionary) => dictionary.offlineError);
    }

    /// Invalid credentials
    if (this is BadRequestException || this is ForbiddenException) {
      return language.translate(
          callback: (dictionary) => dictionary.examPublishBadRequestError);
    }

    /// Temporary server error
    if (this is ServerException) {
      return language.translate(
          callback: (dictionary) =>
              dictionary.examPublishInternalError(exam.title));
    }

    /// Default to app error
    return language.translate(
        callback: (dictionary) => dictionary.examPublishAppError(exam.title));
  }
}

extension ExamsPublishExtension on Exam {
  String getPublishLoading(LanguageCubit language) {
    return language.translate(
        callback: (dictionary) => dictionary.examPublishLoading(title));
  }

  String getPublishSuccess(LanguageCubit language) {
    return language.translate(
        callback: (dictionary) => dictionary.examPublishSuccess(title));
  }
}
