import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:provider/src/provider.dart';
import 'package:schoolexam_correction_ui/blocs/exams/exam_details_bloc.dart';
import 'package:schoolexam_correction_ui/blocs/exams/exam_details_event.dart';
import 'package:schoolexam_correction_ui/components/exams/new_exam_dialog.dart';

class NewExamCard extends StatelessWidget {
  const NewExamCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const radius = 24.0;

    return SizedBox(
      height: 240,
      child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          child: DottedBorder(
            dashPattern: const [20, 20],
            color: Colors.grey,
            strokeWidth: 1,
            borderType: BorderType.RRect,
            radius: const Radius.circular(radius),
            child: AspectRatio(
                aspectRatio: 1.4,
                child: InkWell(
                    onTap: () {
                      context
                          .read<ExamDetailsBloc>()
                          .add(const NewExamOpened());
                      showDialog(
                          context: context,
                          builder: (_) => const NewExamDialog());
                    },
                    child: const Icon(
                      Icons.add,
                      size: 100.0,
                      color: Colors.grey,
                    ))),
          )),
    );
  }
}
