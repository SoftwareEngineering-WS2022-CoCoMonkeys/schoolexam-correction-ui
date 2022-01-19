import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:schoolexam/exams/exams.dart';
import 'package:schoolexam_correction_ui/blocs/exams/exams.dart';
import 'package:schoolexam_correction_ui/components/exams/exam_card.dart';
import 'package:schoolexam_correction_ui/components/exams/new_exam_card.dart';

class ExamScreenBody extends StatefulWidget {
  final List<Exam> exams;

  const ExamScreenBody(this.exams, {Key? key}) : super(key: key);

  @override
  State<ExamScreenBody> createState() => _ExamScreenBodyState();
}

class _ExamScreenBodyState extends State<ExamScreenBody> {
  final RefreshController _controller = RefreshController(initialRefresh: true);

  @override
  Widget build(BuildContext context) => BlocConsumer<ExamsCubit, ExamsState>(
        listener: (context, state) {
          if (state is ExamsLoadSuccess) {
            _controller.refreshCompleted();
          }
        },
        builder: (context, state) => LayoutBuilder(
          builder: (context, constraints) => ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: SmartRefresher(
              onRefresh: () {
                if (state is! ExamsLoadInProgress) {
                  context.read<ExamsCubit>().loadExams();
                }
              },
              controller: _controller,
              child: SingleChildScrollView(
                child: Align(
                    alignment: Alignment.topCenter,
                    child: Wrap(
                      direction: Axis.horizontal,
                      spacing: 30.0,
                      runSpacing: 30.0,
                      children: [
                        const NewExamCard(),
                        ...widget.exams.map((e) => ExamCard(e)).toList()
                      ],
                    )),
              ),
            ),
          ),
        ),
      );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
