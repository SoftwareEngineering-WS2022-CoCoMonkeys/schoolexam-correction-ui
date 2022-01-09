import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

class OverlayInput extends Equatable {
  final Color color;
  final List<Point> points;

  @override
  List<Object?> get props => [color, points];

  const OverlayInput({required this.color, required this.points});

  OverlayInput copyWith({List<Point>? points}) {
    return OverlayInput(color: color, points: points ?? this.points);
  }
}
