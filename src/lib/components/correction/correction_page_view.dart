import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schoolexam_correction_ui/blocs/overlay/correction_overlay.dart';
import 'package:schoolexam_correction_ui/blocs/overlay/correction_overlay_input.dart';
import 'package:schoolexam_correction_ui/blocs/overlay/correction_overlay_page.dart';
import 'package:schoolexam_correction_ui/blocs/remark/correction.dart';
import 'package:schoolexam_correction_ui/components/correction/input/paths_widget.dart';

import 'input/drawing_input_overlay.dart';
import 'submission_view.dart';

class CorrectionPageView extends StatelessWidget {
  final StreamController<List<CorrectionOverlayInput>> linesController;

  final CorrectionOverlayPage overlay;
  final Correction correction;

  CorrectionPageView(
      {Key? key, required this.correction, required this.overlay})
      : linesController =
            StreamController<List<CorrectionOverlayInput>>.broadcast()
              ..add(overlay.inputs),
        super(key: key);

  Size _getSize(BoxConstraints constraints) {
    final size = Size(
        constraints.maxWidth,
        constraints.maxWidth *
            (overlay.pageSize.height / overlay.pageSize.width));

    log("Determined size ${size.width} ${size.height} from ${overlay.pageSize.height} ${overlay.pageSize.width}");

    return size;
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) =>
          InteractiveViewer(
            child: Stack(
              children: [
                SubmissionView(
                    size: _getSize(constraints), correction: correction),
                _CorrectionPageDrawingView(
                  size: _getSize(constraints),
                  linesController: linesController,
                )
              ],
            ),
          ));
}

class _CorrectionPageDrawingView extends StatelessWidget {
  final Size size;
  final StreamController<List<CorrectionOverlayInput>> linesController;

  const _CorrectionPageDrawingView(
      {Key? key, required this.size, required this.linesController})
      : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<CorrectionOverlayCubit, CorrectionOverlayState>(
          builder: (context, state) {
        switch (state.inputTool) {
          case CorrectionInputTool.pencil:
            return Stack(
              children: [
                PathsWidget(size: size, controller: linesController),
                DrawingInputOverlay(
                  size: size,
                  overlayCubit:
                      BlocProvider.of<CorrectionOverlayCubit>(context),
                  linesController: linesController,
                )
              ],
            );
          default:
            return const Text("Not yet supported!");
        }
      });
}
