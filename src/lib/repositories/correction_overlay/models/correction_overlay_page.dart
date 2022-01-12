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
    this.instanceId = instanceId ?? const Uuid().v4().toString();
  }

  CorrectionOverlayPage addInputs(
      {required List<CorrectionOverlayInput> inputs}) {
    final updated = List<CorrectionOverlayInput>.from(this.inputs);

    return copyWith(version: version + 1, inputs: updated..addAll(inputs));
  }

  CorrectionOverlayPage updateInput(
      {required int index, required CorrectionOverlayInput input}) {
    final updated = List<CorrectionOverlayInput>.from(inputs);
    updated[index] = input;

    return copyWith(version: version + 1, inputs: updated);
  }

  CorrectionOverlayPage copyWith(
          {int? version, List<CorrectionOverlayInput>? inputs}) =>
      CorrectionOverlayPage(
          inputs: inputs ?? this.inputs,
          instanceId: instanceId,
          version: version ?? this.version,
          pageSize: pageSize);

  static final empty = CorrectionOverlayPage(
      pageSize: Size.zero, inputs: const [], version: 0, instanceId: "");

  bool get isEmpty => this == CorrectionOverlayPage.empty;
  bool get isNotEmpty => this != CorrectionOverlayPage.empty;
}
