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

  /// Adds [inputs] to the known list of inputs.
  /// The version is increased accordingly.
  CorrectionOverlayPage addInputs(
      {required List<CorrectionOverlayInput> inputs}) {
    final updated = List<CorrectionOverlayInput>.from(this.inputs);

    return copyWith(version: version + 1, inputs: updated..addAll(inputs));
  }

  /// Replaces currently known inputs with [inputs].
  /// The version is increased accordingly.
  CorrectionOverlayPage replaceInputs(
      {required List<CorrectionOverlayInput> inputs}) {
    final updated = List<CorrectionOverlayInput>.from(inputs);

    return copyWith(version: version + 1, inputs: updated);
  }

  static final empty = CorrectionOverlayPage(
      pageSize: Size.zero, inputs: const [], version: 0, instanceId: "");

  bool get isEmpty => this == CorrectionOverlayPage.empty;

  bool get isNotEmpty => this != CorrectionOverlayPage.empty;

  CorrectionOverlayPage copyWith({
    int? version,
    List<CorrectionOverlayInput>? inputs,
    Size? pageSize,
  }) {
    return CorrectionOverlayPage(
      instanceId: instanceId,
      version: version ?? this.version,
      inputs: inputs ?? this.inputs,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}
