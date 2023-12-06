import 'package:flutter/material.dart';

/// 用百分比繪製路徑
class PointPaint extends StatelessWidget {
  final double? width;
  final double? height;
  final Widget? child;
  final List<List<Offset>> Function(Size size) pointBuilder;
  final Color strokeColor;
  final double strokeWidth;
  final Color fillColor;

  const PointPaint.builder({
    super.key,
    this.width,
    this.height,
    required this.pointBuilder,
    required this.strokeColor,
    this.strokeWidth = 1,
    required this.fillColor,
    required this.child,
  });

  factory PointPaint({
    required List<List<Offset>> points,
    required Color strokeColor,
    required double strokeWidth,
    required Color fillColor,
    double? width,
    double? height,
    bool fixed = false,
    Widget? child,
  }) {
    return PointPaint.builder(
      pointBuilder: (size) {
        return points.map((pointGroup) {
          return pointGroup.map((e) {
            var x = e.dx, y = e.dy;
            final maxW = size.width, maxH = size.height;

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

            return Offset(x, y);
          }).toList();
        }).toList();
      },
      width: width,
      height: height,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      fillColor: fillColor,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (child == null) {
      return CustomPaint(
        size: Size(width ?? 0, height ?? 0),
        painter: PointPainter(
          pointBuilder: pointBuilder,
          strokeColor: strokeColor,
          strokeWidth: strokeWidth,
          fillColor: fillColor,
        ),
      );
    } else {
      return Stack(
        children: [
          child!,
          Positioned.fill(
            child: CustomPaint(
              painter: PointPainter(
                pointBuilder: pointBuilder,
                strokeColor: strokeColor,
                strokeWidth: strokeWidth,
                fillColor: fillColor,
              ),
            ),
          ),
        ],
      );
    }
  }
}

/// 設置多個點的路徑剪裁
class PointPainter extends CustomPainter {
  final Color strokeColor;
  final double strokeWidth;
  final Color fillColor;
  final List<List<Offset>> Function(Size size) pointBuilder;

  PointPainter({
    super.repaint,
    required this.pointBuilder,
    required this.strokeColor,
    this.strokeWidth = 1,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = getPath(size);

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    final strokePaint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  Path getPath(Size size) {
    final path = Path();
    for (var pointGroup in pointBuilder(size)) {
      var firstMove = true;
      for (var element in pointGroup) {
        if (firstMove) {
          path.moveTo(element.dx, element.dy);
          firstMove = false;
        } else {
          path.lineTo(element.dx, element.dy);
        }
      }
      path.close();
    }
    return path;
  }
}
