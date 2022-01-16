import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:schoolexam_correction_ui/blocs/remark/remark.dart';

/// This widget allows for editing of the grading table that should be assigned to the exam
class CorrectionGradingTable extends StatelessWidget {
  const CorrectionGradingTable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RemarkCubit, RemarkState>(
        // Only update when the GradingTable changed
        buildWhen: (old, current) =>
            current is GradingTabledUpdatedState ||
            current is StartedCorrectionState,
        builder: (context, state) {
          const minPoints = 0.0;
          final maxPoints =
              state.exam.tasks.fold<double>(0.0, (p, c) => p + c.maxPoints);

          final lowerBounds = state.exam.gradingTable.lowerBounds;
          const headerTextStyle = TextStyle(fontWeight: FontWeight.bold);

          final columnFormatText = Text(
              "% | ${AppLocalizations.of(context)!.pointsColumnHeader}",
              style: TextStyle(color: Colors.grey));
          final tableHeader = TableRow(children: [
            const Text(""),
            Center(
                child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(AppLocalizations.of(context)!.gradingIntervalStart,
                      style: headerTextStyle),
                  columnFormatText
                ],
              ),
            )),
            Center(
                child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(AppLocalizations.of(context)!.gradingIntervalEnd,
                            style: headerTextStyle),
                        const Icon(Icons.edit_outlined)
                      ]),
                  columnFormatText
                ],
              ),
            )),
            Center(
                child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    Text("Note", style: headerTextStyle),
                    Icon(Icons.edit_outlined)
                  ]),
            )),
          ]);

          const greyPlaceHolderText = Text(
            "leer",
            style: TextStyle(color: Colors.grey),
          );
          final table = Table(
              border: const TableBorder(
                  horizontalInside: BorderSide(
                      width: 1, color: Colors.blue, style: BorderStyle.solid)),
              columnWidths: const <int, TableColumnWidth>{
                0: FixedColumnWidth(25),
                1: FlexColumnWidth(),
                2: FlexColumnWidth(),
                3: FlexColumnWidth(),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                tableHeader,
                ...lowerBounds.mapIndexed((index, lb) {
                  // previous row value and conversion to percentages
                  final prevPoints =
                      (index > 0 ? lowerBounds[index - 1].points : maxPoints);

                  double prevPercentage = prevPoints / maxPoints * 100;
                  prevPercentage = prevPercentage.isNaN ? 0 : prevPercentage;

                  double currPercentage = lb.points / maxPoints * 100;
                  currPercentage = currPercentage.isNaN ? 0 : currPercentage;

                  return TableRow(children: [
                    Center(
                        child: IconButton(
                            padding: const EdgeInsets.all(0),
                            icon: const Icon(Icons.delete, size: 25),
                            onPressed: () =>
                                BlocProvider.of<RemarkCubit>(context)
                                    .deleteGradingTableBound(index))),
                    Center(
                        child: prevPoints.isNaN
                            ? greyPlaceHolderText
                            : Text(
                                "${prevPercentage.toStringAsFixed(1)}% (${prevPoints.toStringAsFixed(1)})")),
                    InkWell(
                        onTap: _showSingleWidgetBottomSheet(
                          context: context,
                          content: TextField(
                            controller: TextEditingController(
                                text: (lb.points / maxPoints * 100)
                                    .toStringAsFixed(1)),
                            onSubmitted: (pointsInput) {
                              BlocProvider.of<RemarkCubit>(context)
                                  .changeGradingTableBoundPoints(
                                      index,
                                      double.parse(pointsInput) /
                                          100 *
                                          maxPoints);
                            },
                            style: const TextStyle(fontSize: 36),
                            decoration: InputDecoration(
                                labelText:
                                    "${AppLocalizations.of(context)!.pointsColumnHeader} (%)"),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r"\d+\.?\d*"))
                              //  "\d+(\.\d)?"))
                            ], // Only numbers can be entered
                          ),
                        ),
                        child: Center(
                          child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: lb.points.isNaN
                                  ? greyPlaceHolderText
                                  : Text(
                                      "${currPercentage.toStringAsFixed(1)}% (${lb.points.toStringAsFixed(1)})")),
                        )),
                    InkWell(
                        onTap: _showSingleWidgetBottomSheet(
                          context: context,
                          content: TextField(
                            controller: TextEditingController(text: lb.grade),
                            style: const TextStyle(fontSize: 36),
                            onChanged: (gradeInput) {
                              BlocProvider.of<RemarkCubit>(context)
                                  .changeGradingTableBoundGrade(
                                      index, gradeInput);
                            },
                            decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!
                                    .gradeColumnHeader),
                          ),
                        ),
                        child: Center(
                          child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: lb.grade.isEmpty
                                  ? greyPlaceHolderText
                                  : Text(lb.grade.toString())),
                        ))
                  ]);
                })
              ]);

          final tableActions =
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            ElevatedButton(
                onPressed: () => BlocProvider.of<RemarkCubit>(context)
                    .addGradingTableBound(),
                child: Text(
                    AppLocalizations.of(context)!.newGradingIntervalButton)),
            ElevatedButton(
                onPressed: () => BlocProvider.of<RemarkCubit>(context)
                    .getDefaultGradingTable(),
                child: Text(AppLocalizations.of(context)!
                    .standardGradingIntervalsButton)),
            ElevatedButton(
              onPressed: () =>
                  BlocProvider.of<RemarkCubit>(context).saveGradingTable(),
              child: Text(AppLocalizations.of(context)!.saveButton),
            ),
          ]);
          return Padding(
            padding: const EdgeInsets.all(30.0),
            child: SizedBox(
                width: 600,
                height: 500,
                child: Column(children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      AppLocalizations.of(context)!.gradingTableTitle,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                    ),
                  ),
                  Flexible(child: SingleChildScrollView(child: table)),
                  tableActions
                ])),
          );
        });
  }

// Helper function to show a single highlighted widget in a modal bottom sheet
  _showSingleWidgetBottomSheet(
      {required BuildContext context, required Widget content}) {
    return () => showCupertinoModalBottomSheet(
        context: context,
        builder: (context) => Material(
            child: SizedBox(
                height: 1000,
                child: Center(
                    child: Padding(
                        padding: const EdgeInsets.all(30),
                        child: Column(
                          children: [content],
                        ))))));
  }
}
