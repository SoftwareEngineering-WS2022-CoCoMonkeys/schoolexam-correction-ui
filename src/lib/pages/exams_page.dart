import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schoolexam/exams/exams.dart';
import 'package:schoolexam_correction_ui/blocs/exams/exams.dart';
import 'package:schoolexam_correction_ui/components/exams/exam_screen_body.dart';

class ExamsPage extends StatelessWidget {
  const ExamsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            IconButton(
              onPressed: null,
              icon: Icon(
                Icons.arrow_drop_down,
                color: Theme.of(context).primaryColor,
                size: 32,
              ),
            ),
            const Center(
                child: Text(
              "Lehrer XY",
              style: TextStyle(color: Colors.black),
            ))
          ],
        ),
        leadingWidth: 300,
        title: const Text(
          "Prüfungen",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: BlocBuilder<ExamsCubit, ExamsState>(
          builder: (context, state) {
            return Container(
              alignment: Alignment.topCenter,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Card(
                      child: TextField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.search_outlined,
                            size: 40,
                            color: Theme.of(context).primaryColor,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          labelText: 'Prüfung',
                        ),
                      ),
                    ),
                  ),
                  const StateSelectorChips(),
                  ExamScreenBody(state.filtered)
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class StateSelectorChips extends StatefulWidget {
  const StateSelectorChips({Key? key}) : super(key: key);

  @override
  _StateSelectorChipsState createState() => _StateSelectorChipsState();
}

class _StateSelectorChipsState extends State<StateSelectorChips> {
  final List<bool> selectedList;
  final List<_ExamStatusChip> values;

  _StateSelectorChipsState()
      : values =
            ExamStatus.values.map((e) => _ExamStatusChip(e, e.name)).toList(),
        selectedList = List.generate(ExamStatus.values.length, (index) => true);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: List.generate(
          values.length,
          (index) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: ChoiceChip(
                  label: Text(values[index].displayName),
                  selected: selectedList[index],
                  onSelected: (bool choice) => setState(() {
                    selectedList[index] = choice;

                    context.read<ExamsCubit>().filterExams("", _getSelected());
                  }),
                ),
              )),
    );
  }

  List<ExamStatus> _getSelected() {
    var res = <ExamStatus>[];
    for (var i = 0; i < values.length; i++) {
      if (selectedList[i]) res.add(values[i].status);
    }

    return res;
  }
}

class _ExamStatusChip {
  final ExamStatus status;
  final String displayName;

  _ExamStatusChip(this.status, this.displayName);
}
