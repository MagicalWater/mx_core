import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';

/// 根節點的 loadController
LoadController? _rootLoadController;

/// 預設的loading元件
Widget Function(BuildContext context, LoadStyle style)? _defaultLoadingBuilder;

class LoadStyle {
  /// loading 元件的大小
  final double size;

  /// loading 元件的顏色
  final Color color;

  /// 顯示/隱藏的動畫時間
  final Duration animationDuration;

  /// 背景遮罩顏色
  final Color? maskColor;

  LoadStyle({
    this.size = 50,
    this.color = Colors.blueAccent,
    this.animationDuration = const Duration(milliseconds: 500),
    this.maskColor,
  });
}

enum _LoadMethod {
  controller,
  root,
  value,
}

class LoadProvider extends StatefulWidget {
  /// 當 [method]為[_LoadMethod.root]時
  /// 可以透過 [LoadProvider.setRootLoad] 的方式顯示/隱藏
  final _LoadMethod method;

  final Widget child;
  final LoadController? controller;
  final Widget Function(BuildContext context, LoadStyle style)? builder;

  static void setDefaultLoading(
      Widget Function(BuildContext context, LoadStyle style) builder) {
    _defaultLoadingBuilder = builder;
  }

  /// 點擊穿透, 默認 false
  final bool tapThrough;

  /// 顯示的load樣式
  final LoadStyle? style;

  final bool value;

  LoadProvider({
    required this.child,
    this.style,
    bool? initValue,
    this.controller,
    this.tapThrough = false,
    this.builder,
  })  : this.method = _LoadMethod.controller,
        this.value = false;

  LoadProvider.root({
    required this.child,
    this.style,
    this.tapThrough = false,
    this.builder,
  })  : this.method = _LoadMethod.root,
        this.controller = null,
        this.value = false;

  LoadProvider.value({
    required this.child,
    required this.value,
    this.style,
    this.tapThrough = false,
    this.builder,
  })  : this.method = _LoadMethod.value,
        this.controller = null;

  /// 設置根節點的 load 顯示與否
  static Future<void> setRoot(
    bool show, {
    LoadStyle? style,
  }) async {
    if (_rootLoadController == null) {
      print("找不到根節點的 load, 設置失效");
    } else {
      if (show) {
        await _rootLoadController?.show(style: style);
      } else {
        await _rootLoadController?.hide();
      }
    }
  }

  @override
  _LoadProviderState createState() => _LoadProviderState();
}

class _LoadProviderState extends State<LoadProvider>
    with SingleTickerProviderStateMixin {
  late AnimatedSyncTick _animatedSync;

  late LoadStyle _currentStyle;
  late bool _currentShow;

  StreamController<bool> _loadStreamController = StreamController();

  late Stream<bool> loadStream;

  Offset? _showPos;
  Size? _showSize;

  StreamSubscription? _listenSubscription;

  @override
  void initState() {
    Screen.init();

    loadStream = _loadStreamController.stream.asBroadcastStream();

    _currentStyle = widget.style ?? LoadStyle();

    _animatedSync = AnimatedSyncTick(
      type: AnimatedType.toggle,
      initToggle: _currentShow,
      vsync: this,
    );

    switch (widget.method) {
      case _LoadMethod.controller:
        break;
      case _LoadMethod.root:
        _rootLoadController = LoadController().._bind = this;
        break;
      case _LoadMethod.value:
        _currentShow = widget.value;
        break;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget loadBuilder = StreamBuilder<bool>(
      initialData: _currentShow,
      stream: loadStream,
      builder: (context, snapshot) {
        Widget loadAttach;
        if (snapshot.data!) {
          loadAttach = Container(
            color: Colors.transparent,
            alignment: Alignment.center,
            child: _defaultLoadingBuilder?.call(context, _currentStyle) ??
                widget.builder?.call(context, _currentStyle) ??
                Loading.circle(
                  color: _currentStyle.color,
                  size: _currentStyle.size,
                ),
          );
        } else {
          loadAttach = Container();
        }

        loadAttach = AnimatedComb.quick(
          alignment: Alignment.center,
          child: loadAttach,
          sync: _animatedSync,
          scale: Comb.scale(
            begin: Size.zero,
            end: Size.square(1),
          ),
        );

        if (_currentStyle.maskColor != null) {
          loadAttach = AnimatedComb.quick(
            alignment: Alignment.center,
            child: loadAttach,
            color: Comb.color(
              begin: Colors.transparent,
              end: _currentStyle.maskColor ?? Colors.transparent,
            ),
            sync: _animatedSync,
          );
//          stack.add(maskAttach);
        }

//        stack.add(loadAttach);

        var hasPos = (_showPos != null) && (_showSize != null);

        return Positioned.fill(
          left: _showPos?.dx,
          top: _showPos?.dy,
          right: hasPos
              ? (Screen.width - (_showPos!.dx + _showSize!.width))
              : null,
          bottom: hasPos
              ? (Screen.height - (_showPos!.dy + _showSize!.height))
              : null,
          child: IgnorePointer(
            ignoring: !_currentShow || widget.tapThrough,
            child: loadAttach,
          ),
        );
      },
    );

    var stackWidget = <Widget>[];
//    var aa = Positioned.fill(child: Container(color: Colors.green,));
//    stackWidget.add(aa);
    stackWidget.add(widget.child);
    stackWidget.add(loadBuilder);

    var stack = Stack(
      alignment: Alignment.center,
      children: stackWidget,
    );

    if (widget.method == _LoadMethod.root) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: stack,
      );
    } else {
      return stack;
    }
  }

  @override
  void dispose() {
    _listenSubscription?.cancel();
    _animatedSync.toggle(false);
    _animatedSync.dispose();
    _loadStreamController.close();
    super.dispose();
  }

  bool isShowing() {
    return _currentShow;
  }

  Future<void> toggle({BuildContext? attach}) {
    if (isShowing()) {
      return hide();
    } else {
      return show(attach: attach);
    }
  }

  Future<void> show({
    BuildContext? attach,
    LoadStyle? style,
  }) async {
    if (style != null) {
      _currentStyle = style;
    }

    await Future.delayed(Duration.zero);
    await _attach(attach);
    _currentShow = true;
    _loadStreamController.add(_currentShow);
    await _animatedSync.toggle(true);
  }

  Future<void> hide() async {
    _currentShow = false;
    await Future.delayed(Duration.zero);
    await _animatedSync.toggle(false);
    _loadStreamController.add(_currentShow);
  }

  FutureOr<void> _attach(BuildContext? context) async {
    if (context == null) {
      _showPos = null;
      _showSize = null;
      return;
    }

    var selfBox = context.findRenderObject() as RenderBox?;
    if (selfBox == null || !selfBox.hasSize) {
      print("box 為 null 或尚未有 size, 進行等待");
      await _waitWidgetRender();
      selfBox = context.findRenderObject() as RenderBox?;
    }

    RenderBox? parentScrollBox = context
        .findAncestorStateOfType<ScrollableState>()
        ?.context
        .findRenderObject()! as RenderBox?;

    var selfPos = selfBox!.localToGlobal(Offset.zero);
    var selfSize = selfBox.size;
//  print("檢測 兒子 size = $selfSize, pos = $selfPos");

    if (parentScrollBox != null) {
      var parentPos = parentScrollBox.localToGlobal(Offset.zero);
      var parentSize = parentScrollBox.size;

      var left = max(selfPos.dx, parentPos.dx);
      var top = max(selfPos.dy, parentPos.dy);

      var right = min(
        selfPos.dx + selfSize.width,
        parentPos.dx + parentSize.width,
      );

      var bottom = min(
        selfPos.dy + selfSize.height,
        parentPos.dy + parentSize.height,
      );

//    print("檢測 父親 size = $parentSize, pos = $parentPos");

      selfPos = Offset(left, top);
      selfSize = Size(right - left, bottom - top);
    }

//    print('顯示的位置: $selfPos, $selfSize');

    _showPos = selfPos;
    _showSize = selfSize;
  }
}

class LoadController {
  _LoadProviderState? _bind;

  /// 當前是某正在顯示中
  bool isShowing() {
    return _bind?.isShowing() ?? false;
  }

  /// 切換loading開關
  Future<void> toggle({BuildContext? attach}) async {
    await _bind?.toggle(attach: attach);
  }

  /// [style] => 顯示的樣式
  Future<void> show({
    BuildContext? attach,
    LoadStyle? style,
  }) async {
    await _bind?.show(attach: attach, style: style);
  }

  Future<void> hide() async {
    await _bind?.hide();
  }

  void dispose() {
    _bind = null;
  }
}

/// 等待元件渲染
Future<void> _waitWidgetRender() async {
  var waitRender = Completer<void>();
  var bindingIns = WidgetsBinding.instance;
  if (bindingIns == null) {
    waitRender.complete(null);
  } else {
    bindingIns.addPostFrameCallback((Duration timeStamp) {
      waitRender.complete(null);
    });
  }
  return waitRender.future;
}
