import 'package:flutter/material.dart';
import 'package:mx_core/util/screen_util.dart';

class PopupOption {
  double left;
  double top;
  double right;
  double bottom;
  double width;
  double height;
  Alignment alignment;

  /// 背景遮罩顏色
  Color maskColor;

  PopupOption({
    this.maskColor,
    this.left,
    this.top,
    this.right,
    this.bottom,
    this.width,
    this.height,
    this.alignment = Alignment.topLeft,
  });

  bool get isSpecialPos =>
      left != null ||
      top != null ||
      right != null ||
      bottom != null ||
      width != null ||
      height != null;

  double _tempW, _tempH;

  /// 根據 [left], [right], [top], [bottom], [width], [height] 構建出在螢幕上的padding
  EdgeInsetsGeometry getOverlayPadding(bool isChildSafeArea) {
    if (!isSpecialPos) return null;

//    print("取得 width/height 應該有的 padding~~~: $width,$height");

    double paddingLeft = left ?? 0;
    double paddingTop = top ?? 0;
    double paddingRight = right ?? 0;
    double paddingBottom = bottom ?? 0;

    var remainWidth = Screen.width - paddingLeft - paddingRight;
    double remainHeight;
    if (isChildSafeArea) {
      remainHeight = Screen.contentHeight - paddingTop - paddingBottom;
    } else {
      remainHeight = Screen.height - paddingTop - paddingBottom;
    }

    var remainRect = Rect.fromLTWH(
      paddingLeft,
      paddingTop,
      remainWidth,
      remainHeight,
    );

    _tempW = width ?? remainWidth;
    _tempH = height ?? remainHeight;

    Rect confirmRect;

    if (alignment == Alignment.topLeft) {
      // 對齊上左, 位置資訊不需改變
      confirmRect = _getRect(remainRect.left, remainRect.top);
    } else if (alignment == Alignment.topCenter) {
      // 對齊上中
      confirmRect = _getRect(
        remainRect.center.dx - (_tempW) / 2,
        remainRect.top,
      );
    } else if (alignment == Alignment.topRight) {
      // 對齊上右
      confirmRect = _getRect(
        remainRect.right - _tempW,
        remainRect.top,
      );
    } else if (alignment == Alignment.centerLeft) {
      // 對齊中左
      confirmRect = _getRect(
        remainRect.left,
        remainRect.center.dy - _tempH / 2,
      );
    } else if (alignment == Alignment.center) {
      // 對齊中
      confirmRect = _getRect(
        remainRect.center.dx - _tempW / 2,
        remainRect.center.dy - _tempH / 2,
      );
    } else if (alignment == Alignment.centerRight) {
      // 對齊中右
      confirmRect = _getRect(
        remainRect.right - _tempW,
        remainRect.center.dy - _tempH / 2,
      );
    } else if (alignment == Alignment.bottomLeft) {
      // 對齊下左
      confirmRect = _getRect(
        remainRect.left,
        remainRect.bottom - _tempH,
      );
    } else if (alignment == Alignment.bottomCenter) {
      // 對齊下中
      confirmRect = _getRect(
        remainRect.center.dx - _tempW / 2,
        remainRect.bottom - _tempH,
      );
    } else if (alignment == Alignment.bottomRight) {
      // 對齊下右
      confirmRect = _getRect(
        remainRect.right - _tempW,
        remainRect.bottom - _tempH,
      );
    }

    var p = EdgeInsets.only(
      left: confirmRect.left,
      top: confirmRect.top,
      right: Screen.width - confirmRect.right,
      bottom: Screen.height - confirmRect.bottom,
    );

    print('padding = $p');
    return p;
  }

  Rect _getRect(double l, double t) {
    return Rect.fromLTWH(l, t, _tempW, _tempH);
  }
}
