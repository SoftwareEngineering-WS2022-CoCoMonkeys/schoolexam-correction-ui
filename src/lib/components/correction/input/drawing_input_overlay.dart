import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:schoolexam_correction_ui/components/correction/input/stroke.dart';

typedef PathCallback = void Function(Stroke stroke);

class DrawingInputOverlay extends StatefulWidget {
  final Widget child;
  final PathCallback? callback;
  final StreamController<Stroke> controller;

  const DrawingInputOverlay(
      {Key? key, required this.child, required this.controller, this.callback})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _DrawingInputOverlayState();
}

class _DrawingInputOverlayState extends State<DrawingInputOverlay> {
  Stroke? line;

  void onPanStart(BuildContext context, DragStartDetails details) {
    final box = context.findRenderObject() as RenderBox;
    final offset = box.globalToLocal(details.globalPosition);
    final point = Point(offset.dx, offset.dy);
    final points = [point];

    line = Stroke(points);
    widget.controller.add(line!);
  }

  void onPanUpdate(BuildContext context, DragUpdateDetails details) {
    final box = context.findRenderObject() as RenderBox;
    final offset = box.globalToLocal(details.globalPosition);
    final point = Point(offset.dx, offset.dy);
    final points = [...line!.points, point];

    line = Stroke(points);
    widget.controller.add(line!);
  }

  void onPanEnd(DragEndDetails details) {
    if (widget.callback != null) {
      widget.callback!(line!);
    }
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
      onPanStart: (details) => onPanStart(context, details),
      onPanUpdate: (details) => onPanUpdate(context, details),
      onPanEnd: onPanEnd,
      child: widget.child);
}
