import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:popover/popover.dart';
import 'package:schoolexam/exams/exams.dart';
import 'package:schoolexam_correction_ui/blocs/exam_details/exam_details.dart';
import 'package:schoolexam_correction_ui/blocs/exam_details/exam_details_bloc.dart';
import 'package:schoolexam_correction_ui/blocs/navigation/navigation.dart';
import 'package:schoolexam_correction_ui/components/exams/exam_details_dialog.dart';
import 'package:schoolexam_correction_ui/components/exams/publish_exam_dialog.dart';

class ExamCardActionsBar extends StatelessWidget {
  final Exam exam;

  const ExamCardActionsBar(this.exam, {Key? key}) : super(key: key);

  Widget _getChild({required BuildContext context}) {
    switch (exam.status) {
      case ExamStatus.planned:
        return ElevatedButton.icon(
          icon: const Icon(Icons.edit),
          onPressed: () {
            BlocProvider.of<ExamDetailsCubit>(context)
                .adjustExamOpened(exam: exam);
            showPopover(
                direction: PopoverDirection.top,
                context: context,
                bodyBuilder: (_) => const ExamDetailsDialog());
          },
          label: Text(AppLocalizations.of(context)!.examCardButtonEdit),
        );
      case ExamStatus.inCorrection:
        return ElevatedButton.icon(
          icon: const Icon(Icons.fact_check_outlined),
          onPressed: () {
            BlocProvider.of<NavigationCubit>(context).toCorrection(exam.id);
          },
          label: Text(AppLocalizations.of(context)!.examCardButtonCorrect),
        );
      case ExamStatus.corrected:
        return ElevatedButton.icon(
          icon: const Icon(Icons.cloud_upload),
          onPressed: () {
            showPopover(
                direction: PopoverDirection.top,
                context: context,
                bodyBuilder: (_) => PublishExamDialog(
                      exam: exam,
                    ));
          },
          label: Text(AppLocalizations.of(context)!.examPublish),
        );
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return SizedBox(
        width: constraints.maxWidth * 0.5,
        child: _getChild(context: context),
      );
    });
  }
}
