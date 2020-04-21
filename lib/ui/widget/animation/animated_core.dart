import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';

part 'animated_controller.dart';

part 'animated_value/animated_value.dart';

part 'animated_value/collection_value.dart';

part 'animated_value/delay_value.dart';

part 'animated_value/direction_value.dart';

part 'animated_value/opacity_value.dart';

part 'animated_value/rotate_value.dart';

part 'animated_value/scale_value.dart';

part 'animated_value/size_value.dart';

part 'animated_value/translate_value.dart';

/// 動畫控制器回調
typedef AnimatedCoreCallback = void Function(AnimatedCoreController controller);

//typedef ToggleWidgetBuilder = Widget Function(
//    BuildContext context, bool toggle);

/// 動畫元件核心
/// 參考: https://github.com/YYFlutter/flutter-animation-set
/// 原作者: YYFlutter
///
/// 修改者: Water
///
@Deprecated("改用 AnimatedComb 替代")
// ignore: must_be_immutable
class AnimatedCore extends StatefulWidget {
  final Widget child;

  /// 動畫列表 - 整個列表動畫是串連的行為
  /// <p>主要由以下幾種動畫構成</p>
  /// [AnimatedValue.collection] - 並行動畫
  /// [AnimatedValue.rotateX] - 垂直翻轉動畫
  /// [AnimatedValue.rotateY] - 水平翻轉動畫
  /// [AnimatedValue.rotateZ] - 旋轉動畫
  /// [AnimatedValue.opacity] - 透明動畫
  /// [AnimatedValue.scale] - 縮放 width, height 動畫
  /// [AnimatedValue.scaleX] - 縮放 width 動畫
  /// [AnimatedValue.scaleY] - 縮放 height 動畫
  /// [AnimatedValue.translate] - 位移動畫
  /// [AnimatedValue.translateX] - x軸位移動畫
  /// [AnimatedValue.translateY] - y軸位移動畫
  /// [AnimatedValue.width] - 寬度size動畫
  /// [AnimatedValue.height] - 高度size動畫
  /// [AnimatedValue.direction] - 方向位移動畫
  final List<AnimatedValue> animatedList;

  /// 若此元件會放在重複使用的列表 (List / Grid / Sliver) 裡面, 則帶入 true
  /// <p>具體說明</p>
  /// 在此元素樹生命週期內, 是否有多個 AnimationController
  /// 此參數影響到使用動畫的為 [SingleTickerProviderStateMixin] 或 [TickerProviderStateMixin]
  /// 若生命週期內只有單個請使用 [SingleTickerProviderStateMixin] 效率較高
  /// 若有多個請使用 [TickerProviderStateMixin]
  final bool multipleAnimationController;

  /// 動畫行為
  final AnimatedBehavior behavior;

  /// 創建完成時, 回傳 [ToggleController] 給外部進行動畫開關
  final AnimatedCoreCallback onCreated;

  /// 動畫開關初始值
  /// 當 [behavior] 為 [AnimatedBehavior.toggle] 時有效
  final bool initToggle;

  /// 所有動畫的預設 duration
  final int defaultDuration;

  /// 所有動畫的預設差值器
  final Curve defaultCurve;

  /// 所有動畫的預設錨點
  final Alignment defaultAlignment;

  /// 點擊回調
  final VoidCallback onTap;

  /// 點擊動畫回覆後回調
  final VoidCallback onTapAfterAnimated;

  /// 自動開始 delay
  /// 只在動畫類行為 [AnimatedBehavior.once] 以及 [AnimatedBehavior.repeat] 會自動執行的動畫時有效
  final int startDelay;

  /// toggle 的行為模式中,可根據 toggle 值設定不同的 child
  ToggleWidgetBuilder toggleBuilder;

  AnimatedCore({
    Key key,
    @required this.child,
    this.multipleAnimationController = false,
    this.onCreated,
    this.behavior = AnimatedBehavior.onceReverse,
    this.initToggle,
    this.defaultDuration = 300,
    this.defaultCurve = Curves.easeInOut,
    this.defaultAlignment = FractionalOffset.center,
    this.onTap,
    this.onTapAfterAnimated,
    this.startDelay,
    this.toggleBuilder,
    @required this.animatedList,
  }) : super(key: key);

  /// 建立擁有點擊行為的動畫元件
  /// 藉由 tapDown 按下這個行為觸發動畫
  /// 由 onTap 以及 tapCancel 的事件觸發動畫返回
  factory AnimatedCore.tap({
    Key key,
    @required Widget child,
    bool multipleAnimationController = false,
    AnimatedCoreCallback onCreated,
    int defaultDuration = 300,
    Curve defaultCurve = Curves.easeInOut,
    VoidCallback onTap,
    VoidCallback onTapAfterAnimated,
    @required List<AnimatedValue> animatedList,
  }) =>
      AnimatedCore(
        key: key,
        child: child,
        multipleAnimationController: multipleAnimationController,
        onCreated: onCreated,
        behavior: AnimatedBehavior.tap,
        defaultDuration: defaultDuration,
        defaultCurve: defaultCurve,
        onTap: onTap,
        onTapAfterAnimated: onTapAfterAnimated,
        animatedList: animatedList,
      );

  /// 建立擁有開關行為的動畫元件
  factory AnimatedCore.toggle({
    Key key,
    Widget child,
    ToggleWidgetBuilder toggleBuilder,
    bool multipleAnimationController = false,
    AnimatedCoreCallback onCreated,
    bool initToggle,
    int defaultDuration = 300,
    Curve defaultCurve = Curves.easeInOut,
    VoidCallback onTap,
    @required List<AnimatedValue> animatedList,
  }) =>
      AnimatedCore(
        key: key,
        child: child,
        multipleAnimationController: multipleAnimationController,
        onCreated: onCreated,
        behavior: AnimatedBehavior.toggle,
        initToggle: initToggle,
        defaultDuration: defaultDuration,
        defaultCurve: defaultCurve,
        onTap: onTap,
        toggleBuilder: toggleBuilder,
        animatedList: animatedList,
      );

  /// 建立只執行一次的動畫元件
  factory AnimatedCore.once({
    Key key,
    @required Widget child,
    bool reverse = true,
    bool multipleAnimationController = false,
    int defaultDuration = 300,
    Curve defaultCurve = Curves.easeInOut,
    VoidCallback onTap,
    AnimatedCoreCallback onCreated,
    int startDelay,
    @required List<AnimatedValue> animatedList,
  }) =>
      AnimatedCore(
        key: key,
        child: child,
        multipleAnimationController: multipleAnimationController,
        behavior:
            reverse ? AnimatedBehavior.onceReverse : AnimatedBehavior.once,
        defaultDuration: defaultDuration,
        defaultCurve: defaultCurve,
        onCreated: onCreated,
        onTap: onTap,
        startDelay: startDelay,
        animatedList: animatedList,
      );

  /// 建立不斷重複的動畫元件
  factory AnimatedCore.repeat({
    Key key,
    @required Widget child,
    bool reverse = true,
    bool multipleAnimationController = false,
    int defaultDuration = 300,
    Curve defaultCurve = Curves.easeInOut,
    VoidCallback onTap,
    int startDelay,
    @required List<AnimatedValue> animatedList,
  }) =>
      AnimatedCore(
        key: key,
        child: child,
        multipleAnimationController: multipleAnimationController,
        behavior:
            reverse ? AnimatedBehavior.repeatReverse : AnimatedBehavior.repeat,
        defaultDuration: defaultDuration,
        defaultCurve: defaultCurve,
        onTap: onTap,
        startDelay: startDelay,
        animatedList: animatedList,
      );

  @override
  _CoreState createState() =>
      multipleAnimationController ? _MultipleCoreState() : _SingleCoreState();
}

abstract class _CoreState extends State<AnimatedCore>
    implements TickerProvider, AnimatedCoreController {
  AnimationController _controller;

  /// 當前動畫行為
  AnimatedBehavior currentBehavior;

  /// 當前動畫開關
  bool currentToggle;

  /// 依照 Alignment 分類好動畫列表
  Map<Alignment, _AnimationData> _alignmentAnimationMap = {};

  /// 取得當前的透明值
  double currentOpacityValue;

  /// 取得當前的 width 值
  double currentWidthValue;

  /// 取得當前的 height 值
  double currentHeightValue;

  /// 當前的動畫是否已經初始化完成
  bool isAnimatedInitComplete = false;

  @override
  void initState() {
    _initAnimated();

    // 若外部有實現 onCreated, 則將 controller 控制器傳出去
    if (widget.onCreated != null) {
      widget.onCreated(this);
    }

    super.initState();
  }

  @override
  void didUpdateWidget(AnimatedCore oldWidget) {
    if (_isNeedUpdate(oldWidget)) {
      _initAnimated();
    }
    super.didUpdateWidget(oldWidget);
  }

  /// 初始化動畫
  void _initAnimated() {
    // 設置初始動畫行為以及toggle開關
    currentBehavior = widget.behavior;
    currentToggle = widget.initToggle ?? false;
    currentOpacityValue = null;
    currentWidthValue = null;
    currentHeightValue = null;

    // 取得動畫總時程
    var totalMilliseconds = getTotalDuration().toInt();

    if (_controller == null) {
      // 初始化動畫控制器
      _controller = AnimationController(
        duration: Duration(milliseconds: totalMilliseconds),
        vsync: this,
      )
        ..addListener(() {
          setState(() {});
        })
        ..addStatusListener((status) {
          handleAnimatedStatusChanged(status);
        });
    } else {
      _controller.duration = Duration(milliseconds: totalMilliseconds);
    }

    // 解析所有動畫, 並且在解析完成後
    // 呼叫 handleAnimatedInitComplete() 決定是否要動作
    parseAnimatedList(totalMilliseconds).then((_) {
      isAnimatedInitComplete = true;
      handleAnimatedInitComplete();
    });
  }

  /// 檢查新舊兩個 widget 是否一樣
  bool _isNeedUpdate(AnimatedCore oldWidget) {
    if (oldWidget.behavior != widget.behavior ||
        oldWidget.initToggle != widget.initToggle ||
        oldWidget.defaultDuration != widget.defaultDuration ||
        oldWidget.defaultCurve != widget.defaultCurve ||
        oldWidget.defaultAlignment != widget.defaultAlignment ||
        oldWidget.startDelay != widget.startDelay) {
      return true;
    }

    // 最後再檢查動畫是否一樣
    var isLenSame = oldWidget.animatedList.length == widget.animatedList.length;
    var isInsSame = true;
    if (isLenSame) {
      for (var i = 0; i < oldWidget.animatedList.length; i++) {
        isInsSame = oldWidget.animatedList[i] == widget.animatedList[i];
        if (!isInsSame) break;
      }
    }

    return !isLenSame || !isInsSame;
  }

  @override
  Widget build(BuildContext context) {
    Widget childChain;

    if (currentBehavior == AnimatedBehavior.toggle &&
        widget.toggleBuilder != null) {
      childChain = widget.toggleBuilder(context, currentToggle);
    } else {
      childChain = widget.child;
    }

    Widget appendTransform(
      Matrix4 transform,
      Alignment alignment,
    ) {
      return Transform(
        alignment: alignment,
        transform: transform,
        child: childChain,
      );
    }

    _alignmentAnimationMap.forEach((alignment, data) {
      // 檢查並添加縮放動畫
      if (data._scaleList.isNotEmpty) {
        Matrix4 transform = Matrix4.identity();
        data._scaleList.forEach((e) {
          transform.scale(e.value.width, e.value.height);
        });
        childChain = appendTransform(transform, alignment);
      }

      // 檢查並添加旋轉動畫
      if (data._rotateZList.isNotEmpty) {
        Matrix4 transform = Matrix4.identity();
        data._rotateZList.forEach((e) {
          transform.rotateZ(e.value);
        });
        childChain = appendTransform(transform, alignment);
      }

      // 檢查並添加垂直翻轉動畫
      if (data._rotateXList.isNotEmpty) {
        Matrix4 transform = Matrix4.identity();
        data._rotateXList.forEach((e) {
          transform.rotateX(e.value);
        });
        childChain = appendTransform(transform, alignment);
      }

      // 檢查並添加水平翻轉動畫
      if (data._rotateYList.isNotEmpty) {
        Matrix4 transform = Matrix4.identity();
        data._rotateYList.forEach((e) {
          transform.rotateY(e.value);
        });
        childChain = appendTransform(transform, alignment);
      }

      // 檢查並添加位移動畫
      if (data._offsetList.isNotEmpty) {
        Matrix4 transform = Matrix4.identity();
        data._offsetList.forEach((e) {
          transform.translate(e.value.dx, e.value.dy);
        });
        childChain = appendTransform(transform, alignment);
      }

//      childChain = appendTransform(transform, alignment);
    });

    // 添加透明動畫
    childChain = Opacity(
      opacity: currentOpacityValue ?? 1,
      child: childChain,
    );

    // 添加 size 動畫
    childChain = Container(
      width: currentWidthValue,
      height: currentHeightValue,
      child: childChain,
    );

    // 檢查並添加點擊行為
    if (currentBehavior == AnimatedBehavior.tap) {
      childChain = GestureDetector(
        child: childChain,
        onTapDown: (_) => _controller?.forward(),
        onTapUp: (_) async {
          await _controller?.reverse();
          if (widget.onTapAfterAnimated != null) {
            widget.onTapAfterAnimated();
          }
        },
        onTapCancel: () => _controller?.reverse(),
        onTap: widget.onTap,
      );
    } else if (widget.onTap != null) {
      childChain = GestureDetector(
        child: childChain,
        onTap: widget.onTap,
      );
    }

    return childChain;
  }

  /// 切換動畫開關
  @override
  Future<void> toggle([bool value]) async {
    if (currentBehavior == AnimatedBehavior.toggle) {
      currentToggle = value ?? !currentToggle;
      await syncToggleStatus();
    } else {
      print(
          "警告: 當前動畫行為並非是 AnimatedBehavior.toggle, 無法藉由 toggle 開關動畫(請先呼叫 setBehavior() 設置動畫行為)");
    }
  }

  /// 同步當前開關應該有的動畫
  Future<void> syncToggleStatus() async {
    if (!isAnimatedInitComplete) {
      return;
    }
    if (_controller != null) {
      switch (_controller.status) {
        case AnimationStatus.dismissed:
        case AnimationStatus.reverse:
          if (currentToggle) {
            await _controller?.forward();
          }
          break;
        case AnimationStatus.forward:
        case AnimationStatus.completed:
          if (!currentToggle) {
            await _controller?.reverse();
          }
          break;
      }
    }
  }

  /// 執行一次動畫
  /// 當動畫行為是為以下幾種時有效
  /// [AnimatedBehavior.toggle]
  /// [AnimatedBehavior.tap]
  /// [AnimatedBehavior.once]
  /// [AnimatedBehavior.onceReverse]
  @override
  Future<void> once() async {
    if (isAnimatedInitComplete) {
      if (currentBehavior == AnimatedBehavior.once ||
          currentBehavior == AnimatedBehavior.onceReverse) {
        _controller?.reset();
        await _controller?.forward();
      } else if (currentBehavior == AnimatedBehavior.toggle) {
        /// 先儲存當前的 toggle 狀態
        var oriToggle = currentToggle;
        _controller?.reset();
        await _controller?.forward();
        await _controller?.reverse();
        currentToggle = oriToggle;
        syncToggleStatus();
      } else if (currentBehavior == AnimatedBehavior.tap) {
        _controller?.reset();
        await _controller?.forward();
        await _controller?.reverse();
      }
    }
  }

  /// 設置動畫行為
  @override
  Future<void> setBehavior(AnimatedBehavior behavior,
      [bool toggleValue]) async {
    currentBehavior = behavior;
    if (currentBehavior == AnimatedBehavior.toggle) {
      if (toggleValue != null) {
        await syncToggleStatus();
      }
    } else {
      await handleAnimatedStatusChanged(_controller?.status);
    }
  }

  /// 解析 animated list, 並轉為對應的 animation 放入對應的 list
  /// [total] - 動畫整體時間
  Future<void> parseAnimatedList(int total) async {
    _alignmentAnimationMap.clear();

    // 實際開始時間
    double start = 0;

    // 實際結束時間
    double end = 0;

    // 遍歷動畫列表, 轉為對應的 animation
    widget.animatedList.forEach((e) async {
      // Interval 是個 Curve, 且可設置 開始/結束 時間
      // 可藉此達到 delay 的效果
      // 開始/結束 時間是依照比例, 因此需要再除以 total 時間
      start = (e.delayed ?? 0) + end;
      end = start + e.totalDuration(widget.defaultDuration);
//      print("打印: total = $total, start = $start, end = $end");
      if (e is _CollectionValue) {
        e.animatedList.forEach((ce) async {
          var duration = ce.duration ?? e.duration ?? widget.defaultDuration;
          var delay = ce.delayed ?? 0;
          var tempStart = delay + start;
          var tempEnd = tempStart + duration;
          var tempAlignment =
              ce.alignment ?? e.alignment ?? widget.defaultAlignment;
          var tempCurve = ce.curve ?? e.curve ?? widget.defaultCurve;
          await parseAnimated(
            value: ce,
            start: tempStart / total.toDouble(),
            end: tempEnd / total.toDouble(),
            alignment: tempAlignment,
            curve: tempCurve,
          );
        });
      } else if (!(e is _DelayValue)) {
        var tempAlignment = e.alignment ?? widget.defaultAlignment;
        var tempCurve = e.curve ?? widget.defaultCurve;
        await parseAnimated(
          value: e,
          start: start / total.toDouble(),
          end: end / total.toDouble(),
          alignment: tempAlignment,
          curve: tempCurve,
        );
      }
    });
  }

  /// 解析 animated 並轉為對應的 animation 放入對應的 動畫列表
  /// [value] - 動畫屬性
  /// [start], [end] - 動畫開始/結束時間(為佔整體時間的比例, 並非是真正意義上的時間)
  Future<void> parseAnimated({
    AnimatedValue value,
    double start,
    double end,
    Alignment alignment,
    Curve curve,
  }) async {
    var beginValue, endValue;

    // 由於 direction value 是個方向, 而實際上實作的仍然是使用 offset
    // 因此需要個別做計算處理
    switch (value.runtimeType) {
      case _DirectionValue:
        var rect = await getWidgetRect(context);
        if (rect != null) {
          beginValue = value.begin == null
              ? Offset.zero
              : _getDirectionOffset(
                  value.begin,
                  (value as _DirectionValue).outScreen,
                  rect,
                );
          endValue = value.end == null
              ? Offset.zero
              : _getDirectionOffset(
                  value.end,
                  (value as _DirectionValue).outScreen,
                  rect,
                );
        } else {
          // 沒有抓到 rect, 忽略位移
          print("AnimatedCore 錯誤 - 無法取得元件 rect, 忽略方向位移屬性");
          return;
        }
        break;
      case _ScaleValue:
        switch ((value as _ScaleValue).type) {
          case _ScaleType.all:
            beginValue = Size(value.begin, value.begin);
            endValue = Size(value.end, value.end);
            break;
          case _ScaleType.width:
            beginValue = Size(value.begin, 1);
            endValue = Size(value.end, 1);
            break;
          case _ScaleType.height:
            beginValue = Size(1, value.begin);
            endValue = Size(1, value.end);
            break;
        }
        break;
      default:
        beginValue = value.begin;
        endValue = value.end;
        break;
    }

    var tween;

    Animation animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        start,
        end,
        curve: curve,
      ),
    );

    // 從已有的 動畫列表取出動畫資料, 若沒有則建立一個新的
    _AnimationData animationData =
        _alignmentAnimationMap[alignment] ?? _AnimationData();

    switch (value.runtimeType) {
      case _ScaleValue:
        tween = Tween<Size>(
          begin: beginValue,
          end: endValue,
        );
        break;
      case _WidthValue:
      case _HeightValue:
      case _OpacityValue:
      case _RotateValue:
        tween = Tween<double>(
          begin: beginValue,
          end: endValue,
        );
        break;
      case _TranslateValue:
      case _DirectionValue:
        tween = Tween<Offset>(
          begin: beginValue,
          end: endValue,
        );
        break;
    }

    animation = (tween as Tween).animate(animation);

    switch (value.runtimeType) {
      case _ScaleValue:
        animationData._scaleList.add(animation);
        break;
      case _RotateValue:
        switch ((value as _RotateValue).type) {
          case _RotateType.x:
            // 垂直翻轉
            animationData._rotateXList.add(animation);
            break;
          case _RotateType.y:
            // 水平翻轉
            animationData._rotateYList.add(animation);
            break;
          case _RotateType.z:
            // 旋轉
            animationData._rotateZList.add(animation);
            break;
        }
        break;
      case _TranslateValue:
      case _DirectionValue:
        animationData._offsetList.add(animation);
        break;
      case _OpacityValue:
        // 透明值為一個絕對的數值, 因此不需要層層疊加, 只需要一個當前值
        // 因此由此監聽值的改變不斷設值
        animation.addListener(() {
          currentOpacityValue = animation.value.clamp(0.0, 1.0);
        });
        if (currentOpacityValue == null) {
          currentOpacityValue = animation.value;
        }
        break;
      case _WidthValue:
        // 寬度為一個絕對的數值, 因此不需要層層疊加, 只需要一個當前值
        animation.addListener(() {
          currentWidthValue = max(animation.value, 0.0);
        });
        if (currentWidthValue == null) {
          currentWidthValue = max(animation.value, 0.0);
        }
        break;
      case _HeightValue:
        // 高度為一個絕對的數值, 因此不需要層層疊加, 只需要一個當前值
        animation.addListener(() {
          currentHeightValue = max(animation.value, 0.0);
        });
        if (currentHeightValue == null) {
          currentHeightValue = max(animation.value, 0.0);
        }
        break;
    }

    _alignmentAnimationMap[alignment] = animationData;
  }

  /// 依照當前元件的 rect 以及 位移方向, 返回偏移 Offset
  Offset _getDirectionOffset(
    AxisDirection direction,
    bool outScreen,
    Rect rect,
  ) {
    Offset offset;
    switch (direction) {
      case AxisDirection.up:
        offset = Offset(0, outScreen ? -rect.height - rect.top : -rect.height);
        break;
      case AxisDirection.right:
        offset = Offset(outScreen ? Screen.width - rect.left : rect.width, 0);
        break;
      case AxisDirection.down:
        offset = Offset(0, outScreen ? Screen.width - rect.top : rect.height);
        break;
      case AxisDirection.left:
        offset = Offset(outScreen ? -rect.width - rect.left : -rect.width, 0);
        break;
    }
    return offset;
  }

  /// 取得 animated list 的總total時長
  /// 回傳 milliseconds
  double getTotalDuration() {
    double duration = 0;

    widget.animatedList.forEach((e) {
      duration += ((e.delayed ?? 0) + e.totalDuration(widget.defaultDuration));
    });
    return duration;
  }

  /// 動畫初始化完成, 根據 behavior 行為進行相關處理
  Future<void> handleAnimatedInitComplete() async {
    switch (currentBehavior) {
      case AnimatedBehavior.repeatReverse:
      case AnimatedBehavior.repeat:
        await Future.delayed(Duration(milliseconds: widget.startDelay ?? 0));
        currentToggle = true;
        await _controller?.repeat(
            reverse: currentBehavior == AnimatedBehavior.repeatReverse);
        break;
      case AnimatedBehavior.onceReverse:
      case AnimatedBehavior.once:
        await Future.delayed(Duration(milliseconds: widget.startDelay ?? 0));
        currentToggle = true;
        _controller?.forward();
        break;
      case AnimatedBehavior.toggle:
        if (currentToggle) {
          _controller?.forward();
        }
        break;
      case AnimatedBehavior.tap:
        break;
    }
  }

  /// 動畫狀態改變, 根據 behavior 行為進行相關處理
  /// 以下兩個狀態代表動畫停止
  /// [AnimationStatus.dismissed] - 動畫停止在剛開始
  /// [AnimationStatus.completed] - 動畫停止在結束位置
  /// 因此需要根據動畫行為 [AnimatedBehavior] 進行相應動作
  Future<void> handleAnimatedStatusChanged(AnimationStatus status) async {
    switch (status) {
      case AnimationStatus.dismissed:
        currentToggle = false;
        break;
      case AnimationStatus.forward:
        break;
      case AnimationStatus.reverse:
        break;
      case AnimationStatus.completed:
        currentToggle = true;
        if (currentBehavior == AnimatedBehavior.onceReverse) {
          currentToggle = false;
          await _controller?.reverse();
        }
        break;
    }
  }
}

class _SingleCoreState extends _CoreState with SingleTickerProviderStateMixin {
  /// controller 需要在 super.dispose 之前釋放
  /// 但奇怪的是寫在 [_TapState] 也無法正常釋放, 因此放在此處
  /// 因此無法寫在 [_TapState] 的 dispose 方法內
  @override
  void dispose() {
    _controller.dispose();
    _controller = null;
    super.dispose();
  }
}

class _MultipleCoreState extends _CoreState with TickerProviderStateMixin {
  /// 說明參考 [_SingleToggleState] 的 dispose
  @override
  void dispose() {
    _controller.dispose();
    _controller = null;
    super.dispose();
  }
}

class _AnimationData {
  /// 縮放動畫列表, 用 Size 的方式實現x, y的分別控制
  List<Animation<Size>> _scaleList = [];

  /// 旋轉動畫列表
  List<Animation<double>> _rotateZList = [];

  /// 垂直翻轉動畫
  List<Animation<double>> _rotateXList = [];

  /// 水平翻轉動畫
  List<Animation<double>> _rotateYList = [];

  /// 偏移動畫列表
  List<Animation<Offset>> _offsetList = [];

  _AnimationData();
}
