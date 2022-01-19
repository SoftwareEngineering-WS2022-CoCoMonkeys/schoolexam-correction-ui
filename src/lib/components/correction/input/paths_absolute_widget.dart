import 'dart:async';

import 'package:flutter/material.dart';
import 'package:schoolexam_correction_ui/repositories/correction_overlay/correction_overlay.dart';

class PathsAbsoluteWidget extends StatelessWidget {
  final Size size;
  final StreamController<CorrectionOverlayAbsoluteInput> controller;

  const PathsAbsoluteWidget(
      {Key? key, required this.size, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) => RepaintBoundary(
      child: Container(
          color: Colors.transparent,
          width: size.width,
          height: size.height,
          child: StreamBuilder<CorrectionOverlayAbsoluteInput>(
              stream: controller.stream,
              builder: (context, snapshot) {
                return ClipRect(
                  child: CustomPaint(
                    painter: _PathsPainter(
                        input: snapshot.hasData
                            ? snapshot.requireData
                            : const CorrectionOverlayAbsoluteInput(
                                color: Colors.transparent, points: [])),
                  ),
                );
              })));
}

class _PathsPainter extends CustomPainter {
  final CorrectionOverlayAbsoluteInput input;

  _PathsPainter({required this.input});

  @override
  void paint(Canvas canvas, Size size) {
    final points = input.points;
    Paint paint = Paint()..color = input.color;

    final path = Path();

    if (points.isEmpty) {
      return;
    } else if (points.length < 2) {
      // If the path only has one line, draw a dot.
      path.addOval(
          Rect.fromCircle(center: Offset(points[0].x, points[0].y), radius: 1));
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

  @override
  bool shouldRepaint(_PathsPainter oldDelegate) => true;
}
