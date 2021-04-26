import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:rxdart/rxdart.dart';

import '../load_provider.dart';

part 'easy_refresh_style.dart';

typedef RefreshBuilder = Widget Function(
  BuildContext context,
  RefreshState state,
  PlaceStyle place,
);

typedef RefreshHeaderBuilder = Header Function(
  BuildContext context,
);

typedef RefreshFooterBuilder = Footer Function(
  BuildContext context,
);

/// 預設 header
RefreshHeaderBuilder _defaultHeaderBuilder;

/// 預設 footer
RefreshFooterBuilder _defaultFooterBuilder;

/// 預設佔位提示屬性
PlaceStyle _defaultPlaceStyle;

/// 預設的自訂佔位元件
RefreshBuilder _defaultPlaceBuilder;

/// 可刷新元件, 內部封裝了第三方庫 [EasyRefresh]
class RefreshView extends StatefulWidget {
  final EasyRefreshStyle _easyRefresh;

  /// 下拉刷新回調, null 為沒有下拉刷新
  final VoidCallback onRefresh;

  /// 初始化列表的狀態
  final RefreshState initState;

  /// 列表狀態流
  final Stream<RefreshState> stateStream;

  /// 加載更多回調, null 為沒有加載更多
  final VoidCallback onLoad;

  /// 自訂列表狀態佔位元件, 回傳 null 代表不處理, 使用預設顯示
  /// 若要顯示空則回傳 Container()
  final RefreshBuilder placeBuilder;

  /// 佔位提示屬性
  final PlaceStyle placeStyle;

  /// 中間的讀取圓圈風格
  final RefreshLoadStyle loadStyle;

  /// loading 延遲關閉時間
  final Duration loadingDebounce;

  RefreshView._({
    Key key,
    EasyRefreshStyle easyRefreshStyle,
    this.onRefresh,
    this.onLoad,
    this.initState = const RefreshState._init(),
    this.stateStream,
    this.placeStyle,
    this.placeBuilder,
    this.loadStyle,
    this.loadingDebounce,
  }) : this._easyRefresh = easyRefreshStyle;

  /// EasyRefresh 的默認構建
  /// 將child轉換為CustomScrollView可用的slivers
  /// 內部包含了 SliverView 的基本屬性
  factory RefreshView({
    key,
    RefreshState initState = const RefreshState._init(),
    Stream<RefreshState> stateStream,
    PlaceStyle placeStyle,
    RefreshBuilder placeBuilder,
    VoidCallback onRefresh,
    VoidCallback onLoadMore,
    bool taskIndependence = false,
    ScrollController scrollController,
    Header header,
    Footer footer,
    Widget emptyWidget,
    bool firstRefresh = false,
    Widget firstRefreshWidget,
    int headerIndex = 0,
    bool topBouncing = true,
    bool bottomBouncing = true,
    RefreshLoadStyle loadStyle,
    Duration loadingDebounce,
    @required Widget child,
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
      stateStream: stateStream,
      placeStyle: placeStyle,
      placeBuilder: placeBuilder,
      loadStyle: loadStyle,
    );
  }

  /// custom构造器(推荐)
  /// 直接使用CustomScrollView可用的slivers
  factory RefreshView.custom({
    key,
    RefreshState initState = const RefreshState._init(),
    Stream<RefreshState> stateStream,
    PlaceStyle placeStyle,
    RefreshBuilder placeBuilder,
    VoidCallback onRefresh,
    VoidCallback onLoadMore,
    Widget emptyWidget,
    bool taskIndependence = false,
    Header header,
    bool firstRefresh = false,
    Widget firstRefreshWidget,
    int headerIndex = 0,
    Footer footer,
    Axis scrollDirection = Axis.vertical,
    bool reverse = false,
    ScrollController scrollController,
    bool primary,
    bool shrinkWrap = false,
    Key center,
    double anchor = 0.0,
    double cacheExtent,
    int semanticChildCount,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    bool topBouncing = true,
    bool bottomBouncing = true,
    RefreshLoadStyle loadStyle,
    Duration loadingDebounce,
    @required List<Widget> slivers,
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
      stateStream: stateStream,
      placeStyle: placeStyle,
      placeBuilder: placeBuilder,
      loadStyle: loadStyle,
      loadingDebounce: loadingDebounce,
    );
  }

  /// 自定义构造器
  /// 用法灵活,但需将physics、header和footer放入列表中
  factory RefreshView.builder({
    key,
    RefreshState initState = const RefreshState._init(),
    Stream<RefreshState> stateStream,
    PlaceStyle placeStyle,
    bool firstRefresh = false,
    Widget firstRefreshWidget,
    int headerIndex = 0,
    RefreshBuilder placeBuilder,
    VoidCallback onRefresh,
    VoidCallback onLoadMore,
    bool taskIndependence = false,
    ScrollController scrollController,
    Header header,
    Footer footer,
    bool topBouncing = true,
    bool bottomBouncing = true,
    @required EasyRefreshChildBuilder builder,
    RefreshLoadStyle loadStyle,
    Duration loadingDebounce,
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
      stateStream: stateStream,
      placeStyle: placeStyle,
      placeBuilder: placeBuilder,
      loadStyle: loadStyle,
      loadingDebounce: loadingDebounce,
    );
  }

  /// 設定預設的佔位元件(全局)
  static void setDefaultPlace(RefreshBuilder builder) {
    _defaultPlaceBuilder = builder;
  }

  /// 設定預設的佔位提示屬性
  static void setDefaultPlaceStyle(PlaceStyle style) {
    _defaultPlaceStyle = style;
  }

  /// 設定預設 Header Footer Builder
  static void setDefaultStyle({
    RefreshHeaderBuilder headerBuilder,
    RefreshFooterBuilder footerBuilder,
  }) {
    _defaultHeaderBuilder = headerBuilder;
    _defaultFooterBuilder = footerBuilder;
  }

  @override
  _RefreshViewState createState() => _RefreshViewState();
}

class _RefreshViewState extends State<RefreshView> {
  /// 最終顯示的佔位屬性
  PlaceStyle get _placeStyle {
    return widget.placeStyle ?? _defaultPlaceStyle ?? PlaceStyle._default;
  }

  /// 是否正在刷新中
  bool _isRefreshing = false;

  /// 是否正在加載中
  bool _isLoadingMore = false;

  /// [EasyRefresh] 元件的控制器, 藉此控制刷新/加載相關事項
  EasyRefreshController _easyRefreshController = EasyRefreshController();

  /// 內部的列表元件實際上是一個 [EasyRefresh]
  EasyRefresh _easyRefresh;

  /// 元件滾動的通知
  NotificationListener _easyRefreshNotification;

  /// 狀態監聽
  StreamSubscription _stateStreamSubscription;

  /// 凍結觸摸狀態
  bool _freezeTouch = false;

  /// 是否需要吃掉一次刷新的呼叫
  int _cancelOutRefreshCount = 0;

  /// 是否需要吃掉一次下拉加載的呼叫
  int _cancelOutLoadMoreCount = 0;

  /// 是否在元件更新後首次觸發
  bool _firstTrigger = false;

  /// 真正接收刷新狀態的控制器
  BehaviorSubject<RefreshState> _stateSubject = BehaviorSubject();

  /// 是否延遲接受狀態命令
  var _isDebounceActive = false;

  /// 啟動延遲接受命令的訂閱
  StreamSubscription _disableSubscription;

  Stream<bool> get debounceLoadStream {
    return _stateSubject.stream.map((e) {
//        print("接收到資料: ${e.isLoading}");
//      var isLoading = false;
      return e.centerLoad;
//      switch (e.type) {
//        case RefreshType.refresh:
//          isLoading = e.isLoading;
//          break;
//        case RefreshType.loadMore:
//          isLoading = e.isLoading && !e.bounce;
//          break;
//      }
//      return isLoading;
    }).distinct();
  }

  void _activeDebounce() {
    _isDebounceActive = true;
    _disableSubscription?.cancel();
    _disableSubscription = TimerStream(null, Duration(seconds: 1)).listen((_) {
      _disableSubscription = null;
      _isDebounceActive = false;
    });
  }

  /// 最終顯示的 header
  Header get _showHeader {
    if (widget._easyRefresh.header == null && _defaultHeaderBuilder != null) {
      return _defaultHeaderBuilder(context);
    } else {
      return widget._easyRefresh.header;
    }
  }

  /// 最終顯示的 footer
  Footer get _showFooter {
    if (widget._easyRefresh.header == null && _defaultFooterBuilder != null) {
      return _defaultFooterBuilder(context);
    } else {
      return widget._easyRefresh.footer;
    }
  }

  @override
  void initState() {
    _stateSubject.add(widget.initState);
    _updateEasyRefresh();

    var dataHandleStream = widget.stateStream?.doOnData((e) {
      _handleRefreshState(e);
    });

    if (widget.loadingDebounce != null &&
        widget.loadingDebounce > Duration.zero) {
      dataHandleStream = dataHandleStream?.debounce((e) {
        _activeDebounce();
        if (e.isLoading || !_isDebounceActive) {
          return Stream.value(e);
        } else {
          return TimerStream(e, Duration(seconds: 1));
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
    // 在下一幀之後, 直接推移一個非常非常小的距離
    // 目的只為觸發 NotificationListener 監聽 scrollView 的 size
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _firstTrigger = true;
      widget._easyRefresh.scrollController
          .jumpTo(widget._easyRefresh.scrollController.offset - 0.0000001);
    });
  }

  @override
  void didUpdateWidget(RefreshView oldWidget) {
    _updateEasyRefresh();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stackList = [];

    // 依照下列狀態有不同的顯示目標
    // 1. loadingBody - 顯示讀取圈圈
    // 2. errorBody - 顯示錯誤文字
    // 3. emptyBody - 顯示無資料文字
    // 3. 其餘狀態 - 無任何顯示
    var placeView = _getPlaceWidget();

    stackList.add(_easyRefreshNotification ?? _easyRefresh);
    stackList.add(placeView);
    return LoadProvider(
      loadStream: debounceLoadStream,
      style: LoadStyle(
        color: widget.loadStyle?.color ?? Colors.blueAccent,
        size: widget.loadStyle?.size ?? 50,
      ),
      child: Stack(
        children: stackList,
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
                widget.onRefresh();
              }
              _cancelOutRefreshCount = 0;
            },
      onLoad: widget.onLoad == null
          ? null
          : () async {
              if (_cancelOutLoadMoreCount == 0) {
                _isLoadingMore = true;
                widget.onLoad();
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
              var state = RefreshState.loading(
                type: RefreshType.loadMore,
                bounce: false,
              );
              _handleRefreshState(state);
              _stateSubject.add(state);
              widget.onLoad();
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

  /// 取得 body 的佔位元件
  Widget _getPlaceWidget() {
    return Container(
      child: StreamBuilder<RefreshState>(
        initialData: _stateSubject.value,
        stream: _stateSubject.stream,
        builder: (context, snapshot) {
//          print("取得資料~~~");
          Widget child;

          RefreshBuilder childBuilder =
              widget.placeBuilder ?? _defaultPlaceBuilder;

          if (childBuilder != null) {
            // 代表有實現自定義 佔位 元件
            child = childBuilder(
              context,
              snapshot.data,
              _placeStyle,
            );
          }

          child ??= _getDefaultPlaceWidget(snapshot.data);
          return AbsorbPointer(
            absorbing: _freezeTouch,
            child: child,
          );
        },
      ),
    );
  }

  /// 取得默認佔位元件
  Widget _getDefaultPlaceWidget(RefreshState state) {
    // 等於 null 代表使用默認顯示
    switch (state.type) {
      case RefreshType.refresh:
        if (state.isLoading) {
          // 正在加載中
//          return Container(
//            alignment: Alignment.center,
//            child: Loading.circle(
//              color: Colors.blueAccent,
//              size: 50,
//            ),
//          );
        } else if (state.empty && state.success) {
          // 加載成功, 但內容為空
          return Container(
            alignment: Alignment.center,
            child: Text(
              _placeStyle?.empty ?? "",
              style: _placeStyle?.textStyle,
            ),
          );
        } else if (!state.success) {
          // 有錯誤
          return Container(
            alignment: Alignment.center,
            child: Text(
              _placeStyle?.error ?? "",
              style: _placeStyle?.textStyle,
            ),
          );
        }
        break;
      case RefreshType.loadMore:
//        print("前置: ${state.isLoading}, bounce = ${state.bounce}");
//        if (state.isLoading && !state.bounce) {
////          print("需要顯示加載更多");
//          return Container(
//            alignment: Alignment.center,
//            child: Loading.circle(
//              color: Colors.blueAccent,
//              size: 50,
//            ),
//          );
//        }
        break;
      default:
        break;
    }
    return Container(width: 0, height: 0);
  }

  @override
  void dispose() {
    _stateStreamSubscription?.cancel();
    _stateSubject.close();
    _easyRefreshController.dispose();
    _disableSubscription?.cancel();
    super.dispose();
  }
}

/// 佔位屬性
class PlaceStyle {
  final String error;
  final String empty;

  final TextStyle textStyle;

  static PlaceStyle _default = PlaceStyle();

  const PlaceStyle({
    this.error = "发生错误, 请重新刷新",
    this.empty = "无资料",
    this.textStyle,
  });
}

/// 元件狀態
class RefreshState {
  final RefreshType type;

  /// 是否為空內容元件
  final bool empty;

  /// 是否刷新成功
  final bool success;

  /// 是否已是最新資料
  final bool noMore;

  /// 是否正在刷新/加載中
  final bool isLoading;

  /// 上方下拉loading顯示 / 下方上拉loading顯示
  final bool bounce;

  /// 中間的 loading 顯示
  final bool centerLoad;

  /// 重置刷新狀態
  final bool resetRefresh;

  /// 重置加載更多狀態
  final bool resetLoadMore;

  /// 用於刷新之後設置加載更多的 noMore
  final bool noLoadMore;

  const RefreshState._init()
      : this.empty = false,
        this.success = true,
        this.noMore = false,
        this.isLoading = false,
        this.bounce = true,
        this.centerLoad = true,
        this.type = RefreshType.refresh,
        this.resetRefresh = false,
        this.resetLoadMore = false,
        this.noLoadMore = null;

  /// 設置讀取狀態
  /// * [type] - 讀取的類型, 刷新或加載更多
  /// * [bounce] - 是否顯示對應的下拉刷新或者上拉加載, 若 false 則只有中間的 loading
  /// * [centerLoad] - 中央的 loading 顯示, 預設加載更多不會顯示
  RefreshState.loading({
    this.type = RefreshType.refresh,
    this.bounce = true,
    this.centerLoad = false,
  })  : this.empty = false,
        this.success = true,
        this.noMore = false,
        this.isLoading = true,
        this.resetRefresh = false,
        this.resetLoadMore = false,
        this.noLoadMore = null;

  /// 設置刷新的結果
  RefreshState.refresh({
    this.success,
    this.empty = false,
    this.noMore = false,
    this.resetLoadMore = true,
    this.noLoadMore,
  })  : this.isLoading = false,
        this.bounce = true,
        this.type = RefreshType.refresh,
        this.resetRefresh = false,
        this.centerLoad = false;

  /// 設置加載更多的結果
  RefreshState.loadMore({
    this.success,
    this.empty = false,
    this.noMore = false,
    this.resetRefresh = false,
  })  : this.isLoading = false,
        this.bounce = true,
        this.type = RefreshType.loadMore,
        this.resetLoadMore = false,
        this.noLoadMore = null,
        this.centerLoad = false;
}

/// 狀態類型
enum RefreshType {
  /// 刷新
  refresh,

  /// 加載更多
  loadMore,
}

class RefreshLoadStyle {
  Color color;
  double size;

  RefreshLoadStyle({this.color, this.size});
}
