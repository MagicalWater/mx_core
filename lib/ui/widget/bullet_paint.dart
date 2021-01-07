import 'package:flutter/material.dart';

class BulletPaint extends StatelessWidget {
  final Color color;

  /// 開始展開半圓的位置
  final BulletPosition startPos;

  /// 結束展開半圓的位置
  final BulletPosition endPos;

  /// 半圓形方向
  final AxisDirection direction;

  BulletPaint({
    this.startPos = const BulletPosition(),
    this.endPos = const BulletPosition(isStartPoint: false),
    this.direction = AxisDirection.down,
    this.color = Colors.blueAccent,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BulletPainter(
        startPos: startPos,
        endPos: endPos,
        direction: direction,
        color: color,
      ),
    );
  }
}

/// 半圓形渲染
class _BulletPainter extends CustomPainter {
  final Color color;

  /// 開始展開半圓的位置
  final BulletPosition startPos;

  /// 結束展開半圓的位置
  final BulletPosition endPos;

  /// 半圓形方向
  final AxisDirection direction;

  /// 畫筆
  final Paint _paint = Paint();

  _BulletPainter({
    this.startPos,
    this.endPos,
    this.direction,
    this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var start = startPos.calculatePos(direction, size);
    var end = endPos.calculatePos(direction, size);

    Path path;

    switch (direction) {
      case AxisDirection.up:
        path = _paintUp(size, start, end);
        break;
      case AxisDirection.right:
        path = _paintRight(size, start, end);
        break;
      case AxisDirection.down:
        path = _paintDown(size, start, end);
        break;
      case AxisDirection.left:
        path = _paintLeft(size, start, end);
        break;
    }

    canvas.drawPath(path, _paint..color = color);
  }

  /// 繪製左方
  Path _paintLeft(Size size, double start, double end) {
    var p = Path();
    p.moveTo(size.width, 0);
    p.lineTo(size.width, size.height);
    p.lineTo(start, size.height);
    p.relativeQuadraticBezierTo(
      -(start - end) * 2,
      -size.height / 2,
      0,
      -size.height,
    );
    p.close();
    return p;
  }

  /// 繪製右方
  Path _paintRight(Size size, double start, double end) {
    var p = Path();
    p.moveTo(0, 0);
    p.lineTo(0, size.height);
    p.lineTo(start, size.height);
    p.relativeQuadraticBezierTo(
      (end - start) * 2,
      -size.height / 2,
      0,
      -size.height,
    );
    p.close();
    return p;
  }

  /// 繪製上方
  Path _paintUp(Size size, double start, double end) {
    var p = Path();
    p.moveTo(0, size.height);
    p.lineTo(size.width, size.height);
    p.lineTo(size.width, start);
    p.relativeQuadraticBezierTo(
      -size.width / 2,
      -(start - end) * 2,
      -size.width,
      0,
    );
    p.close();
    return p;
  }

  /// 繪製下方
  Path _paintDown(Size size, double start, double end) {
    var p = Path();
    p.moveTo(0, 0);
    p.lineTo(size.width, 0);
    p.lineTo(size.width, start);
    p.relativeQuadraticBezierTo(
      -size.width / 2,
      (end - start) * 2,
      -size.width,
      0,
    );
    p.lineTo(0, start);
    p.close();
    return p;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class BulletPosition {
  /// 位置
  final double pos;

  /// 位置是否為比例
  final bool isRate;

  /// 計算基準點是否為開始點
  final bool isStartPoint;

  const BulletPosition({
    this.pos = 0,
    this.isRate = false,
    this.isStartPoint = true,
  });

  double calculatePos(AxisDirection direction, Size size) {
    switch (direction) {
      case AxisDirection.up:
        return _calculateUp(size);
        break;
      case AxisDirection.right:
        return _calculateRight(size);
        break;
      case AxisDirection.down:
        return _calculateDown(size);
        break;
      case AxisDirection.left:
        return _calculateLeft(size);
    }
  }

  /// 計算左邊方向
  double _calculateLeft(Size size) {
    double value;
    if (isStartPoint) {
      // 開始基準點
      if (isRate) {
        value = size.width - (size.width * pos);
      } else {
        value = size.width - pos;
      }
    } else {
      // 尾部基準點
      if (isRate) {
        value = size.width * pos;
      } else {
        value = pos;
      }
    }
    return value;
  }

  /// 計算右邊方向
  /// 基本上就是與計算左邊方向的顛倒
  /// 但為了防止判斷太過混雜, 還是單獨拉方法
  double _calculateRight(Size size) {
    double value;
    if (isStartPoint) {
      // 開始基準點
      if (isRate) {
        value = size.width * pos;
      } else {
        value = pos;
      }
    } else {
      // 尾部基準點
      if (isRate) {
        value = size.width - (size.width * pos);
      } else {
        value = size.width - pos;
      }
    }
    return value;
  }

  /// 計算上方方向
  /// 基本上與左方的計算相同, 只差在計算基準點為寬度與高度的差別
  /// 同樣為了防止判斷混淆, 單獨拉方法
  double _calculateUp(Size size) {
    double value;
    if (isStartPoint) {
      // 開始基準點
      if (isRate) {
        value = size.height - (size.height * pos);
      } else {
        value = size.height - pos;
      }
    } else {
      // 尾部基準點
      if (isRate) {
        value = size.height * pos;
      } else {
        value = pos;
      }
    }
    return value;
  }

  /// 計算下方方向
  /// 其餘同上
  double _calculateDown(Size size) {
    double value;
    if (isStartPoint) {
      // 開始基準點
      if (isRate) {
        value = size.height * pos;
      } else {
        value = pos;
      }
    } else {
      // 尾部基準點
      if (isRate) {
        value = size.height - (size.height * pos);
      } else {
        value = size.height - pos;
      }
    }
    return value;
  }
}
