import 'dart:async';
import 'dart:developer';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:schoolexam_correction_ui/blocs/overlay/correction_overlay.dart';
import 'package:schoolexam_correction_ui/blocs/overlay/correction_overlay_input.dart';
import 'package:schoolexam_correction_ui/components/correction/input/drawing_gesture_recognizer.dart';
import 'package:schoolexam_correction_ui/components/correction/input/stroke.dart';

class DrawingInputOverlay extends StatefulWidget {
  final Size size;
  final CorrectionOverlayCubit overlayCubit;
  final StreamController<List<CorrectionOverlayInput>> linesController;

  const DrawingInputOverlay(
      {Key? key,
      required this.size,
      required this.overlayCubit,
      required this.linesController})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _DrawingInputOverlayState();
}

class _DrawingInputOverlayState extends State<DrawingInputOverlay> {
  Stroke? line;

  void _addUpdate() {
    widget.linesController.add(List<CorrectionOverlayInput>.from(
        widget.overlayCubit.state.current.inputs)
      ..addAll(widget.overlayCubit
          .toOverlayInputs(lines: [line!], size: widget.size)));
  }

  void onPanStart(BuildContext context, DragStartDetails details) {
    final box = context.findRenderObject() as RenderBox;
    final offset = box.globalToLocal(details.globalPosition);
    final point = Point(offset.dx, offset.dy);
    final points = [point];

    log("Starting at : ${point.x}, ${point.y} with ${box.size.width}, ${box.size.height} box size");

    line = Stroke(points);
    _addUpdate();
  }

  void onPanUpdate(BuildContext context, DragUpdateDetails details) {
    final box = context.findRenderObject() as RenderBox;
    final offset = box.globalToLocal(details.globalPosition);
    final point = Point(offset.dx, offset.dy);
    final points = [...line!.points, point];

    line = Stroke(points);
    _addUpdate();
  }

  void onPanEnd(DragEndDetails details) {
    // Registering the line with the business logic
    widget.overlayCubit.addDrawing(lines: [line!], size: widget.size);
  }

  @override
  Widget build(BuildContext context) => RawGestureDetector(
        gestures: {
          DrawingGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<DrawingGestureRecognizer>(
                  () => DrawingGestureRecognizer(),
                  (DrawingGestureRecognizer instance) {
            instance.onStart =
                (DragStartDetails details) => onPanStart(context, details);
            instance.onUpdate =
                (DragUpdateDetails details) => onPanUpdate(context, details);
            instance.onEnd = onPanEnd;
          })
        },
        child: Container(
          width: widget.size.width,
          height: widget.size.height,
          color: Colors.transparent,
        ),
      );
}
