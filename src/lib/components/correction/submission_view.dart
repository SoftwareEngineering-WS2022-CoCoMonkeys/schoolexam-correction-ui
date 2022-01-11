import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:schoolexam_correction_ui/blocs/remark/correction.dart';

/// Renders the submission PDF included within [correction].
/// Importantly, this is basically just a read-only view, as the correction annotations are not persisted within the PDF.
class SubmissionView extends StatelessWidget {
  final Size size;
  final Correction correction;

  const SubmissionView({Key? key, required this.size, required this.correction})
      : super(key: key);

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size.width,
        height: size.height,
        child: PDFView(
            defaultPage: correction.pageNumber,
            pageFling: false,
            pageSnap: false,
            enableSwipe: false,
            preventLinkNavigation: true,
            fitPolicy: FitPolicy.BOTH,
            // If you want to test the merging, regularly merge using the remarkCubit.
            // Then you can provide key: UniqueKey() to this view and use correction.correctionData as pdfData
            // key : UniqueKey(),
            // pdfData: correction.correctionData,
            pdfData: correction.submissionData,
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
            }),
      );
}
