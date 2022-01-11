import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import 'correction_overlay_input.dart';
import 'correction_overlay_page.dart';

/// TODO : Save in database or similiar
class CorrectionOverlayDocument extends Equatable {
  late final String instanceId;
  final int version;
  final String path;
  final List<CorrectionOverlayPage> pages;

  CorrectionOverlayDocument(
      {required this.path,
      required this.pages,
      this.version = 0,
      String? instanceId}) {
    this.instanceId = instanceId ?? const Uuid().v4.toString();
  }

  @override
  List<Object?> get props => [instanceId, version];

  CorrectionOverlayDocument addInputs(
      {required int pageNumber, required List<CorrectionOverlayInput> inputs}) {
    final updated = List<CorrectionOverlayPage>.from(pages);
    updated[pageNumber] = pages[pageNumber].addInputs(inputs: inputs);

    return CorrectionOverlayDocument(
        instanceId: instanceId,
        version: version + 1,
        path: path,
        pages: updated);
  }

  CorrectionOverlayDocument updateInput(
      {required int pageNumber,
      required int index,
      required CorrectionOverlayInput input}) {
    final updated = List<CorrectionOverlayPage>.from(pages);
    updated[pageNumber] =
        pages[pageNumber].updateInput(index: index, input: input);

    return CorrectionOverlayDocument(
        instanceId: instanceId,
        version: version + 1,
        path: path,
        pages: updated);
  }

  static final empty = CorrectionOverlayDocument(
      instanceId: "", version: 0, path: "", pages: const []);

  bool get isEmpty => this == CorrectionOverlayDocument.empty;
  bool get isNotEmpty => this != CorrectionOverlayDocument.empty;
}
