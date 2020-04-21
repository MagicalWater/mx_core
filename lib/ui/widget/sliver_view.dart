import 'dart:async';

import 'package:flutter/material.dart';

import 'loading/loading.dart';

typedef SliverStateBuilder = Widget Function(
  BuildContext context,
  SliverState state,
  PlaceProperties place,
);

/// 預設佔位提示屬性
PlaceProperties _defaultPlaceProperties;

/// 預設的自訂佔位元件
SliverStateBuilder _defaultPlaceBuilder;

/// 預設的自訂加載更多元件
SliverStateBuilder _defaultLoadMoreBuilder;

/// 預設的下拉刷新元件
RefreshProperties _defaultRefreshProperties;

/// 列表元件
/// 已停止維護, 改使用第三方庫 https://github.com/xuelongqy/flutter_easyrefresh
class SliverView extends StatefulWidget {
  final List<Widget> slivers;

  /// 是否有載入更多, 默認無, 此參數當 SliverLoad != (loadingBody || refreshing) 時起作用
  final bool loadMore;

  /// 是否有下拉刷新功能, 默認無
  final bool refresh;

  /// 下拉刷新回調
  final RefreshCallback onRefresh;

  /// 初始化列表的狀態
  final SliverState initState;

  /// 列表狀態流
  final Stream<SliverState> stateStream;

  /// 加載更多回調
  final VoidCallback onLoadMore;

  /// 列表在主軸是否依據內容縮放
  /// 默認 false, 為填滿
  final bool shrinkWrap;

  /// 自訂列表狀態佔位元件, 回傳 null 代表不處理, 使用預設顯示
  /// 若要顯示空則回傳 Container()
  final SliverStateBuilder placeBuilder;

  /// 自訂加載更多元件, 回傳 null 代表不處理, 使用預設顯示
  /// 若要顯示空則回傳 Container()
  final SliverStateBuilder loadMoreBuilder;

  /// 列表滑動方向
  final Axis scrollDirection;

  /// 佔位提示屬性
  final PlaceProperties placeProperties;

  /// 是否反向
  final bool reverse;

  /// 列表群組之間的空格
  final SliverSpace groupSpace;

  /// 刷新相關屬性
  final RefreshProperties refreshProperties;

  SliverView({
    this.slivers = const [],
    this.loadMore = false,
    this.refresh = false,
    this.onRefresh,
    this.refreshProperties,
    this.initState = SliverState.standby,
    this.stateStream,
    this.shrinkWrap = false,
    this.scrollDirection = Axis.vertical,
    this.placeProperties,
    this.placeBuilder,
    this.loadMoreBuilder,
    this.reverse = false,
    this.groupSpace,
    this.onLoadMore,
  });

  /// 設定預設的佔位元件(全局)
  static void setDefaultPlace(SliverStateBuilder builder) {
    _defaultPlaceBuilder = builder;
  }

  /// 設定預設的加載更多元件(全局)
  static void setDefaultLoadMore(SliverStateBuilder builder) {
    _defaultLoadMoreBuilder = builder;
  }

  /// 設定預設的佔位提示屬性
  static void setDefaultPlaceProperties(PlaceProperties properties) {
    _defaultPlaceProperties = properties;
  }

  /// 設定預設的下拉刷新元件
  static void setDefaultRefreshProperties(RefreshProperties properties) {
    _defaultRefreshProperties = properties;
  }

  @override
  _SliverViewState createState() => _SliverViewState(currentState: initState);
}

class _SliverViewState extends State<SliverView> {
  /// 加載更多事件是否已經發送
  bool isLoadMoreEventSend = false;

  /// 當前列表的狀態
  SliverState currentState;

  /// 列表狀態監聽
  StreamSubscription statusSubscription;

  /// 最終顯示的佔位屬性
  PlaceProperties get lastPlaceProperties {
    return widget.placeProperties ??
        _defaultPlaceProperties ??
        PlaceProperties._default;
  }

  _SliverViewState({this.currentState});

  @override
  void didChangeDependencies() {
    statusSubscription?.cancel();
    statusSubscription = widget.stateStream?.listen((state) {
      currentState = state;
      if (currentState == SliverState.standby) {
        isLoadMoreEventSend = false;
      }
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stackList = [];
    Widget sliverListView = CustomScrollView(
      scrollDirection: widget.scrollDirection,
      shrinkWrap: widget.shrinkWrap,
      slivers: _getShowSlivers(),
      reverse: widget.reverse,
    );

    if (widget.refresh && widget.onRefresh != null) {
      // 添加官方刷新元件
      var properties = widget.refreshProperties ?? _defaultRefreshProperties;
      sliverListView = RefreshIndicator(
        child: sliverListView,
        onRefresh: widget.onRefresh,
        displacement: properties?.displacement ?? 40.0,
        color: properties?.color,
        backgroundColor: properties?.backgroundColor,
      );
    }

    // 當滿足以下條件, 則需要加入滑動監聽
    // 1. 加載更多事件尚未觸發
    // 2. 沒有正在載入列表
    // 3. 擁有載入更多
    // 4. 滑動監聽回調不為null
    if (widget.loadMore && widget.onLoadMore != null) {
      sliverListView = NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          if (!isLoadMoreEventSend &&
              currentState == SliverState.standby &&
              notification is ScrollEndNotification) {
            // 底部, 觸發加載更多
            if (notification.metrics.extentAfter == 0) {
              isLoadMoreEventSend = true;
              widget.onLoadMore();
            }

            // 頂部
            if (notification.metrics.extentBefore == 0) {}
          }
          return true;
        },
        child: sliverListView,
      );
    }

    // 依照下列狀態有不同的顯示目標
    // 1. loadingBody - 顯示讀取圈圈
    // 2. errorBody - 顯示錯誤文字
    // 3. emptyBody - 顯示無資料文字
    // 3. 其餘狀態 - 無任何顯示
    var placeView = _getPlaceWidget();

    stackList.add(sliverListView);
    stackList.add(placeView);
    return Stack(
      children: stackList,
    );
  }

  /// 取得 body 的佔位元件
  Widget _getPlaceWidget() {
    return Container(
      child: StreamBuilder<SliverState>(
        initialData: currentState,
        stream: widget.stateStream,
        builder: (context, snapshot) {
          Widget child;

          SliverStateBuilder childBuilder =
              widget.placeBuilder ?? _defaultPlaceBuilder;

          if (childBuilder != null) {
            // 代表有實現自定義 佔位 元件
            var custom = childBuilder(
              context,
              snapshot.data,
              lastPlaceProperties,
            );
            if (custom != null) {
              // 自訂顯示
              child = custom;
            }
          }
          if (child == null) {
            // 等於 null 代表使用默認顯示
            switch (snapshot.data) {
              case SliverState.loadingBody:
                child = Container(
                  alignment: Alignment.center,
                  child: Loading.circle(
                    color: Colors.blueAccent,
                    size: 50,
                  ),
                );
                break;
              case SliverState.errorBody:
                child = Container(
                  alignment: Alignment.center,
                  child: Text(
                    lastPlaceProperties?.errorBody ?? "",
                    style: lastPlaceProperties?.textStyle,
                  ),
                );
                break;
              case SliverState.emptyBody:
                child = Container(
                  alignment: Alignment.center,
                  child: Text(
                    lastPlaceProperties?.emptyBody ?? "",
                    style: lastPlaceProperties?.textStyle,
                  ),
                );
                break;
              default:
                child = Container(
                  width: 0,
                  height: 0,
                );
                break;
            }
          }

          if (widget.shrinkWrap) {
            return Wrap(
              children: <Widget>[child],
            );
          } else {
            return child;
          }
        },
      ),
    );
  }

  /// 最終顯示的 slivers, 需要穿插列表空格
  List<Widget> _getShowSlivers() {
    var show = widget.slivers;

    // 先添加群組空格
    show = _getSpaceSlivers(show);

    // 添加加載更多
    show = _getLoadMoreSlivers(show);
    return show;
  }

  /// 取得加入了空格的 slivers
  List<Widget> _getSpaceSlivers(List<Widget> slivers) {
    var show = slivers;

    // 檢查是否加入群組空格
    if (show.isNotEmpty &&
        widget.groupSpace != null &&
        widget.groupSpace.space >= 0) {
      // 有群組空格

      // 取得群組填充的空格元件
      Widget getSpaceSliver() {
        return SliverToBoxAdapter(
          child: Container(
            width: widget.scrollDirection == Axis.horizontal
                ? widget.groupSpace.space
                : null,
            height: widget.scrollDirection == Axis.vertical
                ? widget.groupSpace.space
                : null,
            color: widget.groupSpace.color,
          ),
        );
      }

      // 檢查作用域, 是否需要做用到主體
      if (widget.groupSpace._containBody()) {
        // 將所有群組列表後面都加入空格
        // 此動作加完之後, 主體 and 尾段 皆含有空格
        show = show.expand((element) {
          return [element, getSpaceSliver()];
        }).toList();

        // 檢查是否需要將尾段去除
        if (!widget.groupSpace._containTrailing()) {
          show.removeLast();
        }
      }

      // 檢查是否需要添加尾段
      if (widget.groupSpace._containTrailing()) {
        show.add(getSpaceSliver());
      }

      // 檢查是否需要添加首段
      if (widget.groupSpace._containLeading()) {
        show.insert(0, getSpaceSliver());
      }
    }
    return show;
  }

  /// 取得加入了加載更多的 slivers
  List<Widget> _getLoadMoreSlivers(List<Widget> slivers) {
    var show = slivers;
    if (widget.loadMore) {
      show.add(
        StreamBuilder<SliverState>(
          initialData: currentState,
          stream: widget.stateStream,
          builder: (context, snapshot) {
            var childWidget;
            if (!snapshot.hasData) {
              childWidget = Container();
            } else {
              SliverStateBuilder childBuilder =
                  widget.loadMoreBuilder ?? _defaultLoadMoreBuilder;

              if (childBuilder != null) {
                // 代表有實現自定義 佔位 元件
                var custom = childBuilder(
                  context,
                  snapshot.data,
                  lastPlaceProperties,
                );
                if (custom != null) {
                  // 自訂顯示
                  childWidget = custom;
                }
              }

              childWidget ??= _LoadMoreWidget(
                state: snapshot.data,
                placeProperties: lastPlaceProperties,
              );
            }
            return SliverToBoxAdapter(
              child: Builder(builder: (_) {
                if (!snapshot.hasData) {
                  return Container();
                } else {
                  Widget child;

                  SliverStateBuilder childBuilder =
                      widget.loadMoreBuilder ?? _defaultLoadMoreBuilder;

                  if (childBuilder != null) {
                    // 代表有實現自定義 佔位 元件
                    var custom = childBuilder(
                      context,
                      snapshot.data,
                      lastPlaceProperties,
                    );
                    if (custom != null) {
                      // 自訂顯示
                      child = custom;
                    } else {
                      // null 為默認顯示
                    }
                  }

                  child ??= _LoadMoreWidget(
                    state: snapshot.data,
                    placeProperties: lastPlaceProperties,
                  );

                  return child;
                }
              }),
            );
          },
        ),
      );
    }
    return show;
  }

  @override
  void dispose() {
    statusSubscription?.cancel();
    statusSubscription = null;
    super.dispose();
  }
}

/// 刷新屬性
class RefreshProperties {
  /// 下拉按鈕的箭頭顏色
  Color color;

  /// 下拉按鈕的背景顏色
  Color backgroundColor;

  /// 距離上方的距離
  double displacement;

  RefreshProperties({
    this.color,
    this.backgroundColor,
    this.displacement,
  });
}

/// 佔位屬性
class PlaceProperties {
  final String errorBody;
  final String emptyBody;
  final String loadingMore;
  final String standby;
  final String noMore;

  final TextStyle textStyle;

  static PlaceProperties _default = PlaceProperties();

  const PlaceProperties({
    this.errorBody = "发生错误, 请重新刷新",
    this.emptyBody = "无资料",
    this.loadingMore = "载入更多中...",
    this.standby = "即将载入更多",
    this.noMore = "已无更多资料",
    this.textStyle,
  });
}

/// 加載更多元件
class _LoadMoreWidget extends StatelessWidget {
  final SliverState state;
  final PlaceProperties placeProperties;

  _LoadMoreWidget({this.state, this.placeProperties});

  @override
  Widget build(BuildContext context) {
    String showText = _getShowText();
//    print("更多元件文字: $showText");
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(12),
      child: Text(
        showText,
        style: placeProperties?.textStyle,
      ),
    );
  }

  String _getShowText() {
    switch (state) {
      case SliverState.loadingMore:
        return placeProperties?.loadingMore ?? "";
      case SliverState.standby:
        return placeProperties?.standby ?? "";
      case SliverState.noMore:
        return placeProperties?.noMore ?? "";
      default:
        return "";
    }
  }
}

/// 列表之間的填充空隙
class SliverSpace {
  Color color;
  double space;
  SpaceScope scope;

  SliverSpace({
    this.space,
    this.color = Colors.transparent,
    this.scope = SpaceScope.body,
  });

  bool _containBody() {
    return scope == SpaceScope.body ||
        scope == SpaceScope.leadingBody ||
        scope == SpaceScope.trailingBody;
  }

  bool _containLeading() {
    return scope == SpaceScope.leading ||
        scope == SpaceScope.leadingBody ||
        scope == SpaceScope.leadingTrailing;
  }

  bool _containTrailing() {
    return scope == SpaceScope.trailing ||
        scope == SpaceScope.trailingBody ||
        scope == SpaceScope.leadingTrailing;
  }
}

/// 填充空隙作用域
/// 首段, 主體, 尾段
enum SpaceScope {
  /// 首段
  leading,

  /// 主體
  body,

  /// 尾段
  trailing,

  /// 首段, 主體
  leadingBody,

  /// 尾段, 主體
  trailingBody,

  /// 開頭, 尾段
  leadingTrailing,
}

/// 列表狀態
enum SliverState {
  /// 列表正讀取中
  loadingBody,

  /// 列表主體載入失敗
  errorBody,

  /// 列表主體為空
  emptyBody,

  /// 現在正載入更多
  loadingMore,

  /// 一切準備完成
  standby,

  /// 沒有更多, 與[SliverState.standby] 一樣正常顯示
  noMore,
}
