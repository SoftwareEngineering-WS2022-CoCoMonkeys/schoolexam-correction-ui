import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schoolexam_correction_ui/blocs/overlay/correction_overlay.dart';
import 'package:schoolexam_correction_ui/repositories/correction_overlay/correction_overlay.dart';
import 'package:schoolexam_correction_ui/blocs/remark/correction.dart';
import 'package:schoolexam_correction_ui/components/correction/input/paths_widget.dart';

import 'input/drawing_input_overlay.dart';
import 'submission_view.dart';

class CorrectionPageView extends StatefulWidget {
  final StreamController<List<CorrectionOverlayInput>> linesController;

  final CorrectionOverlayDocument initialDocument;
  final StreamController<CorrectionOverlayDocument> documentController;

  final Correction correction;

  CorrectionPageView(
      {Key? key,
      required this.correction,
      required this.initialDocument,
      required this.documentController})
      : linesController =
            StreamController<List<CorrectionOverlayInput>>.broadcast(),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _CorrectionPageViewState();
}

class _CorrectionPageViewState extends State<CorrectionPageView> {
  StreamSubscription? _documentSubscription;

  @override
  void initState() {
    _documentSubscription =
        widget.documentController.stream.listen(_onDocumentChange);
    super.initState();
  }

  void _onDocumentChange(CorrectionOverlayDocument document) =>
      widget.linesController.add(document.pages[document.pageNumber].inputs);

  Size _getSize(BoxConstraints constraints, CorrectionOverlayPage page) {
    final size = Size(constraints.maxWidth,
        constraints.maxWidth * (page.pageSize.height / page.pageSize.width));

    log("Determined size ${size.width} ${size.height} from ${page.pageSize.height} ${page.pageSize.width}");

    return size;
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<
          CorrectionOverlayDocument>(
      stream: widget.documentController.stream,
      initialData: widget.initialDocument,
      builder: (context, snapshot) => LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) =>
              InteractiveViewer(
                child: (snapshot.requireData.pages.isEmpty)
                    ? const CircularProgressIndicator()
                    : Stack(
                        children: [
                          SubmissionView(
                              documentController: widget.documentController,
                              initialDocument: widget.initialDocument,
                              size: _getSize(
                                  constraints,
                                  snapshot.requireData
                                      .pages[snapshot.requireData.pageNumber]),
                              correction: widget.correction),
                          _CorrectionPageDrawingView(
                            document: snapshot.requireData,
                            size: _getSize(
                                constraints,
                                snapshot.requireData
                                    .pages[snapshot.requireData.pageNumber]),
                            linesController: widget.linesController,
                            documentController: widget.documentController,
                          )
                        ],
                      ),
              )));

  @override
  Future<void> dispose() async {
    super.dispose();
    if (_documentSubscription != null) {
      await _documentSubscription!.cancel();
    }
  }
}

class _CorrectionPageDrawingView extends StatelessWidget {
  final CorrectionOverlayDocument document;
  final Size size;

  // Streams allow to efficiently update downstream children without e.g. duplicating retrieval logic
  final StreamController<List<CorrectionOverlayInput>> linesController;
  final StreamController<CorrectionOverlayDocument> documentController;

  const _CorrectionPageDrawingView(
      {Key? key,
      required this.document,
      required this.size,
      required this.linesController,
      required this.documentController})
      : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<CorrectionOverlayCubit, CorrectionOverlayState>(
          builder: (context, state) {
        switch (state.inputTool) {
          case CorrectionInputTool.pencil:
            return Stack(
              children: [
                PathsWidget(
                    initialData: document.pages[document.pageNumber].inputs,
                    size: size,
                    controller: linesController),
                DrawingInputOverlay(
                  size: size,
                  linesController: linesController,
                  documentController: documentController,
                  initialDocument: document,
                )
              ],
            );
          default:
            return const Text("Not yet supported!");
        }
      });
}
