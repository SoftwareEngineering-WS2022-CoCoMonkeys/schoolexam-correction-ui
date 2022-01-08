import 'package:flutter/cupertino.dart';
import 'package:schoolexam/exams/exams.dart';
import 'package:schoolexam_correction_ui/components/exams/exam_card.dart';

class ExamScreenBody extends StatelessWidget {
  final List<Exam> exams;

  const ExamScreenBody(this.exams, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 30.0,
      runSpacing: 30.0,
      children: exams.map((e) => ExamCard(e)).toList(),
    );
  }
}
