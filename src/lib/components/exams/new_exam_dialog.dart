import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:intl/intl.dart';
import 'package:schoolexam_correction_ui/blocs/exams/exam_details_bloc.dart';
import 'package:schoolexam_correction_ui/blocs/exams/exam_details_event.dart';
import 'package:schoolexam_correction_ui/blocs/exams/exam_details_state.dart';
import 'package:schoolexam_correction_ui/components/exams/exam_form_row.dart';

class NewExamDialog extends StatelessWidget {
  const NewExamDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final DateFormat formatter = DateFormat('dd.MM.yyyy');

    return BlocConsumer<ExamDetailsBloc, ExamDetailsState>(
        listener: (context, state) {
          if (state.status.isSubmissionFailure) {
            // TODO : Improve errors
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                    content: Text(
                        "${state.isNewExamEdit
                            ? "Erstellung"
                            : "Anpassung"} fehlgeschlagen")),
              );
          }
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
                    invalid: state.examTitle.invalid,
                    value: state.examTitle.value,
                    child: Column(
                      children: [
                        TextField(
                            controller: TextEditingController(
                                text: state.examTitle.value),
                            style: TextStyle(
                              fontSize: 36,
                            ),
                            decoration: InputDecoration(
                              labelText: "Titel",
                            ),
                            onChanged: (examTitle) =>
                                context
                                    .read<ExamDetailsBloc>()
                                    .add(ExamTitleChanged(examTitle))),
                      ],
                    ),
                  ),
                  ExamFormRow(
                    prefix: 'Thema',
                    invalid: state.examTopic.invalid,
                    value: state.examTopic.value,
                    child: Column(
                      children: [
                        TextField(
                            controller: TextEditingController(
                                text: state.examTopic.value),
                            style: TextStyle(
                              fontSize: 36,
                            ),
                            decoration: InputDecoration(
                              labelText: "Thema",
                            ),
                            onChanged: (examTopic) =>
                                context
                                    .read<ExamDetailsBloc>()
                                    .add(ExamTopicChanged(examTopic))),
                      ],
                    ),
                  ),
                  ExamFormRow(
                    prefix: 'Kurs',
                    invalid: state.examCourse.invalid,
                    value: state.examCourse.value.displayName,
                    child: Column(
                      children: [
                        const Text("Kurs",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 36)),
                        Container(
                          height: 300,
                          child: CupertinoPicker(
                              itemExtent: 50,
                              onSelectedItemChanged: (int index) {
                                context.read<ExamDetailsBloc>().add(
                                    ExamCourseChanged(
                                        state.validCourses[index]));
                              },
                              children: state.validCourses
                                  .map((c) =>
                                  Text(c.displayName,
                                      style: TextStyle(
                                        fontSize: 36,
                                      )))
                                  .toList()),
                        ),
                      ],
                    ),
                  ),
                  ExamFormRow(
                    prefix: 'Prüfungsdatum',
                    invalid: state.examDate.invalid,
                    value: formatter.format(state.examDate.value.toLocal()),
                    child: Column(
                      children: [
                        const Text("Prüfungsdatum",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 36)),
                        Container(
                          height: 300,
                          child: CupertinoDatePicker(
                            minimumDate: DateTime.now(),
                            mode: CupertinoDatePickerMode.date,
                            onDateTimeChanged: (dateTime) =>
                                context
                                    .read<ExamDetailsBloc>()
                                    .add(ExamDateChanged(dateTime)),
                          ),
                        ),
                      ],
                    ),
                  ),
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
                                  context
                                      .read<ExamDetailsBloc>()
                                      .add(const ExamSubmitted());
                                  Navigator.pop(context);
                                },
                                child: Text(state.isNewExamEdit
                                    ? "Erstellen"
                                    : "Anpassen"),
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
