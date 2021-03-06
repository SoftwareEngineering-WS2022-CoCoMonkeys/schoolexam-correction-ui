import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:schoolexam_correction_ui/blocs/overlay/correction_overlay.dart';
import 'package:schoolexam_correction_ui/blocs/remarks/remarks.dart';
import 'package:schoolexam_correction_ui/repositories/correction_overlay/correction_overlay.dart';

/// Renders the submission PDF included within [correction].
/// Importantly, this is basically just a read-only view, as the correction annotations are not persisted within the PDF.
class SubmissionView extends StatefulWidget {
  final Size size;
  final Correction initial;

  const SubmissionView({Key? key, required this.initial, required this.size})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => SubmissionViewState();
}

class SubmissionViewState extends State<SubmissionView> {
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();

  void _onDocumentChange(CorrectionOverlayDocument document) async {
    final controller = await _controller.future;

    final int? currentPage = await controller.getCurrentPage();

    log("Requested page number is ${document.pageNumber}");
    if (currentPage == null || currentPage != document.pageNumber) {
      log("Jumping to ${document.pageNumber} in PDF.");
      await controller.setPage(document.pageNumber);
    }
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<CorrectionOverlayCubit,
          CorrectionOverlayState>(
      // Only reload when we changed the navigation
      // TODO : Mark changed document
      listenWhen: (old, current) => current is UpdatedNavigationState,
      listener: (context, state) =>
          _onDocumentChange(state.getCurrent(widget.initial)),
      buildWhen: (old, current) => false,
      builder: (context, state) {
        final document = state.getCurrent(widget.initial);

        return BlocBuilder<RemarksCubit, RemarksState>(
            // We never need to rebuild
            buildWhen: (old, current) => false,
            builder: (context, state) {
              if (state is! RemarksCorrectionInProgress) {
                return Container();
              }

              return SizedBox(
                width: widget.size.width,
                height: widget.size.height,
                child: PDFView(
                    defaultPage: document.pageNumber,
                    pageFling: false,
                    pageSnap: false,
                    enableSwipe: false,
                    preventLinkNavigation: true,
                    fitPolicy: FitPolicy.BOTH,
                    // If you want to test the merging, regularly merge using the remarkCubit.
                    // Then you can provide key: UniqueKey() to this view and use correction.correctionData as pdfData
                    // key : UniqueKey(),
                    // pdfData: widget.correction.correctionData,
                    pdfData: state.getCurrent(widget.initial).submissionData,
                    autoSpacing: false,
                    onError: (error) {
                      log(error.toString());
                    },
                    onPageError: (page, error) {
                      log('$page: ${error.toString()}');
                    },
                    onRender: (_pages) {
                      log("Successfully rendered the pdf view.");
                    },
                    onViewCreated: (PDFViewController pdfViewController) {
                      log("Successfully created the pdf view.");
                      _controller.complete(pdfViewController);
                    }),
              );
            });
      });
}
