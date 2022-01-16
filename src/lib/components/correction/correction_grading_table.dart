import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schoolexam_correction_ui/blocs/remark/remark.dart';

/// This widget allows for editing of the grading table that should be assigned to the exam
class CorrectionGradingTable extends StatelessWidget {
  const CorrectionGradingTable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RemarkCubit, RemarkState>(
        // Only update when the GradingTable changed
        buildWhen: (old, current) => current is GradingTabledUpdatedState,
        builder: (context, state) {
          final gradingTableState = state as GradingTabledUpdatedState;
          return Column(
              children: gradingTableState.gradingTable.lowerBounds
                  .map(
                    (lb) => Row(
                      children: [TextField(), const Text("-"), TextField()],
                    ),
                  )
                  .toList());
        });
  }
}
