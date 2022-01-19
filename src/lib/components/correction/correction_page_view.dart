import 'dart:async';
import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schoolexam_correction_ui/blocs/overlay/correction_overlay.dart';
import 'package:schoolexam_correction_ui/blocs/remarks/correction.dart';
import 'package:schoolexam_correction_ui/components/correction/input/eraser_input_overlay.dart';
import 'package:schoolexam_correction_ui/components/correction/input/paths_absolute_widget.dart';
import 'package:schoolexam_correction_ui/components/correction/input/paths_widget.dart';
import 'package:schoolexam_correction_ui/components/correction/remarks/task_remark_widget.dart';
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
  StreamController<CorrectionOverlayAbsoluteInput>? lineController;

  @override
  void initState() {
    linesController =
        StreamController<List<CorrectionOverlayInput>>.broadcast();
    lineController =
        StreamController<CorrectionOverlayAbsoluteInput>.broadcast();
    super.initState();
  }

  Size _getPDFSize(
      {required BoxConstraints constraints,
      required CorrectionOverlayPage page}) {
    // Take up 85% of the allowed space
    final pdfWidth = constraints.maxWidth * 0.85;
    final pdfHeight = constraints.maxHeight * 0.85;

    final byWidth =
        Size(pdfWidth, pdfWidth * (page.pageSize.height / page.pageSize.width));
    final byHeight = Size(
        pdfHeight * (page.pageSize.width / page.pageSize.height), pdfHeight);

    final size = (byWidth.height > constraints.maxHeight) ? byHeight : byWidth;
    log("Determined size ${size.width} ${size.height} from ${page.pageSize.height} ${page.pageSize.width}");
    return size;
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return BlocConsumer<CorrectionOverlayCubit, CorrectionOverlayState>(
            builder: (context, state) {
              final document = state.getCurrent(widget.initial);

              if (document.pages.isEmpty) {
                return const CircularProgressIndicator();
              }

              final page = document.pages[document.pageNumber];
              final size = _getPDFSize(constraints: constraints, page: page);

              return Row(children: [
                SizedBox(
                  width: (constraints.maxWidth - size.width),
                  height: size.height,
                  child: BlocBuilder<CorrectionOverlayCubit,
                      CorrectionOverlayState>(builder: (context, state) {
                    final document = state.getCurrent(widget.initial);
                    return Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: widget.initial.submission.answers
                            .where((element) => element.segments.any(
                                (element) =>
                                    document.pageNumber >= element.start.page &&
                                    document.pageNumber <= element.end.page))
                            .map((e) => AnswerRemarkWidget(
                                task: e.task, initial: widget.initial))
                            .toList());
                  }),
                ),

                /// The [EagerGestureRecognizer] prevents the [InteractiveViewer] of reacting to unwanted device kinds.
                RawGestureDetector(
                  gestures: <Type, GestureRecognizerFactory>{
                    EagerGestureRecognizer:
                        GestureRecognizerFactoryWithHandlers<
                            EagerGestureRecognizer>(
                      () => EagerGestureRecognizer(supportedDevices: {
                        PointerDeviceKind.stylus,
                        PointerDeviceKind.mouse
                      }),
                      (EagerGestureRecognizer instance) {},
                    ),
                  },
                  child: InteractiveViewer(
                    child: Stack(
                      children: [
                        SubmissionView(
                          initial: widget.initial,
                          size: size,
                        ),
                        Stack(
                          children: [
                            PathsWidget(
                                initialData:
                                    document.pages[document.pageNumber].inputs,
                                size: size,
                                controller: linesController!),
                            if (state.inputTool == CorrectionInputTool.pencil ||
                                state.inputTool ==
                                    CorrectionInputTool.marker) ...{
                              PathsAbsoluteWidget(
                                controller: lineController!,
                                size: size,
                              ),
                              DrawingInputOverlay(
                                  size: size,
                                  lineController: lineController!,
                                  initial: widget.initial),
                            },
                            if (state.inputTool == CorrectionInputTool.eraser)
                              EraserInputOverlay(
                                  size: size,
                                  linesController: linesController!,
                                  initial: widget.initial)
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ]);
            },
            listenWhen: (old, current) => current is LoadedOverlayState,
            listener: (context, state) {
              final document = state.getCurrent(widget.initial);

              if (document.pages.isEmpty) {
                return;
              }

              linesController!.add(document.pages[document.pageNumber].inputs);
            });
      });

  @override
  Future<void> dispose() async {
    super.dispose();
    if (linesController != null) {
      await linesController!.close();
    }
  }
}
