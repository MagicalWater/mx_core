import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';

/// 運球動畫
class BallSpring extends StatefulWidget {
  /// 多少顆球
  final int ballCount;

  /// 每顆球的起始彈跳間隔時間
  final int delayInterval;

  /// 位移距離係數
  final int springMultiple;

  /// 大小
  final double size;

  /// 動畫時間(毫秒)
  final int duration;

  /// 裝飾
  final BoxDecoration decoration;

  /// 顏色
  final Color color;

  /// 運球方向
  final Axis direction;

  bool get isHorizontal => direction == Axis.horizontal;

  BallSpring({
    this.ballCount = 1,
    this.delayInterval = 0,
    this.springMultiple = 1,
    this.size = 50,
    this.duration = 500,
    this.decoration,
    this.color,
    this.direction = Axis.horizontal,
  });

  @override
  _BallSpringState createState() => _BallSpringState();
}

class _BallSpringState extends State<BallSpring> with TickerProviderStateMixin {
  AnimatedSyncTick _animatedSyncTick;

  @override
  void initState() {
    _animatedSyncTick = AnimatedSyncTick(
      type: AnimatedType.repeatReverse,
      vsync: this,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var distance = widget.size * widget.springMultiple;

    double width, height;
    if (widget.isHorizontal) {
      width = distance * 3;
      height = widget.size * 1.5;
    } else {
      width = widget.size * 1.5;
      height = distance * 3;
    }

    var ballList = List.generate(widget.ballCount, (index) {
      return buildBallAnimated(
        width,
        height,
        index * widget.delayInterval,
        (widget.decoration ??
                BoxDecoration(color: widget.color ?? Colors.blueAccent))
            .copyWith(shape: BoxShape.circle),
      );
    });

    if (widget.isHorizontal) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: ballList,
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: ballList,
      );
    }
  }

  Widget buildBallAnimated(
      double width, double height, int startDelay, Decoration decoration) {
    return Align(
      child: Container(
        width: width,
        height: height,
        child: AnimatedComb(
          sync: _animatedSyncTick,
          curve: Curves.easeInToLinear,
          child: Align(
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: decoration,
            ),
          ),
          duration: widget.duration ~/ 2,
          shiftDuration: startDelay,
          animatedList: [
            Comb.parallel(
              curve: Curves.easeInSine,
              animatedList: [
                getTranslateStart(),
              ],
            ),
            Comb.parallel(
              curve: Curves.linear,
              animatedList: getScaleEnd()..add(getTranslateEnd()),
            ),
          ],
        ),
      ),
    );
  }

  Comb getTranslateStart() {
    if (widget.isHorizontal) {
      return Comb.translate(
        begin: Offset(-widget.size * widget.springMultiple, 0),
        end: Offset.zero,
      );
    } else {
      return Comb.translate(
        begin: Offset(0, -widget.size * widget.springMultiple),
        end: Offset.zero,
      );
    }
  }

  Comb getTranslateEnd() {
    if (widget.isHorizontal) {
      return Comb.translate(
        begin: Offset.zero,
        end: Offset(widget.size * widget.springMultiple, 0),
      );
    } else {
      return Comb.translate(
        begin: Offset.zero,
        end: Offset(0, widget.size * widget.springMultiple + widget.size / 4),
      );
    }
  }

  List<Comb> getScaleEnd() {
    var scaleDelay = widget.duration ~/ 3;
    var scaleDuration = (widget.duration ~/ 2) - scaleDelay;
    Comb scaleX, scaleY;
    if (widget.isHorizontal) {
      scaleX = Comb.scaleX(
        begin: 1,
        end: 1 / (2 * widget.springMultiple.toDouble()),
        delay: scaleDelay,
        duration: scaleDuration,
      );
      scaleY = Comb.scaleY(
        begin: 1,
        end: 1.5,
        delay: scaleDelay,
        duration: scaleDuration,
      );
    } else {
      scaleX = Comb.scaleX(
        begin: 1,
        end: 1.5,
        delay: scaleDelay,
        duration: scaleDuration,
      );
      scaleY = Comb.scaleY(
        begin: 1,
        end: 1 / (2 * widget.springMultiple.toDouble()),
        delay: scaleDelay,
        duration: scaleDuration,
      );
    }

    return [scaleX, scaleY];
  }

  @override
  void dispose() {
    _animatedSyncTick.dispose();
    super.dispose();
  }
}