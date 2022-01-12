import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schoolexam_correction_ui/blocs/overlay/correction_overlay.dart';
import 'package:schoolexam_correction_ui/blocs/remark/correction.dart';
import 'package:schoolexam_correction_ui/components/correction/correction_page_view.dart';
import 'package:schoolexam_correction_ui/repositories/correction_overlay/correction_overlay.dart';

import 'correction_page_navigation.dart';

class CorrectionTabView extends StatelessWidget {
  final Correction correction;

  final StreamController<CorrectionOverlayDocument> documentController;

  CorrectionTabView({Key? key, required this.correction})
      : documentController =
            StreamController<CorrectionOverlayDocument>.broadcast(),
        super(key: key);

  void _update(CorrectionOverlayState state) {
    final document = _getDocument(state);

    if (document.isEmpty) {
      log("Ignoring state change, as viewed correction is not found within it.");
      return;
    }

    log("Updating document");

    documentController.add(document);
  }

  CorrectionOverlayDocument _getDocument(CorrectionOverlayState state) =>
      state.overlays.firstWhere(
          (element) => element.submissionId == correction.submission.id,
          orElse: () => CorrectionOverlayDocument.empty);

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<CorrectionOverlayCubit, CorrectionOverlayState>(
          listener: (context, state) => _update(state),
          builder: (context, state) => StreamBuilder<CorrectionOverlayDocument>(
              stream: documentController.stream,
              initialData: _getDocument(state),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                return Column(
                  children: [
                    Container(
                      color: null,
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7),
                      child: CorrectionPageView(
                        correction: correction,
                        initialDocument: snapshot.requireData,
                        documentController: documentController,
                      ),
                    ),
                    CorrectionPageNavigation(
                      document: snapshot.requireData,
                    )
                  ],
                );
              }));
}
