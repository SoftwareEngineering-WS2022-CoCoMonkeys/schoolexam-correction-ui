import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

import 'correction_overlay_point.dart';

class CorrectionOverlayInput extends Equatable {
  final Color color;
  final List<CorrectionOverlayPoint> points;

  @override
  List<Object?> get props => [color, points];

  const CorrectionOverlayInput({required this.color, required this.points});

  CorrectionOverlayInput copyWith({List<CorrectionOverlayPoint>? points}) {
    return CorrectionOverlayInput(color: color, points: points ?? this.points);
  }
}

class CorrectionOverlayAbsoluteInput extends Equatable {
  final Color color;
  final List<Point> points;

  @override
  List<Object?> get props => [color, points];

  const CorrectionOverlayAbsoluteInput(
      {required this.color, required this.points});
}
