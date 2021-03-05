import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mx_core/util/screen_util.dart';

import '../line_indicator.dart';
import 'action_width.dart';
import 'base_tab_bar.dart';
import 'builder/builder.dart';
import 'indicator_style.dart';
import 'tab_width.dart';

class SwipeTabBar extends AbstractTabWidget {
  final SwipeTabBuilder tabBuilder;
  final ValueChanged<int> onTabTap;
  final ValueChanged<int> onActionTap;
  final double tabHeight;
  final TabIndicator indicator;
  final IndexedWidgetBuilder gapBuilder;
  final Widget header;
  final Widget footer;

  /// 控制器, 當有帶入值時, [currentIndex] 失效
  /// [TabController] 會接手控制 tab 的選擇
  final TabController controller;

  SwipeTabBar({
    int currentIndex,
    bool scrollable = false,
    ActionWidth actionWidth,
    TabWidth tabWidth,
    this.controller,
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
          tabWidth: tabWidth,
          tabCount: tabBuilder.tabCount,
          actionCount: tabBuilder.actionCount,
        );

  factory SwipeTabBar.text({
    int currentIndex,
    TabController controller,
    TextTabBuilder tabBuilder,
    bool scrollable = false,
    ActionWidth actionWidth,
    TabWidth tabWidth,
    double tabHeight,
    TabIndicator indicator,
    IndexedWidgetBuilder gapBuilder,
    Widget header,
    Widget footer,
    ValueChanged<int> onTabTap,
    ValueChanged<int> onActionTap,
  }) {
    return SwipeTabBar(
      currentIndex: currentIndex,
      controller: controller,
      scrollable: scrollable,
      actionWidth: actionWidth,
      tabWidth: tabWidth,
      tabBuilder: tabBuilder,
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

  TabController _tabController;

  @override
  void initState() {
    bindController(widget.controller);
    currentIndex = _tabController?.index ?? widget.currentIndex;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant SwipeTabBar oldWidget) {
    bindController(widget.controller);
    if (_tabController == null) {
      currentIndex = widget.currentIndex;
    }
    super.didUpdateWidget(oldWidget);
  }

  void bindController(TabController controller) {
    // 先取消綁定舊有
    unbindController();

    _tabController = controller;
    _tabController?.animation?.addListener(_handlePageOffsetCallback);
    _tabController?.addListener(_handleControllerCallback);
  }

  void unbindController() {
    if (_tabController != null) {
      _tabController.removeListener(_handleControllerCallback);
      _tabController?.animation?.removeListener(_handlePageOffsetCallback);
    }
    _tabController = null;
  }

  @override
  void dispose() {
    unbindController();
    super.dispose();
  }

  void _handlePageOffsetCallback() {
    indexOffset = _tabController.animation.value;
    syncIndicator();
    // print('offset = $indexOffset');
    setState(() {});
  }

  void _handleControllerCallback() {
    if (_tabController.index != currentIndex) {
      // 同步 currentIndex
      // print('切換 index: ${_tabController.index}, ${_tabController.indexIsChanging}');
      currentIndex = _tabController.index;
      centerSelect(currentIndex);
      syncIndicator();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var tabHeight = widget.tabHeight ?? 40.scaleA;
    double topHeight = 0, bottomHeight = 0;
    double topPadding = 0, bottomPadding = 0;
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
        animation: _tabController == null,
      );

      switch (widget.indicator.position) {
        case VerticalDirection.up:
          topHeight = widget.indicator.height;
          bottomPadding = tabHeight;
          upContainer = lineIndicator;
          break;
        case VerticalDirection.down:
          bottomHeight = widget.indicator.height;
          topPadding = tabHeight;
          downContainer = lineIndicator;
          break;
      }
    }
    upContainer ??= Container();
    downContainer ??= Container();

    Widget tabStack = IntrinsicWidth(
      child: Column(
        children: [
          Stack(
            children: <Widget>[
              // 構建背景顯示
              Container(
                height: tabHeight + topHeight + bottomHeight,
                child: Container(
                  height: tabHeight,
                  padding:
                      EdgeInsets.only(top: topHeight, bottom: bottomHeight),
                  child: componentTabRow(
                    selectTab: (context, index) {
                      return widget.tabBuilder.buildTabBackground(
                        selected: currentIndex == index,
                        index: index,
                      );
                    },
                    unSelectTab: (context, index) {
                      return widget.tabBuilder.buildTabBackground(
                        selected: currentIndex == index,
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
                ),
              ),

              Positioned.fill(
                top: topHeight,
                bottom: bottomHeight,
                child: componentIndicator(
                  decoration: widget.tabBuilder.swipeDecoration(
                    currentIndex,
                    true,
                  ),
                  duration: Duration(milliseconds: 300),
                  padding: widget.tabBuilder.margin,
                  curve: Curves.fastOutSlowIn,
                  animation: _tabController == null,
                ),
              ),

              Positioned.fill(
                top: 0,
                bottom: bottomPadding,
                child: upContainer,
              ),
              Positioned.fill(
                top: topPadding,
                bottom: 0,
                child: downContainer,
              ),

              if (tabRectMap.isNotEmpty)
                Container(
                  height: tabHeight + topHeight + bottomHeight,
                  child: Container(
                    height: tabHeight,
                    padding: EdgeInsets.only(
                      top: topHeight,
                      bottom: bottomHeight,
                    ),
                    child: componentTabRow(
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
                  ),
                ),
            ],
          ),
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
    var isSelected = currentIndex == index;
    return widget.tabBuilder.buildTabForeground(
      size: tabRectMap[index].size,
      selected: isSelected,
      index: index,
      onTap: () {
        if (isSelected) {
          return;
        }
        centerSelect(index);

        if (_tabController != null) {
          _tabController.animateTo(index);
        }

        if (widget.onTabTap != null) {
          widget.onTabTap(index);
        }
      },
    );
  }

  void centerSelect(int index) {
    if (widget.scrollable && childKeyList.length > index) {
      Scrollable.ensureVisible(
        childKeyList[index].currentContext,
        alignment: 0.5,
        duration: Duration(milliseconds: 300),
      );
    }
  }

  /// 構建 action
  Widget _buildAction({int index}) {
    print('構建: action = ${actionRectMap[index].size}');
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
