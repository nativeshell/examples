import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// LimitedBox that also limits intrinsic width
class IntrinsicLimitedBox extends LimitedBox {
  const IntrinsicLimitedBox({
    Key? key,
    double maxWidth = double.infinity,
    double maxHeight = double.infinity,
    Widget? child,
  }) : super(key: key, maxWidth: maxWidth, maxHeight: maxWidth, child: child);

  @override
  RenderLimitedBox createRenderObject(BuildContext context) {
    return RenderIntrinsicLimitedBox(
      maxWidth: maxWidth,
      maxHeight: maxHeight,
    );
  }
}

class RenderIntrinsicLimitedBox extends RenderLimitedBox {
  RenderIntrinsicLimitedBox({
    RenderBox? child,
    double maxWidth = double.infinity,
    double maxHeight = double.infinity,
  }) : super(child: child, maxWidth: maxWidth, maxHeight: maxHeight);

  @override
  double computeMaxIntrinsicWidth(double height) {
    return min(super.computeMaxIntrinsicWidth(height), maxWidth);
  }
}
