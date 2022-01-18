import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:schoolexam/exams/exams.dart';
import 'package:schoolexam_correction_ui/blocs/remarks/remarks.dart';
import 'package:schoolexam_correction_ui/components/exams/exam_form_row.dart';

class PublishExamDialog extends StatefulWidget {
  final Exam exam;
  final DateFormat formatter = DateFormat('dd.MM.yyyy').add_Hm();

  PublishExamDialog({Key? key, required this.exam}) : super(key: key);

  @override
  State<PublishExamDialog> createState() => _PublishExamDialogState();
}

class _PublishExamDialogState extends State<PublishExamDialog> {
  DateTime? minimumDate;
  DateTime? publishDate;

  @override
  void initState() {
    minimumDate = DateTime.now().add(const Duration(minutes: 14));
    publishDate = minimumDate!.add(const Duration(minutes: 1));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      children: [
        Container(
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0),
            width: 400,
            child: Column(
              children: [
                ExamFormRow(
                  prefix: AppLocalizations.of(context)!.examPublishDate,
                  invalid: false,
                  value: widget.formatter.format(publishDate!.toLocal()),
                  child: Column(
                    children: [
                      Text(AppLocalizations.of(context)!.examPublishDate,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 36)),
                      SizedBox(
                        height: 300,
                        child: CupertinoDatePicker(
                          initialDateTime: publishDate,
                          minimumDate: minimumDate,
                          mode: CupertinoDatePickerMode.dateAndTime,
                          onDateTimeChanged: (dateTime) {
                            setState(() {
                              publishDate = dateTime;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Center(
                          child: SimpleDialogOption(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.blue),
                              onPressed: () {
                                BlocProvider.of<RemarksCubit>(context).publish(
                                    exam: widget.exam,
                                    publishDate: publishDate);
                                Navigator.pop(context);
                              },
                              child: Text(
                                  AppLocalizations.of(context)!.examPublish),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: SimpleDialogOption(
                            child: ElevatedButton(
                              style:
                                  ElevatedButton.styleFrom(primary: Colors.red),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(AppLocalizations.of(context)!.cancel),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ))
      ],
    );
  }
}
