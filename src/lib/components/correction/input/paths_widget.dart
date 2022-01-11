import 'dart:async';

import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:schoolexam_correction_ui/blocs/overlay/correction_overlay_input.dart';

class PathsWidget extends StatelessWidget {
  final Size size;

  final List<CorrectionOverlayInput> initialData;
  final StreamController<List<CorrectionOverlayInput>> controller;

  const PathsWidget(
      {Key? key,
      required this.initialData,
      required this.size,
      required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) => RepaintBoundary(
      child: Container(
          color: Colors.transparent,
          width: size.width,
          height: size.height,
          child: StreamBuilder<List<CorrectionOverlayInput>>(
              initialData: initialData,
              stream: controller.stream,
              builder: (context, snapshot) {
                return ClipRect(
                  child: CustomPaint(
                    // TODO : Help
                    painter: _PathsPainter(
                        size: size,
                        inputs: snapshot.data != null ? snapshot.data! : []),
                  ),
                );
              })));
}

class _PathsPainter extends CustomPainter {
  final Size size;
  final List<CorrectionOverlayInput> inputs;

  _PathsPainter({required this.size, required this.inputs});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < inputs.length; ++i) {
      final input = inputs[i];
      final points = inputs[i]
          .points
          .map((e) => e.toAbsolutePoint(size: this.size))
          .toList();

      Paint paint = Paint()..color = input.color;

      final path = Path();

      if (points.isEmpty) {
        return;
      } else if (points.length < 2) {
        // If the path only has one line, draw a dot.
        path.addOval(Rect.fromCircle(
            center: Offset(points[0].x, points[0].y), radius: 1));
      } else {
        // Otherwise, draw a line that connects each point with a curve.
        path.moveTo(points[0].x, points[0].y);

        for (int i = 1; i < points.length - 1; ++i) {
          final p0 = points[i];
          final p1 = points[i + 1];

          path.quadraticBezierTo(
              p0.x, p0.y, (p0.x + p1.x) / 2, (p0.y + p1.y) / 2);
        }
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_PathsPainter oldDelegate) {
    // TODO : Only redraw if options or lines changes
    return true;
  }
}
