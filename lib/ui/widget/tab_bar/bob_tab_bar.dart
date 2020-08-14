import 'package:flutter/material.dart';
import 'package:mx_core/ui/widget/animated_comb/animated_comb.dart';
import 'package:mx_core/util/screen_util.dart';

import '../line_indicator.dart';
import 'action_width.dart';
import 'base_tab_bar.dart';
import 'builder/builder.dart';
import 'indicator_style.dart';

class BobTabBar extends AbstractTabWidget {
  final TabBuilder tabBuilder;
  final ValueChanged<int> onTabTap;
  final ValueChanged<int> onActionTap;
  final double tabHeight;
  final IndexedWidgetBuilder gapBuilder;
  final TabIndicator indicator;
  final Widget header;
  final Widget footer;

  BobTabBar._({
    int currentIndex,
    bool scrollable = false,
    ActionWidth actionWidth,
    this.tabBuilder,
    this.tabHeight,
    this.indicator,
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

  factory BobTabBar.text({
    int currentIndex,
    TextTabBuilder builder,
    bool scrollable = false,
    ActionWidth actionWidth,
    double height,
    IndexedWidgetBuilder gapBuilder,
    TabIndicator indicator,
    Widget header,
    Widget footer,
    ValueChanged<int> onTabTap,
    ValueChanged<int> onActionTap,
  }) {
    return BobTabBar._(
      currentIndex: currentIndex,
      scrollable: scrollable,
      actionWidth: actionWidth,
      tabBuilder: builder,
      tabHeight: height,
      gapBuilder: gapBuilder,
      indicator: indicator,
      header: header,
      footer: footer,
      onTabTap: onTabTap,
      onActionTap: onActionTap,
    );
  }

  @override
  _BobTabBarState createState() => _BobTabBarState();
}

class _BobTabBarState extends State<BobTabBar> with TabBarMixin {
  List<AnimatedSyncTick> syncTickList;

  var _defaultGap = (context, index) => Container();
  var _defaultHeader = Container();
  var _defaultFooter = Container();

  @override
  void initState() {
    syncTickList = List.generate(
      widget.tabBuilder.tabCount,
      (index) => AnimatedSyncTick.identity(
        type: AnimatedType.once,
        autoStart: false,
      ),
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('構建開始');
    Widget tabStack = Stack(
      children: <Widget>[
        componentTabRow(
          selectTab: (context, index) {
            return _buildTabAnimated(index: index);
          },
          unSelectTab: (context, index) {
            return _buildTabAnimated(index: index);
          },
          action: (context, index) {
            return _buildAction(index: index);
          },
          gap: widget.gapBuilder ?? _defaultGap,
          header: widget.header ?? _defaultHeader,
          footer: widget.footer ?? _defaultFooter,
          location: true,
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

  /// 標籤的動畫
  Widget _buildTabAnimated({int index}) {
    return AnimatedComb(
      sync: syncTickList[index],
      animatedList: _jumpAnimatedList,
      alignment: Alignment.bottomCenter,
      type: AnimatedType.once,
      child: widget.tabBuilder.buildTab(
          isSelected: widget.currentIndex == index,
          index: index,
          onTap: () {
            if (index == widget.currentIndex) {
              return;
            }
            if (widget.scrollable && childKeyList.length > index) {
              Scrollable.ensureVisible(
                childKeyList[index].currentContext,
                alignment: 0.5,
                duration: Duration(milliseconds: 300),
              );
            }
            syncTickList[index].once();
            widget.onTabTap(index);
          }),
    );
  }

  /// 構建 action
  Widget _buildAction({int index}) {
    return widget.tabBuilder.buildAction(
      index: index,
      onTap: () {
        widget.onActionTap(index);
      },
    );
  }
}

var _jumpAnimatedList = <Comb>[
  Comb.scaleY(
    begin: 1.0,
    end: 0.5,
    x: 1,
    curve: Curves.linear,
    duration: 200,
  ),
  Comb.parallel(
    animatedList: [
      Comb.scaleY(
        begin: 0.5,
        end: 1.3,
        x: 1,
        curve: Curves.easeOutSine,
        duration: 300,
      ),
      Comb.scaleY(
          begin: 1.3,
          end: 1,
          x: 1,
          curve: Curves.elasticOut,
          duration: 1000,
          delay: 500),
      Comb.translateY(
        begin: 0,
        end: -20.scaleA,
        duration: 300,
        curve: Curves.easeOutSine,
      ),
      Comb.translateY(
        begin: -20.scaleA,
        end: 0,
        duration: 300,
        delay: 300,
        curve: Curves.easeInSine,
      ),
    ],
  ),
];
