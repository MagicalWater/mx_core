import 'dart:async';
import 'dart:math';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mx_core/ui/widget/animated_comb/animated_comb.dart';
import 'package:mx_core/ui/widget/arrow_container.dart';
import 'package:mx_core/ui/widget/navigator_provider.dart';
import 'package:mx_core/util/screen_util.dart';
import 'package:mx_core/util/widget_rect.dart';

import 'arrow_style.dart';
import 'layout_option.dart';
import 'route_option.dart';

part 'controller.dart';

part 'layout.dart';

part 'rule.dart';

part 'widget.dart';

typedef PopupWidgetBuilder<T> = Widget Function(
  PopupController<T> controller,
);

List<PopupController> _allShowPopup = [];

/// 彈跳視窗類
/// 共有下列幾個靜態方法可使用
/// [Popup.showRoute] - 以 route 方式顯示彈跳視窗(無法使用穿透點擊, 可以視為一個新的頁面, 只是仍然渲染背景)
/// [Popup.showOverlay] - 以 overlay entry 方式顯示彈跳視窗(可使用穿透點擊)
/// [Popup.showArrow] - 箭頭彈跳視窗, 核心為 [Popup.showOverlay]
class Popup {
  Popup._();

  /// 彈出所有彈窗
  static Future<void> removeAll() async {
    final allRemove = <Future<void>>[];
    for (var element in _allShowPopup) {
      allRemove.add(element.remove());
    }
    _allShowPopup.clear();
    await Future.wait(allRemove);
  }

  /// [option] - 彈窗屬性
  /// [builder] - 彈窗元件構建
  /// [animated] - 顯示動畫, 空陣列將使用預設動畫 [Comb.scale], 若不需要動畫則帶入 null
  /// [onTapSpace] - 點擊空白處
  /// [onTapBack] - 點擊返回鍵, 默認將會關閉彈窗
  static PopupController<NavigatorState> showRoute({
    required PopupWidgetBuilder<NavigatorState> builder,
    PopupOption? option,
    List<Comb>? animated = const [],
    void Function(PopupController<NavigatorState> controller)? onTapSpace,
    void Function(PopupController<NavigatorState> controller)? onTapBack,
    RouteSettings? routeSettings,
    PopupRouteOption routeOption = const PopupRouteOption(),
  }) {
    if (animated?.isEmpty == true) {
      animated = [
        Comb.parallel(animatedList: [
          Comb.scale(
            begin: const Size.square(0),
            end: const Size.square(1),
            curve: Curves.easeOutSine,
          ),
          Comb.opacity(begin: 0, end: 1, duration: 200),
        ]),
      ];
    }

    final backgroundSync = AnimatedSyncTick.identity(
      type: AnimatedType.toggle,
      initToggle: true,
    );

    final childSync = AnimatedSyncTick.identity(
      type: AnimatedType.toggle,
      initToggle: true,
    );

    final controller = RouteController();
    _allShowPopup.add(controller);

    final child = builder(controller);

    final childGesture = GestureDetector(
      onTap: () {},
      child: child,
    );

    final layout = _PopupLayout(
      settings: routeSettings,
      maintainState: routeOption.maintainState,
      opaque: routeOption.opaque,
      barrierColor: routeOption.barrierColor,
      barrierDismissible: routeOption.barrierDismissible,
      barrierLabel: routeOption.barrierLabel,
      child: Material(
        type: MaterialType.transparency,
        child: GestureDetector(
          onTap: () {
            if (onTapSpace != null) {
              onTapSpace(controller);
            }
          },
          child: AnimatedComb.quick(
            sync: backgroundSync,
            color: Comb.color(
              begin: Colors.transparent,
              end: option?.maskColor ?? Colors.transparent,
            ),
            child: PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) {
                if (onTapBack != null) {
                  onTapBack(controller);
                } else {
                  controller.remove();
                }
              },
              child: Container(
                padding: option?.getOverlayPadding(child is ShiftAnimation),
                child: animated != null
                    ? AnimatedComb(
                        alignment: option?.alignment ?? FractionalOffset.center,
                        sync: childSync,
                        animatedList: animated,
                        child: childGesture,
                      )
                    : childGesture,
              ),
            ),
          ),
        ),
      ),
    );
    navigatorIns.push(layout);
    controller
      ..registerController(childSync)
      ..registerController(backgroundSync);
    return controller;
  }

  /// [hitRule] - 點擊事件處理規則
  /// [option] - 位置 / 寬高相關屬性
  /// [animated] - 顯示動畫, 空陣列將使用預設動畫 [Comb.scale], 若不需要動畫則帶入 null
  /// [onTapSpace] - 點擊空白處回調, 只有在 [hitRule] 等於 [HitRule.intercept] 時有效
  /// [onTapBack] - 點擊返回鍵, 默認將會關閉彈窗
  /// [below] - 在此彈窗之下
  /// [above] - 在此彈窗之上
  static PopupController<OverlayEntry?> showOverlay({
    required PopupWidgetBuilder<OverlayEntry?> builder,
    PopupOption? option,
    HitRule hitRule = HitRule.intercept,
    List<Comb>? animated = const [],
    void Function(PopupController<OverlayEntry?> controller)? onTapSpace,
    void Function(PopupController<OverlayEntry?> controller)? onTapBack,
    OverlayEntry? below,
    OverlayEntry? above,
  }) {
    if (animated?.isEmpty == true) {
      animated = [
        Comb.parallel(
          animatedList: [
            Comb.scale(begin: const Size.square(0.8)),
            Comb.opacity(begin: 0),
          ],
        ),
      ];
    }

    final controller = OverlayController();
    _allShowPopup.add(controller);
    final backgroundSync = AnimatedSyncTick.identity(
      type: AnimatedType.toggle,
      initToggle: true,
    );
    final childSync = AnimatedSyncTick.identity(
      type: AnimatedType.toggle,
      initToggle: true,
    );

    void popupCallback() {
      if (onTapBack != null) {
        onTapBack(controller);
      } else {
        controller.remove();
      }
    }

    final child = builder(controller);

    final childGesture = GestureDetector(
      onTap: () {},
      child: child,
    );

    final entry = OverlayEntry(
      builder: (context) {
        return _TapWidget(
          hitRule: hitRule,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () {
                if (hitRule == HitRule.intercept && onTapSpace != null) {
                  onTapSpace(controller);
                }
              },
              child: AnimatedComb.quick(
                sync: backgroundSync,
                color: Comb.color(
                  begin: Colors.transparent,
                  end: option?.maskColor ?? Colors.transparent,
                ),
                child: Container(
                  padding: option?.getOverlayPadding(child is SafeArea),
                  child: _DetectWidget(
                    child: animated != null
                        ? AnimatedComb(
                            alignment:
                                option?.alignment ?? FractionalOffset.center,
                            sync: childSync,
                            animatedList: animated,
                            child: childGesture,
                          )
                        : childGesture,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    navigatorIns.overlay!.insert(entry, below: below, above: above);
    controller
      ..registerController(backgroundSync)
      ..registerController(childSync)
      ..registerBackButtonListener(popupCallback)
      ..setEntry(entry);
    return controller;
  }

  static PopupController<OverlayEntry?>? showArrow({
    required BuildContext context,
    required PopupWidgetBuilder<OverlayEntry?> builder,
    ArrowPopupStyle style = const ArrowPopupStyle(),
    Color? maskColor,
    void Function(PopupController<OverlayEntry?> controller)? onTapSpace,
    OverlayEntry? below,
    OverlayEntry? above,
  }) {
    // 取得元件在螢幕上的位置
    final rectResult = WidgetRectUtils.rectOnScreen(context);
    final attachRect = rectResult.visibleRect;

    // 只有當元件的 rect 不為空值時才可以彈窗
    if (attachRect == null || attachRect.isEmpty) return null;

    return showArrowWithRect(
      attachRect: attachRect,
      builder: builder,
      style: style,
      maskColor: maskColor,
      onTapSpace: onTapSpace,
      below: below,
      above: above,
    );
  }

  static PopupController<OverlayEntry?>? showArrowWithRect({
    required Rect attachRect,
    required PopupWidgetBuilder<OverlayEntry?> builder,
    ArrowPopupStyle style = const ArrowPopupStyle(),
    Color? maskColor,
    void Function(PopupController<OverlayEntry?> controller)? onTapSpace,
    OverlayEntry? below,
    OverlayEntry? above,
  }) {
    // 初始化螢幕資訊, 防止在此之前沒有初始化過
    Screen.init();

    // 取得對其的點
    final alignmentPoint = _getAlignmentPoint(
      attachRect,
      style.alignment,
      style.offset,
    );
//    print("取得對齊點: ${alignmentPoint}");

    // 根據元件對齊的點取得相對全螢幕的錨點
    final anchorOffset = FractionalOffset(
      alignmentPoint.x / Screen.width,
      alignmentPoint.y / Screen.height,
    );

    // 取得可以裝載彈出視窗的最大範圍
    final maxRect = _getWidgetMaxRect(
      attachRect: attachRect,
      safeArea: style.safeArea,
      boundedPadding: style.boundedPadding,
      direction: style.direction,
      alignmentPoint: alignmentPoint,
    );

    if (maxRect.isEmpty) {
      // 沒有空間可容納 popup, 直接返回
      print("警告 - 無空間可容納彈出視窗");
      return null;
    }

//    print('''
//==== 箭頭彈窗資訊 ====
//填充 $attachRect
//對齊 ${style.alignment}
//座標 $alignmentPoint
//百分比 $anchorOffset
//容器 $maxRect
//螢幕 ${Screen.width} x ${Screen.height}
//==== ～～～～～～ ====
//    ''');

    final childSizeStreamController = StreamController<Size>();

    final popupController = Popup.showOverlay(
      animated: [
        Comb.parallel(
          animatedList: [
            _getScaleAnimated(style.popupScale, anchorOffset),
            Comb.opacity(begin: 0, end: 1, duration: 200),
          ],
        ),
      ],
      option: PopupOption(
        alignment: anchorOffset,
        maskColor: maskColor,
      ),
      hitRule: HitRule.intercept,
      onTapSpace: onTapSpace,
      builder: (controller) {
        final child = builder(controller);
        return StreamBuilder<Size>(
          stream: childSizeStreamController.stream,
          builder: (context, snapshot) {
            final widgetOffset = snapshot.hasData && !snapshot.data!.isEmpty
                ? _getWidgetOffset(
                    alignmentPoint: alignmentPoint,
                    widgetSize: snapshot.data!,
                    maxRect: maxRect,
                    direction: style.direction,
                    arrowLeafPercent: style.arrowTargetPercent,
                  )
                : null;

//            if (widgetOffset != null) {
//              print('''
//==== 元件偏移資訊 ====
//內容 ${snapshot.data}
//偏移 ${widgetOffset?.dx}, ${widgetOffset?.dy}
//==== ～～～～～～ ====
//              ''');
//            }

            return Container(
              transform: widgetOffset == null
                  ? null
                  : (Matrix4.identity()
                    ..translate(widgetOffset.dx, widgetOffset.dy)),
              child: Align(
                alignment: Alignment.topLeft,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: maxRect.width,
                    maxHeight: maxRect.height,
                  ),
                  child: ArrowContainer(
                    shiftRootPercent: widgetOffset?.arrowLeafPercent ??
                        style.arrowTargetPercent,
                    shiftLeafPercent: widgetOffset?.arrowLeafPercent ??
                        style.arrowTargetPercent,
                    color: style.color,
                    strokeColor: style.strokeColor,
                    strokeWidth: style.strokeWidth,
                    gradient: style.gradient,
                    strokeGradient: style.strokeGradient,
                    radius: style.radius,
                    arrowSize: style.arrowSize,
                    arrowSide: style.arrowSide,
                    arrowRootSize: style.arrowRootSize,
                    direction: _getArrowDirection(style.direction),
                    onSized: (size) {
                      if (childSizeStreamController.isClosed) {
                        return;
                      }
                      childSizeStreamController.add(size);
                    },
                    child: child,
                  ),
                ),
              ),
            );
          },
        );
      },
      below: below,
      above: above,
    );

    popupController.registerRemoveEventCallback(
      onStart: () {
        childSizeStreamController.close();
      },
    );

    return popupController;
  }

  /// 傳入 Rect, 取得 Alignment 再其中的絕對位置
  static Point<double> _getAlignmentPoint(
      Rect rect, Alignment alignment, Offset offset) {
    final alignmentX = (rect.width / 2) * (1 + alignment.x);
    final alignmentY = (rect.height / 2) * (1 + alignment.y);

    return Point(
      rect.left + alignmentX + offset.dx,
      rect.top + alignmentY + offset.dy,
    );
  }

  static Comb _getScaleAnimated(
    PopupScale popupScale,
    FractionalOffset anchor,
  ) {
    if (popupScale == PopupScale.vertical) {
      return Comb.scaleY(begin: 0.8, x: 1);
    } else if (popupScale == PopupScale.horizontal) {
      return Comb.scaleX(begin: 0.8, y: 1);
    } else {
      return Comb.scale(begin: const Size.square(0.8));
    }
  }

  /// 取得箭頭方向
  static AxisDirection _getArrowDirection(AxisDirection widgetDirection) {
    switch (widgetDirection) {
      case AxisDirection.up:
        return AxisDirection.down;
      case AxisDirection.right:
        return AxisDirection.left;
      case AxisDirection.down:
        return AxisDirection.up;
      case AxisDirection.left:
        return AxisDirection.right;
    }
  }

  /// 根據方向以及箭頭的指標百分比
  /// 取得 widget 的 Offset
  static _WidgetOffset _getWidgetOffset({
    required Point alignmentPoint,
    required Size widgetSize,
    required Rect maxRect,
    required AxisDirection direction,
    required double arrowLeafPercent,
  }) {
    final widgetOffset = _WidgetOffset(
      offset: Offset.zero,
      arrowLeafPercent: arrowLeafPercent,
    );

    double dx, dy;
    switch (direction) {
      case AxisDirection.left:
        dx = alignmentPoint.x - widgetSize.width;
        dy = alignmentPoint.y - (widgetSize.height * arrowLeafPercent);
        if (dy < maxRect.top) {
          // 上方超出邊界, 需要修正
//        print("上方超出邊界, 需要修正");
          dy = maxRect.top;
          widgetOffset.arrowLeafPercent =
              (alignmentPoint.y - dy) / widgetSize.height;
        } else if (dy + widgetSize.height > maxRect.bottom) {
          // 下方超出邊界, 需要修正
//        print("下方超出邊界, 需要修正");
          dy = maxRect.bottom - widgetSize.height;
          widgetOffset.arrowLeafPercent =
              (alignmentPoint.y - dy) / widgetSize.height;
        }
        break;
      case AxisDirection.up:
        dx = alignmentPoint.x - (widgetSize.width * arrowLeafPercent);
        dy = alignmentPoint.y - widgetSize.height;
        if (dx < maxRect.left) {
          // 左邊超出邊界, 需要修正
          // print("左邊超出邊界, 需要修正");
          dx = maxRect.left;
          widgetOffset.arrowLeafPercent =
              (alignmentPoint.x - dx) / widgetSize.width;
        } else if (dx + widgetSize.width > maxRect.right) {
          // 右邊超出邊界, 需要修正
          // print("右邊超出邊界, 需要修正");
          dx = Screen.width - widgetSize.width;
          widgetOffset.arrowLeafPercent =
              (alignmentPoint.x - dx) / widgetSize.width;
        }
        break;
      case AxisDirection.right:
        dx = alignmentPoint.x.toDouble();
        dy = alignmentPoint.y - (widgetSize.height * arrowLeafPercent);
        if (dy < maxRect.top) {
          // 上方超出邊界, 需要修正
//        print("上方超出邊界, 需要修正");
          dy = maxRect.top;
          widgetOffset.arrowLeafPercent =
              (alignmentPoint.y - maxRect.top) / widgetSize.height;
        } else if (dy + widgetSize.height > maxRect.bottom) {
          // 下方超出邊界, 需要修正
//        print("下方超出邊界, 需要修正");
          dy = maxRect.bottom - widgetSize.height;
          widgetOffset.arrowLeafPercent =
              (alignmentPoint.y - dy) / widgetSize.height;
        }
        break;
      case AxisDirection.down:
        dx = alignmentPoint.x - (widgetSize.width * arrowLeafPercent);
        dy = alignmentPoint.y.toDouble();
        if (dx < maxRect.left) {
          // 左邊超出邊界, 需要修正
          // print("左邊超出邊界, 需要修正");
          final xPercentValue =
              (widgetSize.width * arrowLeafPercent) - (maxRect.left - dx);
          final xPercent = (xPercentValue) / widgetSize.width;
          dx = maxRect.left;
          widgetOffset.arrowLeafPercent = xPercent;
        } else if (dx + widgetSize.width > maxRect.right) {
          // 右邊超出邊界, 需要修正
          // print("右邊超出邊界, 需要修正");
          dx = maxRect.right - widgetSize.width;
          widgetOffset.arrowLeafPercent =
              (alignmentPoint.x - dx) / widgetSize.width;
        }
        break;
    }
    widgetOffset.offset = Offset(dx, dy);
    return widgetOffset;
  }

  /// 取得元件最大可以放置的 rect
  /// [attachRect] 元件的 rect
  /// [safeArea] 是否需要限制在安全區域
  /// [boundedPadding] 彈出視窗與邊界的距離
  /// [direction] 彈窗顯示的方向(相對於attachRect)
  /// [alignmentPoint] 代表 [attachRect] 的對齊點
  static Rect _getWidgetMaxRect({
    required Rect attachRect,
    required bool safeArea,
    required EdgeInsets? boundedPadding,
    required AxisDirection direction,
    required Point alignmentPoint,
  }) {
    final paddingTop = boundedPadding?.top ?? 0;
    final paddingBottom = boundedPadding?.bottom ?? 0;
    final paddingLeft = boundedPadding?.left ?? 0;
    final paddingRight = boundedPadding?.right ?? 0;

    Rect maxRect;
    switch (direction) {
      case AxisDirection.up:
        // 在目標元件上方

      final top = safeArea ? Screen.statusBarHeight + paddingTop : paddingTop;

        maxRect = Rect.fromLTWH(
          paddingLeft,
          safeArea ? Screen.statusBarHeight + paddingTop : paddingTop,
          Screen.width - paddingLeft - paddingRight,

          // 因為下方接著目標元件, 因此不適用boundedPadding.bottom
          alignmentPoint.y.toDouble() - top,
        );
        break;
      case AxisDirection.right:
        // 在目標元件右側

        maxRect = Rect.fromLTWH(
          // 因為左方接著目標元件, 因此不適用boundedPadding.left
          alignmentPoint.x.toDouble(),
          safeArea ? Screen.statusBarHeight + paddingTop : paddingTop,
          Screen.width - alignmentPoint.x - paddingRight,
          safeArea
              ? Screen.contentHeight - paddingTop - paddingBottom
              : Screen.height - paddingTop - paddingBottom,
        );
        break;
      case AxisDirection.down:
        // 在目標元件下方

        maxRect = Rect.fromLTWH(
          paddingLeft,

          // 因為上方接著目標元件, 因此不適用boundedPadding.top
          alignmentPoint.y.toDouble(),
          Screen.width - paddingLeft - paddingRight,
          safeArea
              ? Screen.height - Screen.bottomBarHeight - paddingBottom
              : Screen.height - paddingBottom,
        );
        break;
      case AxisDirection.left:
        // 在目標元件左側
        maxRect = Rect.fromLTWH(
          paddingLeft,
          safeArea ? Screen.statusBarHeight + paddingTop : paddingTop,
          alignmentPoint.x.toDouble() - paddingLeft,
          safeArea
              ? Screen.contentHeight - paddingTop - paddingBottom
              : Screen.height - paddingTop - paddingBottom,
        );
//      print("螢幕寬度: ${screenWidth}, 最大寬度: ${maxRect.width}");
        break;
    }
    return maxRect;
  }
}

class _WidgetOffset {
  Offset offset;
  double arrowLeafPercent;

  double get dx => offset.dx;

  double get dy => offset.dy;

  _WidgetOffset({
    required this.offset,
    required this.arrowLeafPercent,
  });

  @override
  String toString() {
    return 'offset = $offset, leaf percent = $arrowLeafPercent';
  }
}

/// 箭頭彈窗的縮放動畫
enum PopupScale { vertical, horizontal, all }
