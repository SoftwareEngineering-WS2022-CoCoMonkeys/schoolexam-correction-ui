import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schoolexam_correction_ui/blocs/remark/remark.dart';
import 'package:schoolexam_correction_ui/components/correction/correction_overview.dart';
import 'package:schoolexam_correction_ui/components/correction/correction_participant_selection_widget.dart';
import 'package:schoolexam_correction_ui/components/correction/correction_view.dart';
import 'package:schoolexam_correction_ui/components/error_widget.dart';
import 'package:schoolexam_correction_ui/components/loading_widget.dart';

class CorrectionPage extends StatelessWidget {
  const CorrectionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<RemarkCubit, RemarkState>(builder: (context, state) {
        if (state is LoadingRemarksState) {
          return CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBar(
                middle: Text(state.exam.title),
              ),
              child: const LoadingWidget());
        }

        if (state is LoadingRemarksErrorState) {
          return CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBar(
                middle: Text(state.exam.title),
              ),
              child: const ErrorStateWidget());
        }

        // We do not have any correction open => General overview
        if (state.corrections.isEmpty) {
          return CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBar(
                middle: Text(state.exam.title),
              ),
              child:
                  const Material(child: SafeArea(child: CorrectionOverview())));
        } else {
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
