import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:schoolexam/exams/exams.dart';
import 'package:schoolexam/exams/models/exam.dart';

extension CorrectableStatusExtensions on CorrectableStatus {
  String getDescription({
    required BuildContext context,
  }) {
    switch (this) {
      case CorrectableStatus.inProgress:
        return AppLocalizations.of(context)!.stateInCorrection;
      case CorrectableStatus.corrected:
        return AppLocalizations.of(context)!.stateCorrected;
      case CorrectableStatus.unknown:
        return AppLocalizations.of(context)!.stateUnknown;
      case CorrectableStatus.pending:
        return AppLocalizations.of(context)!.stateInCorrection;
    }
  }
}
