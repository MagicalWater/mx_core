import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'package:mx_core/popup/impl.dart';
import 'package:mx_core/popup/option.dart';
import 'package:mx_core/ui/widget/animated_comb/animated_comb.dart';

import 'particle/particle.dart';
import 'particle_animation.dart';

/// 爆炸的粒子動畫
class BombAnimation extends StatefulWidget {
  final double width;
  final double height;

  /// 粒子可以活動的範圍
  // final Rect activeRect;

  /// 此元件的 child
  final Widget child;

  /// 當是粒子爆炸動畫時, 需要切割成多少粒子
  final int splitWidth, splitHeight;

  /// 粒子動畫結束後回調
  final onEnd;

  /// 分割的粒子類型
  final ParticleType particleType;

  BombAnimation({
    required this.width,
    required this.height,
    required this.child,
    // this.activeRect,
    required this.splitWidth,
    required this.splitHeight,
    this.onEnd,
    this.particleType = ParticleType.ball,
  });

  @override
  _BombAnimationState createState() => _BombAnimationState();
}

class _BombAnimationState extends State<BombAnimation> {
  GlobalKey boundaryKey = GlobalKey();

  bool isBoomOut = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isBoomOut) {
      return Container(
        width: widget.width,
        height: widget.height,
      );
    } else {
      return AnimatedComb.quick(
        type: AnimatedType.tap,
        child: RepaintBoundary(
          key: boundaryKey,
          child: Container(
            width: widget.width,
            height: widget.height,
            child: widget.child,
          ),
        ),
        scale: Comb.scale(
          end: Size.square(0.8),
          curve: Curves.bounceOut,
          duration: 200,
        ),
        onTap: () => showParticlePopup(),
      );
    }
  }

  /// 顯示粒子動畫的浮出視窗
  Future<void> showParticlePopup() async {
    // 先將此元件的圖片截下來
    RenderRepaintBoundary boundary =
        boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    // 取得元件的全局座標
    var offset = boundary.localToGlobal(Offset.zero);
    ui.Image image = await boundary.toImage(pixelRatio: 1);
    ByteData byteData =
        (await image.toByteData(format: ui.ImageByteFormat.png))!;
    var pngBytes = byteData.buffer.asUint8List();
    var bs64 = base64Encode(pngBytes);
    // 將圖片轉換成 顯示的球球
    img.Image decodeImage = img.decodeImage(pngBytes)!;
    var particles = splitImageToParticle(decodeImage);

    isBoomOut = true;

    print('基礎左上角: $offset');

    var screenSize = MediaQuery.of(context).size;
    var activeRect = Rect.fromLTWH(
        -offset.dx, -offset.dy, screenSize.width, screenSize.height);

    // 將粒子動畫顯示在 Overlay 上
    Popup.showOverlay(
      option: PopupOption(
        left: max(offset.dx, 0),
        top: max(offset.dy, 0),
        width: widget.width,
        height: widget.height,
      ),
      hitRule: HitRule.through,
      animated: null,
      builder: (controller) {
        return ParticleAnimation(
          width: widget.width,
          height: widget.height,
          activeRect: activeRect,
          particles: particles,
          auto: true,
          onEnd: () {
//          print("移除動畫");
            controller.remove();
          },
        );
      },
    );

    setState(() {});
  }

  /// 分割元件轉化的圖片, 將之轉成粒子
  List<Particle> splitImageToParticle(img.Image image) {
    // 分割成 3*3
    var rect = splitRect(
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      widget.splitWidth,
      widget.splitHeight,
    );

    return rect.map((e) {
      var color =
          toArgb(image.getPixelSafe(e.center.dx.toInt(), e.center.dy.toInt()));
      return buildParticle(
        radius: rect[0].width / 2,
        color: color,
        x: e.center.dx,
        y: e.center.dy,
      );
    }).toList();
  }

  /// 根據 [widget.particleType] 構建出對應的隨機粒子
  Particle buildParticle({
    required double radius,
    required Color color,
    required double x,
    required double y,
  }) {
    Particle particle;
    switch (widget.particleType) {
      case ParticleType.ball:
        particle = BallParticle(
          radius: radius,
          color: color,
          x: x,
          y: y,
          accY: 0.4,
          restitution: 0.8,
        );
        break;
    }
    particle.random();
    return particle;
  }

  /// 將一個大的 rect 分割成 x * y 等份
  List<Rect> splitRect(Rect rect, int x, int y) {
    var w = rect.width / x;
    var h = rect.height / y;
    List<Rect> rects = [];
    for (int i = 0; i < x; i++) {
      for (int j = 0; j < y; j++) {
        rects.add(Rect.fromLTWH(w * i, h * j, w, h));
      }
    }
    return rects;
  }

  Color toArgb(int argbColor) {
    int r = (argbColor >> 16) & 0xFF;
    int b = argbColor & 0xFF;
    var argb = (argbColor & 0xFF00FF00) | (b << 16) | r;
    return Color(argb);
  }
}
