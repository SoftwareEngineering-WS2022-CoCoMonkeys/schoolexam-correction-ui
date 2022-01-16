import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:schoolexam/exams/exams.dart';
import 'package:schoolexam_correction_ui/blocs/exam_details/exam_details.dart';
import 'package:schoolexam_correction_ui/blocs/exam_details/exam_details_bloc.dart';
import 'package:schoolexam_correction_ui/blocs/navigation/navigation.dart';
import 'package:schoolexam_correction_ui/components/exams/new_exam_dialog.dart';

class ExamCardActionsBar extends StatelessWidget {
  final Exam exam;

  const ExamCardActionsBar(this.exam, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        if (exam.status == ExamStatus.planned) ...[
          ElevatedButton.icon(
            icon: const Icon(Icons.upload_file),
            onPressed: () {},
            label: Text(AppLocalizations.of(context)!.examCardButtonUpload),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.read<ExamDetailsBloc>().add(AdjustExamOpened(exam));
              showCupertinoDialog(
                  context: context, builder: (_) => const NewExamDialog());
            },
            label: Text(AppLocalizations.of(context)!.examCardButtonEdit),
          ),
        ] else if (exam.status == ExamStatus.inCorrection) ...[
          ElevatedButton.icon(
            icon: const Icon(Icons.fact_check_outlined),
            onPressed: () {
              BlocProvider.of<NavigationCubit>(context).toCorrection(exam.id);
            },
            label: Text(AppLocalizations.of(context)!.examCardButtonCorrect),
          ),
        ] else if (exam.status == ExamStatus.corrected) ...[
          ElevatedButton.icon(
            icon: const Icon(Icons.cloud_upload),
            onPressed: () {},
            label: Text(AppLocalizations.of(context)!.examCardButtonReturn),
          ),
        ]
      ],
    );
  }
}
