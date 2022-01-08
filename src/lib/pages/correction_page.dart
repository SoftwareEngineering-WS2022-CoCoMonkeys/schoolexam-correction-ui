import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schoolexam_correction_ui/blocs/remark/remark.dart';
import 'package:schoolexam_correction_ui/components/correction/correction_overview.dart';
import 'package:schoolexam_correction_ui/components/correction/correction_view.dart';

class CorrectionPage extends StatelessWidget {
  const CorrectionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocBuilder<RemarkCubit, RemarkState>(
          builder: (context, state) => (state.corrections.isEmpty)
              ? const CorrectionOverview()
              : const CorrectionView()),
    );
  }
}
