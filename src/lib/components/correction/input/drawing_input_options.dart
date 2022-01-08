import 'dart:ui';

import 'colored_input_options.dart';

class DrawingInputOptions extends ColoredInputOptions {
  /// The effect of pressure on the stroke's size.
  final double thinning;

  /// Controls the density of points along the stroke's edges.
  final double smoothing;

  /// Controls the level of variation allowed in the input points.
  final double streamline;

  // Whether to simulate pressure or use the point's provided pressures.
  final bool simulatePressure;

  // The distance to taper the front of the stroke.
  final double taperStart;

  // The distance to taper the end of the stroke.
  final double taperEnd;

  // Whether to add a cap to the start of the stroke.
  final bool capStart;

  // Whether to add a cap to the end of the stroke.
  final bool capEnd;

  // Whether the line is complete.
  final bool isComplete;

  DrawingInputOptions.pencil({required int size, required Color color})
      : thinning = 0.7,
        smoothing = 0.5,
        streamline = 0.5,
        taperStart = 0.0,
        capStart = true,
        taperEnd = 0.0,
        capEnd = true,
        simulatePressure = true,
        isComplete = false,
        super(size: size, color: color);

  DrawingInputOptions.marker({required int size, required Color color})
      : thinning = 0.7,
        smoothing = 0.5,
        streamline = 0.5,
        taperStart = 0.0,
        capStart = true,
        taperEnd = 0.0,
        capEnd = true,
        simulatePressure = true,
        isComplete = false,
        super(size: size, color: color);
}
