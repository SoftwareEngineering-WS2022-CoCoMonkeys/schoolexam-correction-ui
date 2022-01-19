import 'dart:ui';

import 'input_options.dart';

class ColoredInputOptions extends InputOptions {
  final Color color;

  const ColoredInputOptions({required int size, required this.color})
      : super(size: size);

  @override
  ColoredInputOptions copyWith({
    int? size,
    Color? color,
  }) {
    return ColoredInputOptions(
      size: size ?? this.size,
      color: color ?? this.color,
    );
  }
}
