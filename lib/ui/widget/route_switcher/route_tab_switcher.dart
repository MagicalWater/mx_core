import 'dart:async';
import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core/ui/widget/widget_switcher/image_painter.dart';
import 'package:mx_core/ui/widget/widget_switcher/switch_animation.dart';

/// 頁面切換元件
/// 與[RouteStackSwitcher]差別在於此元件為標籤頁方式
/// 每個頁面只會有一個實例, 且不可手勢回退
/// 目前只支持路由子頁面的配置為[HistoryShow.tab]
class RouteTabSwitcher extends StatefulWidget {
  final List<String> routes;
  final Stream<List<RouteData>> stream;

  final RouteData? initRoute;

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

  final bool debug;

  const RouteTabSwitcher._({
    required this.routes,
    required this.stream,
    required this.duration,
    required this.curve,
    required this.alignment,
    required this.stackConfig,
    required this.animateEnabled,
    this.initRoute,
    this.animatedShadow,
    this.emptyWidget,
    this.scaleIn,
    this.opacityIn,
    this.translateIn,
    this.scaleOut,
    this.opacityOut,
    this.translateOut,
    this.debug = false,
  });

  factory RouteTabSwitcher({
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
    RouteData? initRoute,
    bool animateEnabled = true,
    BoxShadow animatedShadow = const BoxShadow(
      color: Colors.black26,
      blurRadius: 5,
      spreadRadius: 0,
    ),
    bool debug = false,
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
    return RouteTabSwitcher._(
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
      initRoute: initRoute,
      animateEnabled: animateEnabled,
      animatedShadow: animatedShadow,
      debug: debug,
    );
  }

  @override
  State<RouteTabSwitcher> createState() => _RouteTabSwitcherState();
}

class _RouteTabSwitcherState extends State<RouteTabSwitcher>
    with TickerProviderStateMixin {
  /// 當前正在顯示的route index
  late int showIndex;

  /// 推送/回彈時的佔位截圖
  ui.Image? _transitionImage;

  /// 動畫資料
  late final SwitchAnimation switchAnimation;

  /// 元件堆疊, 與[tagStacks]相呼應
  List<WidgetBuilder>? widgetList;

  final cacheKey = <String, ValueKey<int>>{};

  /// 包裹所有元件的容器boundary
  /// 用於推送元件時的佔位截圖
  final GlobalKey _allBoundaryKey = GlobalKey();

  /// route 路由監聽
  StreamSubscription? _subscription;

  late bool isFirstEvent;

  @override
  void initState() {
    final controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          // 動畫結束
          // 1. 重置控制器
          // 2. 刪除佔位截圖
          switchAnimation.reset();
          _transitionImage = null;
          setState(() {});
        }
      });

    // 動畫參數
    switchAnimation = SwitchAnimation(controller: controller);

    // 更新動畫設定
    _updateAnimationParam();

    isFirstEvent = widget.initRoute != null;

    if (widget.initRoute != null) {
      // 同步設置初始路由
      _syncAnimationPush(!widget.initRoute!.isPop);
      _syncWidgetList([widget.initRoute!]);
    }

    _subscription = widget.stream.listen((event) {
      if (isFirstEvent) {
        isFirstEvent = false;
        if (event.length == 1 && event.first == widget.initRoute) {
          if (widget.debug) {
            print(
                'RouteTabSwitcher 忽略預設子頁面route事件: ${widget.initRoute?.route}');
          }
          return;
        }
      }

      if (widget.animateEnabled && switchAnimation.haveTransition) {
        _executeChangeAnimation(event);
      } else {
        _syncAnimationPush(!event.last.isPop);
        _syncWidgetList(event);
        setState(() {});
      }
    });

    super.initState();
  }

  // 同步動畫的推送/彈出
  void _syncAnimationPush(bool isPush) {
    if (isPush != switchAnimation.isPush) {
      switchAnimation.setPush(isPush);
    }
  }

  /// 更新動畫參數
  void _updateAnimationParam() {
    switchAnimation.updateSetting(
      curve: widget.curve,
      opacityIn: widget.opacityIn,
      opacityOut: widget.opacityOut,
      scaleIn: widget.scaleIn,
      scaleOut: widget.scaleOut,
      translateIn: widget.translateIn,
      translateOut: widget.translateOut,
    );
  }

  @override
  void didUpdateWidget(RouteTabSwitcher oldWidget) {
    switchAnimation.setControllerDuration(widget.duration);
    if (oldWidget.scaleIn != widget.scaleIn ||
        oldWidget.scaleOut != widget.scaleOut ||
        oldWidget.opacityIn != widget.opacityIn ||
        oldWidget.opacityOut != widget.opacityOut ||
        oldWidget.translateIn != widget.translateIn ||
        oldWidget.translateOut != widget.translateOut ||
        oldWidget.curve != widget.curve) {
      _updateAnimationParam();
    }
    super.didUpdateWidget(oldWidget);
  }

  /// 先將當前元件的圖片擷取下來
  void _executeChangeAnimation(List<RouteData> datas) async {
    final boundary = _allBoundaryKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;

    if (boundary == null) {
      _transitionImage = null;
      _syncAnimationPush(!datas.last.isPop);
      _syncWidgetList(datas);
      setState(() {});
      return;
    }

    if (!kReleaseMode && boundary.debugNeedsPaint) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (mounted) {
          _executeChangeAnimation(datas);
        }
      });
      return;
    }

    _transitionImage = await boundary.toImage(pixelRatio: 1);

    _syncAnimationPush(!datas.last.isPop);
    _syncWidgetList(datas);

    if (switchAnimation.isAnimating) {
      switchAnimation.reset();
    }
    await switchAnimation.forward();
  }

  /// 同步需要展示的元件列表
  void _syncWidgetList(List<RouteData> datas) {
    showIndex =
        widget.routes.indexWhere((element) => element == datas.last.route);

    widgetList = widget.routes.map((e) {
      final finded = datas.firstWhereOrNull(
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
        return (_) => const SizedBox.shrink();
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (widgetList == null) {
      return widget.emptyWidget ?? const SizedBox.shrink();
    }

    Widget? oldDownWidget;
    Widget? oldUpWidget;

    Widget widgetListComponent;

    if (_transitionImage != null) {
      // 有佔位截圖, 處於轉場效果狀態

      // 取得頁面效果的config, 決定元件的堆疊順序顯示
      final config = switchAnimation.isPush
          ? widget.stackConfig.push
          : widget.stackConfig.pop;

      // 取得佔位截圖元件, 並且套入轉場效果
      final transitionImageEffect = _applyEffectToTransitionImage(config);

      // 取得[widgetList]封裝的元件, 並且套入轉場效果
      widgetListComponent = _applyEffectToWidgetList(config);

      switch (config) {
        case StackSort.oldDown:
          oldDownWidget = transitionImageEffect;
          break;
        case StackSort.oldUp:
          oldUpWidget = transitionImageEffect;
          break;
      }

      oldDownWidget ??= Positioned.fill(child: Container());
    } else {
      oldDownWidget = Positioned.fill(child: Container());

      widgetListComponent = Opacity(
        opacity: 1,
        child: Container(
          decoration: const BoxDecoration(color: Colors.transparent),
          alignment: widget.alignment,
          transform: Matrix4.identity(),
          child: _widgetListComponent(),
        ),
      );
    }

    return RepaintBoundary(
      key: _allBoundaryKey,
      child: Stack(
        children: <Widget>[
          oldDownWidget,
          widgetListComponent,
          if (oldUpWidget != null) oldUpWidget,
        ],
      ),
    );
  }

  /// 當有佔位截圖時, 代表元件處於動畫中
  /// 將[widgetList]封裝成元件, 並且套入效果
  Widget _applyEffectToWidgetList(StackSort sortConfig) {
    // 檢查是否有偏移效果, 決定是否在佔位截圖加入陰影效果
    BoxDecoration? boxShadow;
    if (widget.animatedShadow != null &&
        (switchAnimation.haveTranslateIn || switchAnimation.haveTranslateOut)) {
      boxShadow = BoxDecoration(
        color: Colors.transparent,
        boxShadow: [widget.animatedShadow!],
      );
    }

    final newMatrix = Matrix4.identity();
    final translateInAnimation = switchAnimation.translateInAnimation;
    if (translateInAnimation != null) {
      newMatrix.translate(
        translateInAnimation.value.dx,
        translateInAnimation.value.dy,
      );
    }
    final scaleInAnimation = switchAnimation.scaleInAnimation;
    if (scaleInAnimation != null) {
      newMatrix.scale(scaleInAnimation.value, scaleInAnimation.value);
    }

    final opacityInAnimation = switchAnimation.opacityInAnimation;

    return Opacity(
      opacity: opacityInAnimation != null ? opacityInAnimation.value : 1,
      child: Container(
        decoration: sortConfig == StackSort.oldDown && boxShadow != null
            ? boxShadow
            : const BoxDecoration(color: Colors.transparent),
        alignment: widget.alignment,
        transform: newMatrix,
        child: _widgetListComponent(),
      ),
    );
  }

  /// 當有佔位截圖時, 代表元件處於動畫中
  /// 將佔位截圖封裝成元件, 並且套入效果
  Widget _applyEffectToTransitionImage(StackSort sortConfig) {
    // 檢查是否有偏移效果, 決定是否在佔位截圖加入陰影效果
    BoxDecoration? boxShadow;
    if (widget.animatedShadow != null &&
        (switchAnimation.haveTranslateIn || switchAnimation.haveTranslateOut)) {
      boxShadow = BoxDecoration(
        color: Colors.transparent,
        boxShadow: [widget.animatedShadow!],
      );
    }

    Widget targetShowOldWidget = CustomPaint(
      painter: ImagePainter(image: _transitionImage!),
    );

    // 針對佔位截圖的效果
    final oldMatrix = Matrix4.identity();

    // 偏移效果
    final translateOutAnimation = switchAnimation.translateOutAnimation;
    if (translateOutAnimation != null) {
      oldMatrix.translate(
        translateOutAnimation.value.dx,
        translateOutAnimation.value.dy,
      );
    }

    // 縮放效果
    final scaleOutAnimation = switchAnimation.scaleOutAnimation;
    if (scaleOutAnimation != null) {
      oldMatrix.scale(scaleOutAnimation.value, scaleOutAnimation.value);
    }

    // 將偏移以及縮放效果以Container包起
    targetShowOldWidget = Container(
      decoration: sortConfig == StackSort.oldUp ? boxShadow : null,
      transform: oldMatrix,
      child: targetShowOldWidget,
    );

    // 透明效果
    final opacityOutAnimation = switchAnimation.opacityOutAnimation;
    if (opacityOutAnimation != null) {
      targetShowOldWidget = Opacity(
        opacity: opacityOutAnimation.value,
        child: targetShowOldWidget,
      );
    }

    return Positioned.fill(child: targetShowOldWidget);
  }

  /// 將[widgetStacks]封裝成顯示元件
  Widget _widgetListComponent() {
    return IndexedStack(
      index: showIndex,
      children: widgetList!.map((e) => e(context)).toList(),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    switchAnimation.dispose();
    super.dispose();
  }
}
