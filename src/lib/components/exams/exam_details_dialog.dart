import 'dart:collection';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:formz/formz.dart';
import 'package:intl/intl.dart';
import 'package:schoolexam_correction_ui/blocs/exam_details/exam_details.dart';
import 'package:schoolexam_correction_ui/components/constants.dart';
import 'package:schoolexam_correction_ui/components/was_animated_scope.dart';

class ExamDetailsDialog extends StatelessWidget {
  const ExamDetailsDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      navigationBar: CupertinoNavigationBar(
        leading: TextButton(
          child: Text(AppLocalizations.of(context)!.cancel),
          onPressed: () => Navigator.pop(context),
        ),
        trailing: BlocBuilder<ExamDetailsCubit, ExamDetailsState>(
            buildWhen: (old, current) => old.status != current.status,
            builder: (context, state) => TextButton(
                onPressed: () => state.status.isValid
                    ? BlocProvider.of<ExamDetailsCubit>(context).submitExam()
                    : null,
                child: Text(
                  (state is ExamDetailsCreationState)
                      ? AppLocalizations.of(context)!.newExamButtonCreate
                      : AppLocalizations.of(context)!.newExamButtonEdit,
                ))),
        middle: BlocBuilder<ExamDetailsCubit, ExamDetailsState>(
            buildWhen: (old, current) => false,
            builder: (context, state) => (state is ExamDetailsCreationState)
                ? Text(
                    AppLocalizations.of(context)!.newExamCardTitle,
                  )
                : Text(
                    AppLocalizations.of(context)!.editExamCardTitle,
                  )),
      ),
      child: Material(
          child: SafeArea(
        child: _ExamDetailsDialogForm(),
      )));
}

class _ExamDetailsDialogForm extends StatefulWidget {
  final DateFormat formatter;

  _ExamDetailsDialogForm({Key? key, DateFormat? formatter})
      : formatter = formatter ?? DateFormat('dd.MM.yyyy'),
        super(key: key);

  @override
  State<_ExamDetailsDialogForm> createState() => _ExamDetailsDialogFormState();
}

class _ExamDetailsDialogFormState extends State<_ExamDetailsDialogForm> {
  final formKey = GlobalKey<FormState>();

  /// Trigger changes between the pickers after the completion of the others animation.
  /// The rebuilds are therefore put into [outstanding].
  final Queue<VoidCallback> outstanding;

  _ExamDetailsDialogFormState() : outstanding = Queue<VoidCallback>();

  bool get allowExpansion => !isCourseAnimating && !isDateAnimating;

  /// Only go into the animation widget, if difference occurs.
  bool isCourseSelectionActive = false;
  bool wasCourseSelectionActive = false;

  bool get canShowCourse => !isDateSelectionActive && !wasDateSelectionActive;

  bool get isCourseAnimating =>
      isCourseSelectionActive != wasCourseSelectionActive;

  void _triggerCourse() {
    wasCourseSelectionActive = isCourseSelectionActive;
    isCourseSelectionActive = !wasCourseSelectionActive;
    log("Triggered course $wasCourseSelectionActive -> $isCourseSelectionActive");
  }

  /// Only go into the animation widget, if difference occurs.
  bool isDateSelectionActive = false;
  bool wasDateSelectionActive = false;

  bool get canShowDate => !isCourseSelectionActive && !wasCourseSelectionActive;

  bool get isDateAnimating => isDateSelectionActive != wasDateSelectionActive;

  void _triggerDate() {
    wasDateSelectionActive = isDateSelectionActive;
    isDateSelectionActive = !wasDateSelectionActive;
    log("Triggered date $wasDateSelectionActive -> $isDateSelectionActive");
  }

  @override
  Widget build(BuildContext context) => Column(
        key: formKey,
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoFormSection.insetGrouped(
              backgroundColor: Colors.transparent,
              children: const [_ExamTitleWidget(), _ExamTopicWidget()]),
          CupertinoFormSection
              .insetGrouped(backgroundColor: Colors.transparent, children: [
            /// === COURSE ===
            BlocBuilder<ExamDetailsCubit, ExamDetailsState>(
                builder: (context, state) {
              return CupertinoFormRow(
                  prefix: Text(
                    AppLocalizations.of(context)!.newExamCourse,
                  ),
                  child: InkWell(
                    onTap: (!allowExpansion)
                        ? null
                        : () {
                            if (!canShowCourse) {
                              setState(() {
                                _triggerDate();
                              });
                              outstanding.addFirst(_triggerCourse);
                            } else {
                              setState(() {
                                _triggerCourse();
                              });
                            }
                          },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: state.examCourse.value.displayName.isEmpty
                          ? Text(
                              AppLocalizations.of(context)!.examCardCourse,
                              style: kPlaceHolderStyle,
                            )
                          : Text(state.examCourse.value.displayName,
                              style: CupertinoTheme.of(context)
                                  .textTheme
                                  .textStyle),
                    ),
                  ));
            }),

            /// We are fully animated and desired to be shown.
            if (wasCourseSelectionActive && isCourseSelectionActive) ...[
              SizedBox(height: kPickerHeight, child: _ExamCoursePicker()),
            ]

            /// We await our animation to complete.
            else if (wasCourseSelectionActive != isCourseSelectionActive) ...[
              WasAnimatedScope(
                  onEnd: () {
                    setState(() {
                      wasCourseSelectionActive = isCourseSelectionActive;

                      /// We freed up space for other
                      if (outstanding.isNotEmpty && !wasCourseSelectionActive) {
                        outstanding.removeLast()();
                      }
                    });
                  },
                  fromOpacity: isCourseSelectionActive ? 0.0 : 1.0,
                  toOpacity: isCourseSelectionActive ? 1.0 : 0.0,
                  fromHeight: isCourseSelectionActive ? 0 : kPickerHeight,
                  toHeight: isCourseSelectionActive ? kPickerHeight : 0,
                  duration: const Duration(milliseconds: kDurationMs),
                  builder: (BuildContext context) => _ExamCoursePicker())
            ],

            /// === DATE ===
            BlocBuilder<ExamDetailsCubit, ExamDetailsState>(
                builder: (context, state) {
              return CupertinoFormRow(
                  prefix: Text(AppLocalizations.of(context)!.newExamDate),
                  child: InkWell(
                      onTap: (!allowExpansion)
                          ? null
                          : () {
                              if (!canShowDate) {
                                setState(() {
                                  _triggerCourse();
                                });
                                outstanding.addFirst(_triggerDate);
                              } else {
                                setState(() {
                                  _triggerDate();
                                });
                              }
                            },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          widget.formatter
                              .format(state.examDate.value.toLocal()),
                        ),
                      )));
            }),

            /// We are fully animated and desired to be shown.
            if (wasDateSelectionActive && isDateSelectionActive) ...[
              SizedBox(height: kPickerHeight, child: _ExamDatePicker()),
            ]

            /// We await our animation to complete.
            else if (wasDateSelectionActive != isDateSelectionActive) ...[
              WasAnimatedScope(
                  onEnd: () {
                    setState(() {
                      wasDateSelectionActive = isDateSelectionActive;

                      /// We freed up space for other
                      if (outstanding.isNotEmpty && !wasDateSelectionActive) {
                        outstanding.removeLast()();
                      }
                    });
                  },
                  fromOpacity: isDateSelectionActive ? 0.0 : 1.0,
                  toOpacity: isDateSelectionActive ? 1.0 : 0.0,
                  fromHeight: isDateSelectionActive ? 0 : kPickerHeight,
                  toHeight: isDateSelectionActive ? kPickerHeight : 0,
                  duration: const Duration(milliseconds: kDurationMs),
                  builder: (BuildContext context) => _ExamDatePicker())
            ]
          ])
        ],
      );
}

class _ExamCoursePicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ExamDetailsCubit, ExamDetailsState>(
        builder: (context, state) => CupertinoPicker(
            scrollController: FixedExtentScrollController(
                initialItem: state.validCourses.indexWhere(
                    (element) => element.id == state.examCourse.value.id)),
            itemExtent: 50,
            onSelectedItemChanged: (int index) {
              BlocProvider.of<ExamDetailsCubit>(context)
                  .changeExamCourse(course: state.validCourses[index]);
            },
            children: state.validCourses
                .map((c) => Text(c.displayName,
                    style: const TextStyle(
                      fontSize: 36,
                    )))
                .toList()),
      );
}

class _ExamDatePicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) => CupertinoDatePicker(
      minimumDate: DateTime.now(),
      mode: CupertinoDatePickerMode.date,
      onDateTimeChanged: (dateTime) =>
          BlocProvider.of<ExamDetailsCubit>(context)
              .changeExamDate(date: dateTime));
}

class _ExamTitleWidget extends StatelessWidget {
  const _ExamTitleWidget({Key? key}) : super(key: key);

  @override
  Widget build(
          BuildContext context) =>
      BlocBuilder<ExamDetailsCubit, ExamDetailsState>(
          buildWhen: (old,
                  current) =>
              old.examTitle.status != current.examTitle.status,
          builder: (context, state) => CupertinoFormRow(
              prefix: Text(AppLocalizations.of(context)!.newExamTitle),
              child: CupertinoTextFormFieldRow(
                  initialValue: state.examTitle.value,
                  autovalidateMode: AutovalidateMode.always,
                  validator: (String? value) => (state.examTitle.invalid)
                      ? AppLocalizations.of(context)!.invalidValue
                      : null,
                  onChanged: (examTitle) =>
                      BlocProvider.of<ExamDetailsCubit>(context)
                          .changeExamTitle(title: examTitle),
                  placeholder: AppLocalizations.of(context)!.newExamTitle)));
}

class _ExamTopicWidget extends StatelessWidget {
  const _ExamTopicWidget({Key? key}) : super(key: key);

  @override
  Widget build(
          BuildContext context) =>
      BlocBuilder<ExamDetailsCubit, ExamDetailsState>(
          buildWhen: (old,
                  current) =>
              old.examTopic.status != current.examTopic.status,
          builder: (context, state) => CupertinoFormRow(
              prefix: Text(AppLocalizations.of(context)!.newExamTopic),
              child: CupertinoTextFormFieldRow(
                  initialValue: state.examTopic.value,
                  autovalidateMode: AutovalidateMode.always,
                  validator: (String? value) => (state.examTopic.invalid)
                      ? AppLocalizations.of(context)!.invalidValue
                      : null,
                  onChanged: (examTopic) =>
                      BlocProvider.of<ExamDetailsCubit>(context)
                          .changeExamTopic(topic: examTopic),
                  placeholder: AppLocalizations.of(context)!.newExamTopic)));
}
