import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GradingTableHeader extends TableRow {
  static const headerTextStyle = TextStyle(fontWeight: FontWeight.bold);

  GradingTableHeader({required BuildContext context})
      : super(children: [
          // empty header for icon button
          const Text(""),
          Center(
              child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Text(AppLocalizations.of(context)!.gradingIntervalStart,
                    style: headerTextStyle),
                Text("% | ${AppLocalizations.of(context)!.points}",
                    style: const TextStyle(color: Colors.grey))
              ],
            ),
          )),
          Center(
              child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(children: [
                  Text(AppLocalizations.of(context)!.gradingIntervalEnd,
                      style: headerTextStyle),
                  Text("% | ${AppLocalizations.of(context)!.points}",
                      style: const TextStyle(color: Colors.grey))
                ]),
                const Icon(Icons.edit_outlined)
              ],
            ),
          )),
          Center(
              child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(AppLocalizations.of(context)!.grade,
                      style: headerTextStyle),
                  const Icon(Icons.edit_outlined)
                ]),
          )),
        ]);
}
