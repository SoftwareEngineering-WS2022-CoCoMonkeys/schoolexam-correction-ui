import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schoolexam_correction_ui/blocs/remark/remark.dart';
import 'package:schoolexam_correction_ui/components/correction/correction_grading_table.dart';

import 'correction_participant_selection_widget.dart';

/// This widget is used for displaying a general overview over the current status of submissions and their correction.
class CorrectionOverview extends StatelessWidget {
  const CorrectionOverview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocBuilder<RemarkCubit, RemarksState>(
      builder: (context, state) => Column(
            children: [
              const CorrectionGradingTable(),
              Expanded(
                child: Container(
                    constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.8),
                    child: const CorrectionParticipantSelectionWidget()),
              ),
            ],
          ));
}
