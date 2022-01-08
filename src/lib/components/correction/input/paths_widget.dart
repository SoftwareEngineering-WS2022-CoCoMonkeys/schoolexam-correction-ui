import 'dart:async';

import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:schoolexam_correction_ui/components/correction/input/drawing_input_options.dart';
import 'package:schoolexam_correction_ui/components/correction/input/stroke.dart';

class PathsWidget extends StatelessWidget {
  final DrawingInputOptions options;
  final StreamController<List<Stroke>> controller;

  const PathsWidget({Key? key, required this.options, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) => RepaintBoundary(
      child: Container(
          color: Colors.transparent,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: StreamBuilder<List<Stroke>>(
              stream: controller.stream,
              builder: (context, snapshot) {
                return CustomPaint(
                  painter: _PathsPainter(
                    lines: snapshot.data != null ? snapshot.data! : [],
                    options: options,
                  ),
                );
              })));
}

class PathWidget extends StatelessWidget {
  final DrawingInputOptions options;
  final StreamController<Stroke> controller;

  const PathWidget({Key? key, required this.options, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) => RepaintBoundary(
      child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: StreamBuilder<Stroke>(
              stream: controller.stream,
              builder: (context, snapshot) {
                return CustomPaint(
                  painter: _PathsPainter(
                    lines: snapshot.data != null ? [snapshot.data!] : [],
                    options: options,
                  ),
                );
              })));
}

class _PathsPainter extends CustomPainter {
  final List<Stroke> lines;
  final DrawingInputOptions options;

  _PathsPainter({required this.lines, required this.options});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Colors.black;

    for (int i = 0; i < lines.length; ++i) {
      final outlinePoints = getStroke(
        lines[i].points,
        size: options.size * 1.0,
        thinning: options.thinning,
        smoothing: options.smoothing,
        streamline: options.streamline,
        taperStart: options.taperStart,
        capStart: options.capStart,
        taperEnd: options.taperEnd,
        capEnd: options.capEnd,
        simulatePressure: options.simulatePressure,
        isComplete: options.isComplete,
      );

      final path = Path();

      if (outlinePoints.isEmpty) {
        return;
      } else if (outlinePoints.length < 2) {
        // If the path only has one line, draw a dot.
        path.addOval(Rect.fromCircle(
            center: Offset(outlinePoints[0].x, outlinePoints[0].y), radius: 1));
      } else {
        // Otherwise, draw a line that connects each point with a curve.
        path.moveTo(outlinePoints[0].x, outlinePoints[0].y);

        for (int i = 1; i < outlinePoints.length - 1; ++i) {
          final p0 = outlinePoints[i];
          final p1 = outlinePoints[i + 1];

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
