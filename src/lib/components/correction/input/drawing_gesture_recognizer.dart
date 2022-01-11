import 'package:flutter/gestures.dart';

class DrawingGestureRecognizer extends PanGestureRecognizer {
  DrawingGestureRecognizer() {
    dragStartBehavior = DragStartBehavior.down;
  }

  @override
  bool isPointerAllowed(PointerEvent event) {
    if (event.kind != PointerDeviceKind.stylus) {
      return false;
    }

    return super.isPointerAllowed(event);
  }
}
