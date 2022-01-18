import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schoolexam_correction_ui/blocs/language/language.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

typedef TranslationCallback = String Function(AppLocalizations dictionary);

class LanguageCubit extends Cubit<LanguageState> {
  LanguageCubit() : super(LanguageState.initial());

  /// Detects a possible language switch within the [context] and updates its state accordingly.
  Future<void> loadContext({required BuildContext context}) async {
    final localization = AppLocalizations.of(context);

    if (localization != null) {
      emit(state.copyWith(dictionary: localization));
    }
  }

  String translate({required TranslationCallback callback}) =>
      callback(state.dictionary);
}
