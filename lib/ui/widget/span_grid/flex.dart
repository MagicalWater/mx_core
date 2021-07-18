import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'constraints.dart';
import 'span.dart';

/// 在 SpanGrid 底下, 請以此替代 [Column]
class SpanColumn extends Column with _SpanFlexMixin {
  SpanColumn({
    Key? key,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    TextBaseline? textBaseline,
    List<Widget> children = const <Widget>[],
  }) : super(
          key: key,
          mainAxisAlignment: mainAxisAlignment,
          mainAxisSize: mainAxisSize,
          crossAxisAlignment: crossAxisAlignment,
          textDirection: textDirection,
          verticalDirection: verticalDirection,
          textBaseline: textBaseline,
          children: children,
        );
}

/// 在 SpanGrid 底下, 請以此替代 [Row]
class SpanRow extends Row with _SpanFlexMixin {
  SpanRow({
    Key? key,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    TextBaseline?
        textBaseline, // NO DEFAULT: we don't know what the text's baseline should be
    List<Widget> children = const <Widget>[],
  }) : super(
          key: key,
          mainAxisAlignment: mainAxisAlignment,
          mainAxisSize: mainAxisSize,
          crossAxisAlignment: crossAxisAlignment,
          textDirection: textDirection,
          verticalDirection: verticalDirection,
          textBaseline: textBaseline,
          children: children,
        );
}

mixin _SpanFlexMixin on Flex {
  @override
  RenderFlex createRenderObject(BuildContext context) {
    return SpanFlex(
      direction: direction,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      textDirection: getEffectiveTextDirection(context),
      verticalDirection: verticalDirection,
      textBaseline: textBaseline,
    );
  }
}

/// 在給定的約束上, 尋找祖先的 [AlignExpandedConstraints] 約束
/// 將其中的參數取出取代掉默認的約束
/// 並且在 performLayout 確認佈局時依照 [AlignExpandedConstraints.enableExpanded]
/// 決定是否將所有 [Expanded] 的 flex 設置為0
/// 或者是恢復 [Expanded] 的 flex 值
class SpanFlex extends RenderFlex {
  SpanFlex({
    List<RenderBox>? children,
    Axis direction = Axis.horizontal,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    TextBaseline? textBaseline,
    Clip clipBehavior = Clip.none,
  }) : super(
          children: children,
          direction: direction,
          mainAxisSize: mainAxisSize,
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          textDirection: textDirection,
          verticalDirection: verticalDirection,
          textBaseline: textBaseline,
          clipBehavior: clipBehavior,
        );

  Map<int, int> _oriFlex = {};

  @override
  void layout(Constraints constraints, {bool parentUsesSize = false}) {
    // 遍歷父親節點, 直到尋找到 [_ExpandedRenderBox]
    // 遍可以從此類取得當前的縮放狀態
    // 從此節點取得縮放狀態, 修改到當前對應的 constraint
    // 便可以解決因為約束相同造成無法重新 layout 問題
    ExpandedRenderBox spanBox = findParentRenderObject();

    var expandConstraint = spanBox.constraints as AlignExpandedConstraints;
    var oriConstraints = (constraints as BoxConstraints);

    var usedConstraint = expandConstraint.copyWith(
      minWidth: oriConstraints.minWidth,
      maxWidth: oriConstraints.maxWidth,
      minHeight: oriConstraints.minHeight,
      maxHeight: oriConstraints.maxHeight,
    );
//    print('勾住原始約束: $constraints');

    super.layout(usedConstraint, parentUsesSize: parentUsesSize);
  }

  T findParentRenderObject<T extends RenderBox>() {
    AbstractNode? parentBox = parent;
    while (parentBox != null && parentBox is! T) {
      parentBox = parentBox.parent!;
    }
    if (parentBox != null && parentBox is T) {
      return parentBox;
    } else {
      throw '無法尋找到類型為 ${T.runtimeType.toString()} 的父親渲染類';
    }
  }

  @override
  void performLayout() {
    // 假如當前的約束 expand 為 false 時, 強制將所有 child 的 flex 改為0
    if (!(constraints as AlignExpandedConstraints).enableExpanded) {
      _recoveryAllFlex();
      _modifyAllFlex(0);
    } else {
      // 正常擴展
      _recoveryAllFlex();
    }

    super.performLayout();
  }

  /// 取得所有的 flex 對應
  Map<int, int> _getAllFlex() {
    RenderBox? child = firstChild;
    var index = 0;
    var flexMap = <int, int>{};
    while (child != null) {
      final childParentData = child.parentData as FlexParentData;
      flexMap[index] = childParentData.flex!;
      index++;
      child = childParentData.nextSibling;
    }
    return flexMap;
  }

  /// 修改所有的 flex
  void _modifyAllFlex(int flex) {
    _oriFlex = _getAllFlex();
    RenderBox? child = firstChild;
    while (child != null) {
      final childParentData = child.parentData as FlexParentData;
      childParentData.flex = flex;
      child = childParentData.nextSibling;
    }
  }

  /// 恢復所有的 flex
  void _recoveryAllFlex() {
    if (_oriFlex.isEmpty) {
      return;
    }
    RenderBox? child = firstChild;
    var index = 0;
    while (child != null) {
      final childParentData = child.parentData as FlexParentData;
      childParentData.flex = _oriFlex[index];
      index++;
      child = childParentData.nextSibling;
    }
    _oriFlex.clear();
  }
}
