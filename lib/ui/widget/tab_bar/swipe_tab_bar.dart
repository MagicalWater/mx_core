import 'package:flutter/material.dart';
import 'package:mx_core/util/screen_util.dart';

import '../line_indicator/line_indicator.dart';
import 'action_width.dart';
import 'base_tab_bar.dart';
import 'builder/builder.dart';
import 'indicator_style.dart';
import 'tab_width.dart';

class SwipeTabBar extends AbstractTabWidget {
  final SwipeTabBuilder tabBuilder;
  final void Function(int preIndex, int index)? onTabTap;
  final ValueChanged<int>? onActionTap;

  /// 默認 40.scale
  final double? tabHeight;
  final TabIndicator? indicator;
  final IndexedWidgetBuilder? gapBuilder;
  final Widget? header;
  final Widget? footer;

  /// 控制器, 當有帶入值時, [currentIndex] 失效
  /// [TabController] 會接手控制 tab 的選擇
  final TabController? controller;

  /// 點選tab後自動置中, 當[scrollable]為true時有效
  final bool autoScrollCenter;

  /// 當[scrollable]為true時有效
  /// 決定tab物理特性的元件
  final ScrollPhysics? physics;

  SwipeTabBar({
    Key? key,
    required this.tabBuilder,
    int? currentIndex,
    bool scrollable = false,
    this.autoScrollCenter = true,
    ActionWidth actionWidth = const ActionWidth.shrinkWrap(),
    TabWidth tabWidth = const TabWidth.shrinkWrap(),
    this.controller,
    this.indicator,
    this.tabHeight,
    this.gapBuilder,
    this.header,
    this.footer,
    this.physics,
    this.onTabTap,
    this.onActionTap,
  })  : assert(currentIndex != null || controller != null),
        super(
          key: key,
          scrollable: scrollable,
          actionWidth: actionWidth,
          currentIndex: currentIndex,
          tabWidth: tabWidth,
          tabCount: tabBuilder.tabCount,
          actionCount: tabBuilder.actionCount,
        );

  factory SwipeTabBar.text({
    required TextTabBuilder tabBuilder,
    int? currentIndex,
    TabController? controller,
    bool scrollable = false,
    bool autoScrollCenter = true,
    ActionWidth actionWidth = const ActionWidth.shrinkWrap(),
    TabWidth tabWidth = const TabWidth.shrinkWrap(),
    double? tabHeight,
    TabIndicator? indicator,
    IndexedWidgetBuilder? gapBuilder,
    Widget? header,
    Widget? footer,
    ScrollPhysics? physics,
    void Function(int preIndex, int index)? onTabTap,
    ValueChanged<int>? onActionTap,
  }) {
    return SwipeTabBar(
      currentIndex: currentIndex,
      controller: controller,
      scrollable: scrollable,
      autoScrollCenter: autoScrollCenter,
      actionWidth: actionWidth,
      tabWidth: tabWidth,
      tabBuilder: tabBuilder,
      tabHeight: tabHeight,
      gapBuilder: gapBuilder,
      indicator: indicator,
      header: header,
      footer: footer,
      physics: physics,
      onTabTap: onTabTap,
      onActionTap: onActionTap,
    );
  }

  @override
  State<SwipeTabBar> createState() => _SwipeTabBarState();
}

class _SwipeTabBarState extends State<SwipeTabBar> with TabBarMixin {
  Widget _defaultGap(context, index) => Container();
  final _defaultHeader = Container();
  final _defaultFooter = Container();

  TabController? _tabController;

  @override
  void initState() {
    bindController(widget.controller);
    if (widget.scrollable) {
      tabScrollController = ScrollController();
    }
    currentIndex = _tabController?.index ?? widget.currentIndex!;

    if (widget.controller != null && currentIndex != 0) {
      needScrollCenter = true;
    } else {
      needScrollCenter = false;
    }
    super.initState();
  }

  @override
  void didUpdateWidget(covariant SwipeTabBar oldWidget) {
    bindController(widget.controller);
    if (_tabController == null) {
      currentIndex = widget.currentIndex!;
    } else {
      currentIndex = _tabController!.index;
    }
    super.didUpdateWidget(oldWidget);
  }

  void bindController(TabController? controller) {
    // 先取消綁定舊有
    unbindController();

    _tabController = controller;
    _tabController?.animation?.addListener(_handlePageOffsetCallback);
    _tabController?.addListener(_handleControllerCallback);
  }

  void unbindController() {
    if (_tabController != null) {
      _tabController?.removeListener(_handleControllerCallback);
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
    indexOffset = _tabController!.animation!.value;
    syncIndicator();
    // print('offset = $indexOffset');
    setState(() {});
  }

  void _handleControllerCallback() {
    if (_tabController!.index != currentIndex) {
      // 同步 currentIndex
      // print('切換 index: ${_tabController.index}, ${_tabController.indexIsChanging}');
      currentIndex = _tabController!.index;
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
    Widget? upContainer, downContainer;

    if (widget.indicator != null && widget.indicator!.height > 0) {
      var indicatorBg = widget.indicator?.bgDecoration;
      if (indicatorBg == null && widget.indicator!.bgColor != null) {
        indicatorBg = BoxDecoration(color: widget.indicator!.bgColor);
      }

      List<LinePlace> places = [];
      var needPlace = widget.indicator!.placeColor != null ||
          widget.indicator!.placeDecoration != null;
      if (needPlace && tabRectMap.isNotEmpty) {
        places = tabRectMap.values.map<LinePlace>((e) {
          return LinePlace(
            start: e.left / totalSize.width,
            end: e.right / totalSize.width,
            color: widget.indicator!.placeColor,
            decoration: widget.indicator!.placeDecoration,
            placeUp: false,
          );
        }).toList();
      }

      // print('站位: ${places.map((e) => '${e.start} ~ ${e.end}').toList()}');

      // print('是否擁有dec => ${widget.indicator!.decoration != null}, 是否擁有color => ${widget.indicator!.color != null}');
      var lineIndicator = Container(
        decoration: indicatorBg,
        child: LineIndicator(
          decoration: widget.indicator!.decoration,
          color: widget.indicator!.color,
          start: indicatorStart ?? 0,
          end: indicatorEnd ?? 0,
          duration: widget.indicator!.duration,
          curve: widget.indicator!.curve,
          maxLength: widget.indicator!.maxWidth,
          size: widget.indicator!.height,
          direction: Axis.horizontal,
          appearAnimation: false,
          places: places,
          animation: _tabController == null,
        ),
      );

      switch (widget.indicator!.position) {
        case VerticalDirection.up:
          topHeight = widget.indicator!.height;
          bottomPadding = tabHeight;
          upContainer = lineIndicator;
          break;
        case VerticalDirection.down:
          bottomHeight = widget.indicator!.height;
          topPadding = tabHeight;
          downContainer = lineIndicator;
          break;
      }
    }
    upContainer ??= Container();
    downContainer ??= Container();

    Widget tabStack = IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: <Widget>[
              // 構建背景顯示
              SizedBox(
                height: tabHeight + topHeight + bottomHeight,
                child: Container(
                  height: tabHeight,
                  padding: EdgeInsets.only(
                    top: topHeight,
                    bottom: bottomHeight,
                  ),
                  child: componentTabRow(
                    selectTab: (context, index) {
                      return widget.tabBuilder.buildTabBackground(
                        context: context,
                        selected: currentIndex == index,
                        index: index,
                      );
                    },
                    unSelectTab: (context, index) {
                      return widget.tabBuilder.buildTabBackground(
                        context: context,
                        selected: currentIndex == index,
                        index: index,
                      );
                    },
                    action: (context, index) {
                      return widget.tabBuilder.buildActionBackground(
                        context: context,
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
                  duration: const Duration(milliseconds: 300),
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
                SizedBox(
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
        physics: widget.physics,
        controller: tabScrollController,
        scrollDirection: Axis.horizontal,
        child: tabStack,
      );
    }

    return tabStack;
  }

  Widget _buildTab({required int index}) {
    var currentSelectedIndex = currentIndex;
    var isSelected = currentSelectedIndex == index;
    return widget.tabBuilder.buildTabForeground(
      context: context,
      size: tabRectMap[index]!.size,
      selected: isSelected,
      index: index,
      onTap: () {
        if (isSelected) {
          widget.onTabTap?.call(currentSelectedIndex, index);
          return;
        }

        centerSelect(index);

        _tabController?.animateTo(index);

        widget.onTabTap?.call(currentSelectedIndex, index);
      },
    );
  }

  void centerSelect(int index) {
    if (widget.autoScrollCenter &&
        widget.scrollable &&
        childKeyList.length > index) {
      Scrollable.ensureVisible(
        childKeyList[index].currentContext!,
        alignment: 0.5,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  /// 構建 action
  Widget _buildAction({required int index}) {
    // print('構建: action = ${actionRectMap[index].size}');
    return widget.tabBuilder.buildActionForeground(
      context: context,
      size: actionRectMap[index]!.size,
      index: index,
      onTap: () {
        widget.onActionTap?.call(index);
      },
    );
  }
}
