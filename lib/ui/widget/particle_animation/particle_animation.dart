import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mx_core/mx_core.dart';

import 'particle/particle.dart';
import 'particle_painter.dart';

/// 粒子動畫
class ParticleAnimation extends StatefulWidget {
  final double width;
  final double height;

  /// 粒子可以活動的範圍
  final Rect activeRect;

  /// 粒子列表
  final List<Particle> particles;

  /// 此元件的 child
  final Widget child;

  /// 是否自動執行粒子動畫
  final bool auto;

  /// 粒子動畫結束後回調
  final onEnd;

  /// 分割的粒子類型
  final ParticleType particleType;

  ParticleAnimation({
    this.width,
    this.height,
    this.child,
    this.activeRect,
    this.particles,
    this.auto = false,
    this.onEnd,
    this.particleType = ParticleType.ball,
  });

  @override
  _ParticleAnimationState createState() => _ParticleAnimationState();
}

class _ParticleAnimationState extends State<ParticleAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;

  @override
  void initState() {
    // 一個永遠不會停下來的 animation
    animationController = AnimationController(
      vsync: this,
      duration: Duration(days: 365),
    )..addListener(() {
        // 重新進行渲染
        reRender();
      });

    if (widget.auto) {
      WidgetsBinding.instance.addPostFrameCallback((_) => startAnimation());
    }
    super.initState();
  }

  @override
  void dispose() {
    disposeAnimation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      Widget widgetChain = Container(
        color: Colors.transparent,
        width: widget.width,
        height: widget.height,
        child: Stack(
          children: widget.particles
              .map(
                (e) => CustomPaint(
                  painter: ParticlePainter(particle: e),
                ),
              )
              .toList(),
        ),
      );

      /// 如果是自動動畫粒子, 則不再使用點擊觸發
      if (!widget.auto) {
        widgetChain = AnimatedComb.quick(
          type: AnimatedType.tap,
          child: widgetChain,
          scale: Comb.scale(
              end: Size.square(0.8), curve: Curves.bounceOut, duration: 200),
          onTap: () {
            // 直接操作粒子
            startAnimation();
          },
        );
      }
      return widgetChain;
    });
  }

  /// 開始粒子動畫
  void startAnimation() {
    animationController.forward();
  }

  void disposeAnimation() {
    animationController?.dispose();
    animationController = null;
  }

  /// 依照經過的時間更新每個粒子的位置, 以及其他屬性
  /// 最後重新進行渲染
  void reRender() {
    widget.particles.forEach((e) => updateParticle(e));

    // 遍歷所有的粒子, 檢查是否有需要隱藏的
    widget.particles.removeWhere((e) => e.isNeedDisappear());

    if (widget.particles.isEmpty) {
      // 若所有粒子都消失了, 則停止動畫
      if (widget.onEnd != null) {
        widget.onEnd();
      }
      disposeAnimation();
    } else if (!widget.particles.any((e) => e.needUpdate)) {
      // 若所有粒子都停止了, 則停止動畫
      if (widget.onEnd != null) {
        widget.onEnd();
      }
      disposeAnimation();
    }
    setState(() {});
  }

  /// 更新粒子的屬性為下一幀
  void updateParticle(Particle particle) {
    if (widget.activeRect != null) {
      particle.updateNext(widget.activeRect);
    } else {
//      print("更新下個位置");
      particle.updateNext(Rect.fromLTWH(0, 0, widget.width, widget.height));
    }
  }

  Color toArgb(int argbColor) {
    int r = (argbColor >> 16) & 0xFF;
    int b = argbColor & 0xFF;
    var argb = (argbColor & 0xFF00FF00) | (b << 16) | r;
    return Color(argb);
  }
}

/// 分割成的粒子類型
enum ParticleType {
  /// 使用 BallParticle
  ball,
}
