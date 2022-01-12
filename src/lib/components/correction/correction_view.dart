import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schoolexam_correction_ui/blocs/remark/remark.dart';

import 'correction_input_header.dart';
import 'correction_tab_view.dart';

/// A view over all currently active corrections.
class CorrectionView extends StatelessWidget {
  const CorrectionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<RemarkCubit, RemarkState>(builder: (context, state) {
        if (state.corrections.isEmpty) {
          return const Text("ERROR");
        }

        return Column(
          children: [
            const CorrectionInputHeader(),
            Container(
                color: null,
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.8),
                child: // TODO TabView over all corrections
                    CorrectionTabView(
                  correction: state.corrections[state.selectedCorrection],
                ))
          ],
        );
      });
}
