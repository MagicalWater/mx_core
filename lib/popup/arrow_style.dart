import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mx_core/ui/widget/arrow_container.dart';

import 'impl.dart';

/// 彈出視窗的相關屬性
class ArrowPopupStyle {
  /// 外框寬度
  final double strokeWidth;

  /// 外框顏色
  final Color strokeColor;

  /// 外框漸變
  final Gradient? strokeGradient;

  /// 內容顏色
  final Color color;

  /// 浮出視窗時的背景顏色
  final Gradient? gradient;

  /// 外框圓角半徑
  final Color? backgroundColor;

  /// 箭頭大小
  final double radius;

  /// 箭頭大小
  final double arrowSize;

  /// 箭頭類型
  final ArrowSide arrowSide;

  /// 箭頭根部寬度, 只在 [arrowSide] 為 [ArrowSide.line] 時有效
  final double arrowRootSize;

  /// 浮出視窗的方向(與元件相比)
  final double arrowTargetPercent;

  /// 箭頭指向在 [direction] 的百分點
  final AxisDirection direction;

  /// 彈窗的箭頭指向元件的對齊位置
  final Alignment alignment;

  /// 彈窗的箭頭所指向元件的偏移位置
  final Offset offset;

  /// 彈出視窗的展開動畫類型
  final PopupScale popupScale;

  /// 彈出視窗是否需要限制空間(不突出導航欄)
  final bool safeArea;

  const ArrowPopupStyle({
    this.strokeWidth = 2,
    this.strokeColor = Colors.black,
    this.strokeGradient,
    this.color = Colors.white,
    this.gradient,
    this.backgroundColor,
    this.radius = 4,
    this.arrowSize = 20,
    this.arrowSide = ArrowSide.bezier,
    this.arrowRootSize = 20,
    this.arrowTargetPercent = 0.5,
    this.direction = AxisDirection.right,
    this.alignment = Alignment.center,
    this.offset = Offset.zero,
    this.popupScale = PopupScale.all,
    this.safeArea = true,
  });
}
