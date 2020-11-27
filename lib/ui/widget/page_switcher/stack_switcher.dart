import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mx_core/mx_core.dart';

/// 頁面切換元件
/// 直接將 PageBloc 的 subPageStream 以及 routes 傳入即可
class StackSwitcher extends StatefulWidget {
  final VoidCallback onBackPage;
  final List<String> routes;
  final Stream<List<RouteData>> stream;

  /// 當尚未有 route 傳入時, 所顯示的空元件
  /// 默認為 Container()
  final Widget emptyWidget;

  final Duration duration;

  /// 縮放係數 - 0~1, 1代表不縮放
  final double scaleIn;

  /// 透明係數 - 0~1, 1代表不透明
  final double opacityIn;

  /// 位移係數
  final Offset translateIn;

  /// 縮放係數 - 0~1, 1代表不縮放
  final double scaleOut;

  /// 透明係數 - 0~1, 1代表不透明
  final double opacityOut;

  /// 位移係數
  final Offset translateOut;

  /// 動畫差值器
  /// 受限於無法從值反推回去t的關西, 暫時只能線性
  final Curve curve = Curves.linear;

  /// 動畫總開關
  final bool animateEnabled;

  /// 動畫陰影
  final BoxShadow animatedShadow;

  /// 對齊方向
  final Alignment alignment;

  /// 轉場動畫貯列排序
  final StackConfig stackConfig;

  StackSwitcher._({
    this.routes,
    this.stream,
    this.duration,
    this.emptyWidget,
    this.scaleIn,
    this.opacityIn,
    this.translateIn,
    this.scaleOut,
    this.opacityOut,
    this.translateOut,
    this.alignment,
    this.stackConfig,
    this.animateEnabled,
    this.animatedShadow,
    this.onBackPage,
  });

  factory StackSwitcher({
    List<String> routes,
    Stream<List<RouteData>> stream,
    Duration duration = const Duration(milliseconds: 300),
    Widget emptyWidget,
    double scaleIn = 1,
    double opacityIn = 0,
    Offset translateIn = Offset.zero,
    double scaleOut,
    double opacityOut,
    Offset translateOut,
    Alignment alignment = Alignment.center,
    StackConfig stackConfig = const StackConfig(),
    bool animateEnabled = true,
    BoxShadow animatedShadow = const BoxShadow(
      color: Colors.black26,
      blurRadius: 5,
      spreadRadius: 0,
    ),
    VoidCallback onBackPage,
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
    return StackSwitcher._(
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
      alignment: alignment,
      stackConfig: stackConfig,
      animateEnabled: animateEnabled,
      animatedShadow: animatedShadow,
      onBackPage: onBackPage,
    );
  }

  @override
  _StackSwitcherState createState() => _StackSwitcherState();
}

class _StackSwitcherState extends State<StackSwitcher>
    with TickerProviderStateMixin {
  List<GlobalKey> cacheKey = [];

  GlobalKey _topPageBoundaryKey = GlobalKey();
  GlobalKey _allBoundaryKey = GlobalKey();

  List<WidgetBuilder> _showChildren;
  int showIndex;

  /// 當前的轉場是 push 或 pop 嗎
  bool _transitionPush;
  ui.Image _transitionImage;

  AnimationController _controller;
  Animation<double> _fadeIn;
  Animation<double> _scaleIn;
  Animation<Offset> _translateIn;

  Animation<double> _fadeOut;
  Animation<double> _scaleOut;
  Animation<Offset> _translateOut;

  StreamSubscription _subscription;

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

  /// ======== 以下為滑動回退的相關參數 ========

  /// 初始偏移
  double _initPageOffset;

  /// 移出偏移
  double pageOutOffset;

  /// 移入偏移
  double pageInOffset;

  /// 移出透明值
  double pageOutOpacity;

  /// 移入透明值
  double pageInOpacity;

  /// 返回前頁的進度百分比
  double backPageSwipeRate;

  /// 重置滑出的頁面動畫位置
  Animation<double> restoreSwipePageAnimation;

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
          print('動畫結束');
          _controller.reset();
          _transitionImage = null;
          clearBackSwipeInfo();
          setState(() {});
          print('動畫結束2');
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
  void didUpdateWidget(StackSwitcher oldWidget) {
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
    GlobalKey usedBoundaryKey;

    if (backPageSwipeRate != null && !datas.last.isPop) {
      // 有滑動返回的資訊, 但是當前的頁面改變不是返回
      // 因此要清除返回資訊, 以正當頁面跳動
      clearBackSwipeInfo();
    }

    if (backPageSwipeRate != null) {
      // 正在返回頁面中, 使用頂端頁面的截圖
      usedBoundaryKey = _topPageBoundaryKey;
    } else {
      // 不是返回頁面, 使用全局頁面的截圖
      usedBoundaryKey = _allBoundaryKey;
    }

    if (usedBoundaryKey.currentContext == null) {
      _transitionImage = null;
      _syncData(datas);
      setState(() {});
      return;
    }

    RenderRepaintBoundary boundary =
    usedBoundaryKey.currentContext.findRenderObject();

    if (!kReleaseMode && (boundary.debugNeedsPaint ?? false)) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _cacheCapture(datas);
      });
      return;
    }

    _transitionImage = await boundary.toImage(pixelRatio: 1);

    _syncData(datas);

    if (_controller.isAnimating) {
      _controller.reset();
    }

    if (backPageSwipeRate != null) {
      _controller.value = backPageSwipeRate;
      clearBackSwipeInfo();
      // print('rate = $backRate');
    }

    await _controller.forward();
  }

  /// 清除滑動返回的資訊
  void clearBackSwipeInfo() {
    pageInOffset = null;
    pageOutOffset = null;
    backPageSwipeRate = null;
    restoreSwipePageAnimation?.removeListener(restoreAnimationUpdateOffset);
    restoreSwipePageAnimation = null;
    pageInOpacity = null;
    pageOutOpacity = null;
  }

  void _syncData(List<RouteData> datas) {
    showIndex =
        widget.routes.indexWhere((element) => element == datas.last.route);
    _transitionPush = !datas.last.isPop;

//    print('跳轉類型: push - $_transitionPush');

    if (_transitionPush != isNowSettingPush) {
      _updateSetting(push: _transitionPush);
    }

    _showChildren = datas.indexMap((e, i) {
      GlobalKey key;
      if (cacheKey.length <= i) {
        key = GlobalKey();
        cacheKey.add(key);
      }

//       ValueKey<int> key;
//       if (e.forceNew && e.route == datas.last.route) {
//         print('添加 key');
//         var showIndex = cacheKey[e.route]?.value ?? 0;
//         showIndex++;
// //          print('加 key: $showIndex');
//         key = ValueKey(showIndex);
//         cacheKey[e.route] = key;
//       } else {
//         print('沒有 key');
//         GlobalKey(debugLabel:)
//         key = cacheKey[e.route];
//       }
      return (_) => routeMixinImpl.getPage(e, key: key);
    }).toList();
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    _initPageOffset = details.globalPosition.dx;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    pageOutOffset = details.globalPosition.dx - _initPageOffset;

    if (pageOutOffset < 0) {
      pageOutOffset = 0;
    }

    // 因為是回退, 因此都是以回退為計算基準

    // 計算移出 offset 的百分比
    var offsetOutRate = pageOutOffset.divide(widget.translateIn.dx);
    backPageSwipeRate = offsetOutRate;

    // 透過移出百分比同步滑動移入偏移
    pageInOffset = widget.translateOut.dx.multiply(offsetOutRate);
    if (widget.translateOut.dx < 0) {
      pageInOffset = widget.translateOut.dx - pageInOffset;
    }

    // 透過移出百分比同步移出透明值
    if (haveOpacityIn) {
      var diffIn = 1.0.subtract(widget.opacityIn);
      var convertDiff = diffIn.multiply(offsetOutRate);
      pageOutOpacity = 1.0.subtract(convertDiff);
    }

    // 透過移出百分比同步移入透明值
    if (haveOpacityOut) {
      var diffOut = 1.0.subtract(widget.opacityOut);
      var convertDiff = diffOut.multiply(offsetOutRate);
      pageInOpacity = widget.opacityOut.add(convertDiff);
    }

    setState(() {});
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    // 檢查加速度
    var velocityX = details.velocity.pixelsPerSecond.dx;

    // 當加速度小於0代表切換上一頁
    if (velocityX > 0) {
      // 加速度大於0 => 上一頁
      print('回到上一頁: 加速度 $velocityX');
      _popPage();
    } else if (velocityX < 0) {
      // 停留本頁
      print('停留本頁: 加速度 $velocityX');
      _restoreOffset();
    } else {
      // 檢查是否滑動超過螢幕一半
      if (pageOutOffset >= Screen.width / 2) {
        // 超過螢幕一半代表切換上一頁
        print('回到上一頁: 滑動超過一半螢幕');
        _popPage();
      } else {
        print('停留本頁: 滑動小於一半螢幕');
        _restoreOffset();
      }
    }
  }

  /// 若需要回退上一頁, 則直接呼叫頁面路由類返回上一頁 []
  void _popPage() {
    widget.onBackPage();
    // routeMixinImpl.popSubPage(
    //   route: widget.parentRoute,
    //   context: context,
    // );
  }

  /// 恢復偏移
  Future<void> _restoreOffset() async {
    backPageSwipeRate = null;
    restoreSwipePageAnimation = Tween<double>(begin: pageOutOffset, end: 0.0)
        .chain(CurveTween(curve: widget.curve))
        .animate(_controller);

    restoreSwipePageAnimation.addListener(restoreAnimationUpdateOffset);

    if (_controller.isAnimating) {
      _controller.reset();
    }

    await _controller.forward();
  }

  void restoreAnimationUpdateOffset() {
    if (!_controller.isAnimating || restoreSwipePageAnimation == null) return;

    pageOutOffset = restoreSwipePageAnimation.value;

    var offsetOutRate = pageOutOffset.divide(widget.translateIn.dx);

    backPageSwipeRate = offsetOutRate;

    // 同步滑動移入的百分比
    pageInOffset = widget.translateOut.dx.multiply(offsetOutRate);
    if (widget.translateOut.dx < 0) {
      pageInOffset = widget.translateOut.dx - pageInOffset;
    }

    // 透過移出百分比同步移出透明值
    if (haveOpacityIn) {
      var diffIn = 1.0.subtract(widget.opacityIn);
      var convertDiff = diffIn.multiply(offsetOutRate);
      pageOutOpacity = 1.0.subtract(convertDiff);
    }

    // 透過移出百分比同步移入透明值
    if (haveOpacityOut) {
      var diffOut = 1.0.subtract(widget.opacityOut);
      var convertDiff = diffOut.multiply(offsetOutRate);
      pageInOpacity = widget.opacityOut.add(convertDiff);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showChildren == null) {
      return Container();
    }

    Widget oldDownWidget;
    Widget oldUpWidget;

    Widget newWidget = Stack(
      children: _showChildren.indexMap((e, i) {
        var isLast = i == _showChildren.length - 1;
        var enableSwipe =
            isLast && _showChildren.length > 1 && !_controller.isAnimating;
        var enableTransform = false;
        double pageOffset;
        double pageOpacity;
        if (isLast) {
          enableTransform = true;
          pageOffset = pageOutOffset;
          pageOpacity = pageOutOpacity;
        } else if (i == _showChildren.length - 2) {
          enableTransform = true;
          pageOffset = pageInOffset;
          pageOpacity = pageInOpacity;
        }

        var pageWidget = e.call(context);

        return GestureDetector(
          key: pageWidget.key,
          onHorizontalDragStart: enableSwipe ? _onHorizontalDragStart : null,
          onHorizontalDragUpdate: enableSwipe ? _onHorizontalDragUpdate : null,
          onHorizontalDragEnd: enableSwipe ? _onHorizontalDragEnd : null,
          child: Container(
            decoration: enableSwipe &&
                enableTransform &&
                pageOffset != null &&
                pageOffset > 0
                ? BoxDecoration(
              color: Colors.transparent,
              boxShadow: [widget.animatedShadow],
            )
                : null,
            transform: enableTransform && pageOffset != null
                ? Matrix4.translationValues(
              pageOffset,
              0,
              0,
            )
                : null,
            child: Opacity(
              opacity: pageOpacity ?? 1,
              child: RepaintBoundary(
                child: pageWidget,
                key: isLast ? _topPageBoundaryKey : null,
              ),
            ),
          ),
        );

        return e.call(context);
      }).toList(),
    );

    if (_transitionImage != null) {
      var config =
      _transitionPush ? widget.stackConfig.push : widget.stackConfig.pop;

      BoxDecoration boxShadow;
      if (widget.animatedShadow != null &&
          (haveTranslateIn || haveTranslateOut)) {
        boxShadow = BoxDecoration(
          color: Colors.transparent,
          boxShadow: [widget.animatedShadow],
        );
      }

      Widget targetShowOldWidget;

      targetShowOldWidget = CustomPaint(
        painter: _ImagePainter(
          image: _transitionImage,
        ),
      );

      var oldMatrix = Matrix4.identity();

      if (_translateOut != null) {
        oldMatrix.translate(_translateOut.value.dx, _translateOut.value.dy);
      }

      if (_scaleOut != null) {
        oldMatrix.scale(_scaleOut.value, _scaleOut.value);
      }

      targetShowOldWidget = Container(
        decoration: config == StackSort.oldUp ? boxShadow : null,
        transform: oldMatrix,
        child: targetShowOldWidget,
      );

      if (_fadeOut != null) {
        targetShowOldWidget = Opacity(
          opacity: _fadeOut.value,
          child: targetShowOldWidget,
        );
      }

      var newMatrix = Matrix4.identity();
      if (_translateIn != null) {
        newMatrix.translate(_translateIn.value.dx, _translateIn.value.dy);
      }
      if (_scaleIn != null) {
        newMatrix.scale(_scaleIn.value, _scaleIn.value);
      }

      newWidget = Opacity(
        opacity: _fadeIn != null ? _fadeIn.value : 1,
        child: Container(
          decoration: config == StackSort.oldDown && boxShadow != null
              ? boxShadow
              : BoxDecoration(color: Colors.transparent),
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
          decoration: BoxDecoration(color: Colors.transparent),
          alignment: widget.alignment,
          transform: Matrix4.identity(),
          child: newWidget,
        ),
      );
    }

    return RepaintBoundary(
      key: _allBoundaryKey,
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

  final Paint mainPaint = Paint()
    ..isAntiAlias = true;

  _ImagePainter({this.image});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(image, Offset(0, 0), mainPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    if (oldDelegate is _ImagePainter) {
      return oldDelegate.image != image;
    }
    return true;
  }
}
