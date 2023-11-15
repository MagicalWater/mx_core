import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'space_used_priority.dart';

export 'remaining_space_allocation.dart';
export 'space_used_priority.dart';

/// 強制置中佈局
/// 加入三個點
/// 1. leading - 開頭
/// 2. center - 中間, 且強制置中於整個外層佈局
/// 3. trailing - 結尾
/// leading 以及 trailing 的最大寬度將不可超過整體元件的一半
/// 開頭跟結尾的寬度將會一樣
class ForceCenterLayout extends MultiChildRenderObjectWidget {
  final Widget? leading;
  final Widget center;
  final Widget? trailing;

  /// 當空間不足以讓三個元件同時平鋪時
  /// 需要有優先順序, 默認為中間優先
  final SpaceUsedPriority spaceUsedPriority;

  /// 方向
  final Axis direction;

  /// [direction]為[Axis.horizontal]時, 代表是針對垂直方向的對齊
  /// [direction]為[Axis.vertical]時, 代表是針對水平方向的對齊
  final CrossAxisAlignment crossAxisAlignment;

  /// [center]兩邊間隔
  @Deprecated('不再起作用, 需要間隔請直接在 center 元件內部加入間隔')
  final double gapSpace;

  /// 是否壓縮主軸空間
  @Deprecated('不再起作用, 默認false')
  final bool mainShrinkWrap;

  /// 是否壓縮交叉軸空間
  @Deprecated('不再起作用, 默認false')
  final bool crossShrinkWrap;

  ForceCenterLayout({
    Key? key,
    required this.center,
    this.leading,
    this.trailing,
    this.spaceUsedPriority = SpaceUsedPriority.centerFirst,
    this.direction = Axis.horizontal,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.gapSpace = 0,
    this.mainShrinkWrap = false,
    this.crossShrinkWrap = false,
  }) : super(
          key: key,
          children: [leading, center, trailing].whereNotNull().toList(),
        );

  @override
  RenderObject createRenderObject(BuildContext context) {
    return ForceCenterBox(
      leading: leading,
      center: center,
      trailing: trailing,
      spaceUsedPriority: spaceUsedPriority,
      direction: direction,
      crossAxisAlignment: crossAxisAlignment,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderObject renderObject) {
    (renderObject as ForceCenterBox)
      ..leading = leading
      ..center = center
      ..trailing = trailing
      ..spaceUsedPriority = spaceUsedPriority
      ..direction = direction
      ..crossAxisAlignment = crossAxisAlignment;
  }
}

class _ForceCenterParentData extends ContainerBoxParentData<RenderBox> {}

class ForceCenterBox extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _ForceCenterParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _ForceCenterParentData> {
  Widget? leading;
  Widget center;
  Widget? trailing;

  /// 當空間不足以讓三個元件同時平鋪時
  /// 需要有優先順序, 默認為中間優先
  SpaceUsedPriority spaceUsedPriority;

  /// 方向
  Axis direction;

  /// [direction]為[Axis.horizontal]時, 代表是針對垂直方向的對齊
  /// [direction]為[Axis.vertical]時, 代表是針對水平方向的對齊
  CrossAxisAlignment crossAxisAlignment;

  ForceCenterBox({
    this.leading,
    required this.center,
    this.trailing,
    required this.spaceUsedPriority,
    required this.direction,
    required this.crossAxisAlignment,
  });

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! _ForceCenterParentData) {
      child.parentData = _ForceCenterParentData();
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void performLayout() {
    // _horizontalPerformLayout 與 _verticalPerformLayout 兩個確認佈局的方法
    // 內容幾乎一模一樣, 只差在一個垂直為主, 一個水平為主
    // TODO: 後續應有優化空間, 在此先留下應優化的註解
    switch (direction) {
      case Axis.horizontal:
        _horizontalPerformLayout();
        break;
      case Axis.vertical:
        _verticalPerformLayout();
        break;
    }
  }

  /// 水平佈局
  void _horizontalPerformLayout() {
    RenderBox? leadingChild, centerChild, trailingChild;

    if (childCount == 1) {
      // 只有置中
      centerChild = firstChild!;
    } else if (childCount == 2) {
      // 檢查有開頭還是結尾
      if (leading != null) {
        // 有開頭
        leadingChild = firstChild!;
        centerChild = lastChild!;
      } else {
        // 有結尾
        centerChild = firstChild!;
        trailingChild = lastChild!;
      }
    } else {
      // 三個都有
      leadingChild = firstChild!;
      centerChild = childAfter(leadingChild) as RenderBox;
      trailingChild = lastChild!;
    }

    if (leadingChild != null || trailingChild != null) {
      // 有雙邊, 需要針對空間區域做分配

      // 依照優先序
      switch (spaceUsedPriority) {
        case SpaceUsedPriority.centerFirst:
          // 先將所有空間開放給置中元件
          // 中間佈局
          centerChild.layout(constraints.loosen(), parentUsesSize: true);

          // 再將剩餘的空間分配給兩端
          final remainingWidth = constraints.maxWidth - centerChild.size.width;

          // 兩端約束
          final leafConstraints = constraints
              .copyWith(
                maxWidth: remainingWidth / 2,
              )
              .loosen();

          leadingChild?.layout(leafConstraints, parentUsesSize: true);
          trailingChild?.layout(leafConstraints, parentUsesSize: true);

          break;
        case SpaceUsedPriority.bothEndsFirst:
          // 先將空間平均配給兩端, 以最長的為主
          final leafConstraints = constraints
              .copyWith(
                maxWidth: constraints.maxWidth / 2,
              )
              .loosen();

          // 兩端佈局
          leadingChild?.layout(leafConstraints, parentUsesSize: true);
          trailingChild?.layout(leafConstraints, parentUsesSize: true);

          final maxLeafWidth = max(
            leadingChild?.size.width ?? 0,
            trailingChild?.size.width ?? 0,
          );

          // 剩餘空間寬度
          final remainingWidth = constraints.maxWidth - (maxLeafWidth * 2);

          // 中間約束
          final mainConstraints = constraints
              .copyWith(
                maxWidth: remainingWidth,
              )
              .loosen();

          centerChild.layout(mainConstraints, parentUsesSize: true);

          break;
      }
    } else {
      // 只有置中元件, 直接測量
      centerChild.layout(constraints.loosen(), parentUsesSize: true);
    }

    final maxHeight = [
      leadingChild?.size.height,
      centerChild.size.height,
      trailingChild?.size.height,
    ].whereNotNull().reduce(max);

    final leafWidth = max(
      leadingChild?.size.width ?? 0,
      trailingChild?.size.width ?? 0,
    );

    final mainWidth = centerChild.size.width;
    final maxWidth = leafWidth * 2 + mainWidth;

    const leadingX = 0.0;
    final centerX = leafWidth;
    final trailingX = centerX + mainWidth;

    // 根據 [crossAxisAlignment] 對齊方式取得真正的y
    double getPosY(RenderBox child) {
      switch (crossAxisAlignment) {
        case CrossAxisAlignment.start:
          return 0;
        case CrossAxisAlignment.end:
          return maxHeight - child.size.height;
        case CrossAxisAlignment.center:
        case CrossAxisAlignment.stretch:
        case CrossAxisAlignment.baseline:
          return (maxHeight / 2) - (child.size.height / 2);
      }
    }

    if (leadingChild != null) {
      (leadingChild.parentData as _ForceCenterParentData).offset = Offset(
        leadingX,
        getPosY(leadingChild),
      );
    }

    (centerChild.parentData as _ForceCenterParentData).offset = Offset(
      centerX,
      getPosY(centerChild),
    );

    if (trailingChild != null) {
      (trailingChild.parentData as _ForceCenterParentData).offset = Offset(
        trailingX,
        getPosY(trailingChild),
      );
    }

    size = constraints.constrain(Size(maxWidth, maxHeight));
  }

  /// 垂直佈局
  void _verticalPerformLayout() {
    RenderBox? leadingChild, centerChild, trailingChild;

    if (childCount == 1) {
      // 只有置中
      centerChild = firstChild!;
    } else if (childCount == 2) {
      // 檢查有開頭還是結尾
      if (leading != null) {
        // 有開頭
        leadingChild = firstChild!;
        centerChild = lastChild!;
      } else {
        // 有結尾
        centerChild = firstChild!;
        trailingChild = lastChild!;
      }
    } else {
      // 三個都有
      leadingChild = firstChild!;
      centerChild = childAfter(leadingChild) as RenderBox;
      trailingChild = lastChild!;
    }

    if (leadingChild != null || trailingChild != null) {
      // 有雙邊, 需要針對空間區域做分配

      // 依照優先序
      switch (spaceUsedPriority) {
        case SpaceUsedPriority.centerFirst:
          // 先將所有空間開放給置中元件
          // 中間佈局
          centerChild.layout(constraints.loosen(), parentUsesSize: true);

          // 再將剩餘的空間分配給兩端
          final remainingHeight =
              constraints.maxHeight - centerChild.size.height;

          // 兩端約束
          final leafConstraints = constraints
              .copyWith(
                maxHeight: remainingHeight / 2,
              )
              .loosen();

          leadingChild?.layout(leafConstraints, parentUsesSize: true);
          trailingChild?.layout(leafConstraints, parentUsesSize: true);

          break;
        case SpaceUsedPriority.bothEndsFirst:
          // 先將空間平均配給兩端, 以最長的為主
          final leafConstraints = constraints
              .copyWith(
                maxHeight: constraints.maxHeight / 2,
              )
              .loosen();

          // 兩端佈局
          leadingChild?.layout(leafConstraints, parentUsesSize: true);
          trailingChild?.layout(leafConstraints, parentUsesSize: true);

          final maxLeafHeight = max(
            leadingChild?.size.height ?? 0,
            trailingChild?.size.height ?? 0,
          );

          // 剩餘空間寬度
          final remainingHeight = constraints.maxHeight - (maxLeafHeight * 2);

          // 中間約束
          final mainConstraints = constraints
              .copyWith(
                maxHeight: remainingHeight,
              )
              .loosen();

          centerChild.layout(mainConstraints, parentUsesSize: true);

          break;
      }
    } else {
      // 只有置中元件, 直接測量
      centerChild.layout(constraints.loosen(), parentUsesSize: true);
    }

    final maxWidth = [
      leadingChild?.size.width,
      centerChild.size.width,
      trailingChild?.size.width,
    ].whereNotNull().reduce(max);

    final leafHeight = max(
      leadingChild?.size.height ?? 0,
      trailingChild?.size.height ?? 0,
    );

    final mainHeight = centerChild.size.height;
    final maxHeight = leafHeight * 2 + mainHeight;

    const leadingY = 0.0;
    final centerY = leafHeight;
    final trailingY = centerY + mainHeight;

    // 根據 [crossAxisAlignment] 對齊方式取得真正的y
    double getPosX(RenderBox child) {
      switch (crossAxisAlignment) {
        case CrossAxisAlignment.start:
          return 0;
        case CrossAxisAlignment.end:
          return maxWidth - child.size.width;
        case CrossAxisAlignment.center:
        case CrossAxisAlignment.stretch:
        case CrossAxisAlignment.baseline:
          return (maxWidth / 2) - (child.size.width / 2);
      }
    }

    if (leadingChild != null) {
      (leadingChild.parentData as _ForceCenterParentData).offset = Offset(
        getPosX(leadingChild),
        leadingY,
      );
    }

    (centerChild.parentData as _ForceCenterParentData).offset = Offset(
      getPosX(centerChild),
      centerY,
    );

    if (trailingChild != null) {
      (trailingChild.parentData as _ForceCenterParentData).offset = Offset(
        getPosX(trailingChild),
        trailingY,
      );
    }

    size = constraints.constrain(Size(maxWidth, maxHeight));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }
}
