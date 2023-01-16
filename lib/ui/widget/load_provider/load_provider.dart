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
  /// 當 [_method]為[_LoadMethod.root]時
  /// 可以透過 [LoadProvider.setRootLoad] 的方式顯示/隱藏
  final _LoadMethod _method;

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

  const LoadProvider({
    Key? key,
    required this.child,
    this.style,
    bool? initValue,
    this.controller,
    this.tapThrough = false,
    this.builder,
  })  : _method = _LoadMethod.controller,
        value = initValue ?? false,
        super(key: key);

  const LoadProvider.root({
    Key? key,
    required this.child,
    this.style,
    this.tapThrough = false,
    this.builder,
  })  : _method = _LoadMethod.root,
        controller = null,
        value = false,
        super(key: key);

  const LoadProvider.value({
    Key? key,
    required this.child,
    required this.value,
    this.style,
    this.tapThrough = false,
    this.builder,
  })  : _method = _LoadMethod.value,
        controller = null,
        super(key: key);

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
  State<LoadProvider> createState() => _LoadProviderState();
}

class _LoadProviderState extends State<LoadProvider>
    with SingleTickerProviderStateMixin {
  late AnimatedSyncTick _animatedSync;

  late LoadStyle _currentStyle;
  late bool _currentShow;

  final StreamController<bool> _loadStreamController = StreamController();

  late Stream<bool> loadStream;

  Offset? _showPos;
  Size? _showSize;

  StreamSubscription? _listenSubscription;

  @override
  void initState() {
    Screen.init();

    loadStream = _loadStreamController.stream.asBroadcastStream();

    switch (widget._method) {
      case _LoadMethod.controller:
        _currentShow = widget.value;
        break;
      case _LoadMethod.root:
        _currentShow = false;
        break;
      case _LoadMethod.value:
        _currentShow = widget.value;
        break;
    }

    _currentStyle = widget.style ?? LoadStyle();

    _animatedSync = AnimatedSyncTick(
      type: AnimatedType.toggle,
      initToggle: _currentShow,
      vsync: this,
    );

    switch (widget._method) {
      case _LoadMethod.controller:
        widget.controller?._bind = this;
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
  void didUpdateWidget(covariant LoadProvider oldWidget) {
    if (widget._method == _LoadMethod.value && _currentShow != widget.value) {
      _currentShow = widget.value;
      // print('變更: $_currentShow');
      if (_currentShow) {
        show();
      } else {
        hide();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    Widget content = StreamBuilder<bool>(
      initialData: _currentShow,
      stream: loadStream,
      builder: (context, snapshot) {
        Widget loadAttach;
        if (snapshot.data!) {
          loadAttach = Container(
            color: Colors.transparent,
            alignment: Alignment.center,
            child: widget.builder?.call(context, _currentStyle) ??
                _defaultLoadingBuilder?.call(context, _currentStyle) ??
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
          sync: _animatedSync,
          scale: Comb.scale(
            begin: Size.zero,
            end: const Size.square(1),
          ),
          child: loadAttach,
        );

        if (_currentStyle.maskColor != null) {
          loadAttach = AnimatedComb.quick(
            alignment: Alignment.center,
            color: Comb.color(
              begin: Colors.transparent,
              end: _currentStyle.maskColor ?? Colors.transparent,
            ),
            sync: _animatedSync,
            child: loadAttach,
          );
        }

        final hasPos = (_showPos != null) && (_showSize != null);

        final loadingWidget = Positioned.fill(
          left: _showPos?.dx ?? 0,
          top: _showPos?.dy ?? 0,
          right:
              hasPos ? (Screen.width - (_showPos!.dx + _showSize!.width)) : 0,
          bottom:
              hasPos ? (Screen.height - (_showPos!.dy + _showSize!.height)) : 0,
          child: IgnorePointer(
            ignoring: !_currentShow || widget.tapThrough,
            child: loadAttach,
          ),
        );

        final childWidget = IgnorePointer(
          ignoring: _currentShow && !widget.tapThrough,
          child: widget.child,
        );

        return Stack(
          alignment: Alignment.center,
          children: [
            childWidget,
            loadingWidget,
          ],
        );
      },
    );

    if (widget._method == _LoadMethod.root) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: content,
      );
    } else {
      return content;
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
    if (mounted) {
      await _attach(attach);
      _currentShow = true;
      _loadStreamController.add(_currentShow);
      await _animatedSync.toggle(true);
    }
  }

  Future<void> hide() async {
    _currentShow = false;
    await Future.delayed(Duration.zero);
    await _animatedSync.toggle(false);
    _loadStreamController.add(_currentShow);
  }

  Future<void> _attach(BuildContext? context) async {
    if (context == null) {
      _showPos = null;
      _showSize = null;
      return;
    }

    var selfBox = context.findRenderObject() as RenderBox?;
    if (selfBox == null || !selfBox.hasSize) {
      print("box 為 null 或尚未有 size, 進行等待");
      await _waitWidgetRender();
      if (mounted) {
        selfBox = context.findRenderObject() as RenderBox?;
      } else {
        _showPos = null;
        _showSize = null;
        return;
      }
    }

    if (!mounted) {
      _showPos = null;
      _showSize = null;
      return;
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
  final waitRender = Completer<void>();
  final bindingIns = WidgetsBinding.instance;
  bindingIns.addPostFrameCallback((Duration timeStamp) {
    waitRender.complete(null);
  });
  return waitRender.future;
}
