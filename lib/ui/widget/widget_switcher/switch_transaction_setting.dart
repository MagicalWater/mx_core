import 'package:flutter/material.dart';

/// 動畫設定值
abstract class SwitchTransactionSetting {
  final AnimationController controller;

  /// 偏移
  @protected
  Offset? translateIn, translateOut;

  /// 淡出淡入
  @protected
  double? opacityIn, opacityOut;

  /// 縮放
  @protected
  double? scaleIn, scaleOut;

  /// 動畫曲線
  @protected
  Curve? curve;

  SwitchTransactionSetting({
    required this.controller,
  });

  bool get haveScaleIn => scaleIn != null && scaleIn != 1;

  bool get haveOpacityIn => opacityIn != null && opacityIn != 1;

  bool get haveTranslateIn => translateIn != null && translateIn != Offset.zero;

  bool get haveScaleOut => scaleOut != null && scaleOut != 1;

  bool get haveOpacityOut => opacityOut != null && opacityOut != 1;

  bool get haveTranslateOut =>
      translateOut != null && translateOut != Offset.zero;

  void updateSetting({
    Curve? curve,
    double? opacityIn,
    double? opacityOut,
    double? scaleIn,
    double? scaleOut,
    Offset? translateIn,
    Offset? translateOut,
  }) {
    this.curve = curve;
    this.translateIn = translateIn;
    this.translateOut = translateOut;
    this.opacityIn = opacityIn;
    this.opacityOut = opacityOut;
    this.scaleIn = scaleIn;
    this.scaleOut = scaleOut;
  }
}
