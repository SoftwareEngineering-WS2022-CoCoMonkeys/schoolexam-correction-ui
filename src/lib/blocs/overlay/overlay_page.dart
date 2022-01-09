import 'package:equatable/equatable.dart';
import 'package:schoolexam_correction_ui/blocs/overlay/overlay_input.dart';
import 'package:uuid/uuid.dart';

class OverlayPage extends Equatable {
  late final String instanceId;
  final int version;
  final List<OverlayInput> inputs;

  @override
  List<Object?> get props => [instanceId, version];

  OverlayPage({required this.inputs, this.version = 0, String? instanceId}) {
    this.instanceId = instanceId ?? const Uuid().v4.toString();
  }

  OverlayPage addInputs({required List<OverlayInput> inputs}) {
    return OverlayPage(
        inputs: this.inputs..addAll(inputs),
        version: version + 1,
        instanceId: instanceId);
  }

  OverlayPage updateInput({required int index, required OverlayInput input}) {
    return OverlayPage(
        inputs: inputs..insert(index, input),
        version: version + 1,
        instanceId: instanceId);
  }

  static final empty =
      OverlayPage(inputs: const [], version: 0, instanceId: "");

  bool get isEmpty => this == OverlayPage.empty;
  bool get isNotEmpty => this != OverlayPage.empty;
}
