import 'package:equatable/equatable.dart';

enum CorrectableStatus { unknown, pending, inProgress, corrected }

abstract class Correctable extends Equatable {
  final double achievedPoints;
  final CorrectableStatus status;

  /// Last update to the correctable.
  /// This is crucial for synchronizing online and offline.
  /// However, as we do NOT apply a locking mechanism it is still possible that data is lost.
  /// This can be dealt with, however, by informing the user and allowing a conflict handling equivalent to merge conflicts.
  final DateTime updatedAt;

  const Correctable(
      {required this.achievedPoints,
      required this.status,
      required this.updatedAt});
}
