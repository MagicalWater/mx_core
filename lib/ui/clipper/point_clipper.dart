import 'package:flutter/material.dart';

/// 設置多個點的路徑剪裁
class PointClipper extends CustomClipper<Path> {
  final List<Size> points;

  /// [points] 是否為固定值
  /// 若不是, 則為百分比
  final bool fixed;

  const PointClipper({
    required this.points,
    this.fixed = false,
  });

  @override
  Path getClip(Size size) {
    var path = Path();
    var firstMove = true;
    for (var element in points) {
      var point = _absolutePoint(element, size);
      var x = point.width.toDouble();
      var y = point.height.toDouble();
      if (firstMove) {
        path.moveTo(x, y);
        firstMove = false;
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }

  Size _absolutePoint(Size current, Size size) {
    var x = current.width;
    var y = current.height;

    var maxW = size.width;
    var maxH = size.height;

    if (x <= 0) {
      x = 0;
    }
    if (y <= 0) {
      y = 0;
    }

    if (fixed) {
      if (x >= maxW) {
        x = maxW;
      }
      if (y >= maxH) {
        y = maxH;
      }
    } else {
      if (x >= 1) {
        x = maxW;
      } else {
        x = maxW * x;
      }

      if (y >= 1) {
        y = maxH;
      } else {
        y = maxH * y;
      }
    }

    return Size(x, y);
  }
}
