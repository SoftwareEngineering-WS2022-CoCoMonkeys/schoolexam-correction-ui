import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:schoolexam_correction_ui/blocs/remark/remark_bloc.dart';

class GradingTableActionBar extends StatelessWidget {
  const GradingTableActionBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      ElevatedButton(
          onPressed: () =>
              BlocProvider.of<RemarkCubit>(context).addGradingTableBound(),
          child: Text(AppLocalizations.of(context)!.newGradingIntervalButton)),
      DropdownButton<String>(
        icon: const Icon(Icons.arrow_downward),
        elevation: 16,
        onChanged: (scheme) {
          if (scheme == AppLocalizations.of(context)!.oneToSixGradingScheme) {
            BlocProvider.of<RemarkCubit>(context)
                .getDefaultGradingTable(low: 1, high: 6);
          } else if (scheme ==
              AppLocalizations.of(context)!.zeroToFifteenGradingScheme) {
            BlocProvider.of<RemarkCubit>(context)
                .getDefaultGradingTable(low: 0, high: 15);
          }
        },
        value: AppLocalizations.of(context)!.defaultGradingSchemeButton,
        items: <String>[
          AppLocalizations.of(context)!.defaultGradingSchemeButton,
          AppLocalizations.of(context)!.oneToSixGradingScheme,
          AppLocalizations.of(context)!.zeroToFifteenGradingScheme,
        ].map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
      ElevatedButton(
        onPressed: () =>
            BlocProvider.of<RemarkCubit>(context).saveGradingTable(),
        child: Text(AppLocalizations.of(context)!.save),
      ),
    ]);
  }
}
