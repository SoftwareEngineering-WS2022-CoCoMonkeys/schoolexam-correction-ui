import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:schoolexam_correction_ui/repositories/correction_overlay/correction_overlay.dart';
import 'package:schoolexam_correction_ui/blocs/remark/correction.dart';

/// Renders the submission PDF included within [correction].
/// Importantly, this is basically just a read-only view, as the correction annotations are not persisted within the PDF.
class SubmissionView extends StatefulWidget {
  final Size size;
  final Correction correction;

  final CorrectionOverlayDocument initialDocument;
  final StreamController<CorrectionOverlayDocument> documentController;

  const SubmissionView(
      {Key? key,
      required this.initialDocument,
      required this.documentController,
      required this.size,
      required this.correction})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => SubmissionViewState();
}

class SubmissionViewState extends State<SubmissionView> {
  StreamSubscription? _documentSubscription;
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();

  @override
  void initState() {
    _documentSubscription =
        widget.documentController.stream.listen(_onDocumentChange);
    super.initState();
  }

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
  Widget build(BuildContext context) => SizedBox(
        width: widget.size.width,
        height: widget.size.height,
        child: PDFView(
            defaultPage: widget.initialDocument.pageNumber,
            pageFling: false,
            pageSnap: false,
            enableSwipe: false,
            preventLinkNavigation: true,
            fitPolicy: FitPolicy.BOTH,
            // If you want to test the merging, regularly merge using the remarkCubit.
            // Then you can provide key: UniqueKey() to this view and use correction.correctionData as pdfData
            // key : UniqueKey(),
            // pdfData: widget.correction.correctionData,
            pdfData: widget.correction.submissionData,
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

  @override
  Future<void> dispose() async {
    super.dispose();
    if (_documentSubscription != null) {
      await _documentSubscription!.cancel();
    }
  }
}
