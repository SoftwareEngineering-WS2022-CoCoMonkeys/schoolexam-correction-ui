import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schoolexam_correction_ui/blocs/overlay/correction_overlay.dart';
import 'package:schoolexam_correction_ui/repositories/correction_overlay/correction_overlay.dart';

import 'drawing_gesture_recognizer.dart';
import 'input_options.dart';

class EraserInputOverlay extends StatefulWidget {
  final Size size;
  final CorrectionOverlayDocument initialDocument;

  final StreamController<List<CorrectionOverlayInput>> linesController;
  final StreamController<CorrectionOverlayDocument> documentController;

  const EraserInputOverlay(
      {Key? key,
      required this.size,
      required this.initialDocument,
      required this.documentController,
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

  Future<void> onPanStart(
      {required InputOptions options,
      required BuildContext context,
      required CorrectionOverlayDocument document,
      required List<CorrectionOverlayInput> inputs,
      required DragStartDetails details}) async {
    final box = context.findRenderObject() as RenderBox;
    final offset = box.globalToLocal(details.globalPosition);
    final point = Offset(offset.dx, offset.dy);

    await _erase(
        options: options, document: document, point: point, inputs: inputs);
  }

  Future<void> onPanUpdate(
      {required InputOptions options,
      required BuildContext context,
      required CorrectionOverlayDocument document,
      required List<CorrectionOverlayInput> inputs,
      required DragUpdateDetails details}) async {
    final box = context.findRenderObject() as RenderBox;
    final offset = box.globalToLocal(details.globalPosition);
    final point = Offset(offset.dx, offset.dy);

    await _erase(
        options: options, document: document, point: point, inputs: inputs);
  }

  Future<void> onPanEnd(
      {required BuildContext context,
      required CorrectionOverlayDocument document,
      required List<CorrectionOverlayInput> inputs}) async {
    BlocProvider.of<CorrectionOverlayCubit>(context)
        .replaceDrawings(document: document, inputs: inputs);
  }

  @override
  Widget build(BuildContext context) =>
      StreamBuilder<CorrectionOverlayDocument>(
          initialData: widget.initialDocument,
          stream: widget.documentController.stream,
          builder: (context, snapshot) {
            final document = snapshot.requireData;
            return StreamBuilder<List<CorrectionOverlayInput>>(
                initialData: document.pages[document.pageNumber].inputs,
                stream: widget.linesController.stream,
                builder: (context, snapshot) =>
                    BlocBuilder<CorrectionOverlayCubit, CorrectionOverlayState>(
                        builder: (context, state) {
                      return RawGestureDetector(
                        gestures: {
                          DrawingGestureRecognizer:
                              GestureRecognizerFactoryWithHandlers<
                                      DrawingGestureRecognizer>(
                                  () => DrawingGestureRecognizer(),
                                  (DrawingGestureRecognizer instance) {
                            instance.onStart =
                                (DragStartDetails details) async =>
                                    await onPanStart(
                                        options: state.eraserOptions,
                                        context: context,
                                        document: document,
                                        details: details,
                                        inputs: snapshot.requireData);
                            instance.onUpdate =
                                (DragUpdateDetails details) async =>
                                    await onPanUpdate(
                                        options: state.eraserOptions,
                                        context: context,
                                        document: document,
                                        details: details,
                                        inputs: snapshot.requireData);
                            instance.onEnd = (DragEndDetails details) async =>
                                await onPanEnd(
                                    context: context,
                                    document: document,
                                    inputs: snapshot.requireData);
                          })
                        },
                        child: Container(
                          width: widget.size.width,
                          height: widget.size.height,
                          color: Colors.transparent,
                        ),
                      );
                    }));
          });
}
