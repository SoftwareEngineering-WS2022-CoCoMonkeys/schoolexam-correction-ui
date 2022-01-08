import 'dart:ui';

import 'input_options.dart';

class ColoredInputOptions extends InputOptions {
  Color color;

  ColoredInputOptions({required int size, required this.color})
      : super(size: size);
}
