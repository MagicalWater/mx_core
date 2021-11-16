import 'package:flutter/material.dart';

import 'particle/particle.dart';

class ParticlePainter extends CustomPainter {
  /// 需要進行繪畫的粒子
  Particle particle;

  /// 元件大小, 整個粒子運動空間
  double? width, height;

  /// 粒子物件畫筆
  final Paint _particlePaint = Paint();

  /// 背景畫筆
  final Paint _bgPaint = Paint();

  ParticlePainter({
    required this.particle,
    this.width,
    this.height,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), _bgPaint);
    particle.draw(canvas, _particlePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
