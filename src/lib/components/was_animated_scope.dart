
import 'package:flutter/cupertino.dart';

class WasAnimatedScope extends StatefulWidget {
  final WidgetBuilder builder;
  final VoidCallback onEnd;

  final Duration duration;

  final double? fromOpacity;
  final double? toOpacity;

  final double? fromWidth;
  final double? toWidth;

  final double? fromHeight;
  final double? toHeight;

  WasAnimatedScope({
    Key? key,
    this.fromWidth,
    this.toWidth,
    this.fromHeight,
    this.toHeight,
    this.fromOpacity,
    this.toOpacity,
    this.duration = const Duration(seconds: 1),
    required this.onEnd,
    required this.builder,
  }) : super(key: key) {
    assert((fromWidth != null && toWidth != null) ||
        (fromHeight != null && toHeight != null) ||
        (fromOpacity != null && toOpacity != null));

    assert(fromOpacity == null || (fromOpacity! >= 0 && fromOpacity! <= 1));
    assert(toOpacity == null || (toOpacity! >= 0 && toOpacity! <= 1));

    assert(fromWidth == null || (fromWidth! >= 0 && toWidth! >= 0));
    assert(fromHeight == null || (fromHeight! >= 0 && toHeight! >= 0));

    assert(duration.inMilliseconds > 50);
  }

  @override
  State<StatefulWidget> createState() => _WasAnimatedScopeState();
}

class _WasAnimatedScopeState extends State<WasAnimatedScope> {
  Widget _animationBuilder() {
    final double? dWidth;
    final double? dHeight;
    final double? dOpacity;

    if (widget.fromWidth != null) {
      dWidth = widget.toWidth! - widget.fromWidth!;
    } else {
      dWidth = null;
    }

    if (widget.fromHeight != null) {
      dHeight = widget.toHeight! - widget.fromHeight!;
    } else {
      dHeight = null;
    }

    if (widget.fromOpacity != null) {
      dOpacity = widget.toOpacity! - widget.fromOpacity!;
    } else {
      dOpacity = null;
    }

    return TweenAnimationBuilder(
      duration: widget.duration,
      tween: Tween<double>(begin: 0, end: 1),
      onEnd: () => widget.onEnd(),
      builder: (BuildContext context, double value, Widget? child) {
        /// Possibly Opacity
        final Widget oChild;
        if (dOpacity != null) {
          oChild = Opacity(
            /// Animate either by adding to fromOpacity or by subtracting from fromOpacity.
            opacity: widget.fromOpacity! + dOpacity * value,
            child: child!,
          );
        } else {
          oChild = child!;
        }

        final Widget wChild;
        if (dWidth != null) {
          wChild = SizedBox(
            /// Animate either by adding to fromWidth or by subtracting from fromWidth etc..
            width: widget.fromWidth! + dWidth * value,
            child: oChild,
          );
        } else {
          wChild = oChild;
        }

        final Widget hChild;
        if (dHeight != null) {
          hChild = SizedBox(
            /// Animate either by adding to fromHeight or by subtracting from fromHeight etc..
            height: widget.fromHeight! + dHeight * value,
            child: oChild,
          );
        } else {
          hChild = wChild;
        }

        return hChild;
      },
      child: widget.builder(context),
    );
  }

  @override
  Widget build(BuildContext context) => _animationBuilder();
}
