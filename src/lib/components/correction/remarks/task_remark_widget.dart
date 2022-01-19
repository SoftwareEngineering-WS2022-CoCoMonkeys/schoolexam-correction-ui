import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:popover/popover.dart';
import 'package:schoolexam/schoolexam.dart';
import 'package:schoolexam_correction_ui/blocs/remarks/remarks.dart';
import 'package:schoolexam_correction_ui/components/correction/remarks/task_remark_dialog.dart';

class AnswerRemarkWidget extends StatelessWidget {
  final Correction initial;
  final Task task;

  const AnswerRemarkWidget(
      {Key? key, required this.initial, required this.task})
      : super(key: key);

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) =>
            BlocBuilder<RemarksCubit, RemarksState>(
          builder: (context, state) {
            if (state is! RemarksCorrectionInProgress) {
              // No content - In general an exception
              return Container();
            }

            final correction = state.getCurrent(initial);
            final answer = correction.submission.answers.firstWhere(
                (element) => element.task.id == task.id,
                orElse: () => Answer.empty);

            return Container(
              margin: const EdgeInsets.only(right: 8.0),
              width: double.infinity,
              constraints:
                  BoxConstraints(maxHeight: constraints.maxHeight * 0.3),
              decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: const BorderRadius.all(Radius.circular(8))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      task.title,
                      style: Theme.of(context).textTheme.button,
                    ),
                  ),
                  _TaskRemarkIconWidget(
                    answer: answer,
                  ),
                  Text("${answer.achievedPoints} / ${task.maxPoints}"),
                  Text(AppLocalizations.of(context)!.taskRemarkPoints),
                  ElevatedButton(
                    onPressed: () {
                      showPopover(
                          context: context,
                          bodyBuilder: (_) => TaskRemarkDialog(
                              submission: correction.submission,
                              answer: answer));
                    },
                    child:
                        Text(AppLocalizations.of(context)!.taskRemarkEvaluate),
                  )
                ],
              ),
            );
          },
        ),
      );
}

class _TaskRemarkIconWidget extends StatelessWidget {
  final Answer answer;

  const _TaskRemarkIconWidget({Key? key, required this.answer})
      : super(key: key);

  Widget _getIcon({required double size}) {
    switch (answer.status) {
      case CorrectableStatus.unknown:
        return Icon(
          Icons.check_circle_outlined,
          color: Colors.red,
          size: size,
        );
      case CorrectableStatus.pending:
        return Icon(
          Icons.check_circle_outline,
          color: Colors.grey,
          size: size,
        );
      case CorrectableStatus.corrected:
      case CorrectableStatus.inProgress:
        return Icon(
          Icons.check_circle_outline,
          color: Colors.green,
          size: size,
        );
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: _getIcon(size: 34),
      );
}
