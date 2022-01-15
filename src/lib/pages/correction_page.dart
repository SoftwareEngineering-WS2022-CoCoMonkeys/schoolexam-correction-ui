import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schoolexam_correction_ui/blocs/remark/remark.dart';
import 'package:schoolexam_correction_ui/components/correction/correction_overview.dart';
import 'package:schoolexam_correction_ui/components/correction/correction_participant_selection_widget.dart';
import 'package:schoolexam_correction_ui/components/correction/correction_view.dart';

class CorrectionPage extends StatelessWidget {
  const CorrectionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocBuilder<RemarkCubit, RemarkState>(
      buildWhen: (old, current) =>
          old.corrections.length != current.corrections.length,
      builder: (context, state) {
        // We do not have any correction open => General overview
        if (state.corrections.isEmpty) {
          return CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBar(
                middle: Text(state.exam.title),
              ),
              child:
                  const Material(child: SafeArea(child: CorrectionOverview())));
        } else {
          print("REBUILD");
          return Material(
            child: CupertinoPageScaffold(
                navigationBar: CupertinoNavigationBar(
                  trailing: IconButton(
                    icon: Icon(
                      Icons.person_add_outlined,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (_) => const Dialog(
                              child: CorrectionParticipantSelectionWidget()));
                    },
                  ),
                  middle: Text(state.exam.title),
                ),
                child: const SafeArea(child: CorrectionView())),
          );
        }
      });
}
