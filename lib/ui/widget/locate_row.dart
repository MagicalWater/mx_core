import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class LocateRow extends Flex {
  /// 孩子的位置有所變更時呼叫
  final void Function(List<Rect> locates, Size total) onLocateChanged;

  LocateRow({
    Key key,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    TextDirection textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    TextBaseline textBaseline,
    List<Widget> children = const <Widget>[],
    this.onLocateChanged,
  }) : super(
          children: children,
          key: key,
          direction: Axis.horizontal,
          mainAxisAlignment: mainAxisAlignment,
          mainAxisSize: mainAxisSize,
          crossAxisAlignment: crossAxisAlignment,
          textDirection: textDirection,
          verticalDirection: verticalDirection,
          textBaseline: textBaseline,
        );

  @override
  RenderFlex createRenderObject(BuildContext context) {
    return _LocateRowState(
      direction: direction,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      textDirection: getEffectiveTextDirection(context),
      verticalDirection: verticalDirection,
      textBaseline: textBaseline,
    ).._onLocateChanged = onLocateChanged;
  }

  @override
  void updateRenderObject(BuildContext context, _LocateRowState renderObject) {
    renderObject._onLocateChanged = onLocateChanged;
    super.updateRenderObject(context, renderObject);
  }
}

class _LocateRowState extends RenderFlex {
  /// 孩子的位置有所變更時呼叫
  void Function(List<Rect> locates, Size total) _onLocateChanged;

  List<Rect> tempLocate = [];

  _LocateRowState({
    List<RenderBox> children,
    Axis direction = Axis.horizontal,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    TextDirection textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    TextBaseline textBaseline,
  }) : super(
          children: children,
          direction: direction,
          mainAxisSize: mainAxisSize,
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          textDirection: textDirection,
          verticalDirection: verticalDirection,
          textBaseline: textBaseline,
        );

  @override
  void performLayout() {
    super.performLayout();

    // 取得每個孩子的位置
    RenderBox child = firstChild;
    var childRect = <Rect>[];
    while (child != null) {
      final FlexParentData childParentData = child.parentData as FlexParentData;
      var rect = Rect.fromLTWH(
        childParentData.offset.dx,
        childParentData.offset.dy,
        child.size.width,
        child.size.height,
      );
      childRect.add(rect);
      child = childParentData.nextSibling;
    }

    if (_checkIsLocateChanged(childRect)) {
      tempLocate = childRect;
      _onLocateChanged?.call(childRect, size);
    }
  }

  /// 檢查孩子的位置/大小是否變更
  bool _checkIsLocateChanged(List<Rect> newLocate) {
    if (tempLocate.length != newLocate.length) {
      return true;
    } else {
      for (var i = 0; i < tempLocate.length; i++) {
        var oldChild = tempLocate[i];
        var newChild = newLocate[i];

        if (oldChild != newChild) {
          return true;
        }
      }

      return false;
    }
  }
}

class ChildLocate {
  Offset offset;
  Size size;
}
