import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schoolexam_correction_ui/blocs/overlay/correction_overlay.dart';
import 'package:schoolexam_correction_ui/blocs/remark/correction.dart';
import 'package:schoolexam_correction_ui/components/correction/input/eraser_input_overlay.dart';
import 'package:schoolexam_correction_ui/components/correction/input/paths_widget.dart';
import 'package:schoolexam_correction_ui/repositories/correction_overlay/correction_overlay.dart';

import 'input/drawing_input_overlay.dart';
import 'submission_view.dart';

class CorrectionPageView extends StatefulWidget {
  final Correction initial;

  const CorrectionPageView({Key? key, required this.initial}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CorrectionPageViewState();
}

class _CorrectionPageViewState extends State<CorrectionPageView> {
  StreamController<List<CorrectionOverlayInput>>? linesController;

  @override
  void initState() {
    linesController =
        StreamController<List<CorrectionOverlayInput>>.broadcast();
    super.initState();
  }

  Size _getSize(BoxConstraints constraints, CorrectionOverlayPage page) {
    final size = Size(constraints.maxWidth,
        constraints.maxWidth * (page.pageSize.height / page.pageSize.width));

    log("Determined size ${size.width} ${size.height} from ${page.pageSize.height} ${page.pageSize.width}");

    return size;
  }

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<CorrectionOverlayCubit, CorrectionOverlayState>(
          builder: (context, state) {
        final document = state.getCurrent(widget.initial);

        return LayoutBuilder(builder: (context, constraints) {
          if (document.pages.isEmpty) {
            return const CircularProgressIndicator();
          }

          final size =
              _getSize(constraints, document.pages[document.pageNumber]);

          return InteractiveViewer(
            child: Stack(
              children: [
                SubmissionView(
                  initial: widget.initial,
                  size: size,
                ),
                Stack(
                  children: [
                    PathsWidget(
                        initialData: document.pages[document.pageNumber].inputs,
                        size: size,
                        controller: linesController!),
                    if (state.inputTool == CorrectionInputTool.pencil ||
                        state.inputTool == CorrectionInputTool.marker)
                      DrawingInputOverlay(
                          size: size,
                          linesController: linesController!,
                          initial: widget.initial),
                    if (state.inputTool == CorrectionInputTool.eraser)
                      EraserInputOverlay(
                          size: size,
                          linesController: linesController!,
                          initial: widget.initial)
                  ],
                )
              ],
            ),
          );
        });
      }, listener: (context, state) {
        final document = state.getCurrent(widget.initial);
        linesController!.add(document.pages[document.pageNumber].inputs);
      });

  @override
  Future<void> dispose() async {
    super.dispose();
    if (linesController != null) {
      await linesController!.close();
    }
  }
}
