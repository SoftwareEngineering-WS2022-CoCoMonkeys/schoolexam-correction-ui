import 'package:flutter/material.dart';

typedef ColorWidgetBuilder = Widget Function(
    BuildContext context, Color color, bool selected);
typedef ColorCallback = Function(Color color);

class ColorPickerWidget extends StatefulWidget {
  final List<Color> colors;
  final ColorCallback? onSelected;
  final ColorWidgetBuilder builder;
  final Color? defaultValue;

  const ColorPickerWidget(
      {Key? key,
      required this.colors,
      required this.builder,
      this.onSelected,
      this.defaultValue})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ColorPickerStateWidget();
}

class _ColorPickerStateWidget extends State<ColorPickerWidget> {
  Color? selected;

  @override
  void initState() {
    selected = widget.defaultValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Wrap(
        children: List.generate(
            widget.colors.length,
            (index) => InkWell(
                onTap: () {
                  setState(() {
                    selected = widget.colors[index];
                    if (widget.onSelected != null) {
                      widget.onSelected!(widget.colors[index]);
                    }
                  });
                },
                child: widget.builder(
                    context,
                    widget.colors[index],
                    (selected == null)
                        ? false
                        : selected!.value == widget.colors[index].value))),
      );
}
