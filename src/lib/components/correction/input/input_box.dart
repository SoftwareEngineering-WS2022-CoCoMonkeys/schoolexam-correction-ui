import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schoolexam_correction_ui/blocs/overlay/overlay.dart' as pdf;
import 'package:schoolexam_correction_ui/blocs/overlay/overlay_input.dart';
import 'package:schoolexam_correction_ui/blocs/remark/remark.dart';
import 'package:schoolexam_correction_ui/components/correction/input/paths_widget.dart';

import 'drawing_input_overlay.dart';

class InputBox extends StatefulWidget {
  final Widget child;

  const InputBox({Key? key, required this.child}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _InputBoxState();
}

class _InputBoxState extends State<InputBox> {
  final StreamController<List<OverlayInput>> linesController;

  _InputBoxState()
      : linesController = StreamController<List<OverlayInput>>.broadcast();

  @override
  Widget build(BuildContext context) =>
      BlocListener<pdf.OverlayCubit, pdf.OverlayState>(
        listener: (context, state) {
          linesController.add(state.current.inputs);
        },
        child: BlocBuilder<RemarkCubit, RemarkState>(builder: (context, state) {
          switch (state.inputTool) {
            case RemarkInputTool.pencil:
              return Stack(
                children: [
                  DrawingInputOverlay(
                    overlayCubit: BlocProvider.of<pdf.OverlayCubit>(context),
                    linesController: linesController,
                    child: PathsWidget(
                        controller: linesController, child: widget.child),
                  )
                ],
              );
            default:
              return const Text("Not yet supported!");
          }
        }),
      );

  @override
  void dispose() {
    linesController.close();
    super.dispose();
  }
}
