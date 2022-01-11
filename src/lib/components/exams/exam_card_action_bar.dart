import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schoolexam/exams/exams.dart';
import 'package:schoolexam_correction_ui/blocs/navigation/navigation.dart';

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
            label: const Text("Hochladen"),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.edit),
            onPressed: () {},
            label: const Text("Anpassen"),
          ),
        ] else if (exam.status == ExamStatus.inCorrection) ...[
          ElevatedButton.icon(
            icon: const Icon(Icons.fact_check_outlined),
            onPressed: () {
              BlocProvider.of<NavigationCubit>(context).toCorrection(exam.id);
            },
            label: const Text("Korrigieren"),
          ),
        ] else if (exam.status == ExamStatus.corrected) ...[
          ElevatedButton.icon(
            icon: const Icon(Icons.cloud_upload),
            onPressed: () {},
            label: const Text("Rückgabe"),
          ),
        ]
      ],
    );
  }
}