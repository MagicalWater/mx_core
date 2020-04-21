//import 'dart:math';
//
//import 'package:flutter/material.dart';
//import 'package:mx_core/mx_core.dart';
//
///// 旋轉圓環
//class RotateRing extends StatelessWidget {
//  /// 圓環大小
//  final double size;
//
//  /// 動畫時間(毫秒)
//  final int duration;
//
//  /// 顏色
//  final Color color;
//
//  /// 共要建造幾顆圓球出來
//  final int count;
//
//  final BoxDecoration decoration;
//
//  RotateRing({
//    this.size = 50,
//    this.duration = 500,
//    this.decoration,
//    this.color,
//    this.count = 10,
//  });
//
//  @override
//  Widget build(BuildContext context) {
//    return Align(
//      child: Container(
//        width: size,
//        height: size,
//        child: Stack(
//          children: List.generate(count, (index) => buildCircle(index)),
//        ),
//      ),
//    );
//  }
//
//  /// 構建一個圓圈出來
//  Widget buildCircle(int index) {
//    var delay = duration ~/ count * index;
//    var circleSize = size / count * 2;
//    return Transform.rotate(
//      angle: (2 * pi / count) * index,
//      child: Transform.translate(
//        offset: Offset((size / 2) - (circleSize / 2), 0),
//        child: AnimatedCore.repeat(
//          reverse: true,
//          defaultCurve: Curves.linear,
//          startDelay: delay,
//          child: Align(
//            child: Container(
//              width: circleSize,
//              height: circleSize,
//              decoration: (decoration ?? BoxDecoration(color: color ?? Colors.blueAccent))
//                  .copyWith(shape: BoxShape.circle),
//            ),
//          ),
//          animatedList: [
//            AnimatedValue.collection(
//              defaultDuration: duration ~/ 2,
//              animatedList: [
//                AnimatedValue.opacity(
//                  begin: 0,
//                  end: 1,
//                ),
//                AnimatedValue.scale(
//                  begin: 0,
//                  end: 1,
//                ),
//              ],
//            ),
//          ],
//        ),
//      ),
//    );
//  }
//}
