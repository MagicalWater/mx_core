import 'package:flutter/cupertino.dart';
import 'package:mx_core/extension/list.dart';
import 'package:mx_core/ui/widget/line_indicator.dart';
import 'package:mx_core/ui/widget/locate_row.dart';

import 'action_width.dart';

abstract class AbstractTabWidget extends StatefulWidget {
  final int currentIndex;
  final bool scrollable;
  final ActionWidth actionWidth;
  final int tabCount;
  final int actionCount;

  AbstractTabWidget({
    this.currentIndex,
    this.scrollable,
    this.actionWidth,
    this.tabCount,
    this.actionCount,
  });
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
  Size totalSize;

  double indicatorStart, indicatorEnd;

  @override
  @mustCallSuper
  void initState() {
    _settingChildIndexMap();
    _settingChildKey();
    super.initState();
  }

  @override
  @mustCallSuper
  void didUpdateWidget(T oldWidget) {
    _settingChildIndexMap();
    _settingChildKey();
    syncIndicator();
    super.didUpdateWidget(oldWidget);
  }

  void _settingChildIndexMap() {
    // 由於所有的列表之間跟裡外都會插入空格, 因此真正的 index 對應的孩子需要作轉換
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

    print('tab index = $tabIndexMap');
    print('action index = $actionIndexMap');
  }

  void _settingChildKey() {
    // 由於所有的列表之間跟裡外都會插入空格, 因此真正的 index 對應的孩子需要作轉換
    for (var i = childKeyList.length; i < widget.tabCount; i++) {
//      childKeyList = List.generate(widget.tabCount, (index) => GlobalKey());
      childKeyList.add(GlobalKey());
    }
  }

  /// tab 元件組成
  /// [location] => 是否開啟記錄 tab 位置同步指示器
  Widget componentTabRow({
    IndexedWidgetBuilder selectTab,
    IndexedWidgetBuilder unSelectTab,
    IndexedWidgetBuilder action,
    IndexedWidgetBuilder gap,
    Widget header,
    Widget footer,
    bool location,
  }) {
    var tabList = _buildTabList(
      tab: (context, index) {
        if (index == widget.currentIndex) {
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
//          print('共有: ${rects.asMap()}');
//          print('打印: $tabRectMap');
//          print('總共: $totalSize');
          this.totalSize = totalSize;
          syncIndicator();
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
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
    Decoration decoration,
    Duration duration,
    Curve curve,
  }) {
    return LineIndicator(
      decoration: decoration,
      start: indicatorStart ?? 0,
      end: indicatorEnd ?? 0,
      duration: duration,
      curve: curve,
      appearAnimation: false,
    );
  }

  /// 取得 rect 後, 同步 LineIndicator 顯示
  void syncIndicator() {
    var showRect = tabRectMap[widget.currentIndex];
    indicatorStart = showRect.left / totalSize.width;
    indicatorEnd = showRect.right / totalSize.width;
  }

  /// 取得每個孩子的index
  List<Widget> _buildTabList({
    IndexedWidgetBuilder tab,
    IndexedWidgetBuilder action,
    IndexedWidgetBuilder gap,
    Widget header,
    Widget footer,
    bool location,
  }) {
    Widget packageAction(Widget actionWidget) {
      var actionWidth = widget.actionWidth;
      if (actionWidth?.fixed != null) {
//        print('固定寬度');
        return Container(
          width: actionWidth.fixed,
          child: actionWidget,
        );
      } else if (!widget.scrollable && actionWidth?.flex != null) {
        return Expanded(
          flex: actionWidth.flex,
          child: actionWidget,
        );
      } else {
        return actionWidget;
      }
    }

    var children = <Widget>[
      for (var i = 0; i < widget.tabCount; i++)
        widget.scrollable
            ? Container(
                key: location ? childKeyList[i] : null,
                child: tab(context, i),
              )
            : Expanded(
                flex: 2,
                child: tab(context, i),
              ),
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
