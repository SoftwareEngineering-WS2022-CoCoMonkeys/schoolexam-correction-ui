import 'package:schoolexam/exams/dto/new_exam_dto.dart';
import 'package:schoolexam/utils/network_exceptions.dart';
import 'package:schoolexam_correction_ui/blocs/language/language.dart';

extension ExamDetailsNetworkExtensions on NetworkException {
  String getCreationDescription(LanguageCubit language, NewExamDTO basis) {
    if (this is ConnectionException) {
      return language.translate(
          callback: (dictionary) => dictionary.offlineError);
    }

    /// Invalid credentials
    if (this is BadRequestException || this is ForbiddenException) {
      return language.translate(
          callback: (dictionary) =>
              dictionary.examDetailsCreationBadRequestError);
    }

    /// Temporary server error
    if (this is ServerException) {
      return language.translate(
          callback: (dictionary) =>
              dictionary.examDetailsCreationInternalError(basis.title));
    }

    /// Default to app error
    return language.translate(
        callback: (dictionary) =>
            dictionary.examDetailsCreationAppError(basis.title));
  }

  String getUpdateDescription(LanguageCubit language, NewExamDTO basis) {
    if (this is ConnectionException) {
      return language.translate(
          callback: (dictionary) => dictionary.offlineError);
    }

    /// Invalid credentials
    if (this is BadRequestException || this is ForbiddenException) {
      return language.translate(
          callback: (dictionary) =>
              dictionary.examDetailsUpdateBadRequestError);
    }

    /// Temporary server error
    if (this is ServerException) {
      return language.translate(
          callback: (dictionary) =>
              dictionary.examDetailsUpdateInternalError(basis.title));
    }

    /// Default to app error
    return language.translate(
        callback: (dictionary) =>
            dictionary.examDetailsUpdateAppError(basis.title));
  }
}

extension ExamDetailDTOExtensions on NewExamDTO {
  String getCreationDescription(LanguageCubit language) {
    return language.translate(
        callback: (dictionary) => dictionary.examDetailsCreationSuccess(title));
  }

  String getCreationLoadingDescription(LanguageCubit language) {
    return language.translate(
        callback: (dictionary) => dictionary.examDetailsCreationLoading(title));
  }

  String getUpdateDescription(LanguageCubit language) {
    return language.translate(
        callback: (dictionary) => dictionary.examDetailsUpdateSuccess(title));
  }

  String getUpdateLoadingDescription(LanguageCubit language) {
    return language.translate(
        callback: (dictionary) => dictionary.examDetailsUpdateLoading(title));
  }
}
