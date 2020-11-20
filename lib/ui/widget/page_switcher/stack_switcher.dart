import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mx_core/mx_core.dart';

/// 頁面切換元件
/// 直接將 PageBloc 的 subPageStream 以及 routes 傳入即可
class StackSwitcher extends StatefulWidget {
  final List<String> routes;

  /// 頁面 route data
  final Stream<List<RouteData>> stream;

  /// 當尚未有 route 傳入時, 所顯示的空元件
  /// 默認為 Container()
  final Widget emptyWidget;

  /// 動畫陰影
  final BoxShadow animatedShadow;

  StackSwitcher._({
    this.routes,
    this.stream,
    this.emptyWidget,
    this.animatedShadow,
  });

  factory StackSwitcher({
    List<String> routes,
    Stream<List<RouteData>> stream,
    Widget emptyWidget,
    BoxShadow animatedShadow = const BoxShadow(
      color: Colors.black26,
      blurRadius: 5,
      spreadRadius: 0,
    ),
  }) {
    return StackSwitcher._(
      routes: routes,
      stream: stream,
      emptyWidget: emptyWidget,
      animatedShadow: animatedShadow,
    );
  }

  @override
  _StackSwitcherState createState() => _StackSwitcherState();
}

class _StackSwitcherState extends State<StackSwitcher>
    with TickerProviderStateMixin {
  List<WidgetBuilder> _showChildren;
  StreamSubscription _subscription;

  /// 初始偏移
  double _initOffset;

  /// 滑動偏移
  double pageOffset;

  AnimationController _animationController;

  final tolerance = Tolerance(
    velocity: 1.0 /
        (0.050 *
            WidgetsBinding.instance.window
                .devicePixelRatio), // logical pixels per second
    distance: 1.0 /
        WidgetsBinding
            .instance.window.devicePixelRatio, // logical pixels
  );

  @override
  void initState() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _subscription = widget.stream.listen((event) {
      _syncData(event);
      setState(() {});
    });

    super.initState();
  }

  void _syncData(List<RouteData> datas) {
    _showChildren = datas.map((e) {
      return (_) => routeMixinImpl.getSubPage(e);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_showChildren == null) {
      return Container();
    }

    return Stack(
      children: _showChildren.indexMap((e, index) {
        var isLast = index == _showChildren.length - 1;
        var enableSwipe = isLast && _showChildren.length > 1;
        enableSwipe = true;
        return GestureDetector(
          onHorizontalDragStart: enableSwipe ? _onHorizontalDragStart : null,
          onHorizontalDragUpdate: enableSwipe ? _onHorizontalDragUpdate : null,
          onHorizontalDragEnd: enableSwipe ? _onHorizontalDragEnd : null,
          child: Container(
            transform: enableSwipe && pageOffset != null
                ? Matrix4.translationValues(
              0,
              0,
              0,
            )
                : null,
            child: e.call(context),
          ),
          key: ValueKey(index),
        );
      }).toList(),
    );
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    _initOffset = details.globalPosition.dx;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    pageOffset = details.globalPosition.dx - _initOffset;
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    // 檢查加速度
    var velocityX = details.velocity.pixelsPerSecond.dx;

    // 當加速度小於0代表切換上一頁
    if (velocityX < 0) {
      // 加速度小於0 => 上一頁
    } else if (velocityX > 0){
      // 停留本頁
    } else {
      // 檢查是否滑動超過螢幕一半
      if (pageOffset >= Screen.width / 2) {
        // 超過螢幕一半代表切換上一頁
      } else {

      }
    }

  }

  /// 決定頁面回退還是恢復
  void _determinePageScrollResult() {
    if (pageOffset >= Screen.width / 2) {
      // 超過螢幕一半代表切換
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
