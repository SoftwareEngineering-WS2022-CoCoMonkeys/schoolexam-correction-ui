import 'dart:ui';

import 'package:perfect_freehand/perfect_freehand.dart';

/// An overlay point is a point made up of relative coordinates.
/// This allows for a transition between the UI display and the PDF page.
class CorrectionOverlayPoint {
  /// Relative x coordinate
  final double relX;

  /// Relative y coordinate
  final double relY;

  /// Pressure for this point
  final double p;

  const CorrectionOverlayPoint({
    required this.relX,
    required this.relY,
    this.p = 0.5,
  });

  /// Uses the absolute coordinate [point] and the boundaries [size] to calculate the relative positioning.
  /// The [point] also includes information about the pressure applied by the user to create it.
  CorrectionOverlayPoint.fromAbsolute(
      {required Point point, required Size size})
      : this(
            relX: point.x / size.width,
            relY: point.y / size.height,
            p: point.p);

  Point toAbsolutePoint({required Size size}) =>
      Point(relX * size.width, relY * size.height, p);

  bool get isInvalid => relY > 1 || relY < 0 || relX > 1 || relX < 0;
}
