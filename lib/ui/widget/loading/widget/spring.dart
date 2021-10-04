import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';

/// 變形位移
class Spring extends StatelessWidget {
  /// 位移距離係數
  final int springMultiple;

  /// 大小
  final double size;

  /// 動畫時間(毫秒)
  final int duration;

  /// 裝飾
  final BoxDecoration? decoration;

  /// 顏色
  final Color? color;

  /// 晃動方向
  final Axis direction;

  bool get isHorizontal => direction == Axis.horizontal;

  Spring({
    this.springMultiple = 1,
    this.size = 50,
    this.duration = 500,
    this.decoration,
    this.color,
    this.direction = Axis.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    var distance = size * springMultiple;
    var translateStart = getTranslateStart();
    var translateEnd = getTranslateEnd();
    List<Comb> scaleStart = getScaleStart();
    List<Comb> scaleEnd = getScaleEnd();

    double width, height;
    if (isHorizontal) {
      width = distance * 3;
      height = size * 1.5;
    } else {
      width = size * 1.5;
      height = distance * 3;
    }

    return Align(
      child: Container(
        width: width,
        height: height,
        child: AnimatedComb(
          type: AnimatedType.repeatReverse,
          child: Align(
            child: Container(
              width: size,
              height: size,
              decoration: (decoration ??
                      BoxDecoration(color: color ?? Colors.blueAccent))
                  .copyWith(shape: BoxShape.circle),
            ),
          ),
          duration: duration ~/ 2,
          animatedList: [
            Comb.parallel(
              curve: Curves.easeInSine,
              animatedList: scaleStart..add(translateStart),
            ),
            Comb.parallel(
              curve: Curves.easeOutSine,
              animatedList: scaleEnd..add(translateEnd),
            ),
          ],
        ),
      ),
    );
  }

  Comb getTranslateStart() {
    if (isHorizontal) {
      return Comb.translate(
        begin: Offset(-size * springMultiple, 0),
        end: Offset.zero,
      );
    } else {
      return Comb.translate(
        begin: Offset(0, -size * springMultiple),
        end: Offset.zero,
      );
    }
  }

  Comb getTranslateEnd() {
    if (isHorizontal) {
      return Comb.translate(
        begin: Offset.zero,
        end: Offset(size * springMultiple, 0),
      );
    } else {
      return Comb.translate(
        begin: Offset.zero,
        end: Offset(0, size * springMultiple),
      );
    }
  }

  List<Comb> getScaleStart() {
    Comb scaleX, scaleY;
    if (isHorizontal) {
      scaleX = Comb.scaleX(
        begin: 1,
        end: 2 * springMultiple.toDouble(),
      );
      scaleY = Comb.scaleY(begin: 1, end: 0.5);
    } else {
      scaleX = Comb.scaleX(begin: 1, end: 0.5);
      scaleY = Comb.scaleY(
        begin: 1,
        end: 2 * springMultiple.toDouble(),
      );
    }
    return [scaleX, scaleY];
  }

  List<Comb> getScaleEnd() {
    Comb scaleX, scaleY;
    if (isHorizontal) {
      scaleX = Comb.scaleX(
        begin: 2 * springMultiple.toDouble(),
        end: 1,
      );
      scaleY = Comb.scaleY(begin: 0.5, end: 1);
    } else {
      scaleX = Comb.scaleX(begin: 0.5, end: 1);
      scaleY = Comb.scaleY(
        begin: 2 * springMultiple.toDouble(),
        end: 1,
      );
    }

    return [scaleX, scaleY];
  }
}
