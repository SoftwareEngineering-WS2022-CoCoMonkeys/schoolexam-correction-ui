import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schoolexam/exams/exams.dart';
import 'package:schoolexam_correction_ui/blocs/remark/correction.dart';
import 'package:schoolexam_correction_ui/blocs/remark/remark.dart';

import 'input/input_header.dart';

class CorrectionInputHeader extends StatelessWidget {
  final Exam exam;
  final Correction correction;

  const CorrectionInputHeader(
      {Key? key,
      required this.exam,
      required this.correction})
      : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(maxHeight: 48),
        child: Row(
          children: [
            DropdownButton(
                value: (correction.currentAnswer.isNotEmpty)
                    ? correction.currentAnswer.task.id
                    : null,
                items: exam.tasks
                    .map((e) => DropdownMenuItem(
                          value: e.id,
                          child: Text(e.title),
                        ))
                    .toList(),
                onChanged: (String? newValue) {
                  final task = exam.tasks.firstWhere(
                      (element) => element.id == newValue,
                      orElse: () => Task.empty);
                  BlocProvider.of<RemarkCubit>(context).moveTo(task);
                }),
            const InputHeader()
          ],
        ),
      );
}
