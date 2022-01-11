import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import 'correction_overlay_input.dart';

class CorrectionOverlayPage extends Equatable {
  late final String instanceId;
  final int version;
  final List<CorrectionOverlayInput> inputs;

  /// Size of the underlying PDF page
  final Size pageSize;

  @override
  List<Object?> get props => [instanceId, version];

  CorrectionOverlayPage(
      {required this.inputs,
      required this.pageSize,
      this.version = 0,
      String? instanceId}) {
    this.instanceId = instanceId ?? const Uuid().v4.toString();
  }

  CorrectionOverlayPage addInputs(
      {required List<CorrectionOverlayInput> inputs}) {
    return CorrectionOverlayPage(
        pageSize: pageSize,
        inputs: this.inputs..addAll(inputs),
        version: version + 1,
        instanceId: instanceId);
  }

  CorrectionOverlayPage updateInput(
      {required int index, required CorrectionOverlayInput input}) {
    inputs[index] = input;

    return CorrectionOverlayPage(
        pageSize: pageSize,
        inputs: inputs,
        version: version + 1,
        instanceId: instanceId);
  }

  static final empty = CorrectionOverlayPage(
      pageSize: Size.zero, inputs: const [], version: 0, instanceId: "");

  bool get isEmpty => this == CorrectionOverlayPage.empty;
  bool get isNotEmpty => this != CorrectionOverlayPage.empty;
}
