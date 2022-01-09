import 'package:equatable/equatable.dart';
import 'package:schoolexam_correction_ui/blocs/overlay/overlay_document.dart';
import 'package:schoolexam_correction_ui/blocs/overlay/overlay_page.dart';

import 'overlay_input.dart';

class OverlayState extends Equatable {
  final OverlayPage current;
  final List<OverlayDocument> overlays;

  const OverlayState({required this.current, required this.overlays});

  OverlayState.none() : this(current: OverlayPage.empty, overlays: []);

  OverlayState addInputs(
      {required int documentNumber,
      required int pageNumber,
      required List<OverlayInput> inputs}) {
    final updated = List<OverlayDocument>.from(overlays)
      ..insert(
          documentNumber,
          overlays[documentNumber]
              .addInputs(pageNumber: pageNumber, inputs: inputs));

    return OverlayState(
        current: updated[documentNumber].pages[pageNumber], overlays: updated);
  }

  OverlayState updateInput(
      {required int documentNumber,
      required int pageNumber,
      required int index,
      required OverlayInput input}) {
    final updated = List<OverlayDocument>.from(overlays)
      ..insert(
          documentNumber,
          overlays[documentNumber]
              .updateInput(pageNumber: pageNumber, index: index, input: input));

    return OverlayState(
        current: updated[documentNumber].pages[pageNumber], overlays: updated);
  }

  @override
  List<Object?> get props => [current, overlays];
}
