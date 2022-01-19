import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schoolexam_correction_ui/blocs/overlay/correction_overlay.dart';
import 'package:schoolexam_correction_ui/components/correction/input/colored_input_options.dart';
import 'package:schoolexam_correction_ui/components/correction/input/drawing_input_options.dart';
import 'package:schoolexam_correction_ui/components/correction/input/input_options.dart';

import 'input_settings_widget.dart';

class _BaseSettingsDialog extends StatelessWidget {
  final WidgetBuilder builder;

  const _BaseSettingsDialog({Key? key, required this.builder})
      : super(key: key);

  @override
  Widget build(BuildContext context) => CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      child: SafeArea(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [builder(context)])));
}

class PencilSettingsDialog extends StatelessWidget {
  const PencilSettingsDialog({Key? key}) : super(key: key);

  void change(BuildContext context, DrawingInputOptions options) =>
      BlocProvider.of<CorrectionOverlayCubit>(context)
          .changePencilOptions(options);

  @override
  Widget build(BuildContext context) => _BaseSettingsDialog(builder: (context) {
        return BlocBuilder<CorrectionOverlayCubit, CorrectionOverlayState>(
            builder: (context, state) =>
                InputSettingsWidget<DrawingInputOptions>(
                  callback: <DrawingInputOptions>(options) =>
                      change(context, options),
                  options: state.pencilOptions,
                ));
      });
}

class MarkerSettingsDialog extends StatelessWidget {
  const MarkerSettingsDialog({Key? key}) : super(key: key);

  void change(BuildContext context, DrawingInputOptions options) =>
      BlocProvider.of<CorrectionOverlayCubit>(context)
          .changeMarkerOptions(options);

  @override
  Widget build(BuildContext context) => _BaseSettingsDialog(builder: (context) {
        return BlocBuilder<CorrectionOverlayCubit, CorrectionOverlayState>(
            builder: (context, state) =>
                InputSettingsWidget<DrawingInputOptions>(
                  callback: <DrawingInputOptions>(options) =>
                      change(context, options),
                  options: state.markerOptions,
                ));
      });
}

class TextSettingsDialog extends StatelessWidget {
  const TextSettingsDialog({Key? key}) : super(key: key);

  void change(BuildContext context, ColoredInputOptions options) =>
      BlocProvider.of<CorrectionOverlayCubit>(context)
          .changeTextOptions(options);

  @override
  Widget build(BuildContext context) => _BaseSettingsDialog(builder: (context) {
        return BlocBuilder<CorrectionOverlayCubit, CorrectionOverlayState>(
            builder: (context, state) =>
                InputSettingsWidget<ColoredInputOptions>(
                  callback: <ColoredInputOptions>(options) =>
                      change(context, options),
                  options: state.textOptions,
                ));
      });
}

class EraserSettingsDialog extends StatelessWidget {
  const EraserSettingsDialog({Key? key}) : super(key: key);

  void change(BuildContext context, InputOptions options) =>
      BlocProvider.of<CorrectionOverlayCubit>(context)
          .changeEraserOptions(options);

  @override
  Widget build(BuildContext context) => _BaseSettingsDialog(builder: (context) {
        return BlocBuilder<CorrectionOverlayCubit, CorrectionOverlayState>(
            builder: (context, state) => InputSettingsWidget<InputOptions>(
                  callback: <InputOptions>(options) => change(context, options),
                  options: state.eraserOptions,
                ));
      });
}
