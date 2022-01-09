import 'package:equatable/equatable.dart';
import 'package:schoolexam_correction_ui/blocs/overlay/overlay_page.dart';
import 'package:uuid/uuid.dart';

import 'overlay_input.dart';

/// TODO : Save in database or similiar
class OverlayDocument extends Equatable {
  late final String instanceId;
  final int version;
  final String path;
  final List<OverlayPage> pages;

  OverlayDocument(
      {required this.path,
      required this.pages,
      this.version = 0,
      String? instanceId}) {
    this.instanceId = instanceId ?? const Uuid().v4.toString();
  }

  @override
  List<Object?> get props => [instanceId, version];

  OverlayDocument addInputs(
      {required int pageNumber, required List<OverlayInput> inputs}) {
    return OverlayDocument(
        instanceId: instanceId,
        version: version + 1,
        path: path,
        pages: List<OverlayPage>.from(pages)
          ..insert(pageNumber, pages[pageNumber].addInputs(inputs: inputs)));
  }

  OverlayDocument updateInput(
      {required int pageNumber,
      required int index,
      required OverlayInput input}) {
    return OverlayDocument(
        instanceId: instanceId,
        version: version + 1,
        path: path,
        pages: List<OverlayPage>.from(pages)
          ..insert(pageNumber,
              pages[pageNumber].updateInput(index: index, input: input)));
  }

  static final empty =
      OverlayDocument(instanceId: "", version: 0, path: "", pages: const []);

  bool get isEmpty => this == OverlayDocument.empty;
  bool get isNotEmpty => this != OverlayDocument.empty;
}
