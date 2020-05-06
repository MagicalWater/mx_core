import 'dart:math';

import 'package:flutter/material.dart';

part 'color_value.dart';

part 'delay_value.dart';

part 'opacity_value.dart';

part 'parallel_value.dart';

part 'rotate_value.dart';

part 'scale_value.dart';

part 'size_value.dart';

part 'translate_value.dart';

/// 動畫抽象類, 可使用底下的相關靜態方法生成對應的動畫資料
/// [Comb.parallel] - 並行動畫
/// [Comb.rotateX] - 垂直翻轉動畫
/// [Comb.rotateY] - 水平翻轉動畫
/// [Comb.rotateZ] - 旋轉動畫
/// [Comb.opacity] - 透明動畫
/// [Comb.scale] - 縮放 width, height 動畫
/// [Comb.scaleX] - 縮放 width 動畫
/// [Comb.scaleY] - 縮放 height 動畫
/// [Comb.translate] - 位移動畫
/// [Comb.translateX] - x軸位移動畫
/// [Comb.translateY] - y軸位移動畫
/// [Comb.size] - size動畫
/// [Comb.width] - 寬度size動畫
/// [Comb.height] - 高度size動畫
/// [Comb.color] - 背景色變換動畫
abstract class Comb<T> {
  T begin;
  T end;

  /// 延遲時間
  int delayed;

  /// 動畫時間
  int duration;

  /// 動畫差值器
  Curve curve;

  /// 錨點
//  Alignment alignment;

  /// 取得此動畫物件的總花費時間
  int totalDuration(int defaultDuration) => duration ?? defaultDuration;

  @override
  int get hashCode => super.hashCode;

  bool operator ==(dynamic other) {
    if (other is Comb) {
      return begin == other.begin &&
          end == other.end &&
          delayed == other.delayed &&
          duration == other.duration &&
          curve == other.curve;
    }
    return false;
  }

  /// 並行動畫
  static CombParallel parallel({
    int delay,
    int duration,
    Curve curve,
    Alignment alignment,
    List<Comb> animatedList = const [],
  }) =>
      CombParallel._(
        delayed: delay,
        defaultDuration: duration,
        defaultCurve: curve,
        animatedList: animatedList,
      );

  /// 單純延遲
  static CombDelay delay(
    int delay,
  ) =>
      CombDelay._(duration: delay);

  /// 縮放動畫
  static CombScale scale({
    Size begin = const Size(1, 1),
    Size end = const Size(1, 1),
    int delay,
    int duration,
    Curve curve,
    Alignment alignment,
  }) =>
      CombScale._(
        ScaleType.all,
        begin: begin,
        end: end,
        delayed: delay,
        duration: duration,
        curve: curve,
      );

  static CombScale scaleX({
    double begin = 1.0,
    double end = 1.0,
    double y,
    int delay,
    int duration,
    Curve curve,
    Alignment alignment,
  }) =>
      CombScale._(
        y != null ? ScaleType.all : ScaleType.width,
        begin: Size(begin, y ?? 0),
        end: Size(end, y ?? 0),
        delayed: delay,
        duration: duration,
        curve: curve,
      );

  static CombScale scaleY({
    double begin = 1.0,
    double end = 1.0,
    double x,
    int delay,
    int duration,
    Curve curve,
    Alignment alignment,
  }) =>
      CombScale._(
        x != null ? ScaleType.all : ScaleType.height,
        begin: Size(x ?? 0, begin),
        end: Size(x ?? 0, end),
        delayed: delay,
        duration: duration,
        curve: curve,
      );

  /// size動畫
  static CombSize size({
    Size begin,
    Size end,
    int delay,
    int duration,
    Curve curve,
  }) =>
      CombSize._(
        SizeType.all,
        begin: begin,
        end: end,
        delayed: delay,
        duration: duration,
        curve: curve,
      );

  /// 寬度size動畫
  static CombSize width({
    double begin,
    double end,
    double height,
    int delay,
    int duration,
    Curve curve,
  }) =>
      CombSize._(
        height != null ? SizeType.all : SizeType.width,
        begin: Size(begin, height ?? 0),
        end: Size(end, height ?? 0),
        delayed: delay,
        duration: duration,
        curve: curve,
      );

  /// 高度size動畫
  static CombSize height({
    double begin,
    double end,
    double width,
    int delay,
    int duration,
    Curve curve,
  }) =>
      CombSize._(
        width != null ? SizeType.all : SizeType.height,
        begin: Size(width ?? 0, begin),
        end: Size(width ?? 0, end),
        delayed: delay,
        duration: duration,
        curve: curve,
      );

  /// 位移動畫
  static CombTranslate translate({
    Offset begin = Offset.zero,
    Offset end = Offset.zero,
    int delay,
    int duration,
    Curve curve,
  }) =>
      CombTranslate._(
        TransType.all,
        begin: begin,
        end: end,
        delayed: delay,
        duration: duration,
        curve: curve,
      );

  static CombTranslate translateX({
    double begin = 0,
    double end = 0,
    double y,
    int delay,
    int duration,
    Curve curve,
  }) =>
      CombTranslate._(
        y != null ? TransType.all : TransType.x,
        begin: Offset(begin, y ?? 0),
        end: Offset(end, y ?? 0),
        delayed: delay,
        duration: duration,
        curve: curve,
      );

  static CombTranslate translateY({
    double begin = 0,
    double end = 0,
    double x,
    int delay,
    int duration,
    Curve curve,
  }) =>
      CombTranslate._(
        x != null ? TransType.all : TransType.y,
        begin: Offset(x ?? 0, begin),
        end: Offset(x ?? 0, end),
        delayed: delay,
        duration: duration,
        curve: curve,
      );

  /// 旋轉動畫
  static CombRotate rotateZ({
    double begin = 0.0,
    double end = 0.0,
    int delay,
    int duration,
    Curve curve,
    Alignment alignment,
  }) =>
      CombRotate._(
        RotateType.z,
        begin: begin,
        end: end,
        delayed: delay,
        duration: duration,
        curve: curve,
      );

  /// 垂直翻轉動畫
  static CombRotate rotateX({
    double begin = 0.0,
    double end = 0.0,
    int delay,
    int duration,
    Curve curve,
    Alignment alignment,
  }) =>
      CombRotate._(
        RotateType.x,
        begin: begin,
        end: end,
        delayed: delay,
        duration: duration,
        curve: curve,
      );

  /// 水平翻轉動畫
  static CombRotate rotateY({
    double begin = 0.0,
    double end = 0.0,
    int delay,
    int duration,
    Curve curve,
    Alignment alignment,
  }) =>
      CombRotate._(
        RotateType.y,
        begin: begin,
        end: end,
        delayed: delay,
        duration: duration,
        curve: curve,
      );

  /// 透明動畫
  static CombOpacity opacity({
    double begin = 1.0,
    double end = 1.0,
    int delay,
    int duration,
    Curve curve,
  }) =>
      CombOpacity._(
        begin: begin,
        end: end,
        delayed: delay,
        duration: duration,
        curve: curve,
      );

  /// 背景色變換動畫
  static CombColor color({
    Color begin,
    Color end,
    int delay,
    int duration,
    Curve curve,
  }) =>
      CombColor._(
        begin: begin,
        end: end,
        delayed: delay,
        duration: duration,
        curve: curve,
      );
}
