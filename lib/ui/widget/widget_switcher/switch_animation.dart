import 'package:flutter/material.dart';

import 'switch_transaction_setting.dart';

class SwitchAnimation extends SwitchTransactionSetting {
  Animation<double>? opacityInAnimation;
  Animation<double>? scaleInAnimation;
  Animation<Offset>? translateInAnimation;

  Animation<double>? opacityOutAnimation;
  Animation<double>? scaleOutAnimation;
  Animation<Offset>? translateOutAnimation;

  /// 當前的設定是否為push
  var _isPush = true;

  bool get isPush => _isPush;

  /// 是否有轉場動畫
  bool get haveTransition =>
      haveScaleIn ||
      haveOpacityIn ||
      haveScaleOut ||
      haveOpacityOut ||
      haveTranslateIn ||
      haveTranslateOut;

  SwitchAnimation({
    required AnimationController controller,
  }) : super(controller: controller);

  /// 設置動畫設定為推送或者彈出
  void setPush(bool isPush) {
    _isPush = isPush;
    updateSetting(
      curve: curve,
      opacityIn: opacityIn,
      opacityOut: opacityOut,
      scaleIn: scaleIn,
      scaleOut: scaleOut,
      translateIn: translateIn,
      translateOut: translateOut,
    );
  }

  /// 更新設定
  @override
  void updateSetting({
    Curve? curve,
    double? opacityIn,
    double? opacityOut,
    double? scaleIn,
    double? scaleOut,
    Offset? translateIn,
    Offset? translateOut,
  }) {
    super.updateSetting(
      curve: curve,
      opacityIn: opacityIn,
      opacityOut: opacityOut,
      scaleIn: scaleIn,
      scaleOut: scaleOut,
      translateIn: translateIn,
      translateOut: translateOut,
    );

    final haveScaleIn = scaleIn != null && scaleIn != 1;
    final haveOpacityIn = opacityIn != null && opacityIn != 1;
    final haveTranslateIn = translateIn != null && translateIn != Offset.zero;
    final haveScaleOut = scaleOut != null && scaleOut != 1;
    final haveOpacityOut = opacityOut != null && opacityOut != 1;
    final haveTranslateOut =
        translateOut != null && translateOut != Offset.zero;

    final curveAnimation = CurvedAnimation(
      parent: controller,
      curve: curve!,
    );

    if (_isPush) {
      opacityInAnimation = haveOpacityIn
          ? Tween(begin: opacityIn, end: 1.0).animate(curveAnimation)
          : null;
      opacityOutAnimation = haveOpacityOut
          ? Tween(begin: 1.0, end: opacityOut).animate(curveAnimation)
          : null;

      scaleInAnimation = haveScaleIn
          ? Tween(begin: scaleIn, end: 1.0).animate(curveAnimation)
          : null;
      scaleOutAnimation = haveScaleOut
          ? Tween(begin: 1.0, end: scaleOut).animate(curveAnimation)
          : null;

      translateInAnimation = haveTranslateIn
          ? Tween(begin: translateIn, end: Offset.zero).animate(curveAnimation)
          : null;
      translateOutAnimation = haveTranslateOut
          ? Tween(begin: Offset.zero, end: translateOut).animate(curveAnimation)
          : null;
    } else {
      opacityInAnimation = haveOpacityOut
          ? Tween(begin: opacityOut, end: 1.0).animate(curveAnimation)
          : null;
      opacityOutAnimation = haveOpacityIn
          ? Tween(begin: 1.0, end: opacityIn).animate(curveAnimation)
          : null;

      scaleInAnimation = haveScaleOut
          ? Tween(begin: scaleOut, end: 1.0).animate(curveAnimation)
          : null;
      scaleOutAnimation = haveScaleOut
          ? Tween(begin: 1.0, end: scaleIn).animate(curveAnimation)
          : null;

      translateInAnimation = haveTranslateOut
          ? Tween(begin: translateOut, end: Offset.zero).animate(curveAnimation)
          : null;
      translateOutAnimation = haveTranslateIn
          ? Tween(begin: Offset.zero, end: translateIn).animate(curveAnimation)
          : null;
    }
  }

  void dispose() {
    controller.dispose();
  }

  /// ====== 以下為照搬controller的變數以及方法 ======

  /// 當前是否動畫中
  bool get isAnimating => controller.isAnimating;

  /// 設置動畫控制器的時間
  void setControllerDuration(Duration duration) {
    controller.duration = duration;
  }

  /// 設置動畫控制器的進度
  /// 用於同步手勢回退的進度
  void setControllerProgress(double value) {
    controller.value = value;
  }

  /// 執行動畫
  TickerFuture forward() {
    return controller.forward();
  }

  /// 重置動畫
  void reset() {
    controller.reset();
  }
}
