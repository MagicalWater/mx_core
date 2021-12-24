import 'dart:math';

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
  /// 當空間不足以讓三個元件同時平鋪時
  /// 需要有優先順序, 默認為中間優先
  final SpaceUsedPriority spaceUsedPriority;

  /// 中間的size約束
  final BoxConstraints? centerConstraint;

  /// 兩端的size約束
  final BoxConstraints? bothEndsConstraint;

  /// [center] 元件兩邊的間隙
  final double gapSpace;

  /// 主方向是否壓縮空間
  final bool mainShrinkWrap;

  /// 次方向是否壓縮空間
  final bool crossShrinkWrap;

  /// 方向
  final Axis direction;

  /// [direction]為[Axis.horizontal]時, 代表是針對垂直方向的對齊
  /// [direction]為[Axis.vertical]時, 代表是針對水平方向的對齊
  final CrossAxisAlignment crossAxisAlignment;

  /// [gapBuilder] - 間隙構建
  ForceCenterLayout({
    Key? key,
    required Widget center,
    Widget leading = const SizedBox(),
    Widget trailing = const SizedBox(),
    this.spaceUsedPriority = SpaceUsedPriority.centerFirst,
    this.centerConstraint,
    this.bothEndsConstraint,
    this.gapSpace = 0,
    this.mainShrinkWrap = true,
    this.crossShrinkWrap = true,
    this.direction = Axis.horizontal,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  }) : super(
          key: key,
          children: [leading, center, trailing],
        );

  @override
  RenderObject createRenderObject(BuildContext context) {
    return ForceCenterBox(
      spaceUsedPriority: spaceUsedPriority,
      centerConstraint: centerConstraint,
      bothEndsConstraint: bothEndsConstraint,
      gapSpace: gapSpace,
      mainShrinkWrap: mainShrinkWrap,
      crossShrinkWrap: crossShrinkWrap,
      direction: direction,
      crossAxisAlignment: crossAxisAlignment,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderObject renderObject) {
    (renderObject as ForceCenterBox)
      ..spaceUsedPriority = spaceUsedPriority
      ..centerConstraint = centerConstraint
      ..bothEndsConstraint = bothEndsConstraint
      ..gapSpace = gapSpace
      ..mainShrinkWrap = mainShrinkWrap
      ..direction = direction
      ..crossAxisAlignment = crossAxisAlignment;
  }
}

class _ForceCenterParentData extends ContainerBoxParentData<RenderBox> {}

class ForceCenterBox extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _ForceCenterParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _ForceCenterParentData> {
  /// 當空間不足以讓三個元件同時平鋪時
  /// 需要有優先順序, 默認為中間優先
  SpaceUsedPriority spaceUsedPriority;

  /// 中間的size約束
  BoxConstraints? centerConstraint;

  /// 兩端的size約束
  BoxConstraints? bothEndsConstraint;

  /// 間隙空間
  double gapSpace;

  /// 主方向是否壓縮空間
  bool mainShrinkWrap;

  /// 次方向是否壓縮空間
  bool crossShrinkWrap;

  /// 方向
  Axis direction;

  /// [direction]為[Axis.horizontal]時, 代表是針對垂直方向的對齊
  /// [direction]為[Axis.vertical]時, 代表是針對水平方向的對齊
  CrossAxisAlignment crossAxisAlignment;

  ForceCenterBox({
    required this.spaceUsedPriority,
    this.centerConstraint,
    this.bothEndsConstraint,
    this.gapSpace = 0,
    required this.mainShrinkWrap,
    required this.crossShrinkWrap,
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
  void performLayout() {
    // _horizontalPerformLayout 與 _verticalPerformLayout 兩個確認佈局的方法
    // 內容幾乎一模一樣, 只差在一個垂直為主, 一個水平為主
    // 後續應有優化空間, 在此先留下應優化的註解
    switch (direction) {
      case Axis.horizontal:
        _horizontalPerformLayout();
        break;
      case Axis.vertical:
        _verticalPerformLayout();
        break;
    }
  }

  /// 垂直佈局
  void _verticalPerformLayout() {
    final leadingChild = firstChild!;
    final centerChild = childAfter(leadingChild) as RenderBox;
    final trailingChild = lastChild!;

    // 間隙總寬度
    final totalGapSpace = gapSpace * 2;

    // 兩端的約束
    var bothEndsConstraint = (this.bothEndsConstraint ?? constraints).copyWith(
      minHeight: 0,
      maxHeight: (constraints.maxHeight / 2) - gapSpace,
    );

    // 中間的約束
    var centerConstraint = (this.centerConstraint ?? constraints).copyWith(
      minHeight: 0,
      maxHeight: constraints.maxHeight - totalGapSpace,
    );

    // 優先平鋪測量, 檢查高度是否足夠
    leadingChild.layout(bothEndsConstraint, parentUsesSize: true);
    centerChild.layout(centerConstraint, parentUsesSize: true);
    trailingChild.layout(bothEndsConstraint, parentUsesSize: true);

    // 上下兩端取最大的
    var bothEndHeight =
        max(leadingChild.size.height, trailingChild.size.height);

    // 中間寬度
    var centerHeight = centerChild.size.height;

    // child總高度
    final totalChildSpace = (bothEndHeight * 2) + centerHeight;

    // 總元件高度
    final totalSpace = totalGapSpace + totalChildSpace;

    // print('總高度: $totalSpace');
    if (totalSpace > constraints.maxHeight) {
      // print('高度超過約束: ${constraints.maxHeight}');

      // 檢查空間使用優先順序
      switch (spaceUsedPriority) {
        case SpaceUsedPriority.centerFirst:
          // 中間元件優先
          bothEndHeight =
              (constraints.maxHeight - totalGapSpace - centerHeight) / 2;
          final newBothEndsConstraint = bothEndsConstraint.copyWith(
            maxHeight: bothEndHeight,
          );
          final newCenterConstraint = centerConstraint.copyWith(
            maxHeight: bothEndHeight,
          );
          leadingChild.layout(newBothEndsConstraint, parentUsesSize: true);
          trailingChild.layout(newBothEndsConstraint, parentUsesSize: true);
          centerChild.layout(newCenterConstraint, parentUsesSize: true);

          break;
        case SpaceUsedPriority.bothEndsFirst:
          // 兩端優先
          centerHeight =
              constraints.maxHeight - totalGapSpace - (bothEndHeight * 2);
          final newBothEndsConstraint = bothEndsConstraint.copyWith(
            maxHeight: bothEndHeight,
          );
          final newCenterConstraint = centerConstraint.copyWith(
            maxHeight: centerHeight,
          );
          // print('中間最大高度更改為: $newCenterConstraint, $constraints');
          leadingChild.layout(newBothEndsConstraint, parentUsesSize: true);
          trailingChild.layout(newBothEndsConstraint, parentUsesSize: true);
          centerChild.layout(newCenterConstraint, parentUsesSize: true);
          break;
      }
    } else {
      // 高度可被容納, 不處理
      // print('高度可被空間容納');
    }

    double maxHeight;

    final maxWidth = [
      leadingChild.size.width,
      centerChild.size.width,
      trailingChild.size.width,
      if (!crossShrinkWrap && constraints.hasBoundedWidth) constraints.maxWidth,
    ].reduce(max);

    // 三個元件的 x, y
    double leadingPositionX, centerPositionX, trailingPositionX;
    double leadingPositionY, centerPositionY, trailingPositionY;

    if (mainShrinkWrap) {
      // 主方向壓縮空間
      maxHeight = bothEndHeight * 2 + gapSpace * 2 + centerHeight;
      leadingPositionY = 0;
      centerPositionY = bothEndHeight + gapSpace;
      trailingPositionY = maxHeight - bothEndHeight;
      print('${centerHeight}');
      print(
          '位置: $centerPositionY, ${centerPositionY + gapSpace + centerHeight}, 最終: $trailingPositionY');
    } else {
      // 主方向擴展空間至最大
      maxHeight = constraints.maxHeight;
      leadingPositionY = 0;
      centerPositionY =
          (constraints.maxHeight / 2) - (centerChild.size.height / 2);
      trailingPositionY = maxHeight - trailingChild.size.height;
    }

    // 根據 [crossAxisAlignment] 對齊方式取得真正的x
    double getPositionX(RenderBox child) {
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

    leadingPositionX = getPositionX(leadingChild);
    centerPositionX = getPositionX(centerChild);
    trailingPositionX = getPositionX(trailingChild);

    (leadingChild.parentData as _ForceCenterParentData).offset = Offset(
      leadingPositionX,
      leadingPositionY,
    );
    (centerChild.parentData as _ForceCenterParentData).offset = Offset(
      centerPositionX,
      centerPositionY,
    );
    (trailingChild.parentData as _ForceCenterParentData).offset = Offset(
      trailingPositionX,
      trailingPositionY,
    );

    size = constraints.constrain(Size(maxWidth, maxHeight));
  }

  /// 水平佈局
  void _horizontalPerformLayout() {
    final leadingChild = firstChild!;
    final centerChild = childAfter(leadingChild) as RenderBox;
    final trailingChild = lastChild!;

    // 間隙總寬度
    final totalGapSpace = gapSpace * 2;

    // 兩端的約束
    var bothEndsConstraint = (this.bothEndsConstraint ?? constraints).copyWith(
      maxWidth: (constraints.maxWidth / 2) - gapSpace,
    );

    // 中間的約束
    var centerConstraint = (this.centerConstraint ?? constraints).copyWith(
      maxWidth: constraints.maxWidth - totalGapSpace,
    );

    bothEndsConstraint = bothEndsConstraint.copyWith(
      minWidth: 0,
      maxWidth: (constraints.maxWidth / 2) -
          gapSpace -
          (centerConstraint.minWidth / 2),
    );

    centerConstraint = centerConstraint.copyWith(
      minWidth: 0,
      maxWidth: constraints.maxWidth -
          totalGapSpace -
          (bothEndsConstraint.minWidth * 2),
    );

    // 優先平鋪測量, 檢查寬度是否足夠
    leadingChild.layout(bothEndsConstraint, parentUsesSize: true);
    centerChild.layout(centerConstraint, parentUsesSize: true);
    trailingChild.layout(bothEndsConstraint, parentUsesSize: true);

    // 左右兩端取最大的
    var bothEndWidth = max(leadingChild.size.width, trailingChild.size.width);

    // 中間寬度
    var centerWidth = centerChild.size.width;

    // child總寬度
    final totalChildSpace = (bothEndWidth * 2) + centerWidth;

    // 總元件寬度
    final totalSpace = totalGapSpace + totalChildSpace;

    // print('總寬度: $totalSpace');
    if (totalSpace > constraints.maxWidth) {
      // print('寬度超過約束: ${constraints.maxWidth}');

      // 檢查空間使用優先順序
      switch (spaceUsedPriority) {
        case SpaceUsedPriority.centerFirst:
          // 中間元件優先
          bothEndWidth =
              (constraints.maxWidth - totalGapSpace - centerWidth) / 2;
          final newBothEndsConstraint = bothEndsConstraint.copyWith(
            maxWidth: bothEndWidth,
          );
          final newCenterConstraint = centerConstraint.copyWith(
            maxWidth: centerWidth,
          );
          leadingChild.layout(newBothEndsConstraint, parentUsesSize: true);
          trailingChild.layout(newBothEndsConstraint, parentUsesSize: true);
          centerChild.layout(newCenterConstraint, parentUsesSize: true);

          break;
        case SpaceUsedPriority.bothEndsFirst:
          // 兩端優先
          centerWidth =
              constraints.maxWidth - totalGapSpace - (bothEndWidth * 2);
          final newBothEndsConstraint = bothEndsConstraint.copyWith(
            maxWidth: bothEndWidth,
          );
          final newCenterConstraint = centerConstraint.copyWith(
            maxWidth: centerWidth,
          );
          print('中間最大寬度更改為: $newCenterConstraint, $constraints');
          leadingChild.layout(newBothEndsConstraint, parentUsesSize: true);
          trailingChild.layout(newBothEndsConstraint, parentUsesSize: true);
          centerChild.layout(newCenterConstraint, parentUsesSize: true);
          break;
      }
    } else {
      // 寬度可被容納, 不處理
      // print('寬度可被空間容納');
    }

    double maxWidth;

    final maxHeight = [
      leadingChild.size.height,
      centerChild.size.height,
      trailingChild.size.height,
      if (!crossShrinkWrap && constraints.hasBoundedHeight)
        constraints.maxHeight,
    ].reduce(max);

    // 三個元件的 x, y
    double leadingPositionX, centerPositionX, trailingPositionX;
    double leadingPositionY, centerPositionY, trailingPositionY;

    if (mainShrinkWrap) {
      // 主方向壓縮空間
      maxWidth = bothEndWidth * 2 + gapSpace * 2 + centerWidth;
      leadingPositionX = 0;
      centerPositionX = bothEndWidth + gapSpace;
      trailingPositionX = maxWidth - bothEndWidth;
    } else {
      // 主方向擴展空間至最大
      maxWidth = constraints.maxWidth;
      leadingPositionX = 0;
      centerPositionX =
          (constraints.maxWidth / 2) - (centerChild.size.width / 2);
      trailingPositionX = maxWidth - trailingChild.size.width;
    }

    // 根據 [crossAxisAlignment] 對齊方式取得真正的y
    double getPositionY(RenderBox child) {
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

    leadingPositionY = getPositionY(leadingChild);
    centerPositionY = getPositionY(centerChild);
    trailingPositionY = getPositionY(trailingChild);

    (leadingChild.parentData as _ForceCenterParentData).offset = Offset(
      leadingPositionX,
      leadingPositionY,
    );
    (centerChild.parentData as _ForceCenterParentData).offset = Offset(
      centerPositionX,
      centerPositionY,
    );
    (trailingChild.parentData as _ForceCenterParentData).offset = Offset(
      trailingPositionX,
      trailingPositionY,
    );

    size = constraints.constrain(Size(maxWidth, maxHeight));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }
}
