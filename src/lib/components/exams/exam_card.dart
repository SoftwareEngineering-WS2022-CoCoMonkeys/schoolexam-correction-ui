import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:schoolexam/schoolexam.dart';
import 'package:schoolexam_correction_ui/extensions/exam_status_helper.dart';

import 'exam_card_action_bar.dart';

class ExamCard extends StatelessWidget {
  final Exam exam;

  const ExamCard(this.exam, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('dd.MM.yyyy');

    return SizedBox(
      height: 280,
      child: Card(
        child: AspectRatio(
          aspectRatio: 1.3,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  exam.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                formatter.format(exam.dateOfExam),
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0, top: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                        flex: 2,
                        child: Text(
                          AppLocalizations.of(context)!.examCardState + ": ",
                          textAlign: TextAlign.end,
                        )),
                    const SizedBox(width: 4),
                    Expanded(
                      flex: 4,
                      child: Text(
                          ExamHelper.toValue(exam.status, context: context)),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                        flex: 2,
                        child: Text(
                          AppLocalizations.of(context)!.examCardCourse + ": ",
                          textAlign: TextAlign.end,
                        )),
                    const SizedBox(width: 4),
                    Expanded(
                      flex: 4,
                      child: Text(exam.participants
                          .whereType<Course>()
                          .map((e) => e.displayName)
                          .join()),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        flex: 2,
                        child: Text(
                          AppLocalizations.of(context)!.examCardTopic + ": ",
                          textAlign: TextAlign.end,
                        )),
                    const SizedBox(width: 4),
                    Expanded(
                      flex: 4,
                      child: Text(exam.topic),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        flex: 2,
                        child: Text(
                          AppLocalizations.of(context)!.examCardParticipants +
                              ": ",
                          textAlign: TextAlign.end,
                        )),
                    const SizedBox(width: 4),
                    Expanded(
                      flex: 4,
                      child: Text(exam.participants.length.toString()),
                    )
                  ],
                ),
              ),
              if (exam.status != ExamStatus.planned) ...[
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          flex: 2,
                          child: Text(
                            AppLocalizations.of(context)!.examCardQuota + ": ",
                            textAlign: TextAlign.end,
                          )),
                      const SizedBox(width: 4),
                      Expanded(
                        flex: 4,
                        child: Text(exam.quota.toStringAsFixed(3) + " %"),
                      )
                    ],
                  ),
                )
              ],
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: ExamCardActionsBar(exam)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
