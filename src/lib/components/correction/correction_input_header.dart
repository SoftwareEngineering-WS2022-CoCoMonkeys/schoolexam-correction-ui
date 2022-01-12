import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schoolexam/exams/exams.dart';
import 'package:schoolexam_correction_ui/blocs/remark/remark.dart';

import 'input/input_header.dart';

class CorrectionInputHeader extends StatelessWidget {
  const CorrectionInputHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<RemarkCubit, RemarkState>(builder: (context, state) {
        return Container(
          constraints: const BoxConstraints(maxHeight: 48),
          child: Row(
            children: [
              DropdownButton(
                  value: (state.corrections.isNotEmpty)
                      ? (state.corrections[state.selectedCorrection]
                              .currentAnswer.isNotEmpty)
                          ? state.corrections[state.selectedCorrection]
                              .currentAnswer.task.id
                          : null
                      : null,
                  items: state.exam.tasks
                      .map((e) => DropdownMenuItem(
                            value: e.id,
                            child: Text(e.title),
                          ))
                      .toList(),
                  onChanged: (String? newValue) {
                    final task = state.exam.tasks.firstWhere(
                        (element) => element.id == newValue,
                        orElse: () => Task.empty);
                    BlocProvider.of<RemarkCubit>(context).moveTo(task);
                  }),
              const InputHeader()
            ],
          ),
        );
      });
}
