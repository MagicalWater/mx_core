import 'package:flutter/material.dart';
import 'package:mx_core/util/screen_util.dart';

class PopupOption {
  double? left;
  double? top;
  double? right;
  double? bottom;
  double? width;
  double? height;
  Alignment alignment;

  /// 背景遮罩顏色
  Color? maskColor;

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

  late double _tempW, _tempH;

  /// 根據 [left], [right], [top], [bottom], [width], [height] 構建出在螢幕上的padding
  EdgeInsetsGeometry? getOverlayPadding(bool isChildSafeArea) {
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

    // 由於x範圍為-1~1, 因此固定+1, 將範圍定至 0~2, 再除以2即是比例
    var xPercent = (alignment.x + 1) / 2;
    var yPercent = (alignment.y + 1) / 2;

    var rectCenterX = remainRect.left + (remainRect.width * xPercent);
    var rectCenterY = remainRect.top + (remainRect.height * yPercent);

    double leftPos, topPos;

    if (xPercent == 0) {
      leftPos = remainRect.left;
    } else if (xPercent == 1) {
      leftPos = remainRect.right - _tempW;
    } else {
      leftPos = rectCenterX - (_tempW / 2);
    }

    if (yPercent == 0) {
      topPos = remainRect.top;
    } else if (yPercent == 1) {
      topPos = remainRect.bottom - _tempH;
    } else {
      topPos = rectCenterY - (_tempH / 2);
    }

    var confirmRect = _getRect(leftPos, topPos);

    var p = EdgeInsets.only(
      left: confirmRect.left,
      top: confirmRect.top,
      right: Screen.width - confirmRect.right,
      bottom: Screen.height - confirmRect.bottom,
    );

    // print('padding = $p');
    return p;
  }

  Rect _getRect(double l, double t) {
    return Rect.fromLTWH(l, t, _tempW, _tempH);
  }
}
