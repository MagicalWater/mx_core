import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vector;

part 'circle_range.dart';

part 'side_detect.dart';

part 'controller.dart';

typedef ExpandProgressBuilder = Widget? Function(
  BuildContext context,
  double progress,
);

/// 輔助按鈕, 類似於ios小白點
class AssistTouch extends StatefulWidget {
  /// 主按鈕的 child
  final Widget child;

  /// 主按鈕size
  final double size;

  /// action 的 size, 默認與 [size] 相同
  final double actionSize;

  /// 初始位移位置
  final Offset initOffset;

  /// 展開時的遮罩顏色
  final Color maskColor;

  /// 展開時的遮罩透明度 0~1
  final double maskOpacity;

  /// 是否可拖動, 默認開啟
  /// 當此參數開啟時, 裝載此元件的父親元件(Stack) 必須加入 GlobalKey
  final bool draggable;

  /// action 按鈕的角度, 是否隨著放射的角度變換角度
  final bool rotateAction;

  /// 子按鈕, 寬高與 width, height 相同
  final List<Widget> actions;

  /// 動畫時間(展開/縮起), 默認500毫秒
  final Duration animationDuration;

  /// 當展開圓圈會接觸到邊界時, 兩邊距離邊界的寬度
  final double sideSpace;

  /// 展開半徑
  final double expandRadius;

  /// 面板元件半徑
  final double boardRadius;

  /// 面板元件構建類
  final ExpandProgressBuilder? boardBuilder;

  final AssistTouchController? controller;

  const AssistTouch({
    Key? key,
    required this.initOffset,
    required this.child,
    this.maskColor = Colors.transparent,
    this.maskOpacity = 1,
    this.rotateAction = false,
    this.animationDuration = const Duration(milliseconds: 200),
    this.sideSpace = 50,
    this.expandRadius = 100,
    this.boardRadius = 150,
    this.size = 100,
    double? actionSize,
    this.draggable = true,
    this.actions = const [],
    this.boardBuilder,
    this.controller,
  })  : actionSize = actionSize ?? size,
        super(key: key);

  @override
  State<AssistTouch> createState() => _AssistTouchState();
}

class _AssistTouchState extends State<AssistTouch>
    with SingleTickerProviderStateMixin {
  /// 主按鈕拖曳後的位移動畫控制器
  late AnimationController animationController;

  /// 主按鈕拖曳後的位移動畫
  late Animation<Offset> mainDragAnimation;

  late Tween<Offset> mainTween;

  late Tween<double> actionTween;

  /// 展開的位移動畫
  late Animation<double> actionAnimation;

  /// 主按鈕的偏移
  late Offset mainOffset;

  /// 是否為展開狀態
  bool isExpand = false;

  /// 展開進度
  double expandProgress = 0;

  /// 子元件展開相關屬性
  late List<_ActionExpanded> actionExpanded;

  /// 展開的角度範圍
  _CircleRange? circleRange;

  @override
  void initState() {
    // 初始化主按鈕的偏移
    mainOffset = widget.initOffset;

    // 初始化所有子按鈕的偏移
    actionExpanded = List.generate(
      widget.actions.length,
      (_) => _ActionExpanded(offset: Offset.zero),
    );
    // 依照當前的展開進度, 同步所有子按鈕的偏移
    updateActionExpand();

    // 初始化動畫控制器
    initController();

    // 綁定控制器
    widget.controller?._bind = this;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant AssistTouch oldWidget) {
    if (oldWidget.controller != widget.controller) {
      // 綁定控制器
      widget.controller?._bind = this;
      // 舊的解版
      oldWidget.controller?._bind = null;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    animationController.dispose();
    widget.controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stackList = [];

    // 添加展開後的背景遮罩元件
    var expandMaskWidget = buildExpandMaskWidget();
    if (expandMaskWidget != null) {
      stackList.add(expandMaskWidget);
    }

    // 添加展開後的面板元件
    var borderWidget = buildBorderWidget();
    if (borderWidget != null) {
      stackList.add(borderWidget);
    }

    // 添加 action 元件
    var actionWidgets = buildActionWidget();
    stackList.addAll(actionWidgets);

    // 添加主按鈕元件
    Widget mainButton = buildMainButton();
    stackList.add(mainButton);

    return Stack(
      children: stackList,
    );
  }

  /// 切換展開狀態
  /// [expand] - 是否展開, 若無賦予值, 則會按照當前是否展開來切換
  Future<void> toggleExpand({bool? expand}) {
    // 更新展開範圍
    updateExpandRange(context);

    // 切換展開狀態
    if (expand != null) {
      isExpand = expand;
    } else {
      isExpand = !isExpand;
    }

    // 同步展開狀態動畫
    return syncExpandAnimation();
  }

  /// 主按鈕元件
  Widget buildMainButton() {
    Widget widgetChain = Opacity(
      opacity: 0.8,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: widget.child,
      ),
    );

    // 當 並非展開狀態 以及 元件是可拖動的時候
    // 將主按鈕加入 Draggable 元件裡面達到可拖動效果
    if (!isExpand && widget.draggable) {
      widgetChain = Draggable(
        childWhenDragging: Container(),
        feedback: Opacity(
          opacity: 0.5,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: widget.child,
          ),
        ),
        onDragEnd: (detail) {
          // 拖動結束
//          print("位移訊息(onDragEnd): ${detail.offset}");
        },
        onDraggableCanceled: (Velocity velocity, Offset offset) {
          // 拖動結束, 在此處更新位置訊息
          // 此處的 [offset] 是全局的offset
          // 因此要取得當前的偏移值, 需要再轉為local
//          print("位移訊息(onDraggableCanceled): $offset");

          // 將 offset 轉為局部 offset
          var stackBox = context.findRenderObject() as RenderBox;
          Offset stackDiff = stackBox.globalToLocal(Offset.zero);

          // 因為 draggable 的 dy 是下方, 所以要再減去 元件高度
          var fromOffset = offset + stackDiff;
          var willOffset = getLastOffset(context, fromOffset);
          startTranslateAnimation(from: fromOffset, to: willOffset);
        },
        child: widgetChain,
      );
    }

    // 依照偏移位置加入 Positioned
    widgetChain = Positioned(
      left: mainOffset.dx,
      top: mainOffset.dy,
      child: widgetChain,
    );

    return widgetChain;
  }

  /// 展開後的背景遮罩元件
  Widget? buildExpandMaskWidget() {
    if (expandProgress != 0) {
      // 當展開進度是不等於0的時候, 需要加入跟進度一樣的漸變動畫
      // 依照當前進度取得透明度
      var currentOpacity = _progressConvert(
        lower1: 0,
        upper1: 1,
        value1: expandProgress,
        lower2: 0,
        upper2: widget.maskOpacity,
      );

      // 透明值需介於 0.0~1.0
      currentOpacity = currentOpacity.clamp(0.0, 1.0);

      Widget maskWidget = GestureDetector(
        child: FractionallySizedBox(
          widthFactor: 1,
          heightFactor: 1,
          child: Container(
            color: widget.maskColor.withOpacity(currentOpacity),
          ),
        ),
        onTap: () {
          toggleExpand(expand: false);
        },
      );
      return maskWidget;
    }
    return null;
  }

  /// 展開後的面板元件
  Widget? buildBorderWidget() {
    Widget? borderWidget;
    if (widget.boardBuilder != null && expandProgress >= 0) {
      borderWidget = widget.boardBuilder!(context, expandProgress);
      if (borderWidget != null) {
        borderWidget = Positioned(
          left: mainOffset.dx + (widget.size / 2) - widget.boardRadius,
          top: mainOffset.dy + (widget.size / 2) - widget.boardRadius,
          child: Container(
            width: widget.boardRadius * 2,
            height: widget.boardRadius * 2,
            alignment: Alignment.center,
            child: borderWidget,
          ),
        );
      }
    }
    return borderWidget;
  }

  /// 所有的 action widget
  List<Widget> buildActionWidget() {
    return List.generate(
      widget.actions.length,
      (index) {
        // 將 action 元件加入 opacity
        // 根據當前的 expandProgress 展開進度決定透明值
        // 透明值須介於 0.0~1.0
        var currentOpacity = expandProgress.clamp(0.0, 1.0);

        Widget actionWidget = Opacity(
          opacity: currentOpacity,
          child: widget.actions[index],
        );

        var properties = actionExpanded[index];

        // 依照不同象限, 放射角度需要不同計算方式
        var angle = properties.angle;

        double realAngle = angle;

        if (angle > 270) {
          // 第四象限
          realAngle = 270 - angle + 180;
        } else if (angle > 180) {
          // 第三象限
          realAngle = 270 - angle + 180;
        } else if (angle > 90) {
          // 第二象限
          realAngle = 90 - angle;
        } else {
          // 第一象限
          realAngle = 90 - angle;
        }

        // action按鈕是否有依照展開的方向調整角度
        if (widget.rotateAction) {
          actionWidget = Transform.rotate(
            angle: vector.radians(realAngle),
            child: actionWidget,
          );
        }

        // 依照每個子元件的偏移屬性, 加入 Positioned
        return Positioned(
          left: properties.offset.dx,
          top: properties.offset.dy,
          width: widget.actionSize,
          height: widget.actionSize,
          child: actionWidget,
        );
      },
    );
  }

  /// 拖拉主按鈕之後, 若超過邊界則要開始位移動畫
  void startTranslateAnimation({required Offset from, required Offset to}) {
    mainDragAnimation.removeListener(mainDragAnimationListener);
    mainDragAnimation.addListener(mainDragAnimationListener);
    actionAnimation.removeListener(actionExpandAnimationListener);
    if (from == to) {
      setState(() {
//        print("刷新主 $to");
        mainOffset = to;
      });
    } else {
//      print("重置, 目標 $to");
//      animationController.removeListener(actionListener);
//      actionAnimation?.removeListener(actionListener);
      animationController.reset();
      mainTween.begin = from;
      mainTween.end = to;
      animationController.forward();
    }
  }

  /// 點擊主按鈕之後, 需要做的展開/收縮動畫
  Future<void> syncExpandAnimation() {
    double begin = actionAnimation.value;
    mainDragAnimation.removeListener(mainDragAnimationListener);
    actionAnimation.removeListener(actionExpandAnimationListener);
    actionAnimation.addListener(actionExpandAnimationListener);
    double end = isExpand ? 1 : 0;
    animationController.reset();
    actionTween.begin = begin;
    actionTween.end = end;
    return animationController.forward();
  }

  /// 當偏移位置會造成主按鈕超出邊界時, 需要進行位移修正
  /// [willOffset] - 主按鈕的偏移位置
  /// 回傳 主按鈕最終的偏移位置
  Offset getLastOffset(BuildContext context, Offset willOffset) {
    double lastDx = willOffset.dx;
    double lastDy = willOffset.dy;

    var parentWidth = context.size!.width;
    var parentHeight = context.size!.height;

    if (lastDx <= 0) {
      // 主按鈕的位置超出左邊界, 強制設定為最左邊
      lastDx = 0;
    } else if (lastDx + widget.size >= parentWidth) {
      // 主按鈕的位置超出右邊界, 強制設定為最右邊
      lastDx = parentWidth - widget.size;
    }

    if (lastDy <= 0) {
      // 主按鈕的位置超出上邊界, 強制設定為最上邊
      lastDy = 0;
    } else if (lastDy + widget.size >= parentHeight) {
      // 主按鈕的位置超出下邊界, 強制設定為最下邊
      lastDy = parentHeight - widget.size;
    }

    return Offset(lastDx, lastDy);
  }

  /// 取得展開後的子元件 offset
  _ActionExpanded getActionExpanded(double progress, int widgetIndex) {
    // 當前尚無展開範圍, 直接返回主按鈕的偏移位置
    if (circleRange == null) {
      return _ActionExpanded(offset: mainOffset);
    }

    // 先取得主元件的中央位置
    var mainCenterOffset = Offset(
      mainOffset.dx + widget.size / 2,
      mainOffset.dy + widget.size / 2,
    );

    // 取得按鈕的角度
    var actionAngle = circleRange!.getTheta(widget.actions.length, widgetIndex);

    // 將角度轉換為弧度/弳度
    var radian = vector.radians(actionAngle);

    // 半徑 * cos(弧度) = x軸長度
    double diffX = widget.expandRadius * progress * cos(radian);
    // 半徑 * sin(弧度) = y軸長度
    double diffY = widget.expandRadius * progress * sin(radian);

    // 螢幕上下座標顛倒
    diffY = -diffY;

    var expandDx = mainCenterOffset.dx + diffX - widget.actionSize / 2;

    var expandDy = mainCenterOffset.dy + diffY - widget.actionSize / 2;

//    if (progress >= 1) {
//      print("sin x = ${sin(vector.radians(actionAngle))}");
//      print(
//          "角度伸展: $actionAngle, index = $widgetIndex, 座標: ${Offset(expandDx, expandDy)}, 主按鈕中心點: $mainCenterOffset");
//    }

    return _ActionExpanded(
      offset: Offset(expandDx, expandDy),
      angle: actionAngle,
    );
  }

  /// 初始化動畫控制器
  void initController() {
    animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    mainTween = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, 0),
    );
    mainDragAnimation = mainTween.animate(
        CurvedAnimation(parent: animationController, curve: Curves.bounceOut));

    actionTween = Tween<double>(begin: 0, end: 0);
    actionAnimation = actionTween.animate(CurvedAnimation(
        parent: animationController, curve: Curves.easeOutCubic));
  }

  /// 主按鈕的超出邊界動畫位移監聽
  void mainDragAnimationListener() {
    setState(() {
      mainOffset = mainDragAnimation.value;
    });
  }

  /// 位移的展開動畫進度監聽
  void actionExpandAnimationListener() {
    setState(() {
      // 更新展開進度值
      expandProgress = actionAnimation.value;

      // 重新設定所有 action 元件的偏移值
      updateActionExpand();
    });
  }

  /// 依照當前的展開進度, 設定每個子元件的偏移
  void updateActionExpand() {
    for (int i = 0; i < actionExpanded.length; i++) {
      actionExpanded[i] = getActionExpanded(expandProgress, i);
    }
  }

  /// 更新可以展開的範圍
  void updateExpandRange(BuildContext context) {
    var containerSize = context.size!;
    var mainCenter = Offset(
        mainOffset.dx + widget.size / 2, mainOffset.dy + widget.size / 2);

    circleRange = _CircleRange(
      center: mainCenter,
      mainRadius: widget.size / 2,
      actionRadius: widget.actionSize / 2,
      expandRadius: widget.expandRadius,
      containerSize: containerSize,
      sideSpace: widget.sideSpace,
    );
  }

  /// 傳入兩個範圍, 取得範圍1中的某個點在範圍2中相同比例時的位置
  double _progressConvert({
    required double lower1,
    required double upper1,
    required double value1,
    required double lower2,
    required double upper2,
  }) {
    var proportion1 = (value1 - lower1) / (upper1 - lower1);
    var value2 = (upper2 - lower2) * proportion1 + lower2;
    return value2;
  }
}

/// 子按鈕展開時的屬性
class _ActionExpanded {
  final Offset offset;
  final double angle;

  _ActionExpanded({required this.offset, this.angle = 0});
}
