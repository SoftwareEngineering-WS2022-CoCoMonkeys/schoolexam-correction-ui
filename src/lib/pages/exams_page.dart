import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:schoolexam_correction_ui/blocs/authentication/authentication.dart';
import 'package:schoolexam_correction_ui/components/app_bloc_listener.dart';
import 'package:schoolexam_correction_ui/components/exams/exams_search_view.dart';

class ExamsPage extends StatelessWidget {
  const ExamsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBlocListener(
        builder: (context) => CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
                middle: Text(
                  AppLocalizations.of(context)!.examPageName,
                  style: const TextStyle(color: Colors.black),
                ),
                backgroundColor: Colors.white,
                leading: BlocBuilder<AuthenticationBloc, AuthenticationState>(
                    builder: (context, state) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.person,
                        color: Colors.black,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          state.person.firstName,
                          style: const TextStyle(color: Colors.black),
                        ),
                      )
                    ],
                  );
                })),
            child: const ExamsSearchView()));
  }
}
