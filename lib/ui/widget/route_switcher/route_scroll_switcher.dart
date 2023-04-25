import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';

/// 頁面切換元件, 核心為 [PageView], 因此是左滑右滑的形式
/// 直接將 [PageRouter] 的 subPageStream 以及 routes 傳入即可
class RouteScrollSwitcher extends StatefulWidget {
  final List<String> routes;
  final Stream<List<RouteData>> stream;

  /// 當尚未有 route 傳入時, 所顯示的空元件
  /// 默認為 SizeBox
  final Widget? emptyWidget;

  final Duration duration;

  /// 動畫差值器
  final Curve curve;

  /// 動畫總開關
  final bool animateEnabled;

  final ScrollPhysics? physics;

  final RouteData? initRoute;

  final bool debug;

  const RouteScrollSwitcher._({
    required this.routes,
    required this.stream,
    required this.duration,
    required this.curve,
    required this.animateEnabled,
    this.emptyWidget,
    this.physics,
    this.initRoute,
    this.debug = false,
  });

  factory RouteScrollSwitcher({
    required List<String> routes,
    required Stream<List<RouteData>> stream,
    Duration duration = const Duration(milliseconds: 300),
    Widget? emptyWidget,
    Curve curve = Curves.ease,
    bool animateEnabled = true,
    ScrollPhysics? physics,
    RouteData? initRoute,
    bool debug = false,
  }) {
    return RouteScrollSwitcher._(
      routes: routes,
      stream: stream,
      duration: duration,
      emptyWidget: emptyWidget,
      curve: curve,
      animateEnabled: animateEnabled,
      physics: physics,
      initRoute: initRoute,
      debug: debug,
    );
  }

  @override
  State<RouteScrollSwitcher> createState() => _RouteScrollSwitcherState();
}

class _RouteScrollSwitcherState extends State<RouteScrollSwitcher> {
  Map<String, ValueKey<int>> cacheKey = {};

  PageController? _pageController;

  List<WidgetBuilder>? _showChildren;

  StreamSubscription? _subscription;

  int? toIndex;

  /// 使用者切換的忽略
  int? userIgnore;

  late bool isFirstEvent;

  @override
  void initState() {
    isFirstEvent = widget.initRoute != null;
    if (widget.initRoute != null) {
      // 同步初始路由
      _syncData([widget.initRoute!]);
    }

    _subscription = widget.stream.listen((event) {
      if (isFirstEvent) {
        isFirstEvent = false;
        if (event.length == 1 && event.first == widget.initRoute) {
          if (widget.debug) {
            print(
                'RouteScrollSwitcher 忽略預設子頁面route事件: ${widget.initRoute?.route}');
          }
          return;
        }
      }
      _syncData(event);
    });
    super.initState();
  }

  void _syncData(List<RouteData> datas) {
    var showIndex =
        widget.routes.indexWhere((element) => element == datas.last.route);

//    print('顯示 index = $showIndex');

    var showNew = false;

    var oldLen = _showChildren?.length ?? 0;

    _showChildren = widget.routes.map((e) {
      var finded = datas.firstWhereOrNull(
        (element) => element.route == e,
      );
      if (finded != null) {
        ValueKey<int>? key;
        if (finded.forceNew && finded.route == datas.last.route) {
          var showIndex = cacheKey[finded.route]?.value ?? 0;
          showIndex++;
//          print('加 key: $showIndex');
          key = ValueKey(showIndex);
          cacheKey[finded.route] = key;
          showNew = true;
        } else {
          key = cacheKey[finded.route];
        }
        return (_) => appRouter.getPage(finded, key: key);
      } else {
        var key = cacheKey[e];
        return (_) => appRouter.getPage(e, key: key);
      }
    }).toList();

    var newLen = _showChildren?.length ?? 0;

    if (_pageController == null) {
      _pageController = PageController(initialPage: showIndex);
//      print('~~~~ index = $showIndex');
    } else {
      if (userIgnore == showIndex) {
        userIgnore = null;
        return;
      }

      print('外部設置滑動到 index = $showIndex');
      toIndex = showIndex;
      _pageController!.animateToPage(
        showIndex,
        duration: widget.duration,
        curve: widget.curve,
      );
    }

    if (oldLen != newLen || showNew) {
//      print('刷刷');
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showChildren == null) {
      return const SizedBox.shrink();
    }
    return PageView(
      controller: _pageController,
      physics: widget.physics,
      onPageChanged: (index) {
        // 檢查是否為外部的跳轉需求
        if (toIndex != null) {
          // 若是外部的需求, 則此次的頁面跳轉通知不處理
          if (toIndex == index) {
            toIndex = null;
          }
          return;
        }
        userIgnore = index;
        appRouter.forceModifyPageDetail(widget.routes[index]);
      },
      children: _showChildren!.map((e) => e.call(context)).toList(),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _pageController?.dispose();
    super.dispose();
  }
}
