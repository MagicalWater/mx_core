import 'package:flutter/material.dart';
import 'package:mx_core/util/num_util/double_calculate.dart';

import 'switch_transaction_setting.dart';

/// 元件滑動回退相關參數
class SwipePopData extends SwitchTransactionSetting {
  /// 回退的進度百分比
  double? popPageSwipeRate;

  /// 初始偏移
  Offset? _initPageOffset;

  /// 移出偏移
  Offset? pageOutOffset;

  /// 移入偏移
  Offset? pageInOffset;

  /// 移出透明值
  double? pageOutOpacity;

  /// 移入透明值
  double? pageInOpacity;

  /// 移出縮放值
  double? pageOutScale;

  /// 移入縮放值
  double? pageInScale;

  /// 重置滑出的頁面動畫位置
  Animation<Offset>? _restoreSwipePageAnimation;

  /// 手勢回退方向
  AxisDirection _backDirection;

  /// 觸發手勢回退的最大距離
  double triggerSwiperDistnance;

  SwipePopData({
    required AnimationController controller,
    required AxisDirection popDirection,
    required this.triggerSwiperDistnance,
  })  : _backDirection = popDirection,
        super(controller: controller);

  /// 清除滑動返回的資訊
  void clear() {
    pageInOffset = null;
    pageOutOffset = null;
    popPageSwipeRate = null;
    _restoreSwipePageAnimation?.removeListener(_restoreAnimationUpdateOffset);
    _restoreSwipePageAnimation = null;
    pageInOpacity = null;
    pageOutOpacity = null;
  }

  /// 設置手勢回退方向, 觸發距離
  void setPopDirection({
    required AxisDirection direction,
    required double triggerSwiperDistnance,
  }) {
    _backDirection = direction;
    this.triggerSwiperDistnance = triggerSwiperDistnance;
  }

  /// 橫向滑動開始
  /// [details] - 滑動資訊
  /// [containerBounds] - 容器的方形資訊, 用於檢測是否靠近邊緣
  /// [popDirection] - 回退檢測方向
  /// [triggerSwipeDistance] - 觸發回退的最大距離
  void onHorizontalDragStart({
    required DragStartDetails details,
    Rect? containerBounds,
  }) {
    _initPageOffset = null;
    if (containerBounds != null) {
      double distance;
      // 檢查是否靠近邊緣
      switch (_backDirection) {
        case AxisDirection.up:
          // 檢測下方
          distance = containerBounds.bottom - details.localPosition.dy;
          break;
        case AxisDirection.right:
          // 檢測左方
          distance = details.localPosition.dx;
          break;
        case AxisDirection.down:
          // 檢測上方
          distance = details.localPosition.dy;
          break;
        case AxisDirection.left:
          // 檢測右方
          distance = containerBounds.right - details.localPosition.dx;
          break;
      }
      if (distance < triggerSwiperDistnance) {
        _initPageOffset = details.globalPosition;
      }
    }
  }

  /// 橫向滑動更新, 回傳是否需要更新頁面
  bool onHorizontalDragUpdate({
    required DragUpdateDetails details,
  }) {
    if (_initPageOffset == null) {
      return false;
    } else if (!haveTranslateIn) {
      print('WidgetSwitcher: 尚未設置元件滑入偏移 translateIn, 無法進行手勢回退');
      _initPageOffset = null;
      return false;
    }

    final diffOffset = details.globalPosition - _initPageOffset!;

    // 依照回退方向, 計算出回退百分比
    switch (_backDirection) {
      case AxisDirection.up:
        // 上滑回退
        if (diffOffset.dy > 0) {
          popPageSwipeRate = 0;
        } else if (diffOffset.dy < translateIn!.dy) {
          popPageSwipeRate = 1;
        } else {
          popPageSwipeRate = diffOffset.dy.divide(translateIn!.dy);
        }
        break;
      case AxisDirection.down:
        // 下滑回退
        if (diffOffset.dy < 0) {
          popPageSwipeRate = 0;
        } else if (diffOffset.dy > translateIn!.dy) {
          popPageSwipeRate = 1;
        } else {
          popPageSwipeRate = diffOffset.dy.divide(translateIn!.dy);
        }
        break;
      case AxisDirection.right:
        // 右滑回退
        if (diffOffset.dx < 0) {
          popPageSwipeRate = 0;
        } else if (diffOffset.dx > translateIn!.dx) {
          popPageSwipeRate = 1;
        } else {
          popPageSwipeRate = diffOffset.dx.divide(translateIn!.dx);
        }
        break;
      case AxisDirection.left:
        // 左滑回退
        if (diffOffset.dx > 0) {
          popPageSwipeRate = 0;
        } else if (diffOffset.dx < translateIn!.dx) {
          popPageSwipeRate = 1;
        } else {
          popPageSwipeRate = diffOffset.dx.divide(translateIn!.dx);
        }
        break;
    }

    // 算出回退百分比後, 在此同步到元件偏移/淡出淡入/縮放
    _syncBackRateToOffset(popPageSwipeRate!);
    _syncBackRateToOpacity(popPageSwipeRate!);
    _syncBackRateToScale(popPageSwipeRate!);

    return true;
  }

  /// 橫向滑動結束, 於此判斷是否需要回彈, 或者將元件移回原本為至
  /// 回傳是否需要進行元件彈出
  ///
  /// [details] - 滑動資訊, 當滑動回cancel取消結束時將不會有值
  bool onHorizontalDragEnd({
    DragEndDetails? details,
  }) {
    if (pageOutOffset == null || pageOutOffset == Offset.zero) {
      clear();
      return false;
    }

    // 回退方向與加速度方向是否吻合
    // 若是回退方向吻合加速度方向, 則直接進行回退
    // 若是完全反方向, 則取消回退
    // 若是近乎靜止, 則判斷目前已回退的位置是否超過0.5
    bool? backEvent;

    // x軸加速度
    final velocityX = details?.velocity.pixelsPerSecond.dx ?? 0;
    // y軸加速度
    final velocityY = details?.velocity.pixelsPerSecond.dy ?? 0;

    // 依照方向加速度決定是否切換上一頁
    switch (_backDirection) {
      case AxisDirection.up:
        if (velocityY < 0) {
          backEvent = true;
        } else if (velocityY > 0) {
          backEvent = false;
        }
        break;
      case AxisDirection.right:
        if (velocityX > 0) {
          backEvent = true;
        } else if (velocityX < 0) {
          backEvent = false;
        }
        break;
      case AxisDirection.down:
        if (velocityY > 0) {
          backEvent = true;
        } else if (velocityY < 0) {
          backEvent = false;
        }
        break;
      case AxisDirection.left:
        if (velocityX < 0) {
          backEvent = true;
        } else if (velocityX > 0) {
          backEvent = false;
        }
        break;
    }

    if (backEvent == null) {
      // 檢查是否滑動超過螢幕一半
      if (popPageSwipeRate! >= 0.5) {
        // 超過螢幕一半代表切換上一頁
        print('回到上一頁: 滑動超過一半螢幕');
        return true;
      } else {
        print('停留本頁: 滑動小於一半螢幕');
        _restoreDragEffect();
        return false;
      }
    } else if (backEvent) {
      print('回到上一頁');
      return true;
    } else {
      print('停留本頁');
      _restoreDragEffect();
      return false;
    }
  }

  /// 恢復因手勢拖動造成的效果(偏移/透明/縮放)
  Future<void> _restoreDragEffect() async {
    popPageSwipeRate = null;

    // 恢復過程由[controller]動畫控制器完成
    // 需要監聽控制器的每個tick
    // 由此獲取到恢復百分比, 轉化為回退百分比, 同步至效果(偏移/透明/縮放)上
    _restoreSwipePageAnimation =
        Tween<Offset>(begin: pageOutOffset, end: Offset.zero)
            .chain(CurveTween(curve: curve!))
            .animate(controller)
          ..addListener(_restoreAnimationUpdateOffset);

    if (controller.isAnimating) {
      controller.reset();
    }

    await controller.forward();
  }

  /// 取得[controller]的進度, 轉化至回退百分比, 同步至拖拉效果上
  void _restoreAnimationUpdateOffset() {
    if (!controller.isAnimating || _restoreSwipePageAnimation == null) return;

    pageOutOffset = _restoreSwipePageAnimation!.value;

    switch (_backDirection) {
      case AxisDirection.up:
      case AxisDirection.down:
        popPageSwipeRate = pageOutOffset!.dy.divide(translateIn!.dy);
        break;
      case AxisDirection.right:
      case AxisDirection.left:
        popPageSwipeRate = pageOutOffset!.dx.divide(translateIn!.dx);
        break;
    }

    // 同步至拖拉效果
    _syncBackRateToOffset(popPageSwipeRate!);
    _syncBackRateToOpacity(popPageSwipeRate!);
    _syncBackRateToScale(popPageSwipeRate!);
  }

  /// 依照回退百分比, 同步至元件偏移上
  void _syncBackRateToOffset(double rate) {
    if (rate == 0) {
      pageOutOffset = Offset.zero;
      pageInOffset = translateOut;
    } else if (rate == 1) {
      pageOutOffset = translateIn;
      pageInOffset = Offset.zero;
    } else {
      pageOutOffset = translateIn! * rate;
      pageInOffset = translateOut! - (translateOut! * rate);
    }
  }

  /// 依照回退百分比, 同步至淡出淡入上
  void _syncBackRateToOpacity(double rate) {
    // 透過移出百分比同步移出透明值
    if (haveOpacityIn) {
      final diffIn = 1.0.subtract(opacityIn!);
      final convertDiff = diffIn.multiply(rate);
      pageOutOpacity = 1.0.subtract(convertDiff);
    }

    // 透過移出百分比同步移入透明值
    if (haveOpacityOut) {
      final diffOut = 1.0.subtract(opacityOut!);
      final convertDiff = diffOut.multiply(rate);
      pageInOpacity = opacityOut!.add(convertDiff);
    }
  }

  /// 依照回退百分比, 同步至縮放上
  void _syncBackRateToScale(double rate) {
    // 透過移出百分比同步移出縮放
    if (haveScaleIn) {
      if (scaleIn! > 1.0) {
        // 放大, 因此要倒過來減
        final diffIn = scaleIn!.subtract(1.0);
        final convertDiff = diffIn.multiply(rate);
        pageOutScale = 1.0.add(convertDiff);
      } else {
        // 縮小
        final diffIn = 1.0.subtract(scaleIn!);
        final convertDiff = diffIn.multiply(rate);
        pageOutScale = 1.0.subtract(convertDiff);
      }
    }

    // 透過移出百分比同步移入縮放
    if (haveScaleOut) {
      if (scaleOut! > 1.0) {
        final diffOut = scaleOut!.subtract(1.0);
        final convertDiff = diffOut.multiply(rate);
        pageInScale = scaleOut!.add(convertDiff);
      } else {
        final diffOut = 1.0.subtract(scaleOut!);
        final convertDiff = diffOut.multiply(rate);
        pageInScale = scaleOut!.add(convertDiff);
      }
    }
  }
}
