part of 'refresh_view.dart';

/// 轉換 [EasyRefresh] 元件需要的參數
class EasyRefreshStyle {
  final _EasyRefreshConstructorType constructorType;

  /// 控制器
  final EasyRefreshController? controller;

  /// 刷新回调(null为不开启刷新)
  final OnRefreshCallback? onRefresh;

  /// 加载回调(null为不开启加载)
  final OnLoadCallback? onLoad;

  /// 是否开启控制结束刷新
  final bool enableControlFinishRefresh;

  /// 是否开启控制结束加载
  final bool enableControlFinishLoad;

  /// 任务独立(刷新和加载状态独立)
  final bool taskIndependence;

  /// Header
  final Header? header;
  final int headerIndex;

  /// Footer
  final Footer? footer;

  /// 子组件构造器
  final EasyRefreshChildBuilder? builder;

  /// 子组件
  final Widget? child;

  /// 首次刷新
  final bool firstRefresh;

  /// 首次刷新组件
  /// 不设置时使用header
  final Widget? firstRefreshWidget;

  /// 空视图
  /// 当不为null时,只会显示空视图
  /// 保留[headerIndex]以上的内容
  final Widget? emptyWidget;

  /// 顶部回弹(Header的overScroll属性优先，且onRefresh和header都为null时生效)
  final bool topBouncing;

  /// 底部回弹(Footer的overScroll属性优先，且onLoad和footer都为null时生效)
  final bool bottomBouncing;

  /// CustomListView Key
  final Key? listKey;

  /// 滚动行为
  final ScrollBehavior? behavior;

  /// Slivers集合
  final List<Widget>? slivers;

  /// 列表方向
  final Axis scrollDirection;

  /// 反向
  final bool reverse;
  ScrollController? scrollController;
  final bool? primary;
  final bool shrinkWrap;
  final Key? center;
  final double anchor;
  final double? cacheExtent;
  final int? semanticChildCount;
  final DragStartBehavior dragStartBehavior;

  /// 默认构造器
  /// 将child转换为CustomScrollView可用的slivers
  EasyRefreshStyle({
    this.controller,
    this.onRefresh,
    this.onLoad,
    this.enableControlFinishRefresh = false,
    this.enableControlFinishLoad = false,
    this.taskIndependence = false,
    this.scrollController,
    this.header,
    this.footer,
    this.firstRefresh = false,
    this.firstRefreshWidget,
    this.headerIndex = 0,
    this.emptyWidget,
    this.topBouncing = true,
    this.bottomBouncing = true,
    this.behavior = const EmptyOverScrollScrollBehavior(),
    required this.child,
  })  : this.scrollDirection = Axis.vertical,
        this.reverse = false,
        this.builder = null,
        this.primary = null,
        this.shrinkWrap = false,
        this.center = null,
        this.anchor = 0.0,
        this.cacheExtent = null,
        this.slivers = null,
        this.semanticChildCount = null,
        this.dragStartBehavior = DragStartBehavior.start,
        this.listKey = null,
        this.constructorType = _EasyRefreshConstructorType.none;

  /// custom构造器(推荐)
  /// 直接使用CustomScrollView可用的slivers
  EasyRefreshStyle.custom({
    this.listKey,
    this.controller,
    this.onRefresh,
    this.onLoad,
    this.enableControlFinishRefresh = false,
    this.enableControlFinishLoad = false,
    this.taskIndependence = false,
    this.header,
    this.headerIndex = 0,
    this.footer,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.scrollController,
    this.primary,
    this.shrinkWrap = false,
    this.center,
    this.anchor = 0.0,
    this.cacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.firstRefresh = false,
    this.firstRefreshWidget,
    this.emptyWidget,
    this.topBouncing = true,
    this.bottomBouncing = true,
    this.behavior = const EmptyOverScrollScrollBehavior(),
    required this.slivers,
  })  : this.builder = null,
        this.child = null,
        this.constructorType = _EasyRefreshConstructorType.custom;

  /// 自定义构造器
  /// 用法灵活,但需将physics、header和footer放入列表中
  EasyRefreshStyle.builder({
    this.controller,
    this.onRefresh,
    this.onLoad,
    this.enableControlFinishRefresh = false,
    this.enableControlFinishLoad = false,
    this.taskIndependence = false,
    this.scrollController,
    this.header,
    this.footer,
    this.firstRefresh = false,
    this.topBouncing = true,
    this.bottomBouncing = true,
    this.behavior = const EmptyOverScrollScrollBehavior(),
    required this.builder,
  })  : this.scrollDirection = Axis.vertical,
        this.reverse = false,
        this.child = null,
        this.primary = null,
        this.shrinkWrap = false,
        this.center = null,
        this.anchor = 0.0,
        this.cacheExtent = null,
        this.slivers = null,
        this.semanticChildCount = null,
        this.dragStartBehavior = DragStartBehavior.start,
        this.headerIndex = 0,
        this.firstRefreshWidget = null,
        this.emptyWidget = null,
        this.listKey = null,
        this.constructorType = _EasyRefreshConstructorType.builder;

  /// 轉換為 [EasyRefresh] 元件
  /// * [controller] - 控制器
  /// * [onRefresh] - 刷新回调(null为不开启刷新)
  /// * [onLoad] - 加载回调(null为不开启加载)
  EasyRefresh toWidget({
    Header? header,
    Footer? footer,
    required EasyRefreshController controller,
    OnRefreshCallback? onRefresh,
    OnLoadCallback? onLoad,
  }) {
    switch (constructorType) {
      case _EasyRefreshConstructorType.none:
        return EasyRefresh(
          controller: controller,
          onRefresh: onRefresh,
          onLoad: onLoad,
          enableControlFinishRefresh: true,
          enableControlFinishLoad: true,
          taskIndependence: taskIndependence,
          scrollController: scrollController,
          header: header,
          footer: footer,
          firstRefresh: firstRefresh,
          firstRefreshWidget: firstRefreshWidget,
          headerIndex: headerIndex,
          emptyWidget: emptyWidget,
          topBouncing: topBouncing,
          bottomBouncing: bottomBouncing,
          behavior: behavior,
          child: child,
        );
      case _EasyRefreshConstructorType.custom:
        return EasyRefresh.custom(
          controller: controller,
          onRefresh: onRefresh,
          onLoad: onLoad,
          enableControlFinishRefresh: true,
          enableControlFinishLoad: true,
          taskIndependence: taskIndependence,
          header: header,
          headerIndex: headerIndex,
          footer: footer,
          scrollDirection: scrollDirection,
          reverse: reverse,
          scrollController: scrollController,
          primary: primary,
          shrinkWrap: shrinkWrap,
          center: center,
          anchor: anchor,
          cacheExtent: cacheExtent,
          semanticChildCount: semanticChildCount,
          dragStartBehavior: dragStartBehavior,
          firstRefresh: firstRefresh,
          firstRefreshWidget: firstRefreshWidget,
          emptyWidget: emptyWidget,
          topBouncing: topBouncing,
          bottomBouncing: bottomBouncing,
          behavior: behavior,
          slivers: slivers,
        );
      case _EasyRefreshConstructorType.builder:
        return EasyRefresh.builder(
          controller: controller,
          onRefresh: onRefresh,
          onLoad: onLoad,
          enableControlFinishRefresh: true,
          enableControlFinishLoad: true,
          taskIndependence: taskIndependence,
          scrollController: scrollController,
          header: header,
          footer: footer,
          firstRefresh: firstRefresh,
          topBouncing: topBouncing,
          bottomBouncing: bottomBouncing,
          builder: builder,
        );
    }
  }
}

enum _EasyRefreshConstructorType {
  none,
  custom,
  builder,
}
