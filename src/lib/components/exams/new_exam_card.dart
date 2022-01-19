import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:popover/popover.dart';
import 'package:schoolexam_correction_ui/blocs/exam_details/exam_details.dart';
import 'package:schoolexam_correction_ui/blocs/exam_details/exam_details_bloc.dart';
import 'package:schoolexam_correction_ui/components/exams/exam_card_base.dart';
import 'package:schoolexam_correction_ui/components/exams/exam_details_dialog.dart';

class NewExamCard extends StatelessWidget {
  const NewExamCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => ExamCardBase(
      builder: (context) => DottedBorder(
            dashPattern: const [20, 20],
            color: Colors.grey,
            strokeWidth: 1,
            borderType: BorderType.RRect,
            radius: const Radius.circular(4.0),
            child: AspectRatio(
                aspectRatio: 1.3,
                child: InkWell(
                    onTap: () {
                      BlocProvider.of<ExamDetailsCubit>(context).openNewExam();
                      showPopover(
                          context: context,
                          bodyBuilder: (_) => const ExamDetailsDialog());
                    },
                    child: const Icon(
                      Icons.add,
                      size: 100.0,
                      color: Colors.grey,
                    ))),
          ));
}
