import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schoolexam/exams/exams.dart';
import 'package:schoolexam_correction_ui/blocs/remark/correction.dart';
import 'package:schoolexam_correction_ui/blocs/remark/remark.dart';

import 'input/input_header.dart';

class CorrectionInputHeader extends StatefulWidget {
  final Correction initial;

  const CorrectionInputHeader({Key? key, required this.initial})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _CorrectionInputHeaderState();
}

class _CorrectionInputHeaderState extends State<CorrectionInputHeader> {
  @override
  Widget build(BuildContext context) => Container(
    height: 44,
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 3,
          blurRadius: 3,
          offset: const Offset(2, 0), // changes position of shadow
        ),
      ],
    ),
    child: BlocBuilder<RemarkCubit, RemarkState>(
        // Only update, when the navigation changed (task dropdown)
        buildWhen: (old, current) => current is NavigatedRemarkState,
        builder: (context, state) {
          final current = state.getCurrent(widget.initial);
          return Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: DropdownButton(
                    value: (current.currentAnswer.isNotEmpty)
                        ? current.currentAnswer.task.id
                        : null,
                    items: current.submission.exam.tasks
                        .map((e) => DropdownMenuItem(
                              value: e.id,
                              child: Text(e.title),
                            ))
                        .toList(),
                    onChanged: (String? newValue) {
                      final task = current.submission.exam.tasks.firstWhere(
                          (element) => element.id == newValue,
                          orElse: () => Task.empty);
                      BlocProvider.of<RemarkCubit>(context).moveTo(task: task);
                    }),
              ),
              const Expanded(
                child: InputHeader(),
              )
            ],
          );
        }),
  );
}
