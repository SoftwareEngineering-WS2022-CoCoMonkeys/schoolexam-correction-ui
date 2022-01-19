import 'package:schoolexam/exams/exams.dart';
import 'package:schoolexam/utils/network_exceptions.dart';
import 'package:schoolexam_correction_ui/blocs/language/language.dart';

extension RemarksGradingErrorExtensions on NetworkException {
  String getGradingDescription(LanguageCubit language) {
    if (this is ConnectionException) {
      return language.translate(
          callback: (dictionary) => dictionary.offlineError);
    }

    /// Invalid credentials
    if (this is BadRequestException || this is ForbiddenException) {
      return language.translate(
          callback: (dictionary) => dictionary.remarksGradingBadRequestError);
    }

    /// Temporary server error
    if (this is ServerException) {
      return language.translate(
          callback: (dictionary) => dictionary.remarksGradingInternalError);
    }

    /// Default to app error
    return language.translate(
        callback: (dictionary) => dictionary.remarksGradingAppError);
  }
}

extension RemarksRemarkErrorExtensions on NetworkException {
  String getRemarkDescription(LanguageCubit language, Answer basis) {
    if (this is ConnectionException) {
      return language.translate(
          callback: (dictionary) => dictionary.offlineError);
    }

    /// Invalid credentials
    if (this is BadRequestException || this is ForbiddenException) {
      return language.translate(
          callback: (dictionary) => dictionary.remarksRemarkBadRequestError(basis.task.title, basis.achievedPoints));
    }

    /// Temporary server error
    if (this is ServerException) {
      return language.translate(
          callback: (dictionary) => dictionary.remarksRemarkInternalError(basis.task.title, basis.achievedPoints));
    }

    /// Default to app error
    return language.translate(
        callback: (dictionary) => dictionary.remarksRemarkAppError(basis.task.title, basis.achievedPoints));
  }
}

extension RemarksGradingTableExtension on GradingTable {
  String getUpdateDescription(LanguageCubit language) {
    return language.translate(
        callback: (dictionary) => dictionary.remarksGradingSuccess);
  }

  String getUpdateLoadingDescription(LanguageCubit language) {
    return language.translate(
        callback: (dictionary) => dictionary.remarksGradingLoading);
  }
}
