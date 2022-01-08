import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schoolexam_correction_ui/blocs/remark/remark.dart';
import 'package:schoolexam_correction_ui/components/correction/input/paths_widget.dart';

import 'drawing_input_overlay.dart';
import 'stroke.dart';

class InputBox extends StatefulWidget {
  const InputBox({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _InputBoxState();
}

class _InputBoxState extends State<InputBox> {
  List<Stroke> lines;
  final StreamController<Stroke> currentLineController;
  final StreamController<List<Stroke>> linesController;

  _InputBoxState()
      : lines = <Stroke>[],
        currentLineController = StreamController<Stroke>.broadcast(),
        linesController = StreamController<List<Stroke>>.broadcast();

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<RemarkCubit, RemarkState>(builder: (context, state) {
        switch (state.inputTool) {
          case RemarkInputTool.pencil:
            return Stack(
              children: [
                PathsWidget(
                    options: state.pencilOptions, controller: linesController),
                DrawingInputOverlay(
                  controller: currentLineController,
                  callback: (line) {
                    lines = List.from(lines)..add(line);
                    linesController.add(lines);
                  },
                  child: PathWidget(
                    options: state.pencilOptions,
                    controller: currentLineController,
                  ),
                )
              ],
            );
          default:
            return Text("Not yet supported!");
        }
      });

  @override
  void dispose() {
    currentLineController.close();
    linesController.close();
    super.dispose();
  }
}
