part of '../animated_core.dart';

/// 動畫抽象類, 可使用底下的相關靜態方法生成對應的動畫資料
/// [AnimatedValue.collection] - 並行動畫
/// [AnimatedValue.rotateX] - 垂直翻轉動畫
/// [AnimatedValue.rotateY] - 水平翻轉動畫
/// [AnimatedValue.rotateZ] - 旋轉動畫
/// [AnimatedValue.opacity] - 透明動畫
/// [AnimatedValue.scale] - 縮放 width, height 動畫
/// [AnimatedValue.scaleX] - 縮放 width 動畫
/// [AnimatedValue.scaleY] - 縮放 height 動畫
/// [AnimatedValue.translate] - 位移動畫
/// [AnimatedValue.translateX] - x軸位移動畫
/// [AnimatedValue.translateY] - y軸位移動畫
/// [AnimatedValue.width] - 寬度size動畫
/// [AnimatedValue.height] - 高度size動畫
/// [AnimatedValue.direction] - 方向位移動畫
abstract class AnimatedValue<T> {
  T begin;
  T end;

  /// 延遲時間
  int delayed;

  /// 動畫時間
  int duration;

  /// 動畫差值器
  Curve curve;

  /// 錨點
  Alignment alignment;

  /// 取得此動畫物件的總花費時間
  int totalDuration(int defaultDuration) => duration ?? defaultDuration;

  @override
  int get hashCode => super.hashCode;

  bool operator ==(dynamic other) {
    if (other is AnimatedValue) {
      return begin == other.begin &&
          end == other.end &&
          delayed == other.delayed &&
          duration == other.duration &&
          curve == other.curve &&
          alignment == other.alignment;
    }
    return false;
  }

  /// 並行動畫
  static _CollectionValue collection({
    int delay,
    int defaultDuration,
    Curve defaultCurve,
    Alignment defaultAlignment,
    List<AnimatedValue> animatedList = const [],
  }) =>
      _CollectionValue._(
        delayed: delay,
        defaultDuration: defaultDuration,
        defaultCurve: defaultCurve,
        animatedList: animatedList,
        defaultAlignment: defaultAlignment,
      );

  /// 單純延遲
  static _DelayValue delay(
    int delay,
  ) =>
      _DelayValue._(duration: delay);

  /// 縮放動畫
  static _ScaleValue scale({
    double begin = 1.0,
    double end = 1.0,
    int delay,
    int duration,
    Curve curve,
    Alignment alignment,
  }) =>
      _ScaleValue._(
        _ScaleType.all,
        begin: begin,
        end: end,
        delayed: delay,
        duration: duration,
        curve: curve,
        alignment: alignment,
      );

  static _ScaleValue scaleX({
    double begin = 1.0,
    double end = 1.0,
    int delay,
    int duration,
    Curve curve,
    Alignment alignment,
  }) =>
      _ScaleValue._(
        _ScaleType.width,
        begin: begin,
        end: end,
        delayed: delay,
        duration: duration,
        curve: curve,
        alignment: alignment,
      );

  static _ScaleValue scaleY({
    double begin = 1.0,
    double end = 1.0,
    int delay,
    int duration,
    Curve curve,
    Alignment alignment,
  }) =>
      _ScaleValue._(
        _ScaleType.height,
        begin: begin,
        end: end,
        delayed: delay,
        duration: duration,
        curve: curve,
        alignment: alignment,
      );

  /// 方向位移動畫
  /// 需要注意方向位移動畫初始化時需要時間
  /// 因此可能會有動畫初始化位置不正確的問題
  static _DirectionValue direction({
    AxisDirection begin,
    AxisDirection end,
    int delay,
    int duration,
    bool outScreen = false,
    Curve curve,
  }) =>
      _DirectionValue._(
        begin: begin,
        end: end,
        delayed: delay,
        duration: duration,
        outScreen: outScreen,
        curve: curve,
      );

  /// 寬度size動畫
  static _WidthValue width({
    double begin,
    double end,
    int delay,
    int duration,
    Curve curve,
  }) =>
      _WidthValue._(
        begin: begin,
        end: end,
        delayed: delay,
        duration: duration,
        curve: curve,
      );

  /// 高度size動畫
  static _HeightValue height({
    double begin,
    double end,
    int delay,
    int duration,
    Curve curve,
  }) =>
      _HeightValue._(
        begin: begin,
        end: end,
        delayed: delay,
        duration: duration,
        curve: curve,
      );

  /// 位移動畫
  static _TranslateValue translate({
    Offset begin,
    Offset end,
    int delay,
    int duration,
    Curve curve,
  }) =>
      _TranslateValue._(
        begin: begin,
        end: end,
        delayed: delay,
        duration: duration,
        curve: curve,
      );

  static _TranslateValue translateX({
    double begin,
    double end,
    int delay,
    int duration,
    Curve curve,
  }) =>
      _TranslateValue._(
        begin: Offset(begin, 0),
        end: Offset(end, 0),
        delayed: delay,
        duration: duration,
        curve: curve,
      );

  static _TranslateValue translateY({
    double begin,
    double end,
    int delay,
    int duration,
    Curve curve,
  }) =>
      _TranslateValue._(
        begin: Offset(0, begin),
        end: Offset(0, end),
        delayed: delay,
        duration: duration,
        curve: curve,
      );

  /// 旋轉動畫
  static _RotateValue rotateZ({
    double begin = 0.0,
    double end = 0.0,
    int delay,
    int duration,
    Curve curve,
    Alignment alignment,
  }) =>
      _RotateValue._(
        _RotateType.z,
        begin: begin,
        end: end,
        delayed: delay,
        duration: duration,
        curve: curve,
        alignment: alignment,
      );

  /// 垂直翻轉動畫
  static _RotateValue rotateX({
    double begin = 0.0,
    double end = 0.0,
    int delay,
    int duration,
    Curve curve,
    Alignment alignment,
  }) =>
      _RotateValue._(
        _RotateType.x,
        begin: begin,
        end: end,
        delayed: delay,
        duration: duration,
        curve: curve,
        alignment: alignment,
      );

  /// 水平翻轉動畫
  static _RotateValue rotateY({
    double begin = 0.0,
    double end = 0.0,
    int delay,
    int duration,
    Curve curve,
    Alignment alignment,
  }) =>
      _RotateValue._(
        _RotateType.y,
        begin: begin,
        end: end,
        delayed: delay,
        duration: duration,
        curve: curve,
        alignment: alignment,
      );

  /// 透明動畫
  static _OpacityValue opacity({
    double begin = 1.0,
    double end = 1.0,
    int delay,
    int duration,
    Curve curve,
  }) =>
      _OpacityValue._(
        begin: begin,
        end: end,
        delayed: delay,
        duration: duration,
        curve: curve,
      );
}
