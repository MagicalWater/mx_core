import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class ImagePainter extends CustomPainter {
  final ui.Image image;

  final Paint mainPaint = Paint()..isAntiAlias = true;

  ImagePainter({required this.image});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(image, const Offset(0, 0), mainPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    if (oldDelegate is ImagePainter) {
      return oldDelegate.image != image;
    }
    return true;
  }
}
