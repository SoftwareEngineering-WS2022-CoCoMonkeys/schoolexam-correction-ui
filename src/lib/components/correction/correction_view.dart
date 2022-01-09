import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:schoolexam_correction_ui/blocs/remark/correction.dart';
import 'package:schoolexam_correction_ui/blocs/remark/remark.dart';
import 'package:schoolexam_correction_ui/components/correction/input/input_box.dart';
import 'correction_input_header.dart';

/// Given, that at least one correction is currently active, this view is used for correcting.
class CorrectionView extends StatelessWidget {
  const CorrectionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<RemarkCubit, RemarkState>(builder: (context, state) {
        if (state.corrections.isEmpty) {
          return const Text("ERROR");
        }

        return Column(
          children: [
            const CorrectionInputHeader(),
            Container(
              color: null,
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7),
              child: AspectRatio(
                  aspectRatio: 1 / sqrt(2),
                  child: Stack(
                    children: [
                      // TODO : TabView
                      InputBox(
                        child: _PDFView(
                            correction:
                                state.corrections[state.selectedCorrection]),
                      ),
                    ],
                  )),
            )
          ],
        );
      });
}

class _PDFView extends StatelessWidget {
  final Correction correction;

  const _PDFView({Key? key, required this.correction}) : super(key: key);

  @override
  Widget build(BuildContext context) => PDFView(
      pdfData: correction.correction,
      autoSpacing: false,
      onError: (error) {
        dev.log(error.toString());
      },
      onPageError: (page, error) {
        dev.log('$page: ${error.toString()}');
      },
      onRender: (_pages) {
        dev.log("Successfully rendered the pdf view.");
      },
      onViewCreated: (PDFViewController pdfViewController) {
        dev.log("Successfully created the pdf view.");
      });
}
