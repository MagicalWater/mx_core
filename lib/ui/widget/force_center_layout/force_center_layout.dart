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

  /// 三個元件在允許空間內的對齊
  /// 當方向為橫向時, y軸的位置無效(設定y軸位置使用[crossAxisAlignment])
  /// 當方向為縱向時, x軸的位置無效(設定x軸位置使用[crossAxisAlignment])
  final Alignment leadingAlignment;
  final Alignment centerAlignment;
  final Alignment trailingAlignment;

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
    this.leadingAlignment = Alignment.topLeft,
    this.centerAlignment = Alignment.center,
    this.trailingAlignment = Alignment.bottomRight,
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
      leadingAlignment: leadingAlignment,
      centerAlignment: centerAlignment,
      trailingAlignment: trailingAlignment,
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
      ..crossAxisAlignment = crossAxisAlignment
      ..leadingAlignment = leadingAlignment
      ..centerAlignment = centerAlignment
      ..trailingAlignment = trailingAlignment;
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

  /// 三個元件在允許空間內的對齊
  Alignment leadingAlignment;
  Alignment centerAlignment;
  Alignment trailingAlignment;

  ForceCenterBox({
    this.leading,
    required this.center,
    this.trailing,
    required this.spaceUsedPriority,
    required this.direction,
    required this.crossAxisAlignment,
    this.leadingAlignment = Alignment.topLeft,
    this.centerAlignment = Alignment.center,
    this.trailingAlignment = Alignment.bottomRight,
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
          final remainingWidth = max(
            constraints.maxWidth - centerChild.size.width,
            0.0,
          );

          // 兩端約束
          final leafConstraints = constraints.loosen().copyWith(
            maxWidth: remainingWidth / 2,
          );

          leadingChild?.layout(leafConstraints, parentUsesSize: true);
          trailingChild?.layout(leafConstraints, parentUsesSize: true);

          break;
        case SpaceUsedPriority.bothEndsFirst:
        // 先將空間平均配給兩端, 以最長的為主
          final leafConstraints = constraints.loosen().copyWith(
            maxWidth: constraints.maxWidth / 2,
          );

          // 兩端佈局
          leadingChild?.layout(leafConstraints, parentUsesSize: true);
          trailingChild?.layout(leafConstraints, parentUsesSize: true);

          final maxLeafWidth = max(
            leadingChild?.size.width ?? 0,
            trailingChild?.size.width ?? 0,
          );

          // 剩餘空間寬度
          final remainingWidth = max(
            constraints.maxWidth - (maxLeafWidth * 2),
            0.0,
          );

          // 中間約束
          final mainConstraints = constraints.loosen().copyWith(
            maxWidth: remainingWidth,
          );

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

    double getPosX(Rect rect, RenderBox child, Alignment alignment) {
      // 先取得剩餘可活動的x軸空間
      final remainingWidth = rect.width - child.size.width;
      final remainingRect = Rect.fromLTWH(
        rect.left,
        rect.top,
        remainingWidth,
        rect.height,
      );
      return alignment.withinRect(remainingRect).dx;
    }

    if (leadingChild != null) {
      final rect = Rect.fromLTWH(0.0, 0.0, leafWidth, maxHeight);
      final leadingX = getPosX(rect, leadingChild, leadingAlignment);
      (leadingChild.parentData as _ForceCenterParentData).offset = Offset(
        leadingX,
        getPosY(leadingChild),
      );
    }

    final centerRect = Rect.fromLTWH(leafWidth, 0.0, mainWidth, maxHeight);
    final centerX = getPosX(centerRect, centerChild, centerAlignment);
    (centerChild.parentData as _ForceCenterParentData).offset = Offset(
      centerX,
      getPosY(centerChild),
    );

    if (trailingChild != null) {
      final rect =
      Rect.fromLTWH(leafWidth + mainWidth, 0.0, leafWidth, maxHeight);
      final trailingX = getPosX(rect, trailingChild, trailingAlignment);
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
          final remainingHeight = max(
            constraints.maxHeight - centerChild.size.height,
            0.0,
          );

          // 兩端約束
          final leafConstraints = constraints.loosen().copyWith(
            maxHeight: remainingHeight / 2,
          );

          leadingChild?.layout(leafConstraints, parentUsesSize: true);
          trailingChild?.layout(leafConstraints, parentUsesSize: true);

          break;
        case SpaceUsedPriority.bothEndsFirst:
        // 先將空間平均配給兩端, 以最長的為主
          final leafConstraints = constraints.loosen().copyWith(
            maxHeight: constraints.maxHeight / 2,
          );

          // 兩端佈局
          leadingChild?.layout(leafConstraints, parentUsesSize: true);
          trailingChild?.layout(leafConstraints, parentUsesSize: true);

          final maxLeafHeight = max(
            leadingChild?.size.height ?? 0,
            trailingChild?.size.height ?? 0,
          );

          // 剩餘空間寬度
          final remainingHeight = max(
            constraints.maxHeight - (maxLeafHeight * 2),
            0.0,
          );

          // 中間約束
          final mainConstraints = constraints.loosen().copyWith(
            maxHeight: remainingHeight,
          );

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

    double getPosY(Rect rect, RenderBox child, Alignment alignment) {
      // 先取得剩餘可活動的y軸空間
      final remainingHeight = rect.height - child.size.height;
      final remainingRect = Rect.fromLTWH(
        rect.left,
        rect.top,
        rect.width,
        remainingHeight,
      );
      return alignment.withinRect(remainingRect).dy;
    }

    if (leadingChild != null) {
      final rect = Rect.fromLTWH(0.0, 0.0, maxWidth, leafHeight);
      final leadingY = getPosY(rect, leadingChild, leadingAlignment);
      (leadingChild.parentData as _ForceCenterParentData).offset = Offset(
        getPosX(leadingChild),
        leadingY,
      );
    }

    final centerRect = Rect.fromLTWH(0.0, leafHeight, maxWidth, mainHeight);
    final centerY = getPosY(centerRect, centerChild, centerAlignment);
    (centerChild.parentData as _ForceCenterParentData).offset = Offset(
      getPosX(centerChild),
      centerY,
    );

    if (trailingChild != null) {
      final rect =
      Rect.fromLTWH(0.0, leafHeight + mainHeight, maxWidth, leafHeight);
      final trailingY = getPosY(rect, trailingChild, trailingAlignment);
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
