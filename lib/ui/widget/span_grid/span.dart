import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'constraints.dart';
import 'layout.dart';
import 'parent_data.dart';

class Span extends ParentDataWidget<SpanGrid> {
  /// 當true時, 代表此元件不參與size競爭, 而是跟隨著給定的 size
  final bool fill;

  /// 佔用寬度/高度
  final int span;

  Span({
    this.fill = false,
    this.span = 1,
    Widget child,
  }) : super(child: _Expanded(child: child));

  @override
  void applyParentData(RenderObject renderObject) {
    (renderObject.parentData as AlignGridParentData)
      ..fill = fill
      ..span = span;
  }
}

class _Expanded extends SingleChildRenderObjectWidget {
  _Expanded({Widget child}) : super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return ExpandedRenderBox();
  }
}

class ExpandedRenderBox extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {

  @override
  bool hitTestChildren(BoxHitTestResult result, { Offset position }) {
    if (child != null) {
      final BoxParentData childParentData = child.parentData;
      return result.addWithPaintOffset(
        offset: childParentData.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          assert(transformed == position - childParentData.offset);
          return child.hitTest(result, position: transformed);
        },
      );
    }
    return false;
  }

  @override
  void performLayout() {
    assert(constraints is AlignExpandedConstraints);

    var enableExpanded =
        (constraints as AlignExpandedConstraints).enableExpanded;

    if (enableExpanded) {
      // 佔滿整個 expand
      var expandConstraint = constraints;
//      print('擴展 from: $constraints, to: $expandConstraint');
      child.layout(expandConstraint, parentUsesSize: true);
      double maxWidth, maxHeight;
      if (constraints.maxWidth.isInfinite) {
        maxWidth = child.size.width;
      } else {
        maxWidth = constraints.maxWidth;
      }

      if (constraints.maxHeight.isInfinite) {
        maxHeight = child.size.height;
      } else {
        maxHeight = constraints.maxHeight;
      }

      size = Size(maxWidth, maxHeight);
//      print('expand確認 - 展開 size: $size, 給定約束: $expandConstraint, isTight: ${expandConstraint.isTight}');
    } else {
      // 不考慮 expand, 以原始 size 為主
//      print('縮起 from: $constraints');
      child.layout(constraints, parentUsesSize: true);
      size = child.size;
//      print('expand確認 - 縮起 size: $size, 給定約束: $constraints, isTight: ${constraints.isTight}');
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final childParentData = child.parentData as BoxParentData;
    context.paintChild(child, childParentData.offset + offset);
  }
}
