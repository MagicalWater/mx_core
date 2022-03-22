import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

// ignore: implementation_imports
import 'package:flutter_easyrefresh/src/behavior/scroll_behavior.dart';
import 'package:rxdart/rxdart.dart';

import '../load_provider/load_provider.dart';
import 'refresh_controller.dart';
import 'refresh_state.dart';

export 'refresh_controller.dart';
export 'refresh_state.dart';

part 'easy_refresh_style.dart';

typedef RefreshHeaderBuilder = Header Function(
  BuildContext context,
);

typedef RefreshFooterBuilder = Footer Function(
  BuildContext context,
);

/// 預設 header
RefreshHeaderBuilder? _defaultHeaderBuilder;

/// 預設 footer
RefreshFooterBuilder? _defaultFooterBuilder;

/// 可刷新元件, 內部封裝了第三方庫 [EasyRefresh]
class RefreshView extends StatefulWidget {
  final EasyRefreshStyle _easyRefresh;

  /// 下拉刷新回調, null 為沒有下拉刷新
  final VoidCallback? onRefresh;

  /// 初始化列表的狀態
  final RefreshState initState;

  /// 列表狀態控制
  final RefreshController? refreshController;

  /// 加載更多回調, null 為沒有加載更多
  final VoidCallback? onLoad;

  /// 中間的讀取圓圈風格
  final RefreshLoadStyle? loadStyle;

  /// loading 延遲關閉時間
  final Duration? loadingDebounce;

  const RefreshView._({
    Key? key,
    required EasyRefreshStyle easyRefreshStyle,
    this.onRefresh,
    this.onLoad,
    this.initState = RefreshState.none,
    this.refreshController,
    this.loadStyle,
    this.loadingDebounce,
  }) : _easyRefresh = easyRefreshStyle;

  /// EasyRefresh 的默認構建
  /// 將child轉換為CustomScrollView可用的slivers
  /// 內部包含了 SliverView 的基本屬性
  factory RefreshView({
    key,
    RefreshState initState = RefreshState.none,
    VoidCallback? onRefresh,
    VoidCallback? onLoadMore,
    bool taskIndependence = false,
    ScrollController? scrollController,
    RefreshController? refreshController,
    Header? header,
    Footer? footer,
    Widget? emptyWidget,
    bool firstRefresh = false,
    Widget? firstRefreshWidget,
    int headerIndex = 0,
    bool topBouncing = true,
    bool bottomBouncing = true,
    RefreshLoadStyle? loadStyle,
    Duration? loadingDebounce,
    required Widget child,
  }) {
    var refresh = EasyRefreshStyle(
      taskIndependence: taskIndependence,
      scrollController: scrollController,
      header: header,
      footer: footer,
      emptyWidget: emptyWidget,
      firstRefresh: firstRefresh,
      firstRefreshWidget: firstRefreshWidget,
      headerIndex: headerIndex,
      topBouncing: topBouncing,
      bottomBouncing: bottomBouncing,
      child: child,
    );

    return RefreshView._(
      key: key,
      easyRefreshStyle: refresh,
      onRefresh: onRefresh,
      onLoad: onLoadMore,
      initState: initState,
      refreshController: refreshController,
      loadStyle: loadStyle,
    );
  }

  /// custom构造器(推荐)
  /// 直接使用CustomScrollView可用的slivers
  factory RefreshView.custom({
    key,
    RefreshState initState = RefreshState.none,
    VoidCallback? onRefresh,
    VoidCallback? onLoadMore,
    Widget? emptyWidget,
    bool taskIndependence = false,
    Header? header,
    bool firstRefresh = false,
    Widget? firstRefreshWidget,
    int headerIndex = 0,
    Footer? footer,
    Axis scrollDirection = Axis.vertical,
    bool reverse = false,
    ScrollController? scrollController,
    RefreshController? refreshController,
    bool? primary,
    bool shrinkWrap = false,
    Key? center,
    double anchor = 0.0,
    double? cacheExtent,
    int? semanticChildCount,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    bool topBouncing = true,
    bool bottomBouncing = true,
    RefreshLoadStyle? loadStyle,
    Duration? loadingDebounce,
    required List<Widget> slivers,
  }) {
    var refresh = EasyRefreshStyle.custom(
      taskIndependence: taskIndependence,
      header: header,
      headerIndex: headerIndex,
      firstRefresh: firstRefresh,
      firstRefreshWidget: firstRefreshWidget,
      footer: footer,
      scrollDirection: scrollDirection,
      reverse: reverse,
      scrollController: scrollController,
      primary: primary,
      shrinkWrap: shrinkWrap,
      center: center,
      emptyWidget: emptyWidget,
      anchor: anchor,
      cacheExtent: cacheExtent,
      semanticChildCount: semanticChildCount,
      dragStartBehavior: dragStartBehavior,
      topBouncing: topBouncing,
      bottomBouncing: bottomBouncing,
      slivers: slivers,
    );

    return RefreshView._(
      key: key,
      easyRefreshStyle: refresh,
      onRefresh: onRefresh,
      onLoad: onLoadMore,
      initState: initState,
      refreshController: refreshController,
      loadStyle: loadStyle,
      loadingDebounce: loadingDebounce,
    );
  }

  /// 自定义构造器
  /// 用法灵活,但需将physics、header和footer放入列表中
  factory RefreshView.builder({
    key,
    RefreshState initState = RefreshState.none,
    bool firstRefresh = false,
    Widget? firstRefreshWidget,
    int headerIndex = 0,
    VoidCallback? onRefresh,
    VoidCallback? onLoadMore,
    bool taskIndependence = false,
    ScrollController? scrollController,
    RefreshController? refreshController,
    Header? header,
    Footer? footer,
    bool topBouncing = true,
    bool bottomBouncing = true,
    required EasyRefreshChildBuilder builder,
    RefreshLoadStyle? loadStyle,
    Duration? loadingDebounce,
  }) {
    var refresh = EasyRefreshStyle.builder(
      taskIndependence: taskIndependence,
      scrollController: scrollController,
      header: header,
      firstRefresh: firstRefresh,
      footer: footer,
      topBouncing: topBouncing,
      bottomBouncing: bottomBouncing,
      builder: builder,
    );

    return RefreshView._(
      key: key,
      easyRefreshStyle: refresh,
      onRefresh: onRefresh,
      onLoad: onLoadMore,
      initState: initState,
      refreshController: refreshController,
      loadStyle: loadStyle,
      loadingDebounce: loadingDebounce,
    );
  }

  /// 設定預設 Header Footer Builder
  static void setDefaultStyle({
    RefreshHeaderBuilder? headerBuilder,
    RefreshFooterBuilder? footerBuilder,
  }) {
    _defaultHeaderBuilder = headerBuilder;
    _defaultFooterBuilder = footerBuilder;
  }

  @override
  _RefreshViewState createState() => _RefreshViewState();
}

class _RefreshViewState extends State<RefreshView> {
  /// 是否正在刷新中
  bool _isRefreshing = false;

  /// 是否正在加載中
  bool _isLoadingMore = false;

  /// [EasyRefresh] 元件的控制器, 藉此控制刷新/加載相關事項
  final EasyRefreshController _easyRefreshController = EasyRefreshController();

  /// 內部的列表元件實際上是一個 [EasyRefresh]
  late EasyRefresh _easyRefresh;

  /// 元件滾動的通知
  NotificationListener? _easyRefreshNotification;

  /// 狀態監聽
  StreamSubscription? _stateStreamSubscription;

  /// 凍結觸摸狀態
  bool _freezeTouch = false;

  /// 是否需要吃掉一次刷新的呼叫
  int _cancelOutRefreshCount = 0;

  /// 是否需要吃掉一次下拉加載的呼叫
  int _cancelOutLoadMoreCount = 0;

  /// 是否在元件更新後首次觸發
  bool _firstTrigger = false;

  /// 真正接收刷新狀態的控制器
  final BehaviorSubject<RefreshState> _stateSubject = BehaviorSubject();

  /// 是否延遲接受狀態命令
  var _isDebounceActive = false;

  /// 啟動延遲接受命令的訂閱
  StreamSubscription? _disableSubscription;

  StreamSubscription? _debounceLoadSubscription;

  Stream<bool> get debounceLoadStream =>
      _stateSubject.map((e) => e.centerLoad).distinct();

  final LoadController _loadController = LoadController();

  void _activeDebounce() {
    _isDebounceActive = true;
    _disableSubscription?.cancel();
    _disableSubscription =
        TimerStream(null, const Duration(seconds: 1)).listen((_) {
      _disableSubscription = null;
      _isDebounceActive = false;
    });
  }

  /// 最終顯示的 header
  Header? get _showHeader {
    if (widget._easyRefresh.header == null && _defaultHeaderBuilder != null) {
      return _defaultHeaderBuilder!(context);
    } else {
      return widget._easyRefresh.header;
    }
  }

  /// 最終顯示的 footer
  Footer? get _showFooter {
    if (widget._easyRefresh.header == null && _defaultFooterBuilder != null) {
      return _defaultFooterBuilder!(context);
    } else {
      return widget._easyRefresh.footer;
    }
  }

  @override
  void initState() {
    _stateSubject.add(widget.initState);

    _debounceLoadSubscription = debounceLoadStream.listen((event) {
      if (event) {
        _loadController.show();
      } else {
        _loadController.hide();
      }
    });

    _updateEasyRefresh();

    var dataHandleStream = widget.refreshController?.stream.doOnData((e) {
      _handleRefreshState(e);
    });

    if (widget.loadingDebounce != null &&
        widget.loadingDebounce! > Duration.zero) {
      dataHandleStream = dataHandleStream?.debounce((e) {
        _activeDebounce();
        if (e.isLoading || !_isDebounceActive) {
          return Stream.value(e);
        } else {
          return TimerStream(e, const Duration(seconds: 1));
        }
      });
    }

    _stateStreamSubscription = dataHandleStream?.listen((data) {
//      print("資料傳遞");
      _stateSubject.add(data);
    });

    super.initState();
  }

  /// 處理刷新/加載狀態
  void _handleRefreshState(RefreshState state) {
//    print("準備處理狀態: ${state.isLoading}");
//    _tempState = state;
    switch (state.type) {
      case RefreshType.refresh:
        if (state.isLoading && !_isRefreshing) {
          // 如果當前沒有刷新中, 但是收到刷新請求
          _isRefreshing = true;
          if (state.bounce) {
            _cancelOutRefreshCount = 1;
            _easyRefreshController.callRefresh();
          } else {
            _freezeTouch = true;
//            setState(() {});
          }
        } else if (!state.isLoading && _isRefreshing) {
          // 收到結束刷新的通知
          _freezeTouch = false;
          _isRefreshing = false;
          _easyRefreshController.finishRefresh(
            success: state.success,
            noMore: state.noMore,
          );
          if (state.noLoadMore == true) {
            _easyRefreshController.finishLoad(success: true, noMore: true);
          } else if (state.resetLoadMore) {
            _easyRefreshController.resetLoadState();

            // 檢測是否需要自動觸發加載更多
            if (widget.onLoad != null) {
              _triggerScrollPosDetect();
            }
          }
        }
        break;
      case RefreshType.loadMore:
        if (state.isLoading && !_isLoadingMore) {
          // 如果當前沒有加載更多中, 但是收到加載更多請求
          _isLoadingMore = true;
          if (state.bounce) {
            _cancelOutLoadMoreCount = 1;
            _easyRefreshController.callLoad();
          } else {
            _freezeTouch = true;
//            setState(() {});
          }
        } else if (!state.isLoading && _isLoadingMore) {
          // 收到結束加載的通知
          _freezeTouch = false;
          _isLoadingMore = false;
          _easyRefreshController.finishLoad(
            success: state.success,
            noMore: state.noMore,
          );
          if (state.resetRefresh) {
            _easyRefreshController.resetRefreshState();
          }
          // 檢測是否需要自動觸發加載更多
          if (widget.onLoad != null && !state.noMore) {
//            print("觸發加載更多檢測");
            _triggerScrollPosDetect();
          }
        }
        break;
    }
  }

  void _triggerScrollPosDetect() {
    // 若滑動監聽為空 or 元件的emptyWidget不為空, 則不需要
    if (_easyRefreshNotification == null || _easyRefresh.emptyWidget != null) {
      return;
    }

    // 在下一幀之後, 直接推移一個非常非常小的距離
    // 目的只為觸發 NotificationListener 監聽 scrollView 的 size
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _firstTrigger = true;
      var scrollController = widget._easyRefresh.scrollController!;
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.offset - 0.0000001);
      } else {
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          if (scrollController.hasClients) {
            scrollController.jumpTo(scrollController.offset - 0.0000001);
          }
        });
      }
    });
  }

  @override
  void didUpdateWidget(RefreshView oldWidget) {
    _updateEasyRefresh();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return LoadProvider(
      initValue: _stateSubject.value.centerLoad,
      controller: _loadController,
      style: LoadStyle(
        color: widget.loadStyle?.color ?? Colors.blueAccent,
        size: widget.loadStyle?.size ?? 50,
      ),
      child: AbsorbPointer(
        absorbing: _freezeTouch,
        child: _easyRefreshNotification ?? _easyRefresh,
      ),
    );
  }

  /// 更新 [_easyRefresh] 元件
  void _updateEasyRefresh() {
    widget._easyRefresh.scrollController ??= ScrollController();

    _easyRefresh = widget._easyRefresh.toWidget(
      header: _showHeader,
      footer: _showFooter,
      controller: _easyRefreshController,
      onRefresh: widget.onRefresh == null
          ? null
          : () async {
//              print("發出刷新");
              if (_cancelOutRefreshCount == 0) {
                _isRefreshing = true;
                widget.onRefresh!();
              }
              _cancelOutRefreshCount = 0;
            },
      onLoad: widget.onLoad == null
          ? null
          : () async {
              if (_cancelOutLoadMoreCount == 0) {
                _isLoadingMore = true;
                widget.onLoad!();
              }
              _cancelOutLoadMoreCount = 0;
            },
    );

    // 當滿足以下條件, 則需要加入滑動監聽
    // 1. 加載更多事件尚未觸發
    // 2. 沒有正在載入列表
    // 3. 擁有載入更多
    // 4. 滑動監聽回調不為null
    if (widget.onLoad != null) {
//      print("啟動滑動監聽");
      _easyRefreshNotification = NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          if (_firstTrigger) {
//            print("監聽: ${notification.metrics.extentAfter}");
            var metrics = notification.metrics;
            _firstTrigger = false;
            // 底部, 觸發加載更多
            if (metrics.maxScrollExtent == 0) {
//                print("觸發加載更多");
              var state = const RefreshState.loading(
                type: RefreshType.loadMore,
                bounce: false,
              );
              _handleRefreshState(state);
              _stateSubject.add(state);
              widget.onLoad!();
            }

            // 頂部
            if (metrics.extentBefore == 0) {}
          }
          return true;
        },
        child: _easyRefresh,
      );
    }
  }

  @override
  void dispose() {
    _stateStreamSubscription?.cancel();
    _stateSubject.close();
    _easyRefreshController.dispose();
    _disableSubscription?.cancel();
    _debounceLoadSubscription?.cancel();
    _loadController.dispose();
    super.dispose();
  }
}

class RefreshLoadStyle {
  Color? color;
  double? size;

  RefreshLoadStyle({this.color, this.size});
}
