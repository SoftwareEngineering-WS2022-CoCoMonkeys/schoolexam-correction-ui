import 'package:equatable/equatable.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations_de.dart';

class LanguageState extends Equatable {
  final AppLocalizations dictionary;

  const LanguageState({required this.dictionary});

  LanguageState.initial() : this(dictionary: AppLocalizationsDe());

  @override
  List<Object?> get props => [dictionary];

  LanguageState copyWith({
    AppLocalizations? dictionary,
  }) {
    return LanguageState(
      dictionary: dictionary ?? this.dictionary,
    );
  }
}
