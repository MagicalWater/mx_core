import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mx_core/extension/list.dart';
import 'package:mx_core/ui/widget/widget_switcher/switch_animation.dart';

import 'controller/action.dart';
import 'image_painter.dart';
import 'stack_config.dart';
import 'swipe_pop_data.dart';

export 'stack_config.dart';

part 'controller/controller.dart';

/// 仿造頁面切換的元件, 並含有側滑回退的功能
class WidgetSwitcher<T> extends StatefulWidget {
  /// 自訂元件彈出處理, 默認會自動呼叫[controller.pop()]
  final VoidCallback? onPopHandler;

  final WidgetSwitchController<T> controller;

  /// 元件構建
  final Widget Function(BuildContext context, T tag) builder;

  /// 初始展示的元件tag
  final T? initTag;

  /// 當尚未有 route 傳入時, 所顯示的空元件
  /// 默認為 SizedBox.shrink()
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

  /// 回退位移方向
  /// 預設 [AxisDirection.right] 右滑回退
  final AxisDirection popDirection;

  /// 是否啟用滑動回退, 默認 true
  final bool swipePopEnabled;

  /// 觸發滑動的距離, 默認 40
  final double triggerSwipeDistance;

  /// 動畫差值器
  /// 受限於無法從值反推回去t的關西, 暫時只能線性
  final Curve curve = Curves.linear;

  /// 動畫總開關
  final bool animateEnabled;

  /// 動畫陰影
  final BoxShadow? animatedShadow;

  /// 對齊方向
  final Alignment alignment;

  /// 轉場動畫貯列排序
  final StackConfig stackConfig;

  const WidgetSwitcher._({
    required this.controller,
    required this.builder,
    this.initTag,
    required this.duration,
    required this.swipePopEnabled,
    required this.triggerSwipeDistance,
    required this.alignment,
    required this.stackConfig,
    required this.animateEnabled,
    this.onPopHandler,
    this.popDirection = AxisDirection.right,
    this.animatedShadow,
    this.emptyWidget,
    this.scaleIn,
    this.opacityIn,
    this.translateIn,
    this.scaleOut,
    this.opacityOut,
    this.translateOut,
  });

  factory WidgetSwitcher({
    required WidgetSwitchController<T> controller,
    required Widget Function(BuildContext context, T tag) builder,
    T? initTag,
    Duration duration = const Duration(milliseconds: 200),
    VoidCallback? onPopHandler,
    AxisDirection popDirection = AxisDirection.right,
    double triggerSwipeDistance = 40,
    Alignment alignment = Alignment.center,
    StackConfig stackConfig = const StackConfig(),
    bool swipePopEnabled = true,
    bool animateEnabled = true,
    BoxShadow? animatedShadow = const BoxShadow(
      color: Colors.black26,
      blurRadius: 5,
      spreadRadius: 0,
    ),
    Widget? emptyWidget,
    double? scaleIn = 1,
    double? opacityIn = 0,
    Offset? translateIn = Offset.zero,
    double? scaleOut,
    double? opacityOut,
    Offset? translateOut,
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
    return WidgetSwitcher._(
      controller: controller,
      builder: builder,
      initTag: initTag,
      duration: duration,
      emptyWidget: emptyWidget,
      scaleIn: scaleIn,
      scaleOut: scaleOut,
      opacityIn: opacityIn,
      opacityOut: opacityOut,
      translateIn: translateIn,
      translateOut: translateOut,
      onPopHandler: onPopHandler,
      popDirection: popDirection,
      swipePopEnabled: swipePopEnabled,
      triggerSwipeDistance: triggerSwipeDistance,
      alignment: alignment,
      stackConfig: stackConfig,
      animateEnabled: animateEnabled,
      animatedShadow: animatedShadow,
    );
  }

  @override
  _WidgetSwitcherState<T> createState() => _WidgetSwitcherState<T>();
}

class _WidgetSwitcherState<T> extends State<WidgetSwitcher<T>>
    with TickerProviderStateMixin
    implements WidgetSwitchControllerAction<T> {
  @override
  List<T> get history => tagStacks;

  /// 綁定的controller
  late WidgetSwitchController _bindActionController;

  /// 推送/回彈時的佔位截圖
  ui.Image? _transitionImage;

  /// 滑動回退的資料
  late final SwipePopData swipePopData;

  /// 動畫資料
  late final SwitchAnimation switchAnimation;

  /// 元件tag堆疊, 與[widgetStacks]相呼應
  final tagStacks = <T>[];

  /// 元件堆疊, 與[tagStacks]相呼應
  List<WidgetBuilder>? widgetStacks;

  /// 所有元件的key, 用途有兩個
  /// 1. 將所有元件區分為不同的元件(防止系統混淆)
  /// 2. 供給[_topPageBoundaryKey]取得最頂部顯示的元件截圖
  List<GlobalKey> cacheKey = [];

  /// 最頂部顯示的元件boundary
  /// 用於回彈元件時的佔位截圖
  GlobalKey? get _topPageBoundaryKey {
    if (cacheKey.isNotEmpty) {
      return cacheKey.last;
    }
    return null;
  }

  /// 包裹所有元件的容器boundary
  /// 用於推送元件時的佔位截圖
  final GlobalKey _allBoundaryKey = GlobalKey();

  @override
  void initState() {
    _bindActionController = widget.controller;
    _bindActionController._bind = this;

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
          // 3. 清除滑動回退資訊
          switchAnimation.reset();
          _transitionImage = null;
          swipePopData.clear();
          setState(() {});
        }
      });

    // 動畫參數
    switchAnimation = SwitchAnimation(controller: controller);

    // 手勢回退參數
    swipePopData = SwipePopData(
      controller: controller,
      popDirection: widget.popDirection,
      triggerSwiperDistnance: widget.triggerSwipeDistance,
    );

    // 更新動畫設定
    _updateAnimationParam();

    if (widget.initTag != null) {
      tagStacks.add(widget.initTag!);
      _syncWidgetStack();
    }

    super.initState();
  }

  @override
  void didUpdateWidget(WidgetSwitcher<T> oldWidget) {
    switchAnimation.setControllerDuration(widget.duration);
    swipePopData.setPopDirection(
      direction: widget.popDirection,
      triggerSwiperDistnance: widget.triggerSwipeDistance,
    );
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

  /// 執行切換元件動畫
  /// 1. 擷取當前的元件圖像當作佔位展示
  /// 2. 展示完成後進行元件確切的切換
  void _executeChangeAnimation(bool isPush) async {
    GlobalKey usedBoundaryKey;

    // 檢查當前是否正在回退
    // 若當前有回退資訊, 但是卻收到推送元件的需求
    // 就需要先清除回退的資訊, 以正當元件推送
    if (swipePopData.popPageSwipeRate != null && isPush) {
      swipePopData.clear();
    }

    if (swipePopData.popPageSwipeRate != null) {
      // 正在返回頁面中, 使用頂端頁面的截圖
      usedBoundaryKey = _topPageBoundaryKey!;
    } else {
      // 不是返回頁面, 使用全局頁面的截圖
      usedBoundaryKey = _allBoundaryKey;
    }

    final boundary = usedBoundaryKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;

    // 檢查使用的boundary是否已經綁定到context上
    if (boundary == null) {
      print('無法獲取圖片, 取消動畫回退方式, 直接回退上一頁');

      // 刪除佔位圖片
      _transitionImage = null;

      // 如果需要, 更新動畫設定
      _syncAnimationPush(isPush);

      // 清除滑動回退資訊
      swipePopData.clear();

      // 同步元件列表
      _syncWidgetStack();

      setState(() {});
      return;
    }

    // 若為debug模式, 可能會出現widget尚未繪製的情形
    // 因此在此處使用下一針再進行佔位圖像動態回退
    if (!kReleaseMode && boundary.debugNeedsPaint) {
      WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
        if (mounted) {
          _executeChangeAnimation(isPush);
        }
      });
      return;
    }

    // 取得佔位截圖
    _transitionImage = await boundary.toImage(pixelRatio: 1);

    // 如果需要, 更新動畫設定
    _syncAnimationPush(isPush);

    // 同步元件列表
    _syncWidgetStack();

    // 若是當前正在動畫展示中, 則停止
    if (switchAnimation.isAnimating) {
      switchAnimation.reset();
    }

    // 若於此處仍有回退資訊時
    // 1. 此次動畫請求為回彈請求
    // 2. 為手勢拖拉放開後且滿足回彈條件
    // 因此需要將將動畫的進度與手勢回退的進度同步
    if (swipePopData.popPageSwipeRate != null) {
      switchAnimation.setControllerProgress(swipePopData.popPageSwipeRate!);

      // 同步進度後, 就可以清除手勢回退的資訊了
      swipePopData.clear();
    }

    // 最後開始展示動畫
    await switchAnimation.forward();
  }

  /// 推送元件
  @override
  void push(T tag) {
    tagStacks.add(tag);
    if (widget.animateEnabled && switchAnimation.haveTransition) {
      // print('動畫展示: ${switchAnimation.translateIn}');
      // print('動畫展示: ${switchAnimation.translateOut}');
      // 開始動畫展示
      _executeChangeAnimation(true);
    } else {
      // print('沒有動畫');
      // print('沒有動畫: ${switchAnimation.translateIn}');
      // print('沒有動畫: ${switchAnimation.translateOut}');
      _syncAnimationPush(true);
      _syncWidgetStack();
      setState(() {});
    }
  }

  /// 回彈元件
  @override
  void pop({T? tag, int? count}) {
    if (tagStacks.isEmpty) {
      // 沒有任何元件可以談出
      print('WidgetSwitcher: 元件數量為空, 無法進行pop');
      return;
    }

    // 先彈出一個元件
    tagStacks.removeLast();

    // 因為已經先彈出一個元件了, 因此默認數量可以設置為0
    count ??= 0;

    if (tag != null) {
      final endIndex = tagStacks.lastIndexOf(tag);
      if (endIndex == -1) {
        print('WidgetSwitcher: 無法於歷史元件中找到$tag標示的元件, 無法進行pop');
        return;
      }
      final newTagStacks = tagStacks.sublist(0, endIndex + 1);
      tagStacks.clear();
      tagStacks.addAll(newTagStacks);
    } else if (count > 0 && tagStacks.isNotEmpty) {
      final length = tagStacks.length;

      // 將長度-1才等於index
      final end = (length - 1) - count;
      if (end <= 0) {
        // 全彈光
        tagStacks.clear();
      } else {
        final newTagStacks = tagStacks.sublist(0, end);
        tagStacks.clear();
        tagStacks.addAll(newTagStacks);
      }
    }

    if (widget.animateEnabled && switchAnimation.haveTransition) {
      print('執行彈出動畫');
      _executeChangeAnimation(false);
    } else {
      print('執行直接彈出頁面');
      _syncAnimationPush(false);
      _syncWidgetStack();
      setState(() {});
    }
  }

  /// 同步動畫的推送/彈出
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

    swipePopData.updateSetting(
      curve: widget.curve,
      opacityIn: widget.opacityIn,
      opacityOut: widget.opacityOut,
      scaleIn: widget.scaleIn,
      scaleOut: widget.scaleOut,
      translateIn: widget.translateIn,
      translateOut: widget.translateOut,
    );
  }

  /// 同步需要展示的元件列表
  void _syncWidgetStack() {
    cacheKey = cacheKey.sublist(0, min(cacheKey.length, tagStacks.length));

    widgetStacks = tagStacks.indexMap((e, i) {
      if (cacheKey.length <= i) {
        cacheKey.add(GlobalKey());
      }
      return (BuildContext context) => SizedBox(
            key: ValueKey(i),
            child: widget.builder(context, e),
          );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (widgetStacks == null) {
      return widget.emptyWidget ?? const SizedBox.shrink();
    }

    Widget? oldDownWidget;
    Widget? oldUpWidget;

    // 真正要顯示的元件, 由[widgetStacks]轉化而成
    Widget widgetStacksComponent;

    if (_transitionImage != null) {
      // 有佔位截圖, 處於轉場效果狀態

      // 取得頁面效果的config, 決定元件的堆疊順序顯示
      final config = switchAnimation.isPush
          ? widget.stackConfig.push
          : widget.stackConfig.pop;

      // 取得佔位截圖元件, 並且套入轉場效果
      final transitionImageEffect = _applyEffectToTransitionImage(config);

      // 取得[widgetStacks]封裝的元件, 並且套入轉場效果
      widgetStacksComponent = _applyEffectToWidgetStacks(config);

      // 依照轉場效果的設定排序顯示
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

      widgetStacksComponent = Opacity(
        opacity: 1,
        child: Container(
          decoration: const BoxDecoration(color: Colors.transparent),
          alignment: widget.alignment,
          transform: Matrix4.identity(),
          child: _widgetStackComponent(),
        ),
      );
    }

    return RepaintBoundary(
      key: _allBoundaryKey,
      child: Stack(
        children: <Widget>[
          oldDownWidget,
          widgetStacksComponent,
          if (oldUpWidget != null) oldUpWidget,
        ],
      ),
    );
  }

  /// 當有佔位截圖時, 代表元件處於動畫或拖拉效果中
  /// 將[widgetStacks]封裝成元件, 並且套入效果
  Widget _applyEffectToWidgetStacks(StackSort sortConfig) {
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
        child: _widgetStackComponent(),
      ),
    );
  }

  /// 當有佔位截圖時, 代表元件處於動畫或拖拉效果中
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

    // 繪製佔位截圖的元件
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
  Widget _widgetStackComponent() {
    return Stack(
      children: widgetStacks!.indexMap((e, i) {
        final pageWidget = e(context);
        if (!widget.swipePopEnabled) {
          return pageWidget;
        }

        // 是否為最上層元件
        final isLast = i == widgetStacks!.length - 1;

        // 是否激活滑動檢測功能
        // 只有當為最上層元件, 且當時為非動畫效果時才可激活
        final enableSwipe = isLast &&
            widgetStacks!.length > 1 &&
            !swipePopData.controller.isAnimating;

        // 是否可以進行元件偏移
        // 只有最上層元件以及第二個上層元件才可以
        var enableTransform = false;

        // 元件效果顯示(偏移/淡出淡入/縮放)
        Offset? pageOffset;
        double? pageOpacity;
        double? pageScale;
        if (swipePopData.popPageSwipeRate != null &&
            swipePopData.popPageSwipeRate! > 0) {
          // 目前頁面擁有回退百分比
          if (isLast) {
            enableTransform = true;
            pageOffset = swipePopData.pageOutOffset;
            pageOpacity = swipePopData.pageOutOpacity;
            pageScale = swipePopData.pageOutScale;
          } else if (i == widgetStacks!.length - 2) {
            enableTransform = true;
            pageOffset = swipePopData.pageInOffset;
            pageOpacity = swipePopData.pageInOpacity;
            pageScale = swipePopData.pageInScale;
          } else {
            pageOpacity = 0;
          }
        } else if (!isLast) {
          // 非滑動期間, 如了第一個頁面之外其餘不用顯示
          pageOpacity = 0;
        }

        final matrix = Matrix4.identity();

        if (enableTransform) {
          if (pageOffset != null) {
            matrix.translate(pageOffset.dx, pageOffset.dy);
          }

          if (pageScale != null) {
            matrix.scale(pageScale, pageScale);
          }
        }

        // 是否顯示元件陰影(只有在頁面處於效果狀態時才顯示)
        final isShadowActive = enableSwipe &&
            enableTransform &&
            pageOffset != null &&
            pageOffset != Offset.zero &&
            widget.animatedShadow != null;

        return GestureDetector(
          onHorizontalDragStart: enableSwipe
              ? (details) => swipePopData.onHorizontalDragStart(
                    details: details,
                    containerBounds: context.findRenderObject()?.paintBounds,
                  )
              : null,
          onHorizontalDragUpdate: enableSwipe
              ? (details) {
                  final result =
                      swipePopData.onHorizontalDragUpdate(details: details);
                  if (result) {
                    // 需要更新頁面
                    setState(() {});
                  }
                }
              : null,
          onHorizontalDragEnd: enableSwipe
              ? (details) {
                  print('滑動結束');
                  final result =
                      swipePopData.onHorizontalDragEnd(details: details);
                  if (result) {
                    // 觸發彈出元件
                    if (widget.onPopHandler == null) {
                      // 不自訂動作, 直接彈出
                      pop();
                    } else {
                      // 外部需要自訂彈出動作
                      widget.onPopHandler?.call();
                    }
                  }
                }
              : null,
          onHorizontalDragCancel: enableSwipe
              ? () {
                  print('滑動取消');
                  // 側滑取消了, 當作end處理
                  final result = swipePopData.onHorizontalDragEnd();
                  if (result) {
                    // 觸發彈出元件
                    if (widget.onPopHandler == null) {
                      // 不自訂動作, 直接彈出
                      pop();
                    } else {
                      // 外部需要自訂彈出動作
                      widget.onPopHandler?.call();
                    }
                  }
                }
              : null,
          child: Container(
            decoration: isShadowActive
                ? BoxDecoration(
                    color: Colors.transparent,
                    boxShadow: [widget.animatedShadow!],
                  )
                : const BoxDecoration(color: Colors.transparent),
            alignment: widget.alignment,
            transform: matrix,
            child: Opacity(
              opacity: pageOpacity ?? 1,
              child: RepaintBoundary(
                child: pageWidget,
                key: cacheKey[i],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    switchAnimation.dispose();
    _bindActionController._bind = null;
    super.dispose();
  }
}
