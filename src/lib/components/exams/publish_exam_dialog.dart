import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:schoolexam/exams/exams.dart';
import 'package:schoolexam_correction_ui/blocs/remarks/remarks.dart';
import 'package:schoolexam_correction_ui/components/constants.dart';
import 'package:schoolexam_correction_ui/components/exams/exam_form_row.dart';
import 'package:schoolexam_correction_ui/components/was_animated_scope.dart';

class PublishExamDialog extends StatefulWidget {
  final Exam exam;
  final DateFormat formatter = DateFormat('dd.MM.yyyy').add_Hm();

  PublishExamDialog({Key? key, required this.exam}) : super(key: key);

  @override
  State<PublishExamDialog> createState() => _PublishExamDialogState();
}

class _PublishExamDialogState extends State<PublishExamDialog> {
  bool isDateShown = false;
  bool wasDateShown = false;

  bool get isDateAnimating => isDateShown != wasDateShown;

  DateTime? minimumDate;
  DateTime? publishDate;

  @override
  void initState() {
    minimumDate = DateTime.now().add(const Duration(minutes: 14));
    publishDate = minimumDate!.add(const Duration(minutes: 1));
    super.initState();
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
            child: Text(AppLocalizations.of(context)!.examPublish),
            onPressed: () {
              BlocProvider.of<RemarksCubit>(context)
                  .publish(exam: widget.exam, publishDate: publishDate);
              Navigator.pop(context);
            },
          ),
          middle: Text(widget.exam.title)),
      child: Material(
          child: SafeArea(
              child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoFormSection.insetGrouped(
            children: [
              CupertinoFormRow(
                prefix: Text(AppLocalizations.of(context)!.examPublishDate),
                child: InkWell(
                  onTap: (isDateAnimating)
                      ? null
                      : () => setState(() {
                            wasDateShown = isDateShown;
                            isDateShown = !wasDateShown;
                            log("Triggered date $wasDateShown -> $isDateShown");
                          }),
                  child: Text(widget.formatter.format(publishDate!.toLocal())),
                ),
              ),
              if (wasDateShown && isDateShown) ...[
                SizedBox(
                  height: kPickerHeight,
                  child: _PublishDatePicker(
                      publishDate: publishDate!,
                      minimumDate: minimumDate!,
                      onDateTimeChanged: (value) => setState(() {
                            publishDate = value;
                          })),
                )
              ] else if (wasDateShown != isDateShown) ...[
                WasAnimatedScope(
                    onEnd: () {
                      setState(() {
                        wasDateShown = isDateShown;
                      });
                    },
                    fromOpacity: isDateShown ? 0.0 : 1.0,
                    toOpacity: isDateShown ? 1.0 : 0.0,
                    fromHeight: isDateShown ? 0 : kPickerHeight,
                    toHeight: isDateShown ? kPickerHeight : 0,
                    duration: const Duration(milliseconds: kDurationMs),
                    builder: (BuildContext context) => _PublishDatePicker(
                        publishDate: publishDate!,
                        minimumDate: minimumDate!,
                        onDateTimeChanged: (value) => setState(() {
                              publishDate = value;
                            })))
              ]
            ],
          )
        ],
      ))));
}

class _PublishDatePicker extends StatelessWidget {
  final DateTime publishDate;
  final DateTime minimumDate;
  final ValueChanged<DateTime> onDateTimeChanged;

  const _PublishDatePicker(
      {Key? key,
      required this.publishDate,
      required this.minimumDate,
      required this.onDateTimeChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) => CupertinoDatePicker(
      initialDateTime: publishDate,
      minimumDate: minimumDate,
      mode: CupertinoDatePickerMode.dateAndTime,
      onDateTimeChanged: onDateTimeChanged);
}
