import 'package:equatable/equatable.dart';

enum CorrectableStatus { unknown, pending, corrected, published, archived }

abstract class Correctable extends Equatable {
  final double achievedPoints;
  final CorrectableStatus status;

  const Correctable({required this.achievedPoints, required this.status});
}
