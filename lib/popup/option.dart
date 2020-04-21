import 'package:flutter/material.dart';

class PopupOption {
  double left;
  double top;
  double width;
  double height;
  Alignment alignment;

  /// 背景遮罩顏色
  Color maskColor;

  PopupOption({
    this.maskColor,
    this.left,
    this.top,
    this.width,
    this.height,
    this.alignment = Alignment.topLeft,
  });
}