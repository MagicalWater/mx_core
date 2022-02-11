import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mx_core/extension/list.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core/ui/widget/line_indicator.dart';
import 'package:mx_core/ui/widget/locate_row.dart';

import 'action_width.dart';
import 'tab_width.dart';

abstract class AbstractTabWidget extends StatefulWidget {
  final int? currentIndex;
  final bool scrollable;
  final ActionWidth? actionWidth;
  final TabWidth? tabWidth;
  final int tabCount;
  final int actionCount;

  const AbstractTabWidget({Key? key,
    required this.scrollable,
    required this.tabCount,
    required this.actionCount,
    this.currentIndex,
    this.actionWidth,
    this.tabWidth,
  }) : super(key: key);
}

mixin TabBarMixin<T extends AbstractTabWidget> on State<T> {
  /// 孩子與對應的 key
  List<GlobalKey> childKeyList = [];

  /// tab之間跟裡外會插入間隔
  /// 此對應代表插入間隔後的 index 對應到真正的孩子 index
  Map<int, int> tabIndexMap = {};

  Map<int, int> actionIndexMap = {};

  /// 真正的孩子 index 對應到 rect
  Map<int, Rect> tabRectMap = {};

  Map<int, Rect> actionRectMap = {};

  /// 總共的 size
  late Size totalSize;

  double? indicatorStart, indicatorEnd;

  late int currentIndex;

  /// 當前 index 的偏移量
  /// 此為搭配 [TabController] 時使用的偏移變數
  double? indexOffset;

  ScrollController? tabScrollController;

  bool needScrollCenter = false;

  @override
  @mustCallSuper
  void initState() {
    settingChildIndexMap();
    settingChildKey();
    super.initState();
  }

  @override
  @mustCallSuper
  void didUpdateWidget(T oldWidget) {
    if (widget.tabCount != oldWidget.tabCount) {
      tabRectMap.clear();
      settingChildIndexMap();
      settingChildKey();
    } else {
      syncIndicator();
    }
    super.didUpdateWidget(oldWidget);
  }

  /// 由於所有的列表之間跟裡外都會插入空格, 因此真正的 index 對應的孩子需要作轉換
  void settingChildIndexMap() {
    tabIndexMap.clear();
    for (var i = 0; i < widget.tabCount; i++) {
      var splitIndex = i * 2 + 1;
      tabIndexMap[splitIndex] = i;
    }

    var lastTabIndex = (widget.tabCount - 1) * 2 + 1;

    actionIndexMap.clear();
    for (var i = 0; i < widget.actionCount; i++) {
      var splitIndex = i * 2 + 1;
      actionIndexMap[splitIndex + (lastTabIndex + 1)] = i;
    }

    // print('tab index = $tabIndexMap');
    // print('action index = $actionIndexMap');
  }

  /// 給所有的 tab 加入 globalKey
  /// 方便在 Scrollable.of(context) 的方式將 tab 滑動到置中
  void settingChildKey() {
    for (var i = childKeyList.length; i < widget.tabCount; i++) {
//      childKeyList = List.generate(widget.tabCount, (index) => GlobalKey());
      childKeyList.add(GlobalKey());
    }
  }

  /// tab 元件組成
  /// [location] => 是否開啟記錄 tab 位置同步指示器
  Widget componentTabRow({
    required IndexedWidgetBuilder selectTab,
    required IndexedWidgetBuilder unSelectTab,
    required IndexedWidgetBuilder action,
    required IndexedWidgetBuilder gap,
    required Widget header,
    required Widget footer,
    required bool location,
  }) {
    var tabList = _buildTabList(
      tab: (context, index) {
        if (index == currentIndex) {
          return selectTab(context, index);
        } else {
          return unSelectTab(context, index);
        }
      },
      action: (context, index) {
        return action(context, index);
      },
      gap: gap,
      header: header,
      footer: footer,
      location: location,
    );

    Widget rowWidget;
    if (location) {
      rowWidget = LocateRow(
        mainAxisSize: MainAxisSize.min,
        children: tabList,
        onLocateChanged: (rects, totalSize) {
          // 取得每個 tab 真正的 rect
          tabIndexMap.forEach((key, value) {
            tabRectMap[value] = rects[key];
          });
          actionIndexMap.forEach((key, value) {
            actionRectMap[value] = rects[key];
          });
          // print('共有: ${rects.asMap()}');
          // print('打印: $tabRectMap');
          // print('總共: $totalSize');
          this.totalSize = totalSize;
          syncIndicator();
          WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
            if (needScrollCenter &&
                (tabScrollController?.position.maxScrollExtent ?? 0) > 0) {
              // print('自動轉移: ${tabScrollController != null} => ${tabRectMap[currentIndex].left}');

              // totalSize.width 是全部寬度
              // 當 totalSize.width - 最大滑動寬度 = 顯示寬度

              double showWidth = totalSize.width -
                  tabScrollController!.position.maxScrollExtent;

              var targetRect = tabRectMap[currentIndex]!;
              bool isShowFull = targetRect.right <= showWidth;

              if (!isShowFull) {
                tabScrollController?.animateTo(
                  targetRect.left,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.fastLinearToSlowEaseIn,
                );
              }
              needScrollCenter = false;
            }
            setState(() {});
          });
        },
      );
    } else {
      rowWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: tabList,
      );
    }

    return rowWidget;
  }

  /// 指示器
  Widget componentIndicator({
    required Duration duration,
    required Curve curve,
    required bool animation,
    Decoration? decoration,
    EdgeInsetsGeometry? padding,
  }) {
    // print('刷新指示: $indicatorStart, $indicatorEnd');
    return LineIndicator(
      decoration: decoration,
      start: indicatorStart ?? 0,
      end: indicatorEnd ?? 0,
      padding: padding,
      duration: duration,
      curve: curve,
      appearAnimation: false,
      animation: animation,
    );
  }

  /// 取得 rect 後, 同步 LineIndicator 顯示
  void syncIndicator() {
    if (currentIndex <= -1) {
      if (indicatorStart != null && indicatorEnd != null) {
        var center = indicatorStart!.add(indicatorEnd!).divide(2);
        indicatorStart = center;
        indicatorEnd = center;
      } else {
        indicatorStart = 0;
        indicatorEnd = 0;
      }
      return;
    }
    // print('rect = ${tabRectMap}, curr = $currentIndex');

    if (indexOffset != null && indexOffset != currentIndex) {
      var indexShow = indexOffset!.floor();
      if (indexShow == indexOffset) {
        // 滑動中, 但位於第 indexShow 個tab正中間, 不需要計算偏移
        var showRect = tabRectMap[indexShow]!;
        indicatorStart = showRect.left.divide(totalSize.width);
        indicatorEnd = showRect.right.divide(totalSize.width);
      } else if (indexOffset! > currentIndex) {
        // 往前滑動, 需要計算偏移

        var showRect = tabRectMap[indexShow]!;
        // print('往後偏移');
        // 往下一個偏移
        var nextRect = tabRectMap[indexShow + 1]!;

        // 計算依照偏移百分比計算
        var percent = indexOffset! - indexShow;

        var leftOffset =
            nextRect.left.subtract(showRect.left).multiply(percent);
        var rightOffset =
            nextRect.right.subtract(showRect.right).multiply(percent);

        indicatorStart = showRect.left.add(leftOffset).divide(totalSize.width);
        indicatorEnd = showRect.right.add(rightOffset).divide(totalSize.width);
      } else if (indexOffset! < currentIndex) {
        // 往後滑動, 需要計算偏移
        var showRect = tabRectMap[indexShow + 1]!;
        var preRect = tabRectMap[indexShow]!;

        // 計算依照偏移百分比計算
        var percent = indexOffset! - indexShow;

        var leftOffset = showRect.left.subtract(preRect.left).multiply(percent);
        var rightOffset =
            showRect.right.subtract(preRect.right).multiply(percent);

        indicatorStart = preRect.left.add(leftOffset).divide(totalSize.width);
        indicatorEnd = preRect.right.add(rightOffset).divide(totalSize.width);
      }
    } else {
      var showRect = tabRectMap[currentIndex]!;
      indicatorStart = showRect.left.divide(totalSize.width);
      indicatorEnd = showRect.right.divide(totalSize.width);
    }
  }

  /// 取得每個孩子的index
  List<Widget> _buildTabList({
    required IndexedWidgetBuilder tab,
    required IndexedWidgetBuilder action,
    required IndexedWidgetBuilder gap,
    required Widget header,
    required Widget footer,
    required bool location,
  }) {
    Widget packageAction(Widget actionWidget) {
      var actionWidth = widget.actionWidth;
      if (actionWidth?.fixed != null) {
//        print('固定寬度');
        return Container(width: actionWidth!.fixed, child: actionWidget);
      } else if (!widget.scrollable && actionWidth?.flex != null) {
        return Expanded(flex: actionWidth!.flex!, child: actionWidget);
      } else {
        return actionWidget;
      }
    }

    Widget packageTab(Widget tabWidget, int index) {
      var tabWidth = widget.tabWidth;
      if (tabWidth?.fixed != null) {
//        print('固定寬度');
        return SizedBox(
          key: location ? childKeyList[index] : null,
          width: tabWidth!.fixed,
          child: tabWidget,
        );
      } else if (!widget.scrollable && tabWidth?.flex != null) {
        return Expanded(flex: tabWidth!.flex!, child: tabWidget);
      } else {
        return Container(
          key: location ? childKeyList[index] : null,
          child: tabWidget,
        );
      }

      // widget.scrollable
      //     ? Container(
      //         key: location ? childKeyList[i] : null,
      //         child: tabWidget,
      //       )
      //     : Expanded(
      //         flex: 2,
      //         child: tabWidget,
      //       );
    }

    var children = <Widget>[
      for (var i = 0; i < widget.tabCount; i++) packageTab(tab(context, i), i),
      for (var i = 0; i < widget.actionCount; i++)
        packageAction(
          action(context, i),
        ),
    ].intersperse((index) => gap(context, index))
      ..insert(0, header)
      ..add(footer);

    return children;
  }
}
