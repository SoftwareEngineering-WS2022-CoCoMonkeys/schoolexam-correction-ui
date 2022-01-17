import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:schoolexam/exams/exams.dart';
import 'package:schoolexam_correction_ui/blocs/exam_details/exam_details.dart';
import 'package:schoolexam_correction_ui/blocs/exam_details/exam_details_bloc.dart';
import 'package:schoolexam_correction_ui/blocs/navigation/navigation.dart';
import 'package:schoolexam_correction_ui/blocs/remark/remark.dart';
import 'package:schoolexam_correction_ui/components/exams/new_exam_dialog.dart';
import 'package:schoolexam_correction_ui/components/exams/publish_exam_dialog.dart';

class ExamCardActionsBar extends StatelessWidget {
  final Exam exam;

  const ExamCardActionsBar(this.exam, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late final Widget child;
    switch (exam.status) {
      case ExamStatus.planned:
        child = ElevatedButton.icon(
          icon: const Icon(Icons.edit),
          onPressed: () {
            BlocProvider.of<ExamDetailsBloc>(context)
                .adjustExamOpened(exam: exam);
            showCupertinoDialog(
                context: context, builder: (_) => const NewExamDialog());
          },
          label: Text(AppLocalizations.of(context)!.examCardButtonEdit),
        );
        break;
      case ExamStatus.inCorrection:
        child = ElevatedButton.icon(
          icon: const Icon(Icons.fact_check_outlined),
          onPressed: () {
            BlocProvider.of<NavigationCubit>(context).toCorrection(exam.id);
          },
          label: Text(AppLocalizations.of(context)!.examCardButtonCorrect),
        );
        break;
      case ExamStatus.corrected:
        child = ElevatedButton.icon(
          icon: const Icon(Icons.cloud_upload),
          onPressed: () {
            showDialog(
                context: context,
                builder: (_) => PublishExamDialog(exam: exam));
          },
          label: Text(AppLocalizations.of(context)!.examPublish),
        );
        break;
      default:
        child = Container();
        break;
    }

    return LayoutBuilder(builder: (context, constraints) {
      return SizedBox(
        width: constraints.maxWidth * 0.5,
        child: child,
      );
    });
  }
}
