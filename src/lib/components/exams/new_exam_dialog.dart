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

    return BlocConsumer<ExamDetailsCubit, ExamDetailsState>(
        listener: (context, state) {
      if (state.status.isSubmissionFailure) {
        showCupertinoDialog<void>(
          context: context,
          builder: (BuildContext context) => CupertinoAlertDialog(
            title: Text(AppLocalizations.of(context)!.errorTitle),
            content: Text(AppLocalizations.of(context)!.updateExamError),
            actions: <CupertinoDialogAction>[
              CupertinoDialogAction(
                child: Text("Ok"),
                isDefaultAction: true,
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          ),
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
                            onChanged: (examTitle) =>
                                BlocProvider.of<ExamDetailsCubit>(context)
                                    .changeExamTitle(title: examTitle)),
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
                            onChanged: (examTopic) =>
                                BlocProvider.of<ExamDetailsCubit>(context)
                                    .changeExamTopic(topic: examTopic)),
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
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 36)),
                        SizedBox(
                          height: 300,
                          child: CupertinoPicker(
                              scrollController: FixedExtentScrollController(
                                  initialItem: state.validCourses.indexWhere(
                                      (element) =>
                                          element.id ==
                                          state.examCourse.value.id)),
                              itemExtent: 50,
                              onSelectedItemChanged: (int index) {
                                BlocProvider.of<ExamDetailsCubit>(context)
                                    .changeExamCourse(
                                        course: state.validCourses[index]);
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
                    child: Column(children: [
                      Text(AppLocalizations.of(context)!.newExamDate,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 36)),
                      SizedBox(
                        height: 300,
                        child: CupertinoDatePicker(
                            minimumDate: DateTime.now(),
                            mode: CupertinoDatePickerMode.date,
                            onDateTimeChanged: (dateTime) =>
                                BlocProvider.of<ExamDetailsCubit>(context)
                                    .changeExamDate(date: dateTime)),
                      ),
                    ]),
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
                                        BlocProvider.of<ExamDetailsCubit>(
                                                context)
                                            .submitExam();
                                      }
                                    : null,
                                child: Text((state is ExamDetailsCreationState)
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
                                child:
                                    Text(AppLocalizations.of(context)!.cancel),
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
