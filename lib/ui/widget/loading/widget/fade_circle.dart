import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';

/// 透明漸變圓環
class FadeCircle extends StatefulWidget {
  /// 圓環大小
  final double size;

  /// 動畫時間(毫秒)
  final int duration;

  /// 顏色
  final Color? color;

  /// 共要建造幾顆圓球出來
  final int count;

  /// 圓動畫共有多少個頭
  final int headCount;

  final BoxDecoration? decoration;

  const FadeCircle({
    Key? key,
    this.size = 50,
    this.duration = 500,
    this.decoration,
    this.color,
    this.count = 10,
    this.headCount = 1,
  }) : super(key: key);

  @override
  _FadeCircleState createState() => _FadeCircleState();
}

class _FadeCircleState extends State<FadeCircle>
    with SingleTickerProviderStateMixin {
  late AnimatedSyncTick _animatedSyncTick;

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
    return Align(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: List.generate(widget.count, (index) => buildCircle(index)),
        ),
      ),
    );
  }

  /// 構建一個圓圈出來
  Widget buildCircle(int index) {
    var delay = widget.duration * 2 ~/ widget.count * index;
    var circleSize = widget.size / widget.count * 2.5;
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..rotateZ((2 * pi / widget.count) * index)
        ..translate((widget.size / 2) - (circleSize / 2), 0, 0),
      child: AnimatedComb.quick(
        sync: _animatedSyncTick,
        curve: Curves.linear,
        shiftDuration: -delay,
        multipleAnimationController: true,
        child: Container(
          width: circleSize,
          height: circleSize,
          decoration: (widget.decoration ??
                  BoxDecoration(color: widget.color ?? Colors.blueAccent))
              .copyWith(shape: BoxShape.circle),
        ),
        duration: (widget.duration) ~/ widget.headCount,
        scale: Comb.scale(
          begin: const Size.square(0),
          end: const Size.square(1),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animatedSyncTick.dispose();
    super.dispose();
  }
}
