part of 'refresh_view.dart';

/// 轉換 [EasyRefresh] 元件需要的參數
class EasyRefreshStyle {
  final _EasyRefreshConstructorType constructorType;

  /// 任务独立(刷新和加载状态独立)
  final bool taskIndependence;

  /// Header
  final Header header;
  final int headerIndex;

  /// Footer
  final Footer footer;

  /// 子组件构造器
  final EasyRefreshChildBuilder builder;

  /// 子组件
  final Widget child;

  /// 首次刷新
  final bool firstRefresh;

  /// 首次刷新组件
  /// 不设置时使用header
  final Widget firstRefreshWidget;

  /// 空视图
  /// 当不为null时,只会显示空视图
  /// 保留[headerIndex]以上的内容
  final Widget emptyWidget;

  /// 顶部回弹(onRefresh为null时生效)
  final bool topBouncing;

  /// 底部回弹(onLoad为null时生效)
  final bool bottomBouncing;

  /// Slivers集合
  final List<Widget> slivers;

  /// 列表方向
  final Axis scrollDirection;

  /// 反向
  final bool reverse;
  ScrollController scrollController;
  final bool primary;
  final bool shrinkWrap;
  final Key center;
  final double anchor;
  final double cacheExtent;
  final int semanticChildCount;
  final DragStartBehavior dragStartBehavior;

  /// 默认构造器
  /// 将child转换为CustomScrollView可用的slivers
  EasyRefreshStyle({
    this.taskIndependence = false,
    this.scrollController,
    this.header,
    this.footer,
    this.firstRefresh,
    this.firstRefreshWidget,
    this.headerIndex,
    this.emptyWidget,
    this.topBouncing = true,
    this.bottomBouncing = true,
    @required this.child,
  })  : this.scrollDirection = null,
        this.reverse = null,
        this.builder = null,
        this.primary = null,
        this.shrinkWrap = null,
        this.center = null,
        this.anchor = null,
        this.cacheExtent = null,
        this.slivers = null,
        this.semanticChildCount = null,
        this.dragStartBehavior = null,
        this.constructorType = _EasyRefreshConstructorType.none;

  /// custom构造器(推荐)
  /// 直接使用CustomScrollView可用的slivers
  EasyRefreshStyle.custom({
    this.taskIndependence = false,
    this.header,
    this.headerIndex,
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
    this.firstRefresh,
    this.firstRefreshWidget,
    this.emptyWidget,
    this.topBouncing = true,
    this.bottomBouncing = true,
    @required this.slivers,
  })  : this.builder = null,
        this.child = null,
        this.constructorType = _EasyRefreshConstructorType.custom;

  /// 自定义构造器
  /// 用法灵活,但需将physics、header和footer放入列表中
  EasyRefreshStyle.builder({
    this.taskIndependence = false,
    this.scrollController,
    this.header,
    this.footer,
    this.firstRefresh,
    this.topBouncing = true,
    this.bottomBouncing = true,
    @required this.builder,
  })  : this.scrollDirection = null,
        this.reverse = null,
        this.child = null,
        this.primary = null,
        this.shrinkWrap = null,
        this.center = null,
        this.anchor = null,
        this.cacheExtent = null,
        this.slivers = null,
        this.semanticChildCount = null,
        this.dragStartBehavior = null,
        this.headerIndex = null,
        this.firstRefreshWidget = null,
        this.emptyWidget = null,
        this.constructorType = _EasyRefreshConstructorType.builder;

  /// 轉換為 [EasyRefresh] 元件
  /// * [controller] - 控制器
  /// * [onRefresh] - 刷新回调(null为不开启刷新)
  /// * [onLoad] - 加载回调(null为不开启加载)
  EasyRefresh toWidget({
    Header header,
    Footer footer,
    @required EasyRefreshController controller,
    OnRefreshCallback onRefresh,
    OnLoadCallback onLoad,
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
          child: child,
        );
        break;
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
          slivers: slivers,
        );
        break;
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
        break;
      default:
        return null;
    }
  }
}

enum _EasyRefreshConstructorType {
  none,
  custom,
  builder,
}
