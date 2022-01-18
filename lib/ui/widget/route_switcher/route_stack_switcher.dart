import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';

/// 頁面切換元件, 內部核心調用[WidgetSwitcher]
/// 使用routes路由以及自訂回退達成頁面切換效果
/// 目前只支持路由子頁面的配置為[HistoryShow.stack]
class RouteStackSwitcher extends StatefulWidget {
  /// 頁面彈出處理
  /// 當開始滑動彈出時, 必須帶入此值
  final VoidCallback? onPopHandler;

  final Stream<List<RouteData>> stream;

  /// 當尚未有 route 傳入時, 所顯示的空元件
  /// 默認為 SizedBox.shrink()
  final Widget? emptyWidget;

  final Duration duration;

  /// 縮放係數 - 0~1, 1代表不縮放
  final double? scaleIn;

  /// 透明係數 - 0~1, 1代表不透明
  final double? opacityIn;

  /// 位移係數
  final Offset? translateIn;

  /// 縮放係數 - 0~1, 1代表不縮放
  final double? scaleOut;

  /// 透明係數 - 0~1, 1代表不透明
  final double? opacityOut;

  /// 位移係數
  final Offset? translateOut;

  /// 回退位移方向
  /// 預設 [AxisDirection.right] 右滑回退
  final AxisDirection popDirection;

  /// 是否啟用滑動彈出, 默認 false
  /// 若是啟用滑動彈出, 則[onPopHandler]必須帶入值
  final bool swipePopEnabled;

  /// 觸發滑動的距離, 默認 40
  final double triggerSwipeDistance;

  /// 動畫差值器
  /// 受限於無法從值反推回去t的關西, 暫時只能線性
  final Curve curve = Curves.linear;

  /// 動畫總開關
  final bool animateEnabled;

  /// 動畫陰影
  final BoxShadow? animatedShadow;

  /// 對齊方向
  final Alignment alignment;

  /// 轉場動畫貯列排序
  final StackConfig stackConfig;

  const RouteStackSwitcher._({
    required this.onPopHandler,
    required this.stream,
    required this.duration,
    required this.swipePopEnabled,
    required this.triggerSwipeDistance,
    required this.alignment,
    required this.stackConfig,
    required this.animateEnabled,
    this.popDirection = AxisDirection.right,
    this.animatedShadow,
    this.emptyWidget,
    this.scaleIn,
    this.opacityIn,
    this.translateIn,
    this.scaleOut,
    this.opacityOut,
    this.translateOut,
  });

  factory RouteStackSwitcher({
    VoidCallback? onPopHandler,
    required Stream<List<RouteData>> stream,
    Duration duration = const Duration(milliseconds: 200),
    AxisDirection popDirection = AxisDirection.right,
    double triggerSwipeDistance = 40,
    Alignment alignment = Alignment.center,
    StackConfig stackConfig = const StackConfig(),
    bool swipePopEnabled = false,
    bool animateEnabled = true,
    BoxShadow? animatedShadow = const BoxShadow(
      color: Colors.black26,
      blurRadius: 5,
      spreadRadius: 0,
    ),
    Widget? emptyWidget,
    double? scaleIn = 1,
    double? opacityIn = 0,
    Offset? translateIn = Offset.zero,
    double? scaleOut,
    double? opacityOut,
    Offset? translateOut,
  }) {
    if (scaleOut == null && scaleIn != null) {
      scaleOut = scaleIn;
    }
    if (opacityOut == null && opacityIn != null) {
      opacityOut = opacityIn;
    }
    if (translateOut == null && translateIn != null) {
      translateOut = translateIn;
    }

    assert(
      !swipePopEnabled || (swipePopEnabled && onPopHandler != null),
      'RouteStackSwitcher: 當開啟滑動彈出頁面時, 必須帶入onPopHandler自訂動作',
    );

    return RouteStackSwitcher._(
      onPopHandler: onPopHandler,
      stream: stream,
      duration: duration,
      emptyWidget: emptyWidget,
      scaleIn: scaleIn,
      scaleOut: scaleOut,
      opacityIn: opacityIn,
      opacityOut: opacityOut,
      translateIn: translateIn,
      translateOut: translateOut,
      popDirection: popDirection,
      swipePopEnabled: swipePopEnabled,
      triggerSwipeDistance: triggerSwipeDistance,
      alignment: alignment,
      stackConfig: stackConfig,
      animateEnabled: animateEnabled,
      animatedShadow: animatedShadow,
    );
  }

  @override
  _RouteStackSwitcherState createState() => _RouteStackSwitcherState();
}

class _RouteStackSwitcherState extends State<RouteStackSwitcher> {
  final controller = WidgetSwitchController<String>();

  /// 路由訂閱監聽
  StreamSubscription<List<RouteData>>? routeSubscription;

  /// 當前顯示的路由歷史
  List<RouteData> routes = [];

  @override
  void initState() {
    routeSubscription = widget.stream.listen((event) {
      // 比對路由, 檢查跳轉方式
      if (event.isNotEmpty) {
        final lastRoute = event.last;
        final isPush = !lastRoute.isPop;
        if (isPush) {
          // 是往前推, 檢查是否有刪除歷史
          final removedIndex = _getRemovedRouteIndex(
            pre: routes,
            current: event,
          );
          controller.push(
            lastRoute.route,
            removeUntil: (tag, index) {
              if (removedIndex.contains(index)) {
                return false;
              }
              return true;
            },
          );
        } else {
          controller.pop(popUntil: (tag, index) {
            if (index == event.length - 1) {
              return true;
            }
            return false;
          });
        }
      } else {
        controller.pop(popUntil: (tag, index) => false);
      }
      routes = event;
    });
    super.initState();
  }

  /// 比較前後兩個route history
  /// 取得被刪除的歷史
  List<int> _getRemovedRouteIndex({
    required List<RouteData> pre,
    required List<RouteData> current,
  }) {
    final maxIndex = max(pre.length, current.length);
    final List<int> removedIndex = [];

    for (var i = 0; i < maxIndex; i++) {
      final preRoute = pre.length > i ? pre[i] : null;
      final currentRoute = current.length > i ? current[i] : null;

      if (preRoute != null && currentRoute != null) {
        // 比較兩個是否一樣
        if (preRoute.route == currentRoute.route) {
          // 路由相同
        } else {
          // 路由不同
          removedIndex.add(i);
        }
      } else if (preRoute == null) {
        // 新添加的route
      } else if (currentRoute == null) {
        // 路由已被刪除
        removedIndex.add(i);
      }
    }
    return removedIndex;
  }

  @override
  void dispose() {
    routeSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WidgetSwitcher(
      controller: controller,
      builder: (BuildContext context, String tag) {
        return appRouter.getPage(tag);
      },
      onPopHandler: widget.onPopHandler,
      duration: widget.duration,
      swipePopEnabled: widget.swipePopEnabled,
      triggerSwipeDistance: widget.triggerSwipeDistance,
      alignment: widget.alignment,
      stackConfig: widget.stackConfig,
      animateEnabled: widget.animateEnabled,
      popDirection: widget.popDirection,
      animatedShadow: widget.animatedShadow,
      emptyWidget: widget.emptyWidget,
      scaleIn: widget.scaleIn,
      opacityIn: widget.opacityIn,
      translateIn: widget.translateIn,
      scaleOut: widget.scaleOut,
      opacityOut: widget.opacityOut,
      translateOut: widget.translateOut,
    );
  }
}
