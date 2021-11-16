import 'dart:async';
import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core/router/app_router.dart';

/// 頁面切換元件
/// 直接將 PageBloc 的 subPageStream 以及 routes 傳入即可
class PageSwitcher extends StatefulWidget {
  final List<String> routes;
  final Stream<List<RouteData>> stream;

  /// 當尚未有 route 傳入時, 所顯示的空元件
  /// 默認為 Container()
  final Widget? emptyWidget;

  final Duration duration;

  /// 縮放係數 - 0~1, 1代表不縮放
  final double? scaleIn;

  /// 透明係數 - 0~1, 1代表不透明
  final double? opacityIn;

  /// 位移係數
  final Offset? translateIn;

  /// 縮放係數 - 0~1, 1代表不縮放
  final double? scaleOut;

  /// 透明係數 - 0~1, 1代表不透明
  final double? opacityOut;

  /// 位移係數
  final Offset? translateOut;

  /// 動畫差值器
  final Curve curve;

  /// 動畫總開關
  final bool animateEnabled;

  /// 動畫陰影
  final BoxShadow? animatedShadow;

  /// 對齊方向
  final Alignment alignment;

  /// 轉場動畫貯列排序
  final StackConfig stackConfig;

  const PageSwitcher._({
    required this.routes,
    required this.stream,
    required this.duration,
    required this.curve,
    required this.alignment,
    required this.stackConfig,
    required this.animateEnabled,
    this.animatedShadow,
    this.emptyWidget,
    this.scaleIn,
    this.opacityIn,
    this.translateIn,
    this.scaleOut,
    this.opacityOut,
    this.translateOut,
  });

  factory PageSwitcher({
    required List<String> routes,
    required Stream<List<RouteData>> stream,
    Widget? emptyWidget,
    Duration duration = const Duration(milliseconds: 300),
    double? scaleIn = 1,
    double? opacityIn = 0,
    Offset? translateIn = Offset.zero,
    double? scaleOut,
    double? opacityOut,
    Offset? translateOut,
    Curve curve = Curves.ease,
    Alignment alignment = Alignment.center,
    StackConfig stackConfig = const StackConfig(),
    bool animateEnabled = true,
    BoxShadow animatedShadow = const BoxShadow(
      color: Colors.black26,
      blurRadius: 5,
      spreadRadius: 0,
    ),
  }) {
    if (scaleOut == null && scaleIn != null) {
      scaleOut = scaleIn;
    }
    if (opacityOut == null && opacityIn != null) {
      opacityOut = opacityIn;
    }
    if (translateOut == null && translateIn != null) {
      translateOut = translateIn;
    }
    return PageSwitcher._(
      routes: routes,
      stream: stream,
      duration: duration,
      emptyWidget: emptyWidget,
      scaleIn: scaleIn,
      scaleOut: scaleOut,
      opacityIn: opacityIn,
      opacityOut: opacityOut,
      translateIn: translateIn,
      translateOut: translateOut,
      curve: curve,
      alignment: alignment,
      stackConfig: stackConfig,
      animateEnabled: animateEnabled,
      animatedShadow: animatedShadow,
    );
  }

  @override
  _PageSwitcherState createState() => _PageSwitcherState();
}

class _PageSwitcherState extends State<PageSwitcher>
    with TickerProviderStateMixin {
  Map<String, ValueKey<int>> cacheKey = {};

  final GlobalKey _boundaryKey = GlobalKey();

  List<WidgetBuilder>? _showChildren;
  late int showIndex;

  /// 當前的轉場是 push 或 pop 嗎
  late bool _transitionPush;
  ui.Image? _transitionImage;

  late AnimationController _controller;
  Animation<double>? _fadeIn;
  Animation<double>? _scaleIn;
  Animation<Offset>? _translateIn;

  Animation<double>? _fadeOut;
  Animation<double>? _scaleOut;
  Animation<Offset>? _translateOut;

  late StreamSubscription _subscription;

  /// 當前的設定是 push 或者 pop
  bool isNowSettingPush = true;

  /// 是否有縮放
  bool get haveScaleIn => widget.scaleIn != null && widget.scaleIn != 1;

  bool get haveOpacityIn => widget.opacityIn != null && widget.opacityIn != 1;

  bool get haveTranslateIn =>
      widget.translateIn != null && widget.translateIn != Offset.zero;

  bool get haveScaleOut => widget.scaleOut != null && widget.scaleOut != 1;

  bool get haveOpacityOut =>
      widget.opacityOut != null && widget.opacityOut != 1;

  bool get haveTranslateOut =>
      widget.translateOut != null && widget.translateOut != Offset.zero;

  /// 是否有轉場動畫
  bool get haveTransition =>
      haveScaleIn ||
      haveOpacityIn ||
      haveScaleOut ||
      haveOpacityOut ||
      haveTranslateIn ||
      haveTranslateOut;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reset();
          _transitionImage = null;
          setState(() {});
        }
      });

    _updateSetting();

    _subscription = widget.stream.listen((event) {
      if (widget.animateEnabled && haveTransition) {
        _cacheCapture(event);
      } else {
        _syncData(event);
        setState(() {});
      }
    });
    super.initState();
  }

  void _updateSetting({bool push = true}) {
    isNowSettingPush = push;

    var curve = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    if (isNowSettingPush) {
      _fadeIn = haveOpacityIn
          ? Tween(begin: widget.opacityIn, end: 1.0).animate(curve)
          : null;
      _fadeOut = haveOpacityOut
          ? Tween(begin: 1.0, end: widget.opacityOut).animate(curve)
          : null;

      _scaleIn = haveScaleIn
          ? Tween(begin: widget.scaleIn, end: 1.0).animate(curve)
          : null;
      _scaleOut = haveScaleOut
          ? Tween(begin: 1.0, end: widget.scaleOut).animate(curve)
          : null;

      _translateIn = haveTranslateIn
          ? Tween(begin: widget.translateIn, end: Offset.zero).animate(curve)
          : null;
      _translateOut = haveTranslateOut
          ? Tween(begin: Offset.zero, end: widget.translateOut).animate(curve)
          : null;
    } else {
      _fadeIn = haveOpacityOut
          ? Tween(begin: widget.opacityOut, end: 1.0).animate(curve)
          : null;
      _fadeOut = haveOpacityIn
          ? Tween(begin: 1.0, end: widget.opacityIn).animate(curve)
          : null;

      _scaleIn = haveScaleOut
          ? Tween(begin: widget.scaleOut, end: 1.0).animate(curve)
          : null;
      _scaleOut = haveScaleOut
          ? Tween(begin: 1.0, end: widget.scaleIn).animate(curve)
          : null;

      _translateIn = haveTranslateOut
          ? Tween(begin: widget.translateOut, end: Offset.zero).animate(curve)
          : null;
      _translateOut = haveTranslateIn
          ? Tween(begin: Offset.zero, end: widget.translateIn).animate(curve)
          : null;
    }
  }

  @override
  void didUpdateWidget(PageSwitcher oldWidget) {
    _controller.duration = widget.duration;
    if (oldWidget.scaleIn != widget.scaleIn ||
        oldWidget.scaleOut != widget.scaleOut ||
        oldWidget.opacityIn != widget.opacityIn ||
        oldWidget.opacityOut != widget.opacityOut) {
      _updateSetting();
    }
    super.didUpdateWidget(oldWidget);
  }

  /// 先將當前元件的圖片擷取下來
  void _cacheCapture(List<RouteData> datas) async {
    if (_boundaryKey.currentContext == null) {
      _transitionImage = null;
      _syncData(datas);
      setState(() {});
      return;
    }

    var boundary = _boundaryKey.currentContext!.findRenderObject()
        as RenderRepaintBoundary;

    if (!kReleaseMode && boundary.debugNeedsPaint) {
      WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
        _cacheCapture(datas);
      });
      return;
    }

    _transitionImage = await boundary.toImage(pixelRatio: 1);

    _syncData(datas);

    if (_controller.isAnimating) {
      _controller.reset();
    }
    await _controller.forward();
  }

  void _syncData(List<RouteData> datas) {
    showIndex =
        widget.routes.indexWhere((element) => element == datas.last.route);
    _transitionPush = !datas.last.isPop;

//    print('跳轉類型: push - $_transitionPush');

    if (_transitionPush != isNowSettingPush) {
      _updateSetting(push: _transitionPush);
    }

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
        } else {
          key = cacheKey[finded.route];
        }
        return (_) => appRouter.getPage(finded, key: key);
      } else {
        return (_) => Container();
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_showChildren == null) {
      return Container();
    }

    Widget? oldDownWidget;
    Widget? oldUpWidget;

    Widget newWidget = IndexedStack(
      index: showIndex,
      children: _showChildren!.map((e) => e.call(context)).toList(),
    );

    if (_transitionImage != null) {
      var config =
          _transitionPush ? widget.stackConfig.push : widget.stackConfig.pop;

      BoxDecoration? boxShadow;
      if (widget.animatedShadow != null &&
          (haveTranslateIn || haveTranslateOut)) {
        boxShadow = BoxDecoration(
          color: Colors.transparent,
          boxShadow: [widget.animatedShadow!],
        );
      }

      Widget targetShowOldWidget;

      targetShowOldWidget = CustomPaint(
        painter: _ImagePainter(
          image: _transitionImage!,
        ),
      );

      var oldMatrix = Matrix4.identity();

      if (_translateOut != null) {
        oldMatrix.translate(_translateOut!.value.dx, _translateOut!.value.dy);
      }

      if (_scaleOut != null) {
        oldMatrix.scale(_scaleOut!.value, _scaleOut!.value);
      }

      targetShowOldWidget = Container(
        decoration: config == StackSort.oldUp ? boxShadow : null,
        transform: oldMatrix,
        child: targetShowOldWidget,
      );

      if (_fadeOut != null) {
        targetShowOldWidget = Opacity(
          opacity: _fadeOut!.value,
          child: targetShowOldWidget,
        );
      }

      var newMatrix = Matrix4.identity();
      if (_translateIn != null) {
        newMatrix.translate(_translateIn!.value.dx, _translateIn!.value.dy);
      }
      if (_scaleIn != null) {
        newMatrix.scale(_scaleIn!.value, _scaleIn!.value);
      }

      newWidget = Opacity(
        opacity: _fadeIn != null ? _fadeIn!.value : 1,
        child: Container(
          decoration: config == StackSort.oldDown && boxShadow != null
              ? boxShadow
              : const BoxDecoration(color: Colors.transparent),
          alignment: widget.alignment,
          transform: newMatrix,
          child: newWidget,
        ),
      );

      targetShowOldWidget = Positioned.fill(child: targetShowOldWidget);

      switch (config) {
        case StackSort.oldDown:
          oldDownWidget = targetShowOldWidget;
          break;
        case StackSort.oldUp:
          oldUpWidget = targetShowOldWidget;
          break;
      }

      oldDownWidget ??= Positioned.fill(child: Container());
    } else {
      oldDownWidget = Positioned.fill(child: Container());

      newWidget = Opacity(
        opacity: 1,
        child: Container(
          decoration: const BoxDecoration(color: Colors.transparent),
          alignment: widget.alignment,
          transform: Matrix4.identity(),
          child: newWidget,
        ),
      );
    }

    return RepaintBoundary(
      key: _boundaryKey,
      child: Stack(
        children: <Widget>[
          oldDownWidget,
          newWidget,
          if (oldUpWidget != null) oldUpWidget,
        ],
      ),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    _controller.dispose();
    super.dispose();
  }
}

class _ImagePainter extends CustomPainter {
  final ui.Image image;

  final Paint mainPaint = Paint()..isAntiAlias = true;

  _ImagePainter({required this.image});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(image, const Offset(0, 0), mainPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    if (oldDelegate is _ImagePainter) {
      return oldDelegate.image != image;
    }
    return true;
  }
}

class StackConfig {
  final StackSort push;
  final StackSort pop;

  const StackConfig({
    this.push = StackSort.oldDown,
    this.pop = StackSort.oldUp,
  });
}

enum StackSort {
  /// 老元件排序在上面
  oldDown,

  /// 老元件排序在下面
  oldUp,
}
