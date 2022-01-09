import 'dart:async';

import 'package:flutter/material.dart';
import 'package:schoolexam_correction_ui/blocs/overlay/overlay_input.dart';

class PathsWidget extends StatelessWidget {
  final Widget child;
  final StreamController<List<OverlayInput>> controller;

  const PathsWidget({Key? key, required this.child, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) => RepaintBoundary(
      child: Container(
          color: Colors.transparent,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: StreamBuilder<List<OverlayInput>>(
              stream: controller.stream,
              builder: (context, snapshot) {
                return ClipRect(
                  child: CustomPaint(
                    // TODO : Help
                    //child: child,
                    painter: _PathsPainter(
                        inputs: snapshot.data != null ? snapshot.data! : []),
                  ),
                );
              })));
}

class _PathsPainter extends CustomPainter {
  final List<OverlayInput> inputs;

  _PathsPainter({required this.inputs});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < inputs.length; ++i) {
      final input = inputs[i];
      Paint paint = Paint()..color = input.color;

      final path = Path();

      if (input.points.isEmpty) {
        return;
      } else if (input.points.length < 2) {
        // If the path only has one line, draw a dot.
        path.addOval(Rect.fromCircle(
            center: Offset(input.points[0].x, input.points[0].y), radius: 1));
      } else {
        // Otherwise, draw a line that connects each point with a curve.
        path.moveTo(input.points[0].x, input.points[0].y);

        for (int i = 1; i < input.points.length - 1; ++i) {
          final p0 = input.points[i];
          final p1 = input.points[i + 1];

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
