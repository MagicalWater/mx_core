import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';

/// 方形變形位移
class RoundSpring extends StatefulWidget {
  /// 球數量
  final int ballCount;

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

  RoundSpring({
    this.springMultiple = 1,
    this.ballCount = 1,
    this.size = 50,
    this.duration = 500,
    this.decoration,
    this.color,
  });

  @override
  _RoundSpringState createState() => _RoundSpringState();
}

class _RoundSpringState extends State<RoundSpring>
    with TickerProviderStateMixin {
  late AnimatedSyncTick _animatedSyncTick;

  @override
  void initState() {
    _animatedSyncTick = AnimatedSyncTick(
      type: AnimatedType.repeat,
      vsync: this,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var distance = widget.size * widget.springMultiple;
    return Align(
      child: Container(
        width: distance * 3,
        height: distance * 3,
        child: Stack(
          children: List.generate(widget.ballCount, (index) {
            var splitTime = widget.duration / widget.ballCount;
            var shift = splitTime * index;
//            print("延遲: $delayStart, 每段: ${widget.duration}");
            return getRoundSpringWidget(distance, shift.toInt());
          }),
        ),
      ),
    );
  }

  Widget getRoundSpringWidget(double distance, int shiftDuration) {
    return AnimatedComb(
      shiftDuration: shiftDuration,
      sync: _animatedSyncTick,
      child: Align(
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: (widget.decoration ??
                  BoxDecoration(color: widget.color ?? Colors.blueAccent))
              .copyWith(shape: BoxShape.circle),
        ),
      ),
      duration: widget.duration ~/ 8,
      animatedList: [
        Comb.parallel(
          curve: Curves.easeInSine,
          animatedList: _getScaleStart(Axis.horizontal)
            ..add(_getTranslateStart(AxisDirection.up)),
        ),
        Comb.parallel(
          curve: Curves.easeOutSine,
          animatedList: _getScaleEnd(Axis.horizontal)
            ..add(_getTranslateEnd(AxisDirection.up)),
        ),
          Comb.parallel(
            curve: Curves.easeInSine,
            animatedList: _getScaleStart(Axis.vertical)
              ..add(_getTranslateStart(AxisDirection.right)),
          ),
          Comb.parallel(
            curve: Curves.easeOutSine,
            animatedList: _getScaleEnd(Axis.vertical)
              ..add(_getTranslateEnd(AxisDirection.right)),
          ),
          Comb.parallel(
            curve: Curves.easeInSine,
            animatedList: _getScaleStart(Axis.horizontal)
              ..add(_getTranslateStart(AxisDirection.down)),
          ),
          Comb.parallel(
            curve: Curves.easeOutSine,
            animatedList: _getScaleEnd(Axis.horizontal)
              ..add(_getTranslateEnd(AxisDirection.down)),
          ),
          Comb.parallel(
            curve: Curves.easeInSine,
            animatedList: _getScaleStart(Axis.vertical)
              ..add(_getTranslateStart(AxisDirection.left)),
          ),
          Comb.parallel(
            curve: Curves.easeOutSine,
            animatedList: _getScaleEnd(Axis.vertical)
              ..add(_getTranslateEnd(AxisDirection.left)),
          ),
      ],
    );
  }

  Comb _getTranslateStart(AxisDirection direction) {
    Comb translateValue;
    var distance = widget.size * widget.springMultiple;
    switch (direction) {
      case AxisDirection.up:
        translateValue = Comb.translate(
          begin: Offset(-distance, -distance),
          end: Offset(0, -distance),
        );
        break;
      case AxisDirection.right:
        translateValue = Comb.translate(
          begin: Offset(distance, -distance),
          end: Offset(distance, 0),
        );
        break;
      case AxisDirection.down:
        translateValue = Comb.translate(
          begin: Offset(distance, distance),
          end: Offset(0, distance),
        );
        break;
      case AxisDirection.left:
        translateValue = Comb.translate(
          begin: Offset(-distance, distance),
          end: Offset(-distance, 0),
        );
        break;
    }
    return translateValue;
  }

  Comb _getTranslateEnd(AxisDirection direction) {
    Comb translateValue;
    var distance = widget.size * widget.springMultiple;
    switch (direction) {
      case AxisDirection.up:
        translateValue = Comb.translate(
          begin: Offset(0, -distance),
          end: Offset(distance, -distance),
        );
        break;
      case AxisDirection.right:
        translateValue = Comb.translate(
          begin: Offset(distance, 0),
          end: Offset(distance, distance),
        );
        break;
      case AxisDirection.down:
        translateValue = Comb.translate(
          begin: Offset(0, distance),
          end: Offset(-distance, distance),
        );
        break;
      case AxisDirection.left:
        translateValue = Comb.translate(
          begin: Offset(-distance, 0),
          end: Offset(-distance, -distance),
        );
        break;
    }
    return translateValue;
  }

  List<Comb> _getScaleStart(Axis direction) {
    Comb scaleX, scaleY;
    if (direction == Axis.horizontal) {
      scaleX = Comb.scaleX(
        begin: 1,
        end: 2 * widget.springMultiple.toDouble(),
      );
      scaleY = Comb.scaleY(begin: 1, end: 0.5);
    } else {
      scaleX = Comb.scaleX(begin: 1, end: 0.5);
      scaleY = Comb.scaleY(
        begin: 1,
        end: 2 * widget.springMultiple.toDouble(),
      );
    }
    return [scaleX, scaleY];
  }

  List<Comb> _getScaleEnd(Axis direction) {
    Comb scaleX, scaleY;
    if (direction == Axis.horizontal) {
      scaleX = Comb.scaleX(
        begin: 2 * widget.springMultiple.toDouble(),
        end: 1,
      );
      scaleY = Comb.scaleY(begin: 0.5, end: 1);
    } else {
      scaleX = Comb.scaleX(begin: 0.5, end: 1);
      scaleY = Comb.scaleY(
        begin: 2 * widget.springMultiple.toDouble(),
        end: 1,
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