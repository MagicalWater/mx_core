import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mx_core/mx_core.dart';

///// 頁面切換元件
///// 直接將 PageBloc 的 subPageStream 傳入即可
//class PageSwitcher2 extends StatelessWidget {
//  final List<String> routes;
//  final Stream<List<RouteData>> stream;
//
//  /// 當尚未有 route 傳入時, 所顯示的空元件
//  /// 默認為 Container()
//  final Widget emptyWidget;
//
//  final int duration;
//
//  PageSwitcher2({
//    this.routes,
//    this.stream,
//    this.duration = 300,
//    this.emptyWidget,
//  });
//
//  @override
//  Widget build(BuildContext context) {
//    return StreamBuilder<List<RouteData>>(
//      stream: stream,
//      builder: (context, snapshot) {
//        if (!snapshot.hasData) {
//          return emptyWidget ?? Container();
//        }
//        var routeDatas = snapshot.data;
//        var index = routes.indexWhere((element) => element == routeDatas.last.route);
//        var children = routes.map((e) {
//          var finded = routeDatas.firstWhere((element) => element.route == e,
//              orElse: () => null);
//          if (finded != null) {
//            return routeMixinImpl.getSubPage(finded);
//          } else {
//            return Container();
//          }
//        }).toList();
//        return IndexedStack(
//          index: index,
//          children: children,
//        );
//      },
//    );
//  }
//}
//
//import 'package:flutter/material.dart';

class PageSwitcher2 extends StatefulWidget {
  final List<String> routes;
  final Stream<List<RouteData>> stream;

  /// 當尚未有 route 傳入時, 所顯示的空元件
  /// 默認為 Container()
  final Widget emptyWidget;

  final int duration;

  PageSwitcher2({
    this.routes,
    this.stream,
    this.duration = 300,
    this.emptyWidget,
  });

  @override
  _PageSwitcher2State createState() => _PageSwitcher2State();
}

class _PageSwitcher2State extends State<PageSwitcher2>
    with TickerProviderStateMixin {
  GlobalKey _boundaryKey = GlobalKey();
  List<Widget> _showChildren;
  int showIndex;

  ui.Image _translationImage;

  AnimationController _controller;
  Animation<double> _forwardAnimation;
  Animation<double> _reversedAnimation;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _forwardAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.ease,
      ),
    );
    _reversedAnimation = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.ease,
      ),
    );

    widget.stream.listen((event) {
      var routeDatas = event;
      showIndex = widget.routes
          .indexWhere((element) => element == routeDatas.last.route);
      _showChildren = widget.routes.map((e) {
        var finded = routeDatas.firstWhere((element) => element.route == e,
            orElse: () => null);
        if (finded != null) {
          return routeMixinImpl.getSubPage(finded);
        } else {
          return Container();
        }
      }).toList();
      cacheCapture();
    });
    super.initState();
  }

  /// 先將當前元件的圖片擷取下來
  void cacheCapture() async {
    _translationImage = null;
    setState(() {});
    _controller.reset();
    if (_boundaryKey.currentContext == null) {
      return;
    }
    print('動畫啟動');
    RenderRepaintBoundary boundary =
        _boundaryKey.currentContext.findRenderObject();
    _translationImage = await boundary.toImage(pixelRatio: 1);
    await _controller.forward();
    _translationImage = null;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_showChildren == null) {
      return Container();
    }

    var showWidget = RepaintBoundary(
      key: _boundaryKey,
      child: IndexedStack(
        index: showIndex,
        children: _showChildren,
      ),
    );

    if (_translationImage != null) {
      var imageWidget = CustomPaint(
        painter: _ImagePainter(
          image: _translationImage,
        ),
      );

      var oldAnim = AnimatedBuilder(
        animation: _reversedAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _reversedAnimation.value,
            child: ScaleTransition(
              scale: Tween(begin: 1.0, end: 0.8).animate(_reversedAnimation),
              child: imageWidget,
            ),
          );
        },
      );

      var newAnim = AnimatedBuilder(
        animation: _forwardAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _forwardAnimation.value,
            child: ScaleTransition(
              scale: Tween(begin: 0.8, end: 1.0).animate(_forwardAnimation),
              child: showWidget,
            ),
          );
        },
      );

      return Stack(
        children: <Widget>[
          oldAnim,
          newAnim,
        ],
      );
    }

    return showWidget;
  }
}

class _ImagePainter extends CustomPainter {
  final ui.Image image;

  final Paint mainPaint = Paint()..isAntiAlias = true;

  _ImagePainter({this.image});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(image, Offset(0, 0), mainPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
