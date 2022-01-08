import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schoolexam_correction_ui/blocs/remark/remark.dart';

/// This widget is used for displaying a general overview over the current status of submissions and their correction.
class CorrectionOverview extends StatelessWidget {
  const CorrectionOverview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocBuilder<RemarkCubit, RemarkState>(
      builder: (context, state) => Column(
            children: [
              Container(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.8),
                child: ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: state.submissions.length,
                  itemBuilder: (BuildContext context, int index) => ListTile(
                    title: Text(state.submissions[index].student.displayName),
                    // TODO : Localization
                    subtitle: Text(state.submissions[index].status.name),
                    onTap: () {
                      showCupertinoDialog<void>(
                        context: context,
                        builder: (BuildContext context) => CupertinoAlertDialog(
                          title: const Text('Korrektur'),
                          content: Text(
                              'Möchten sie die Korrektur von ${state.submissions[index].student.displayName} öffnen?'),
                          actions: <CupertinoDialogAction>[
                            CupertinoDialogAction(
                              child: const Text('Nein'),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            CupertinoDialogAction(
                              child: const Text('Ja'),
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
                  ),
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(),
                ),
              )
            ],
          ));
}
