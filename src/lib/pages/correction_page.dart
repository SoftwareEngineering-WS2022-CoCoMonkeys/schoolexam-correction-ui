import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schoolexam_correction_ui/blocs/navigation/navigation.dart';
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
      BlocBuilder<NavigationCubit, AppNavigationState>(
          builder: (context, appState) {
        return BlocBuilder<RemarkCubit, RemarksState>(builder: (context, state) {
          if (state is RemarksLoadFailure) {
            return CupertinoPageScaffold(
                navigationBar: CupertinoNavigationBar(
                  middle: Text(state.exam.title),
                ),
                child: const ErrorStateWidget());
          }

          /// We are still loading the data.
          else if (state is RemarksLoadSuccess ||
              state is RemarksGradingState) {
            return CupertinoPageScaffold(
                navigationBar: CupertinoNavigationBar(
                  middle: Text(state.exam.title),
                ),
                child: const Material(
                    child: SafeArea(child: CorrectionOverview())));
          }

          /// If we have an ongoing correction, we display the according correction view.
          else if (state is RemarksCorrectionInProgress) {
            return Material(
              child: CupertinoPageScaffold(
                  resizeToAvoidBottomInset: false,
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

          /// We do not have any correction open => General overview
          else {
            return CupertinoPageScaffold(
                navigationBar: CupertinoNavigationBar(
                  middle: Text(state.exam.title),
                ),
                child: const LoadingWidget());
          }
        });
      });
}
