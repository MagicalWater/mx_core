import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mx_core/util/screen_util.dart';

import '../line_indicator.dart';
import 'action_width.dart';
import 'base_tab_bar.dart';
import 'builder/builder.dart';
import 'indicator_style.dart';

class SwipeTabBar extends AbstractTabWidget {
  final SwipeTabBuilder tabBuilder;
  final ValueChanged<int> onTabTap;
  final ValueChanged<int> onActionTap;
  final double tabHeight;
  final TabIndicator indicator;
  final IndexedWidgetBuilder gapBuilder;
  final Widget header;
  final Widget footer;

  SwipeTabBar._({
    int currentIndex,
    bool scrollable = false,
    ActionWidth actionWidth,
    this.tabBuilder,
    this.indicator,
    this.tabHeight,
    this.gapBuilder,
    this.header,
    this.footer,
    this.onTabTap,
    this.onActionTap,
  }) : super(
          currentIndex: currentIndex,
          scrollable: scrollable,
          actionWidth: actionWidth,
          tabCount: tabBuilder.tabCount,
          actionCount: tabBuilder.actionCount,
        );

  factory SwipeTabBar.text({
    int currentIndex,
    TextTabBuilder builder,
    bool scrollable = false,
    ActionWidth actionWidth,
    double tabHeight,
    TabIndicator indicator,
    IndexedWidgetBuilder gapBuilder,
    Widget header,
    Widget footer,
    ValueChanged<int> onTabTap,
    ValueChanged<int> onActionTap,
  }) {
    return SwipeTabBar._(
      currentIndex: currentIndex,
      scrollable: scrollable,
      actionWidth: actionWidth,
      tabBuilder: builder,
      tabHeight: tabHeight,
      gapBuilder: gapBuilder,
      indicator: indicator,
      header: header,
      footer: footer,
      onTabTap: onTabTap,
      onActionTap: onActionTap,
    );
  }

  @override
  _SwipeTabBarState createState() => _SwipeTabBarState();
}

class _SwipeTabBarState extends State<SwipeTabBar> with TabBarMixin {
  var _defaultGap = (context, index) => Container();
  var _defaultHeader = Container();
  var _defaultFooter = Container();

  @override
  Widget build(BuildContext context) {
    Widget tabStack = Stack(
      children: <Widget>[
        // 構建背景顯示
        componentTabRow(
          selectTab: (context, index) {
            return widget.tabBuilder.buildTabBackground(
              isSelected: widget.currentIndex == index,
              index: index,
            );
          },
          unSelectTab: (context, index) {
            return widget.tabBuilder.buildTabBackground(
              isSelected: widget.currentIndex == index,
              index: index,
            );
          },
          action: (context, index) {
            return widget.tabBuilder.buildActionBackground(
              index: index,
            );
          },
          gap: widget.gapBuilder ?? _defaultGap,
          header: widget.header ?? _defaultHeader,
          footer: widget.footer ?? _defaultFooter,
          location: true,
        ),

        Positioned.fill(
          child: componentIndicator(
            decoration: widget.tabBuilder.swipeDecoration,
            duration: Duration(milliseconds: 300),
            curve: Curves.fastOutSlowIn,
          ),
        ),

        if (tabRectMap.isNotEmpty)
          componentTabRow(
            selectTab: (context, index) {
              return _buildTab(index: index);
            },
            unSelectTab: (context, index) {
              return _buildTab(index: index);
            },
            action: (context, index) {
              return _buildAction(index: index);
            },
            gap: widget.gapBuilder ?? _defaultGap,
            header: widget.header ?? _defaultHeader,
            footer: widget.footer ?? _defaultFooter,
            location: false,
          ),
      ],
    );

    Widget upContainer, downContainer;

    if (widget.indicator != null && widget.indicator.height > 0) {
      var lineIndicator = LineIndicator(
        decoration: widget.indicator.decoration,
        color: widget.indicator.color,
        start: indicatorStart ?? 0,
        end: indicatorEnd ?? 0,
        duration: widget.indicator.duration,
        curve: widget.indicator.curve,
        maxLength: widget.indicator.maxWidth,
        size: widget.indicator.height,
        direction: Axis.horizontal,
        appearAnimation: false,
      );

      switch (widget.indicator.position) {
        case VerticalDirection.up:
          upContainer = Container(child: lineIndicator);
          break;
        case VerticalDirection.down:
          downContainer = Container(child: lineIndicator);
          break;
      }
    }
    upContainer ??= Container();
    downContainer ??= Container();

    tabStack = IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          upContainer,
          Container(
            height: widget.tabHeight ?? 40.scaleA,
            child: tabStack,
          ),
          downContainer,
        ],
      ),
    );

    if (widget.scrollable) {
      tabStack = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: tabStack,
      );
    }

    return tabStack;
  }

  Widget _buildTab({int index}) {
    var isSelected = widget.currentIndex == index;
    return widget.tabBuilder.buildTabForeground(
      size: tabRectMap[index].size,
      isSelected: isSelected,
      index: index,
      onTap: () {
        if (isSelected) {
          return;
        }
        if (widget.scrollable && childKeyList.length > index) {
          Scrollable.ensureVisible(
            childKeyList[index].currentContext,
            alignment: 0.5,
            duration: Duration(milliseconds: 300),
          );
        }
        if (widget.onTabTap != null) {
          widget.onTabTap(index);
        }
      },
    );
  }

  /// 構建 action
  Widget _buildAction({int index}) {
    return widget.tabBuilder.buildActionForeground(
      size: actionRectMap[index].size,
      index: index,
      onTap: () {
        if (widget.onActionTap != null) {
          widget.onActionTap(index);
        }
      },
    );
  }
}
