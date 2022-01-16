import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schoolexam_correction_ui/blocs/overlay/correction_overlay.dart';
import 'package:schoolexam_correction_ui/blocs/remark/correction.dart';
import 'package:schoolexam_correction_ui/repositories/correction_overlay/correction_overlay.dart';

import 'drawing_gesture_recognizer.dart';
import 'input_options.dart';

class EraserInputOverlay extends StatefulWidget {
  final Size size;
  final Correction initial;
  final StreamController<List<CorrectionOverlayInput>> linesController;

  const EraserInputOverlay(
      {Key? key,
      required this.size,
      required this.initial,
      required this.linesController})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _EraserInputOverlayState();
}

class _EraserInputOverlayState extends State<EraserInputOverlay> {
  Future<void> _erase(
      {required InputOptions options,
      required CorrectionOverlayDocument document,
      required Offset point,
      required List<CorrectionOverlayInput> inputs}) async {
    final toDelete = <int>[];

    final path = Path();
    path.addOval(Rect.fromCircle(center: point, radius: options.size * 1.0));
    final bounds = path.getBounds();

    for (int i = 0; i < inputs.length; i++) {
      final kill = inputs[i].points.any((e) {
        final p = e.toAbsolutePoint(size: widget.size);
        return bounds.contains(Offset(p.x, p.y));
      });

      if (kill) {
        toDelete.add(i);
      }
    }

    if (toDelete.isEmpty) {
      return;
    }

    final lines = List<CorrectionOverlayInput>.from(inputs);
    final initialLength = lines.length;

    for (int i = toDelete.length - 1; i >= 0; i--) {
      if (lines.length > toDelete[i]) {
        lines.removeAt(toDelete[i]);
      }
    }

    if (initialLength != lines.length) {
      widget.linesController.add(lines);
    }
  }

  void onPointerDown(
      {required InputOptions options,
      required BuildContext context,
      required CorrectionOverlayDocument document,
      required List<CorrectionOverlayInput> inputs,
      required PointerDownEvent details}) async {
    if (details.kind != PointerDeviceKind.stylus &&
        details.kind != PointerDeviceKind.mouse) {
      return;
    }

    final offset = details.localPosition;
    final point = Offset(offset.dx, offset.dy);

    await _erase(
        options: options, document: document, point: point, inputs: inputs);
  }

  void onPointerMove(
      {required InputOptions options,
      required BuildContext context,
      required CorrectionOverlayDocument document,
      required List<CorrectionOverlayInput> inputs,
      required PointerMoveEvent details}) async {
    if (details.kind != PointerDeviceKind.stylus &&
        details.kind != PointerDeviceKind.mouse) {
      return;
    }

    final offset = details.localPosition;
    final point = Offset(offset.dx, offset.dy);

    await _erase(
        options: options, document: document, point: point, inputs: inputs);
  }

  void onPointerUp(
      {required BuildContext context,
      required CorrectionOverlayDocument document,
      required List<CorrectionOverlayInput> inputs}) {
    BlocProvider.of<CorrectionOverlayCubit>(context)
        .replaceDrawings(document: document, inputs: inputs);
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<CorrectionOverlayCubit, CorrectionOverlayState>(
          builder: (context, state) {
        final document = state.getCurrent(widget.initial);

        return StreamBuilder<List<CorrectionOverlayInput>>(
            initialData: document.pages[document.pageNumber].inputs,
            stream: widget.linesController.stream,
            builder: (context, snapshot) =>
                BlocBuilder<CorrectionOverlayCubit, CorrectionOverlayState>(
                    builder: (context, state) {
                  return Listener(
                    onPointerDown: (details) => onPointerDown(
                        options: state.eraserOptions,
                        context: context,
                        document: document,
                        details: details,
                        inputs: snapshot.requireData),
                    onPointerMove: (details) => onPointerMove(
                        options: state.eraserOptions,
                        context: context,
                        document: document,
                        details: details,
                        inputs: snapshot.requireData),
                    onPointerUp: (details) => onPointerUp(
                        context: context,
                        document: document,
                        inputs: snapshot.requireData),
                    child: Container(
                      width: widget.size.width,
                      height: widget.size.height,
                      color: Colors.transparent,
                    ),
                  );
                }));
      });
}
