import 'dart:async';
import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:schoolexam_correction_ui/blocs/overlay/correction_overlay.dart';
import 'package:schoolexam_correction_ui/components/correction/input/drawing_gesture_recognizer.dart';
import 'package:schoolexam_correction_ui/components/correction/input/stroke.dart';
import 'package:schoolexam_correction_ui/repositories/correction_overlay/correction_overlay.dart';

class DrawingInputOverlay extends StatefulWidget {
  final CorrectionOverlayDocument initialDocument;

  final Size size;
  final StreamController<List<CorrectionOverlayInput>> linesController;
  final StreamController<CorrectionOverlayDocument> documentController;

  const DrawingInputOverlay(
      {Key? key,
      required this.initialDocument,
      required this.documentController,
      required this.size,
      required this.linesController})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _DrawingInputOverlayState();
}

class _DrawingInputOverlayState extends State<DrawingInputOverlay> {
  Stroke? line;

  void _addUpdate(
      BuildContext context, CorrectionOverlayDocument document) async {
    widget.linesController.add(List<CorrectionOverlayInput>.from(
        document.pages[document.pageNumber].inputs)
      ..addAll(BlocProvider.of<CorrectionOverlayCubit>(context)
          .toOverlayInputs(lines: [line!], size: widget.size)));
  }

  void onPanStart(BuildContext context, DragStartDetails details,
      CorrectionOverlayDocument document) {
    final box = context.findRenderObject() as RenderBox;
    final offset = box.globalToLocal(details.globalPosition);
    final point = Point(offset.dx, offset.dy);
    final points = [point];

    log("Starting at : ${point.x}, ${point.y} with ${box.size.width}, ${box.size.height} box size");

    line = Stroke(points);
    _addUpdate(context, document);
  }

  void onPanUpdate(BuildContext context, DragUpdateDetails details,
      CorrectionOverlayDocument document) {
    final box = context.findRenderObject() as RenderBox;
    final offset = box.globalToLocal(details.globalPosition);
    final point = Point(offset.dx, offset.dy);
    final points = [...line!.points, point];

    line = Stroke(points);
    _addUpdate(context, document);
  }

  void onPanEnd(BuildContext context, DragEndDetails details,
      CorrectionOverlayDocument document) {
    // Registering the line with the business logic
    BlocProvider.of<CorrectionOverlayCubit>(context)
        .addDrawing(document: document, lines: [line!], size: widget.size);
  }

  @override
  Widget build(BuildContext context) =>
      StreamBuilder<CorrectionOverlayDocument>(
          initialData: widget.initialDocument,
          stream: widget.documentController.stream,
          builder: (context, snapshot) {
            final document = snapshot.requireData;

            return RawGestureDetector(
              gestures: {
                DrawingGestureRecognizer: GestureRecognizerFactoryWithHandlers<
                        DrawingGestureRecognizer>(
                    () => DrawingGestureRecognizer(),
                    (DrawingGestureRecognizer instance) {
                  instance.onStart = (DragStartDetails details) =>
                      onPanStart(context, details, document);
                  instance.onUpdate = (DragUpdateDetails details) =>
                      onPanUpdate(context, details, document);
                  instance.onEnd = (DragEndDetails details) =>
                      onPanEnd(context, details, document);
                })
              },
              child: Container(
                width: widget.size.width,
                height: widget.size.height,
                color: Colors.transparent,
              ),
            );
          });
}
