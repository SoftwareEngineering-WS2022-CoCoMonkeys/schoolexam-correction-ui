import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:schoolexam_correction_ui/components/correction/input/colored_input_options.dart';
import 'package:schoolexam_correction_ui/components/correction/input/input_options.dart';

import 'color_picker_widget.dart';

typedef InputOptionsChangedCallback<T extends InputOptions> = void Function(
    T options);

class InputSettingsWidget<T extends InputOptions> extends StatefulWidget {
  final InputOptionsChangedCallback<T> callback;
  final T options;

  const InputSettingsWidget(
      {Key? key, required this.options, required this.callback})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _InputSettingsWidgetState();
}

class _InputSettingsWidgetState extends State<InputSettingsWidget> {
  double? value;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          if (widget.options is ColoredInputOptions)
            ColorPickerWidget(
                defaultValue: (widget.options as ColoredInputOptions)
                    .color
                    .withAlpha(255),
                colors: const [
                  Colors.black,
                  Colors.green,
                  Colors.orange,
                  Colors.yellow,
                  Colors.red
                ],
                onSelected: (Color color) => widget.callback(
                    (widget.options as ColoredInputOptions)
                        .copyWith(color: color)),
                builder: (BuildContext context, Color color, bool selected) =>
                    Stack(
                      children: [
                        Icon(
                          Icons.circle,
                          color: color,
                          size: (selected) ? 32 : 24,
                        ),
                        if (selected)
                          const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              Icons.check,
                              size: 24,
                              color: Colors.white,
                            ),
                          )
                      ],
                    )),
          Row(
            children: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      value = max((value ?? widget.options.size * 1.0) - 1, 0);
                    });
                  },
                  icon: const Icon(Icons.remove)),
              CupertinoSlider(
                min: 1,
                max: 20,
                thumbColor: (widget.options is ColoredInputOptions)
                    ? (widget.options as ColoredInputOptions).color
                    : Colors.black,
                onChangeEnd: (double value) => widget
                    .callback(widget.options.copyWith(size: value.toInt())),
                value: value ?? widget.options.size * 1.0,
                divisions: 50,
                onChanged: (double value) {
                  setState(() {
                    this.value = value;
                  });
                },
              ),
              IconButton(
                  onPressed: () {
                    setState(() {
                      value = min((value ?? widget.options.size * 1.0) + 1, 20);
                    });
                  },
                  icon: const Icon(Icons.add)),
            ],
          )
        ],
      );
}
