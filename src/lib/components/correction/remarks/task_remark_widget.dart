import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:schoolexam/schoolexam.dart';
import 'package:schoolexam_correction_ui/blocs/remark/correction.dart';
import 'package:schoolexam_correction_ui/blocs/remark/remark.dart';

class AnswerRemarkWidget extends StatelessWidget {
  final Correction initial;
  final Task task;

  const AnswerRemarkWidget(
      {Key? key, required this.initial, required this.task})
      : super(key: key);

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) =>
            BlocBuilder<RemarkCubit, RemarkState>(
          builder: (context, state) {
            final correction = state.getCurrent(initial);
            final answer = correction.submission.answers.firstWhere(
                (element) => element.task.id == task.id,
                orElse: () => Answer.empty);

            return Container(
              width: double.infinity,
              constraints:
                  BoxConstraints(maxHeight: constraints.maxHeight * 0.3),
              decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8))),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      task.title,
                      style: Theme.of(context).textTheme.button,
                    ),
                    _TaskRemarkIconWidget(
                      answer: answer,
                    ),
                    Text("${answer.achievedPoints} / ${task.maxPoints}"),
                    Text(AppLocalizations.of(context)!.taskRemarkPoints),
                    ElevatedButton(
                      onPressed: () {
                        showCupertinoModalBottomSheet(
                            context: context,
                            builder: (context) => Material(
                                child: SizedBox(
                                    height: 1000,
                                    child: Center(
                                        child: Padding(
                                            padding: const EdgeInsets.all(30),
                                            child: _TaskRemarkSelectionWidget(
                                              answer: answer,
                                              submission: correction.submission,
                                            ))))));
                      },
                      child: Text(
                          AppLocalizations.of(context)!.taskRemarkEvaluate),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      );
}

class _TaskRemarkSelectionWidget extends StatefulWidget {
  final Submission submission;
  final Answer answer;

  const _TaskRemarkSelectionWidget(
      {Key? key, required this.submission, required this.answer})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _TaskRemarkSelectionWidgetState();
}

class _TaskRemarkSelectionWidgetState
    extends State<_TaskRemarkSelectionWidget> {
  TextEditingController? controller;

  @override
  void initState() {
    controller =
        TextEditingController(text: widget.answer.achievedPoints.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) => TextField(
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
        ],
        controller: controller,
        style: const TextStyle(
          fontSize: 36,
        ),
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.taskRemarkPoints,
        ),
        onSubmitted: (text) => BlocProvider.of<RemarkCubit>(context).mark(
            submission: widget.submission,
            task: widget.answer.task,
            achievedPoints: double.parse(text)),
      );

  @override
  void dispose() {
    super.dispose();
    if (controller != null) {
      controller!.dispose();
    }
  }
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
      case CorrectableStatus.published:
        return Icon(
          Icons.check_circle_outline,
          color: Colors.green,
          size: size,
        );
      case CorrectableStatus.archived:
        return Icon(
          Icons.check_circle,
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
