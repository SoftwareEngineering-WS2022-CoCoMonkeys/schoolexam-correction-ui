import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schoolexam/exams/exams.dart';
import 'package:schoolexam_correction_ui/blocs/exams/exams.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:schoolexam_correction_ui/extensions/exam_extensions.dart';

import 'exam_screen_body.dart';

class ExamsSearchView extends StatelessWidget {
  const ExamsSearchView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocBuilder<ExamsCubit, ExamsState>(
      builder: (context, state) => Container(
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width * 0.6,
                child: Card(
                  child: TextField(
                    onChanged: (search) => context
                        .read<ExamsCubit>()
                        .onSearchChanged(search.toLowerCase()),
                    onSubmitted: (search) => context
                        .read<ExamsCubit>()
                        .onSearchChanged(search.toLowerCase()),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.search_outlined,
                        size: 40,
                        color: Theme.of(context).primaryColor,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      labelText: AppLocalizations.of(context)!.exam,
                    ),
                  ),
                ),
              ),
              const StateSelectorChips(),
              Expanded(flex: 1, child: ExamScreenBody(state.filtered))
            ],
          )));
}

class StateSelectorChips extends StatefulWidget {
  const StateSelectorChips({Key? key}) : super(key: key);

  @override
  _StateSelectorChipsState createState() => _StateSelectorChipsState();
}

class _StateSelectorChipsState extends State<StateSelectorChips> {
  final List<ExamStatus> selectable;

  _StateSelectorChipsState()
      : selectable = [
          ExamStatus.planned,
          ExamStatus.submissionReady,
          ExamStatus.inCorrection,
          ExamStatus.corrected,
          ExamStatus.published,
        ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExamsCubit, ExamsState>(
        builder: (context, state) => Material(
              child: Wrap(
                children: List.generate(
                    selectable.length,
                    (index) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ChoiceChip(
                            label: Text(selectable[index]
                                .getDescription(context: context)),
                            selected: state.states.any((element) =>
                                element.name == selectable[index].name),
                            onSelected: (bool choice) => setState(() {
                              BlocProvider.of<ExamsCubit>(context)
                                  .onStatusChanged(
                                      status: selectable[index], added: choice);
                            }),
                          ),
                        )),
              ),
            ));
  }
}
