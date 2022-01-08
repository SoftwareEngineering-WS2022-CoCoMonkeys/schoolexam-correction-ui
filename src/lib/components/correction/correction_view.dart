import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:native_pdf_view/native_pdf_view.dart';
import 'package:schoolexam_correction_ui/blocs/remark/remark.dart';
import 'package:schoolexam_correction_ui/components/correction/input/input_box.dart';

import 'correction_input_header.dart';
import 'drawing_page.dart';

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
                    children: const [
                      _PDFView(),
                      InputBox(),
                    ],
                  )),
            )
          ],
        );
      });
}

class _PDFView extends StatelessWidget {
  const _PDFView();

  @override
  Widget build(BuildContext context) => BlocBuilder<RemarkCubit, RemarkState>(
        buildWhen: (previous, current) {
          var condition =
              previous.selectedCorrection != current.selectedCorrection;

          if (condition) {
            dev.log(
                "Rebuilding PDF view, as correction changed from ${previous.selectedCorrection} to ${current.selectedCorrection}");
          }

          return condition;
        },
        builder: (context, state) {
          final _controller = PdfController(
            document: PdfDocument.openFile(
                state.corrections[state.selectedCorrection].correctionPath),
            initialPage: 1,
          );

          return PdfView(
              documentLoader: const Center(
                child: CircularProgressIndicator(),
              ),
              controller: _controller,
              onDocumentLoaded: (document) {},
              onPageChanged: (page) {});
        },
      );
}
