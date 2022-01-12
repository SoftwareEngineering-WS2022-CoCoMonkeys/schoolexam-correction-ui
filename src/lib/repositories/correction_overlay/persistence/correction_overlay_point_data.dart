import 'package:schoolexam_correction_ui/repositories/correction_overlay/correction_overlay.dart';
import 'package:schoolexam_correction_ui/repositories/correction_overlay/persistence/correction_overlay_input_data.dart';

/// Data class for storing a single point within a set of inputs.
/// This data class needs no primary key, because we are never interested in deleting a specific single point (based on its identity) from the persistence layer.
class CorrectionOverlayPointData {
  /// Associates this single point to an input collection.
  /// This in turn maps it to a specific page, document, submission...
  final int inputId;

  final double relX;
  final double relY;
  final double p;

  const CorrectionOverlayPointData(
      {required this.inputId,
      required this.relX,
      required this.relY,
      required this.p});

  /// Used by SQFlite to automatically generate insert, update... queries.
  Map<String, dynamic> toMap() {
    return {'inputId': inputId, 'relX': relX, 'relY': relY, 'p': p};
  }

  static CorrectionOverlayPointData fromMap(Map<String, dynamic> data) =>
      CorrectionOverlayPointData(
          inputId: data['inputId'],
          relX: data['relX'],
          relY: data['relY'],
          p: data['p']);

  static CorrectionOverlayPointData fromModel(
          {required CorrectionOverlayInputData input,
          required CorrectionOverlayPoint point}) =>
      CorrectionOverlayPointData(
          inputId: input.id!, relX: point.relX, relY: point.relY, p: point.p);

  CorrectionOverlayPoint toModel() =>
      CorrectionOverlayPoint(relX: relX, relY: relY, p: p);
}
