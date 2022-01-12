import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schoolexam_correction_ui/blocs/overlay/correction_overlay.dart';
import 'package:schoolexam_correction_ui/presentation/custom_icons.dart';

class InputHeader extends StatelessWidget {
  const InputHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<CorrectionOverlayCubit, CorrectionOverlayState>(
        builder: (context, state) => Container(
            constraints: const BoxConstraints(maxHeight: 48),
            child: Row(
              children: [
                IconButton(
                    onPressed: () {
                      BlocProvider.of<CorrectionOverlayCubit>(context)
                          .undo(document: state.overlays[state.documentNumber]);
                    },
                    icon: const Icon(Icons.undo)),
                IconButton(
                    onPressed: () {
                      BlocProvider.of<CorrectionOverlayCubit>(context)
                          .redo(document: state.overlays[state.documentNumber]);
                    },
                    icon: const Icon(Icons.redo)),
                IconButton(
                    onPressed: () {
                      BlocProvider.of<CorrectionOverlayCubit>(context)
                          .changeTool(CorrectionInputTool.text);
                    },
                    color: (state.inputTool == CorrectionInputTool.text)
                        ? Theme.of(context).primaryColor
                        : null,
                    icon: const Icon(CustomIcons.font)),
                IconButton(
                    onPressed: () {
                      BlocProvider.of<CorrectionOverlayCubit>(context)
                          .changeTool(CorrectionInputTool.pencil);
                    },
                    color: (state.inputTool == CorrectionInputTool.pencil)
                        ? Theme.of(context).primaryColor
                        : null,
                    icon: const Icon(CustomIcons.pencil_alt)),
                IconButton(
                    onPressed: () {
                      BlocProvider.of<CorrectionOverlayCubit>(context)
                          .changeTool(CorrectionInputTool.marker);
                    },
                    color: (state.inputTool == CorrectionInputTool.marker)
                        ? Theme.of(context).primaryColor
                        : null,
                    icon: const Icon(CustomIcons.marker)),
                IconButton(
                    onPressed: () {
                      BlocProvider.of<CorrectionOverlayCubit>(context)
                          .changeTool(CorrectionInputTool.eraser);
                    },
                    color: (state.inputTool == CorrectionInputTool.eraser)
                        ? Theme.of(context).primaryColor
                        : null,
                    icon: const Icon(CustomIcons.eraser)),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: VerticalDivider(
                    thickness: 2,
                  ),
                ),
                IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.circle,
                      color: Colors.black,
                    )),
              ],
            )),
      );
}
