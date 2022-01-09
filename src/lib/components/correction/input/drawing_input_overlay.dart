import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:schoolexam_correction_ui/blocs/overlay/overlay.dart';
import 'package:schoolexam_correction_ui/blocs/overlay/overlay_input.dart';
import 'package:schoolexam_correction_ui/components/correction/input/stroke.dart';

class DrawingInputOverlay extends StatefulWidget {
  final OverlayCubit overlayCubit;
  final StreamController<List<OverlayInput>> linesController;

  final Widget child;

  const DrawingInputOverlay(
      {Key? key,
      required this.overlayCubit,
      required this.linesController,
      required this.child})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _DrawingInputOverlayState();
}

class _DrawingInputOverlayState extends State<DrawingInputOverlay> {
  Stroke? line;

  void _addUpdate() {
    widget.linesController.add(
        List<OverlayInput>.from(widget.overlayCubit.state.current.inputs)
          ..addAll(widget.overlayCubit.toOverlayInputs(lines: [line!])));
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
    widget.overlayCubit.addDrawing(lines: [line!]);
  }

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.green.withOpacity(0.25),
        child: GestureDetector(
            onPanStart: (details) => onPanStart(context, details),
            onPanUpdate: (details) => onPanUpdate(context, details),
            onPanEnd: onPanEnd,
            child: widget.child),
      );
}
