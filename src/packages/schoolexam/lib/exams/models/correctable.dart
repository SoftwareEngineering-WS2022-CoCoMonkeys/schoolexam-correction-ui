enum CorrectableStatus { unknown, pending, corrected, published, archived }

abstract class Correctable {
  final double achievedPoints;
  final CorrectableStatus status;

  const Correctable({required this.achievedPoints, required this.status});
}
