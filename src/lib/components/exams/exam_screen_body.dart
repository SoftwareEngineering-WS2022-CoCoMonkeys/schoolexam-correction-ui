import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:schoolexam/exams/exams.dart';
import 'package:schoolexam_correction_ui/blocs/exams/exams.dart';
import 'package:schoolexam_correction_ui/components/exams/exam_card.dart';
import 'package:schoolexam_correction_ui/components/exams/new_exam_card.dart';

class ExamScreenBody extends StatelessWidget {
  final List<Exam> exams;

  const ExamScreenBody(this.exams, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => RefreshIndicator(
          onRefresh: () async {
            await context.read<ExamsCubit>().loadExams();
          },
          child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Wrap(
                  direction: Axis.horizontal,
                  spacing: 30.0,
                  runSpacing: 30.0,
                  children: [
                    const NewExamCard(),
                    ...exams.map((e) => ExamCard(e)).toList()
                  ],
                ),
              )),
        ),
      );
}
