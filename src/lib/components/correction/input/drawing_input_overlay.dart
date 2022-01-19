import 'dart:async';
import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:schoolexam_correction_ui/blocs/overlay/correction_overlay.dart';
import 'package:schoolexam_correction_ui/blocs/remarks/correction.dart';
import 'package:schoolexam_correction_ui/components/correction/input/stroke.dart';
import 'package:schoolexam_correction_ui/repositories/correction_overlay/correction_overlay.dart';

class DrawingInputOverlay extends StatefulWidget {
  final Correction initial;
  final Size size;
  final StreamController<CorrectionOverlayAbsoluteInput> lineController;

  const DrawingInputOverlay(
      {Key? key,
      required this.initial,
      required this.size,
      required this.lineController})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _DrawingInputOverlayState();
}

class _DrawingInputOverlayState extends State<DrawingInputOverlay> {
  Stroke? line;
  CorrectionOverlayCubit? cubit;

  @override
  void initState() {
    cubit = BlocProvider.of<CorrectionOverlayCubit>(context);
    super.initState();
  }

  void onPointerDown(PointerDownEvent details) {
    if (details.kind != PointerDeviceKind.stylus &&
        details.kind != PointerDeviceKind.mouse) {
      return;
    }

    final offset = details.localPosition;
    final point = Point(offset.dx, offset.dy, details.pressure);
    final points = [point];

    log("Starting at : ${point.x}, ${point.y} ");

    line = Stroke(points);
    final input = cubit!.convertStroke(line: line!);
    widget.lineController.add(input);
  }

  void onPointerMove(PointerMoveEvent details) {
    if (details.kind != PointerDeviceKind.stylus &&
        details.kind != PointerDeviceKind.mouse) {
      return;
    }

    // This should in theory never trigger.
    if (line == null) {
      return;
    }

    final offset = details.localPosition;
    final point = Point(offset.dx, offset.dy, details.pressure);
    final points = [...line!.points, point];

    line = Stroke(points);
    final input = cubit!.convertStroke(line: line!);
    widget.lineController.add(input);
  }

  void onPointerUp(BuildContext context, PointerUpEvent details,
      CorrectionOverlayDocument document) {
    if (details.kind != PointerDeviceKind.stylus &&
        details.kind != PointerDeviceKind.mouse) {
      return;
    }

    // This should in theory never trigger.
    if (line == null) {
      return;
    }

    // Registering the line with the business logic
    BlocProvider.of<CorrectionOverlayCubit>(context)
        .addDrawing(document: document, lines: [line!], size: widget.size);
    widget.lineController.add(const CorrectionOverlayAbsoluteInput(
        color: Colors.transparent, points: []));
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<CorrectionOverlayCubit, CorrectionOverlayState>(
          builder: (context, state) {
        final document = state.getCurrent(widget.initial);

        return Listener(
          onPointerDown: (details) => onPointerDown(details),
          onPointerMove: (details) => onPointerMove(details),
          onPointerUp: (details) => onPointerUp(context, details, document),
          child: Container(
            width: widget.size.width,
            height: widget.size.height,
            color: Colors.transparent,
          ),
        );
      });
}
