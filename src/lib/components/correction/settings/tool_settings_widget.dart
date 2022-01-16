import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schoolexam_correction_ui/blocs/overlay/correction_overlay.dart';
import 'package:schoolexam_correction_ui/components/correction/input/colored_input_options.dart';
import 'package:schoolexam_correction_ui/components/correction/input/drawing_input_options.dart';
import 'package:schoolexam_correction_ui/components/correction/input/input_options.dart';

import 'input_settings_widget.dart';

class PencilSettingsWidget extends StatelessWidget {
  const PencilSettingsWidget({Key? key}) : super(key: key);

  void change(BuildContext context, DrawingInputOptions options) =>
      BlocProvider.of<CorrectionOverlayCubit>(context)
          .changePencilOptions(options);

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<CorrectionOverlayCubit, CorrectionOverlayState>(
          builder: (context, state) => InputSettingsWidget<DrawingInputOptions>(
                callback: <DrawingInputOptions>(options) =>
                    change(context, options),
                options: state.pencilOptions,
              ));
}

class MarkerSettingsWidget extends StatelessWidget {
  const MarkerSettingsWidget({Key? key}) : super(key: key);

  void change(BuildContext context, DrawingInputOptions options) =>
      BlocProvider.of<CorrectionOverlayCubit>(context)
          .changeMarkerOptions(options);

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<CorrectionOverlayCubit, CorrectionOverlayState>(
          builder: (context, state) => InputSettingsWidget<DrawingInputOptions>(
                callback: <DrawingInputOptions>(options) =>
                    change(context, options),
                options: state.markerOptions,
              ));
}

class TextSettingsWidget extends StatelessWidget {
  const TextSettingsWidget({Key? key}) : super(key: key);

  void change(BuildContext context, ColoredInputOptions options) =>
      BlocProvider.of<CorrectionOverlayCubit>(context)
          .changeTextOptions(options);

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<CorrectionOverlayCubit, CorrectionOverlayState>(
          builder: (context, state) => InputSettingsWidget<ColoredInputOptions>(
                callback: <ColoredInputOptions>(options) =>
                    change(context, options),
                options: state.textOptions,
              ));
}

class EraserSettingsWidget extends StatelessWidget {
  const EraserSettingsWidget({Key? key}) : super(key: key);

  void change(BuildContext context, InputOptions options) =>
      BlocProvider.of<CorrectionOverlayCubit>(context)
          .changeEraserOptions(options);

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<CorrectionOverlayCubit, CorrectionOverlayState>(
          builder: (context, state) => InputSettingsWidget<InputOptions>(
                callback: <InputOptions>(options) => change(context, options),
                options: state.eraserOptions,
              ));
}
