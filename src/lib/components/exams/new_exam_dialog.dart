import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:schoolexam/exams/models/course.dart';
import 'package:schoolexam_correction_ui/blocs/exams/details_exam_bloc.dart';
import 'package:schoolexam_correction_ui/blocs/exams/exam_details_event.dart';
import 'package:schoolexam_correction_ui/blocs/exams/exam_details_form_input.dart';
import 'package:schoolexam_correction_ui/blocs/exams/exam_details_state.dart';
import 'package:schoolexam_correction_ui/components/exams/exam_form_row.dart';

class NewExamDialog extends StatefulWidget {
  NewExamDialog({Key? key}) : super(key: key);

  @override
  NewExamDialogState createState() => NewExamDialogState();
}

class NewExamDialogState extends State<NewExamDialog> {
  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final DateFormat formatter = DateFormat('dd.MM.yyyy');

    return BlocConsumer<ExamDetailsBloc, ExamDetailsState>(
        listener: (context, state) {
      ;
    }, builder: (context, state) {
      return SimpleDialog(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0),
            width: 400,
            child: CupertinoFormSection.insetGrouped(
                backgroundColor: Colors.transparent,
                key: formKey,
                children: [
                  ExamFormRow(
                      prefix: 'Titel',
                      value: state.examTitle.value,
                      callback: () => showCupertinoModalBottomSheet(
                            context: context,
                            builder: (context) => Material(
                              child: Container(
                                height: 1000,
                                child: Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(30),
                                    child: Column(
                                      children: [
                                        const Text("Titel",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 36)),
                                        CupertinoTextField(
                                            style: TextStyle(
                                              fontSize: 36,
                                            ),
                                            onChanged: (examTitle) => context
                                                .read<ExamDetailsBloc>()
                                                .add(ExamTitleChanged(
                                                    examTitle))),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )),
                  ExamFormRow(
                      prefix: 'Thema',
                      value: state.examTopic.value,
                      callback: () => showCupertinoModalBottomSheet(
                            context: context,
                            builder: (context) => Material(
                              child: Container(
                                height: 1000,
                                child: Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(30),
                                    child: Column(
                                      children: [
                                        const Text("Thema",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 36)),
                                        CupertinoTextField(
                                            style: TextStyle(
                                              fontSize: 36,
                                            ),
                                            onChanged: (examTopic) => context
                                                .read<ExamDetailsBloc>()
                                                .add(ExamTopicChanged(
                                                    examTopic))),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )),
                  ExamFormRow(
                      prefix: 'Kurs',
                      value: state.examCourse.value.displayName,
                      callback: () => showCupertinoModalBottomSheet(
                            context: context,
                            builder: (context) => Material(
                              child: Container(
                                height: 1000,
                                child: Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(30),
                                    child: Column(
                                      children: [
                                        const Text("Kurs",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 36)),
                                        Container(
                                          height: 300,
                                          child: CupertinoPicker(
                                              itemExtent: 50,
                                              onSelectedItemChanged:
                                                  (int value) {
                                                print(value);
                                              },
                                              children: state.validCourses
                                                  .map(
                                                      (c) => Text(c.displayName,
                                                          style: TextStyle(
                                                            fontSize: 36,
                                                          )))
                                                  .toList()),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )),
                  ExamFormRow(
                      prefix: 'Prüfungsdatum',
                      value: formatter.format(state.examDate.value.toLocal()),
                      callback: () => showCupertinoModalBottomSheet(
                            context: context,
                            builder: (context) => Material(
                              child: Container(
                                height: 1000,
                                child: Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(30),
                                    child: Column(
                                      children: [
                                        const Text("Prüfungsdatum",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 36)),
                                        Container(
                                          height: 300,
                                          child: CupertinoDatePicker(
                                            minimumDate: DateTime.now(),
                                            mode: CupertinoDatePickerMode.date,
                                            onDateTimeChanged: (dateTime) =>
                                                context
                                                    .read<ExamDetailsBloc>()
                                                    .add(ExamDateChanged(
                                                        dateTime)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )),
                  Padding(
                    padding: EdgeInsets.only(top: 30.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: SimpleDialogOption(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.blue),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('Erstellen'),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: SimpleDialogOption(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.red),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('Abbrechen'),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ]),
          )
        ],
      );
    });
  }
}
