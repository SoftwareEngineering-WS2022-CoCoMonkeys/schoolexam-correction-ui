import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schoolexam_correction_ui/blocs/remark/remark.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CorrectionParticipantSelectionWidget extends StatelessWidget {
  const CorrectionParticipantSelectionWidget({Key? key}) : super(key: key);

  bool _isSelected(RemarkState state, int index) => state.corrections
      .any((element) => element.submission.id == state.submissions[index].id);

  @override
  Widget build(BuildContext context) => BlocBuilder<RemarkCubit, RemarkState>(
      builder: (context, state) => ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: state.submissions.length,
            itemBuilder: (BuildContext context, int index) {
              final isSelected = _isSelected(state, index);

              return ListTile(
                title: Text(state.submissions[index].student.displayName),
                // TODO : Localization
                subtitle: Text(state.submissions[index].status.name),
                leading: (isSelected) ? const Icon(Icons.check) : null,
                onTap: (isSelected)
                    ? null
                    : () {
                        showCupertinoDialog<void>(
                          context: context,
                          builder: (BuildContext context) =>
                              CupertinoAlertDialog(
                            title:
                                Text(AppLocalizations.of(context)!.correction),
                            content: Text(AppLocalizations.of(context)!
                                .correctionSelectionConfirmWithName(state
                                    .submissions[index].student.displayName)),
                            actions: <CupertinoDialogAction>[
                              CupertinoDialogAction(
                                child: Text(AppLocalizations.of(context)!.no),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              CupertinoDialogAction(
                                child: Text(AppLocalizations.of(context)!.yes),
                                isDefaultAction: true,
                                onPressed: () {
                                  BlocProvider.of<RemarkCubit>(context)
                                      .open(state.submissions[index]);
                                  Navigator.pop(context);
                                },
                              )
                            ],
                          ),
                        );
                      },
              );
            },
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(),
          ));
}
