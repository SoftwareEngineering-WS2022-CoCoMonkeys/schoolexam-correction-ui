import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:popover/popover.dart';
import 'package:schoolexam_correction_ui/blocs/overlay/correction_overlay.dart';
import 'package:schoolexam_correction_ui/components/correction/input/input_options.dart';
import 'package:schoolexam_correction_ui/components/correction/settings/tool_settings_widget.dart';
import 'package:schoolexam_correction_ui/presentation/custom_icons.dart';

import 'colored_input_options.dart';

void _showInputDialog(BuildContext context, CorrectionInputTool tool) async {
  switch (tool) {
    case CorrectionInputTool.text:
      await showPopover(
          context: context,
          bodyBuilder: (context) => const TextSettingsDialog(),
          direction: PopoverDirection.bottom);
      break;
    case CorrectionInputTool.pencil:
      await showPopover(
          context: context,
          bodyBuilder: (context) => const PencilSettingsDialog(),
          direction: PopoverDirection.bottom);
      break;
    case CorrectionInputTool.marker:
      await showPopover(
          context: context,
          bodyBuilder: (context) => const MarkerSettingsDialog(),
          direction: PopoverDirection.bottom);
      break;
    case CorrectionInputTool.eraser:
      await showPopover(
          context: context,
          bodyBuilder: (context) => const EraserSettingsDialog(),
          direction: PopoverDirection.bottom);
      break;
  }
}

class InputHeader extends StatelessWidget {
  const InputHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<CorrectionOverlayCubit, CorrectionOverlayState>(
        builder: (context, state) => Container(
            constraints: const BoxConstraints(maxHeight: 48),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                    onPressed: () {
                      BlocProvider.of<CorrectionOverlayCubit>(context)
                          .undo(document: state.overlays[state.documentNumber]);
                    },
                    color: Colors.black,
                    icon: const Icon(Icons.undo)),
                IconButton(
                    onPressed: () {
                      BlocProvider.of<CorrectionOverlayCubit>(context)
                          .redo(document: state.overlays[state.documentNumber]);
                    },
                    color: Colors.black,
                    icon: const Icon(Icons.redo)),
                const _InputIconButton(
                    icon: Icon(CustomIcons.pencil_alt),
                    tool: CorrectionInputTool.pencil),
                const _InputIconButton(
                    icon: Icon(CustomIcons.marker),
                    tool: CorrectionInputTool.marker),
                const _InputIconButton(
                    icon: Icon(CustomIcons.eraser),
                    tool: CorrectionInputTool.eraser),
                _InputSettingsWidget(
                  tool: state.inputTool,
                )
              ],
            )),
      );
}

///
///
class _InputIconButton extends StatelessWidget {
  final CorrectionInputTool tool;
  final Icon icon;

  const _InputIconButton({Key? key, required this.tool, required this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<CorrectionOverlayCubit, CorrectionOverlayState>(
          builder: (context, state) {
        return IconButton(
          icon: icon,
          color: (tool == state.inputTool)
              ? Theme.of(context).primaryColor
              : Colors.black,
          onPressed: () async {
            if (tool == state.inputTool) {
              _showInputDialog(context, tool);
            } else {
              switch (tool) {
                case CorrectionInputTool.text:
                  BlocProvider.of<CorrectionOverlayCubit>(context)
                      .changeTool(CorrectionInputTool.text);
                  break;
                case CorrectionInputTool.pencil:
                  BlocProvider.of<CorrectionOverlayCubit>(context)
                      .changeTool(CorrectionInputTool.pencil);
                  break;
                case CorrectionInputTool.marker:
                  BlocProvider.of<CorrectionOverlayCubit>(context)
                      .changeTool(CorrectionInputTool.marker);
                  break;
                case CorrectionInputTool.eraser:
                  BlocProvider.of<CorrectionOverlayCubit>(context)
                      .changeTool(CorrectionInputTool.eraser);
                  break;
              }
            }
          },
        );
      });
}

class _InputSettingsWidget extends StatelessWidget {
  final CorrectionInputTool tool;

  const _InputSettingsWidget({Key? key, required this.tool}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<CorrectionOverlayCubit, CorrectionOverlayState>(
          builder: (context, state) {
        late final InputOptions options;
        switch (tool) {
          case CorrectionInputTool.eraser:
            options = state.eraserOptions;
            break;
          case CorrectionInputTool.marker:
            options = state.markerOptions;
            break;
          case CorrectionInputTool.pencil:
            options = state.pencilOptions;
            break;
          case CorrectionInputTool.text:
            options = state.textOptions;
            break;
        }

        return GestureDetector(
          onTap: () => _showInputDialog(context, tool),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: VerticalDivider(
                  thickness: 2,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Container(
                  height: options.size * 1.0,
                  width: 24,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.black),
                ),
              ),
              if (options is ColoredInputOptions)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(
                    Icons.circle,
                    color: options.color,
                  ),
                ),
            ],
          ),
        );
      });
}
