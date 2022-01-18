import 'package:schoolexam_correction_ui/repositories/correction_overlay/models/correction_overlay_document.dart';

abstract class CorrectionOverlayRepository {
  /// Retrieves the [CorrectionOverlayDocument] currently stored for the corresponding submission [submissionId].
  /// If no correction exists yet, an empty instance is returned.
  Future<CorrectionOverlayDocument> getDocument({required String submissionId});

  /// Stores the [document] for later retrieval. Any existing data is fully overwritten.
  Future<bool> saveDocument({required CorrectionOverlayDocument document});
}
