import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:schoolexam/exams/models/exam.dart';

abstract class ExamHelper {
  static String toValue(
      ExamStatus exam, {
        required BuildContext context,
      }) {
    switch (exam) {
      case ExamStatus.planned:
        return AppLocalizations.of(context)!.statePlanned;
      case ExamStatus.unknown:
        return AppLocalizations.of(context)!.stateUnknown;
      case ExamStatus.buildReady:
        return AppLocalizations.of(context)!.stateBuildReady;
      case ExamStatus.submissionReady:
        return AppLocalizations.of(context)!.stateSubmissionReady;
      case ExamStatus.inCorrection:
        return AppLocalizations.of(context)!.stateInCorrection;
      case ExamStatus.corrected:
        return AppLocalizations.of(context)!.stateCorrected;
      case ExamStatus.published:
        return AppLocalizations.of(context)!.statePublished;
    }
  }
}