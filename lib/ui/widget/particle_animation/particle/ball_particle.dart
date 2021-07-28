import 'dart:math';
import 'dart:ui';

import 'particle.dart';

/// 球類粒子
class BallParticle extends Particle {
  /// 球類粒子顏色
  Color color;

  /// 球半徑
  double radius;

  /// 球的彈力恢復係數(最滿是1.0)
  double restitution;

  /// 當觸及到邊界次數超過此值, 則粒子就該消失了
  int? boundLimit;

  int _currentBoundTimes = 0;

  /// 粒子最小的寬度, 當球的半徑小於此值, 則粒子就該消失了
  double radiusLowerBound = 3;

  BallParticle({
    required this.color,
    this.radius = 10,
    double x = 0,
    double y = 0,
    double velocityX = 0,
    double velocityY = 0,
    double accX = 0,
    double accY = 0,
    this.restitution = 1.0,
    this.boundLimit = 2,
  }) : super(
          x: x,
          y: y,
          velocityX: velocityX,
          velocityY: velocityY,
          accX: accX,
          accY: accY,
        ) {
    radius = max(radius, radiusLowerBound);
  }

//  BallParticle copy() {
//    return BallParticle(
//      color: color,
//      radius: radius,
//      x: x,
//      y: y,
//      velocityX: velocityX * 1.5,
//      velocityY: velocityY * 1.2,
//      accX: accX,
//      accY: accY,
//      restitution: restitution,
//    );
//  }

  @override
  void updateNext(Rect rect) {
    // 先呼叫 super 更新下一幀的屬性

    var preX = x;
    var preY = y;

    x += velocityX;
    y += velocityY;

//    print("y速度: ${velocityY}");

    // 是否超出垂直/橫式邊界
    var isOutVerticalBound = false;
    var isOutHorizontalBound = false;

    // 接著檢查上下左右邊界是否越界, 以及相關處理
    if (y > rect.bottom - radius) {
      // 超過下邊界
      // 1. 回退 y 的位置
      // 2. 將 y 軸速度更改為反方向
      y = preY;
      velocityY = -(velocityY - accY) * restitution;
      _currentBoundTimes += 1;
      isOutVerticalBound = true;
    }

    if (y < rect.top + radius) {
      // 超過上邊界
      // 1. 回退 y 的位置
      // 2. 將 y 軸速度更改為反方向
      y = preY;
      velocityY = -(velocityY - accY) * restitution;
      _currentBoundTimes += 1;
      isOutVerticalBound = true;
    }

    if (x < rect.left + radius) {
      // 超過左邊界
      // 1. 回退 x 的位置
      // 2. 將 x 軸速度更改為反方向
      x = preX;
      velocityX = -(velocityX - accX) * restitution;
      _currentBoundTimes += 1;
      isOutHorizontalBound = true;
    }

    if (x > rect.right - radius) {
      // 超過右邊界
      // 1. 回退 x 的位置
      // 2. 將 x 軸速度更改為反方向
      x = preX;
      velocityX = -(velocityX - accX) * restitution;
      _currentBoundTimes += 1;
      isOutHorizontalBound = true;
    }

    // 沒有超過垂直邊界, 可以再加上加速度
    // 因為若超過垂直邊界, 代表速度會改變方向, 因此反彈速度就會受影響
    if (!isOutVerticalBound) {
      velocityY += accY;
    }

    // 原因同上
    if (!isOutHorizontalBound) {
      velocityX += accX;
    }
  }

  @override
  bool isNeedDisappear() {
    // 當半徑小於2時, 需要隱藏
    var isBoundLimitOut = false;
    if (boundLimit != null) {
      isBoundLimitOut = _currentBoundTimes >= boundLimit!;
    }
    if (radius < radiusLowerBound || isBoundLimitOut) {
//      print("粒子需要隱藏: $radius, $_currentBoundTimes");
      return true;
    }
//    print("粒子不需要隱藏");
    return false;
  }

  @override
  void draw(Canvas canvas, Paint paint) {
    paint.color = color;
    canvas.drawCircle(Offset(x, y), radius, paint);
  }
}
