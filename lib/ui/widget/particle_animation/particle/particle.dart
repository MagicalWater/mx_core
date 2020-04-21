import 'dart:math';
import 'dart:ui';

export 'ball_particle.dart';

/// 粒子基礎
abstract class Particle {
  /// x,y 加速度
  double accX, accY;

  /// x, y 速率
  double velocityX, velocityY;

  /// x, y 座標
  double x, y;

  /// 粒子是否還需要更新(當沒有速度以及加速度時, 不需要更新)
  bool get needUpdate {
    return !(accX == 0 && accY == 0 && velocityX == 0 && velocityY == 0);
  }

  /// 隨機一個速度以及加速度屬性
  void random() {
    velocityX = Random().nextDouble() * 5 + 2;
    velocityX = Random().nextBool() ? velocityX : -velocityX;
    velocityY = Random().nextDouble() * 5 + 2;
    velocityY = Random().nextBool() ? velocityY : -velocityY;
  }

  /// 將當前屬性更新成下一幀的屬性
  /// [rect] 粒子可活動範圍
  /// 回傳 [Particle] 粒子
  /// 當有回傳值時, 代表需要在畫布新增一個粒子
  void updateNext(Rect rect) {
    x += velocityX;
    y += velocityY;
    velocityX += accX;
    velocityY += accY;
  }

  /// 此粒子是否需要消失
  bool isNeedDisappear() {
    return false;
  }

  Particle({
    this.x,
    this.y,
    this.accX,
    this.accY,
    this.velocityX,
    this.velocityY,
  });

  void draw(Canvas canvas, Paint paint);
}
