//import 'package:flutter/foundation.dart';
//import 'package:flutter/material.dart';
//import 'package:flutter/rendering.dart';
//import 'package:mx_core/mx_core.dart';
//
//import 'constraints.dart';
//import 'span.dart';
//
///// 此元件已棄用, 無法達到目的, 因為無法介入 [Column] 以及 [Row] 對 layout 的判斷
///// 改用 [SpanColumn] 以及 [SpanRow]
//class SpanExpanded extends ParentDataWidget<Flex> {
//  final int flex;
//
//  SpanExpanded({
//    this.flex,
//    Widget child,
//  }) : super(child: _SpanExpanded(child: child));
//
//  @override
//  void applyParentData(RenderObject renderObject) {
//    assert(renderObject.parentData is FlexParentData);
//    final FlexParentData parentData = renderObject.parentData;
//    bool needsLayout = false;
//
//    if (parentData.flex != flex) {
//      parentData.flex = flex;
//      needsLayout = true;
//    }
//
//    if (needsLayout) {
//      final AbstractNode targetParent = renderObject.parent;
//      if (targetParent is RenderObject) targetParent.markNeedsLayout();
//    }
//  }
//}
//
//class _SpanExpanded extends SingleChildRenderObjectWidget {
//  _SpanExpanded({Widget child}) : super(child: child);
//
//  @override
//  RenderObject createRenderObject(BuildContext context) {
//    return _SpansRenderBox();
//  }
//}
//
//class _SpansRenderBox extends RenderBox
//    with RenderObjectWithChildMixin<RenderBox> {
//  @override
//  void layout(Constraints constraints, {bool parentUsesSize = false}) {
//    // 遍歷父親節點, 直到尋找到 [_ExpandedRenderBox]
//    // 遍可以從此類取得當前的縮放狀態
//    // 從此節點取得縮放狀態, 修改到當前對應的 constraint
//    // 便可以解決因為約束相同造成無法重新 layout 問題
//    ExpandedRenderBox spanBox = findParentRenderObject();
//
//    var expandConstraint = spanBox.constraints as AlignExpandedConstraints;
//    var oriConstraints = (constraints as BoxConstraints);
//
//    var usedConstraint = expandConstraint.copyWith(
//      minWidth: oriConstraints.minWidth,
//      maxWidth: oriConstraints.maxWidth,
//      minHeight: oriConstraints.minHeight,
//      maxHeight: oriConstraints.maxHeight,
//    );
////    print('勾住原始約束: $constraints');
//
//    super.layout(usedConstraint, parentUsesSize: parentUsesSize);
//  }
//
//  T findParentRenderObject<T extends RenderBox>() {
//    AbstractNode parentBox = parent;
//    while (parentBox is! T && parentBox != null) {
//      parentBox = parentBox.parent;
//    }
//    if (parentBox != null) {
//      return parentBox;
//    } else {
//      throw '無法尋找到類型為 ${T.runtimeType.toString()} 的父親渲染類';
//    }
//  }
//
//  @override
//  void performLayout() {
//    // 網上找到
//    print('約束是 align 嗎: ${constraints is AlignExpandedConstraints}');
//    bool enableExpanded =
//        (constraints as AlignExpandedConstraints).enableExpanded;
//    if (enableExpanded) {
//      // 展到最開
//      var expandConstraint = BoxConstraints(
//        minWidth: constraints.maxWidth.isInfinite
//            ? constraints.minWidth
//            : constraints.maxWidth,
//        maxWidth: constraints.maxWidth,
//        minHeight: constraints.maxHeight.isInfinite
//            ? constraints.minHeight
//            : constraints.maxHeight,
//        maxHeight: constraints.maxHeight,
//      );
//      child.layout(expandConstraint, parentUsesSize: true);
//      size = child.size;
//      print('展開確認: $expandConstraint, size = $size, ori = $constraints');
//    } else {
//      // 縮到最小
//      var minConstraints = BoxConstraints(
//        minWidth: constraints.minWidth,
//        maxWidth: constraints.maxWidth,
//        minHeight: constraints.minHeight,
//        maxHeight: 1,
//      );
//      child.layout(minConstraints, parentUsesSize: true);
//      size = child.size;
//      print('縮小確認: $minConstraints, isTight: ${minConstraints.isTight}');
//    }
//  }
//}
