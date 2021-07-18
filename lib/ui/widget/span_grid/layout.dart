import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'constraints.dart';
import 'parent_data.dart';
import 'space/space.dart';
import 'span.dart';

//TODO: 尚未優化的地方 - 若子元件的 size 沒有變化, 則不需要二次layout, 目前因為方便, 全為二次

/// 新版空間切割佈局, 功能以及佈局近似於 [GridView]
/// 已解決舊版 [SpanGrid] 因使用 [Flow] 所出現的 約束以及最終大小確認無法同時間估算, 因此多次 setState 造成的性能消耗
/// 有顯著的複雜性以及效能上的改進
///
/// 與 [GridView] 相比, 以下為更進階的功能
/// 1. 依照 [direction] 方向可選擇佔用寬度/高度
/// 2. 藉由 [align] 決定子元件對齊方式
class SpanGrid extends MultiChildRenderObjectWidget {
  /// <p>空間切割數量</p>
  /// * [direction] 為 [Axis.horizontal] - 切割高度
  /// * [direction] 為 [Axis.vertical] - 切割寬度
  final int segmentCount;

  /// 排列方向
  final Axis direction;

  /// 對齊方式
  final AlignType align;

  /// 直向間隙
  final double verticalSpace;

  /// 橫向間隙
  final double horizontalSpace;

  /// 元件是否只佔用子元件所需的size
  /// true - 只佔用子元件所需的size
  /// false - 張到最開
  final bool shrinkWrap;

  SpanGrid({
    Key? key,
    this.segmentCount = 1,
    this.direction = Axis.vertical,
    this.align = AlignType.max,
    this.verticalSpace = 0,
    this.horizontalSpace = 0,
    this.shrinkWrap = true,
    List<Widget> children = const <Widget>[],
  }) : super(
            key: key,
            children: children.map((e) {
              return e is Span
                  ? e
                  : Span(
                      child: e,
                    );
            }).toList());

  @override
  RenderObject createRenderObject(BuildContext context) {
    return SplitBox(
      segmentCount: segmentCount,
      direction: direction,
      align: align,
      verticalSpace: verticalSpace,
      horizontalSpace: horizontalSpace,
      shrinkWrap: shrinkWrap,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as SplitBox)
      ..segmentCount = segmentCount
      ..direction = direction
      ..verticalSpace = verticalSpace
      ..horizontalSpace = horizontalSpace
      ..shrinkWrap = shrinkWrap;
  }
}

class SplitBox extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, AlignGridParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, AlignGridParentData> {
  int segmentCount;
  Axis direction;
  AlignType align;
  double verticalSpace;
  double horizontalSpace;
  bool shrinkWrap;

  late BoxConstraints _containerConstraint;
  late BoxConstraints _childConstraint;

  SplitBox({
    required this.segmentCount,
    required this.direction,
    required this.align,
    required this.verticalSpace,
    required this.horizontalSpace,
    required this.shrinkWrap,
  }) : super();

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! AlignGridParentData) {
      child.parentData = AlignGridParentData();
    }
  }

  @override
  bool hitTestSelf(Offset position) {
    return true;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void performLayout() {
    // 依照方向同步相關約束
    _syncConstraint();

//    print('同步寬高約束');
//    print('原始: $constraints');
//    print('容器: $_containerConstraint');
//    print('物件: $_childConstraint');

    // 空間計算類
    var spaceCompute = SpaceCompute(
      segmentCount: segmentCount,
      direction: direction,
      segmentWidth: _childConstraint.maxWidth,
      segmentHeight: _childConstraint.maxHeight,
      verticalSpace: verticalSpace,
      horizontalSpace: horizontalSpace,
    );

    // 依照對齊方式以及方向
    // 調整每個子元件佔用的空間資訊
    List<AlignChildInfo> childInfo = _adjustmentChildInfo();

    // 將所有的 child size 丟入 SpaceCompute 計算出偏移位置
    var childPos = spaceCompute.compute(childInfo);

    // 設置每個子元件的確切偏移位置
    _settingChildPosition(childPos);

    var lastShrinkWrap = shrinkWrap;
    if (constraints.maxWidth.isInfinite || constraints.maxHeight.isInfinite) {
      // 約束為無限空間, 因此 lastShrinkWrap 必須為 true
      lastShrinkWrap = true;
    }

    // 依照 shrinkWrap 決定元件最終大小
    if (lastShrinkWrap) {
      // 只佔用元件佔用的 size

      // 依照每個子元件的空間取得佔用空間大小
      var placeSize = _getPlaceSize(childPos);

      // 設置所有元件佔用的大小
      switch (direction) {
        case Axis.horizontal:
          size = Size(placeSize.width, _containerConstraint.maxHeight);
//          print('元件佔用 size: $size');
          break;
        case Axis.vertical:
          size = Size(_containerConstraint.maxWidth, placeSize.height);
//          print('元件佔用 size: $size');
          break;
      }
    } else {
      // 張到最開
      size = _containerConstraint.biggest;
    }
  }

  /// 從所有的子元件佔用空間計算出所佔用size
  Size _getPlaceSize(List<SpaceResult> spaces) {
    double maxWidth = 0;
    double maxHeight = 0;
    spaces.forEach((e) {
      maxWidth = max(maxWidth, e.offset.dx + e.size.width);
      maxHeight = max(maxHeight, e.offset.dy + e.size.height);
    });
    return Size(maxWidth, maxHeight);
  }

  /// 配置所有 child 的位置
  void _settingChildPosition(List<SpaceResult> spaces) {
    var index = 0;
    var child = firstChild;
    while (child != null) {
      var childData = child.parentData as AlignGridParentData;
      childData.offset = spaces[index].offset;
      child = childData.nextSibling;
      index++;
    }
  }

  /// 依照對齊類型以及方向重新調整子元件的size資訊
  List<AlignChildInfo> _adjustmentChildInfo() {
    List<AlignChildInfo> adjustmentInfo;
    switch (align) {
      case AlignType.free:
        // 自由擴展, 瀑布流

        adjustmentInfo = _getAllChildInfo(
          childConstraint: _childConstraint.toAlignExpanded(true),
          ignoreFill: false,
          fullSpan: true,
        );

        break;
      case AlignType.max:
        // 取得所有子元件的真實size
        // 忽略 fill 屬性的子原件
        adjustmentInfo = _getAllChildInfo(
          childConstraint: _childConstraint.toAlignExpanded(false),
          ignoreFill: true,
          fullSpan: false,
        );

//        print('子元件數量: ${adjustmentInfo.length}');
//
//        adjustmentInfo.forEach((e) {
//          print('子元件需求: $e');
//        });

        // 對齊最大的size, 因此需要再次確認layout
        Size? maxSize;

        // 若沒有任何的 childInfo
        // 即是子元件全都為 fill 屬性
        if (adjustmentInfo.isNotEmpty) {
          adjustmentInfo.forEach((e) {
            maxSize ??= e.size;
            switch (direction) {
              case Axis.horizontal:
                maxSize = Size(
                  max(maxSize!.width, e.size.width),
                  _childConstraint.maxHeight,
                );
                break;
              case Axis.vertical:
                maxSize = Size(
                  _childConstraint.maxWidth,
                  max(maxSize!.height, e.size.height),
                );
                break;
            }
          });
          adjustmentInfo = _getAllChildInfo(
            childConstraint: BoxConstraints(
              minWidth: _childConstraint.minWidth,
              maxWidth: maxSize!.width,
              minHeight: _childConstraint.minHeight,
              maxHeight: maxSize!.height,
            ).toAlignExpanded(true),
            ignoreFill: false,
            fullSpan: false,
          );
        } else {
          adjustmentInfo = _getAllChildInfo(
            childConstraint: _childConstraint.toAlignExpanded(true),
            ignoreFill: false,
            fullSpan: true,
          );
        }
        break;
    }
    return adjustmentInfo;
  }

  /// 同步約束
  void _syncConstraint() {
    switch (direction) {
      case Axis.horizontal:
        // 如果高度無限, 則以第一個 child 為主
        if (constraints.maxHeight.isInfinite && firstChild != null) {
          firstChild!.layout(
            constraints.toAlignExpanded(false),
            parentUsesSize: true,
          );
          _childConstraint = constraints.copyWith(
            minHeight: constraints.minHeight > firstChild!.size.height
                ? firstChild!.size.height
                : null,
            maxHeight: firstChild!.size.height,
          );
          var maxHeight = (_childConstraint.maxHeight * segmentCount) +
              (segmentCount - 1) * verticalSpace;

          _containerConstraint = _childConstraint.copyWith(
            minHeight:
                _childConstraint.minHeight > maxHeight ? maxHeight : null,
            maxHeight: maxHeight,
          );
        } else {
          _containerConstraint = constraints;

          var maxHeight = (_containerConstraint.maxHeight -
                  (segmentCount - 1) * verticalSpace) /
              segmentCount;
          _childConstraint = constraints.copyWith(
            minHeight: constraints.minHeight > maxHeight ? maxHeight : null,
            maxHeight: maxHeight,
          );
        }
        break;
      case Axis.vertical:
        // 如果寬度無限, 則以第一個 child 為主
        if (constraints.maxWidth.isInfinite && firstChild != null) {
          firstChild!.layout(
            constraints.toAlignExpanded(false),
            parentUsesSize: true,
          );

          _childConstraint = constraints.copyWith(
            minWidth: constraints.minWidth > firstChild!.size.width
                ? firstChild!.size.width
                : null,
            maxWidth: firstChild!.size.width,
          );

          var maxWidth = (_childConstraint.maxWidth * segmentCount) +
              (segmentCount - 1) * horizontalSpace;

          _containerConstraint = _childConstraint.copyWith(
            minWidth: _childConstraint.minWidth > maxWidth ? maxWidth : null,
            maxWidth: maxWidth,
          );
        } else {
//          print('寬度: $constraints');
          _containerConstraint = constraints;

          var maxWidth = (_containerConstraint.maxWidth -
                  (segmentCount - 1) * horizontalSpace) /
              segmentCount;

          _childConstraint = constraints.copyWith(
            minWidth: constraints.minWidth > maxWidth ? maxWidth : null,
            maxWidth: maxWidth,
          );
        }
        break;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  /// 取得所有子元件的 size
  /// [ignoreFill] - 忽略含有 fill 的 parentData
  /// [fullSpan] - 是否每個 fill 的子元件都滿 span
  List<AlignChildInfo> _getAllChildInfo({
    required AlignExpandedConstraints childConstraint,
    required bool ignoreFill,
    required bool fullSpan,
  }) {
    var allChildInfo = <AlignChildInfo>[];
    var child = firstChild;
    while (child != null) {
      var childData = child.parentData as AlignGridParentData;
      var isFill = childData.isFill ?? false;
      if (ignoreFill && isFill) {
        child = childData.nextSibling;
        continue;
      }
      var placeSpan = childData.span ?? 1;
      if (isFill && fullSpan) {
        placeSpan = segmentCount;
      }

      switch (direction) {
        case Axis.horizontal:
          var maxHeight = childConstraint.maxHeight * placeSpan +
              verticalSpace * (placeSpan - 1);
          child.layout(
            childConstraint.copyWith(maxHeight: maxHeight),
            parentUsesSize: true,
          );
          break;
        case Axis.vertical:
          var maxWidth = childConstraint.maxWidth * placeSpan +
              horizontalSpace * (placeSpan - 1);
//          print('子元件: ${child.runtimeType.toString()}');
//          if (child.runtimeType.toString() == 'RenderFlex') {
//            print('孩子數量: ${(child as RenderFlex).childCount}, 約束: ${childConstraint.copyWith(maxWidth: maxWidth)}');
//          }

//          if (childConstraint.enableExpanded) {
//            _modifyAllChildFlex();
//          }

          child.layout(
            childConstraint.copyWith(maxWidth: maxWidth),
            parentUsesSize: true,
          );
          break;
      }
      var info = AlignChildInfo(size: child.size, span: placeSpan);
      allChildInfo.add(info);
      child = childData.nextSibling;
    }
    return allChildInfo;
  }

//  void _modifyAllChildFlex(ContainerRenderObjectMixin children) {
//    var findChild = children.firstChild;
//    while (findChild != null) {
////      findChild is
//      findChild = (findChild.parentData as ContainerParentDataMixin).nextSibling;
//    }
//    // 將所有子元件的 flex 改為 0
//    if (child is ContainerRenderObjectMixin) {
//      var firstChild = (child as ContainerRenderObjectMixin).
//  }
//    (child as RenderFlex).firstChild
//  }
}

enum AlignType {
  free,
  max,
}

class AlignChildInfo {
  Size size;
  int span;

  AlignChildInfo({required this.size, required this.span});

  @override
  String toString() {
    return 'size: $size, span: $span';
  }
}
