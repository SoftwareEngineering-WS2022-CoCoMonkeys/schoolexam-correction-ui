import 'package:schoolexam/utils/network_exceptions.dart';
import 'package:schoolexam_correction_ui/blocs/language/language.dart';

extension LoginErrorNetworkExtensions on NetworkException {
  String getDescription(LanguageCubit language) {
    if (this is ConnectionException) {
      return language.translate(
          callback: (dictionary) => dictionary.offlineError);
    }

    /// Invalid credentials
    if (this is BadRequestException || this is ForbiddenException) {
      return language.translate(
          callback: (dictionary) => dictionary.loginBadRequestError);
    }

    /// Temporary server error
    if (this is ServerException) {
      return language.translate(
          callback: (dictionary) => dictionary.loginInternalError);
    }

    /// Default to app error
    return language.translate(
        callback: (dictionary) => dictionary.loginAppError);
  }
}
