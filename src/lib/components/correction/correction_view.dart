import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schoolexam_correction_ui/blocs/remark/remark.dart';
import 'package:schoolexam_correction_ui/components/correction/input/input_box.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

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
                      _PDFView(),
                      const InputBox(),
                    ],
                  )),
            )
          ],
        );
      });
}

class _PDFView extends StatelessWidget {
  @override
  Widget build(BuildContext context) => BlocBuilder<RemarkCubit, RemarkState>(
        buildWhen: (previous, current) => current is UpdatedRemarks,
        builder: (context, state) {
          dev.log("Rebuilding PDF for state of type ${state.runtimeType}");
          return SfPdfViewer.memory(
            state.corrections[state.selectedCorrection].correction,
            onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
              AlertDialog(
                title: Text(details.error),
                content: Text(details.description),
                actions: <Widget>[
                  FlatButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
      );
}
