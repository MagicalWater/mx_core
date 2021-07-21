import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';

/// 頁面切換元件
/// 直接將 PageBloc 的 subPageStream 以及 routes 傳入即可
class ScrollSwitcher extends StatefulWidget {
  final List<String> routes;
  final Stream<List<RouteData>> stream;

  /// 當尚未有 route 傳入時, 所顯示的空元件
  /// 默認為 Container()
  final Widget? emptyWidget;

  final Duration duration;

  /// 動畫差值器
  final Curve curve;

  /// 動畫總開關
  final bool animateEnabled;

  final ScrollPhysics? physics;

  ScrollSwitcher._({
    required this.routes,
    required this.stream,
    required this.duration,
    required this.curve,
    required this.animateEnabled,
    this.emptyWidget,
    this.physics,
  });

  factory ScrollSwitcher({
    required List<String> routes,
    required Stream<List<RouteData>> stream,
    Duration duration = const Duration(milliseconds: 300),
    Widget? emptyWidget,
    Curve curve = Curves.ease,
    bool animateEnabled = true,
    ScrollPhysics? physics,
  }) {
    return ScrollSwitcher._(
      routes: routes,
      stream: stream,
      duration: duration,
      emptyWidget: emptyWidget,
      curve: curve,
      animateEnabled: animateEnabled,
      physics: physics,
    );
  }

  @override
  _ScrollSwitcherState createState() => _ScrollSwitcherState();
}

class _ScrollSwitcherState extends State<ScrollSwitcher> {
  Map<String, ValueKey<int>> cacheKey = {};

  PageController? _pageController;

  List<WidgetBuilder>? _showChildren;

  late StreamSubscription _subscription;

  int? toIndex;

  /// 使用者切換的忽略
  int? userIgnore;

  @override
  void initState() {
    _subscription = widget.stream.listen((event) {
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
        ValueKey<int> key;
        if (finded.forceNew && finded.route == datas.last.route) {
          var showIndex = cacheKey[finded.route]?.value ?? 0;
          showIndex++;
//          print('加 key: $showIndex');
          key = ValueKey(showIndex);
          cacheKey[finded.route] = key;
          showNew = true;
        } else {
          key = cacheKey[finded.route]!;
        }
        return (_) => routeMixinImpl.getPage(finded, key: key);
      } else {
        var key = cacheKey[e];
        return (_) => routeMixinImpl.getPage(e, key: key);
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
      return Container();
    }
    return PageView(
      children: _showChildren!.map((e) => e.call(context)).toList(),
      controller: _pageController,
      physics: widget.physics,
      onPageChanged: (index) {
        if (toIndex != null) {
//          print('吃掉');
          if (toIndex == index) {
//            print('解放');
            toIndex = null;
          }
          return;
        }
        userIgnore = index;
        routeMixinImpl.forceModifyPageDetail(widget.routes[index]);
      },
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    _pageController?.dispose();
    super.dispose();
  }
}
