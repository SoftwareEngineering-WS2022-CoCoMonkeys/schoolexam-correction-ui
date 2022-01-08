import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schoolexam_correction_ui/blocs/remark/remark.dart';
import 'package:schoolexam_correction_ui/presentation/custom_icons.dart';

class InputHeader extends StatelessWidget {
  const InputHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocBuilder<RemarkCubit, RemarkState>(
      builder: (context, state) => Container(
          constraints: const BoxConstraints(maxHeight: 48),
          child: Row(
            children: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.undo)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.redo)),
              IconButton(
                  onPressed: () {
                    BlocProvider.of<RemarkCubit>(context)
                        .changeTool(RemarkInputTool.text);
                  },
                  icon: const Icon(CustomIcons.font)),
              IconButton(
                  onPressed: () {
                    BlocProvider.of<RemarkCubit>(context)
                        .changeTool(RemarkInputTool.pencil);
                  },
                  icon: const Icon(CustomIcons.pencil_alt)),
              IconButton(
                  onPressed: () {
                    BlocProvider.of<RemarkCubit>(context)
                        .changeTool(RemarkInputTool.marker);
                  },
                  icon: const Icon(CustomIcons.marker)),
              IconButton(
                  onPressed: () {
                    BlocProvider.of<RemarkCubit>(context)
                        .changeTool(RemarkInputTool.eraser);
                  },
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
          )));
}
