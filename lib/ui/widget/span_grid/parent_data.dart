import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class AlignGridParentData extends ContainerBoxParentData<RenderBox> {
  bool fill;
  int span;

  double width;
  double height;

  Rect get content => Rect.fromLTWH(
        offset.dx,
        offset.dy,
        width,
        height,
      );

  bool get isFill => fill;

  bool get isAlignChild => span != null;
}
