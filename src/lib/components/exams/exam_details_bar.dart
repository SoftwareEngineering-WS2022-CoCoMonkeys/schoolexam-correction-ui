import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:formz/formz.dart';
import 'package:schoolexam_correction_ui/blocs/exam_details/exam_details.dart';

/// Retrieve the bar for the [ExamDetailsDialog].
/// Due to the enforcment of [ObstructingPreferredSizeWidget] no easy wrapping is possible.
ObstructingPreferredSizeWidget getBar(BuildContext context) =>
    CupertinoNavigationBar(
      leading: TextButton(
        child: Align(
            alignment: Alignment.centerLeft,
            child: Text(AppLocalizations.of(context)!.cancel)),
        onPressed: () => Navigator.pop(context),
      ),
      trailing: BlocBuilder<ExamDetailsCubit, ExamDetailsState>(
          buildWhen: (old, current) => false,
          builder: (context, state) => TextButton(
              onPressed: () => state.status.isValidated
                  ? () {
                      BlocProvider.of<ExamDetailsCubit>(context).submitExam();
                    }
                  : null,
              child: Text(
                (state is ExamDetailsCreationState)
                    ? AppLocalizations.of(context)!.newExamButtonCreate
                    : AppLocalizations.of(context)!.newExamButtonEdit,
              ))),
      middle: BlocBuilder<ExamDetailsCubit, ExamDetailsState>(
          buildWhen: (old, current) => false,
          builder: (context, state) => (state is ExamDetailsCreationState)
              ? Text(
                  AppLocalizations.of(context)!.newExamCardTitle,
                )
              : Text(
                  AppLocalizations.of(context)!.editExamCardTitle,
                )),
    );
