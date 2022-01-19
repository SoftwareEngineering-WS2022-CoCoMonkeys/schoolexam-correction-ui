import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:schoolexam/exams/exams.dart';
import 'package:schoolexam_correction_ui/blocs/remarks/remarks_bloc.dart';

class TaskRemarkDialog extends StatefulWidget {
  final Submission submission;
  final Answer answer;

  const TaskRemarkDialog(
      {Key? key, required this.submission, required this.answer})
      : super(key: key);

  @override
  State<TaskRemarkDialog> createState() => _TaskRemarkDialogState();
}

class _TaskRemarkDialogState extends State<TaskRemarkDialog> {
  TextEditingController? controller;

  @override
  void initState() {
    controller =
        TextEditingController(text: widget.answer.achievedPoints.toString());
    super.initState();
  }

  String? _errorDescription(String? value) {
    if (value == null) {
      return AppLocalizations.of(context)!.invalidValue;
    }

    final res = double.tryParse(value);

    if (res == null || res < 0 || res > widget.answer.task.maxPoints) {
      return AppLocalizations.of(context)!.invalidValue;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) => CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      navigationBar: CupertinoNavigationBar(
          leading: TextButton(
            child: Text(AppLocalizations.of(context)!.cancel),
            onPressed: () => Navigator.pop(context),
          ),
          trailing: TextButton(
              child: Text(AppLocalizations.of(context)!.save),
              onPressed: () {
                if (_errorDescription(controller!.text) == null) {
                  BlocProvider.of<RemarksCubit>(context).mark(
                    submission: widget.submission,
                    task: widget.answer.task,
                    achievedPoints: double.parse(controller!.text),
                  );
                }
              }),
          middle: Text(widget.answer.task.title)),
      child: SafeArea(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        CupertinoFormSection.insetGrouped(
          children: [
            CupertinoFormRow(
              prefix: Text(AppLocalizations.of(context)!.taskRemarkPoints),
              child: CupertinoTextFormFieldRow(
                scrollPadding: EdgeInsets.zero,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  /// We only allow up to two decimal points
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                controller: controller,
                autovalidateMode: AutovalidateMode.always,
                validator: _errorDescription,
              ),
            )
          ],
        ),
      ])));

  @override
  void dispose() {
    if (controller != null) {
      controller!.dispose();
    }
    super.dispose();
  }
}
