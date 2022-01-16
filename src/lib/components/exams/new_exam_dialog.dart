import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:formz/formz.dart';
import 'package:intl/intl.dart';
import 'package:schoolexam_correction_ui/blocs/exam_details/exam_details.dart';
import 'package:schoolexam_correction_ui/blocs/exam_details/exam_details_bloc.dart';
import 'package:schoolexam_correction_ui/blocs/exam_details/exam_details_state.dart';
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
                        "${state.isNewExamEdit ? "Erstellung" : "Anpassung"} fehlgeschlagen")),
              );
          } else if (state.status.isSubmissionSuccess) {
            Navigator.pop(context);
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
                    prefix: AppLocalizations.of(context)!.newExamTitle,
                    invalid: state.examTitle.invalid,
                    value: state.examTitle.value,
                    child: Column(
                      children: [
                        TextField(
                            controller: TextEditingController(
                                text: state.examTitle.value),
                            style: const TextStyle(
                              fontSize: 36,
                            ),
                            decoration: InputDecoration(
                              labelText:
                              AppLocalizations.of(context)!.newExamTitle,
                            ),
                            onChanged: (examTitle) => context
                                .read<ExamDetailsBloc>()
                                .add(ExamTitleChanged(examTitle))),
                      ],
                    ),
                  ),
                  ExamFormRow(
                    prefix: AppLocalizations.of(context)!.newExamTopic,
                    invalid: state.examTopic.invalid,
                    value: state.examTopic.value,
                    child: Column(
                      children: [
                        TextField(
                            controller: TextEditingController(
                                text: state.examTopic.value),
                            style: const TextStyle(
                              fontSize: 36,
                            ),
                            decoration: InputDecoration(
                              labelText:
                              AppLocalizations.of(context)!.newExamTopic,
                            ),
                            onChanged: (examTopic) => context
                                .read<ExamDetailsBloc>()
                                .add(ExamTopicChanged(examTopic))),
                      ],
                    ),
                  ),
                  ExamFormRow(
                    prefix: AppLocalizations.of(context)!.newExamCourse,
                    invalid: state.examCourse.invalid,
                    value: state.examCourse.value.displayName,
                    child: Column(
                      children: [
                        Text(AppLocalizations.of(context)!.newExamCourse,
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
                                  .map((c) => Text(c.displayName,
                                  style: const TextStyle(
                                    fontSize: 36,
                                  )))
                                  .toList()),
                        ),
                      ],
                    ),
                  ),
                  ExamFormRow(
                    prefix: AppLocalizations.of(context)!.newExamDate,
                    invalid: state.examDate.invalid,
                    value: formatter.format(state.examDate.value.toLocal()),
                    child: Column(
                      children: [
                        Text(AppLocalizations.of(context)!.newExamDate,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 36)),
                        Container(
                          height: 300,
                          child: CupertinoDatePicker(
                            minimumDate: DateTime.now(),
                            mode: CupertinoDatePickerMode.date,
                            onDateTimeChanged: (dateTime) => context
                                .read<ExamDetailsBloc>()
                                .add(ExamDateChanged(dateTime)),
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
                                onPressed: state.status.isValidated
                                    ? () {
                                  context
                                      .read<ExamDetailsBloc>()
                                      .add(const ExamSubmitted());
                                }
                                    : null,
                                child: Text(state.isNewExamEdit
                                    ? AppLocalizations.of(context)!
                                    .newExamButtonCreate
                                    : AppLocalizations.of(context)!
                                    .newExamButtonEdit),
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
                                child: Text(AppLocalizations.of(context)!
                                    .newExamButtonCancel),
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