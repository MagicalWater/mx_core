import 'dart:async';

import 'package:flutter/material.dart';

import '../rect_provider.dart';

part 'horizontal_marquee.dart';

part 'vertical_marquee.dart';

/// 跑馬燈元件
class Marquee extends StatefulWidget {
  /// 元件
  final List<Widget> children;

  /// 滾動速率
  final int velocity;

  /// 每次跑馬燈啟動的間隔時間
  final Duration interval;

  /// 跑馬燈到的行為
  final MarqueeType type;

  /// 是否自動啟動跑馬燈
  final bool auto;

  /// 跑馬燈幾次循環, null 為無限次數
  final int times;

  /// 跑馬燈每次結束的回調
  final void Function(int times) onEnd;

  /// 跑馬燈開始時回調
  final void Function() onStart;

  /// 跑馬燈控制器
  final Function(MarqueeController controller) onCreated;

  Marquee._({
    @required this.children,
    Key key,
    this.auto = true,
    this.times,
    this.onCreated,
    this.onStart,
    this.onEnd,
    this.velocity = 100,
    this.type = MarqueeType.horizontal,
    this.interval = const Duration(milliseconds: 1000),
  }) : super(key: key);

  factory Marquee({
    List<Widget> children,
    Key key,
    bool auto = true,
    int times,
    final Function(MarqueeController controller) onCreated,
    VoidCallback onStart,
    Function(int times) onEnd,
    int velocity = 100,
    MarqueeType type = MarqueeType.horizontal,
    Duration interval = const Duration(milliseconds: 1000),
  }) {
    List<Widget> lastChildren = [];
    children.forEach((e) {
      lastChildren.add(e);
    });
    lastChildren.add(children[0]);
    return Marquee._(
      children: lastChildren,
      key: key,
      auto: auto,
      times: times,
      onCreated: onCreated,
      onStart: onStart,
      onEnd: onEnd,
      velocity: velocity,
      type: type,
      interval: interval,
    );
  }

  factory Marquee.text({
    @required List<String> texts,
    TextStyle style,
    Key key,
    bool auto = true,
    int times,
    final Function(MarqueeController controller) onCreated,
    VoidCallback onStart,
    Function(int times) onEnd,
    int velocity = 100,
    MarqueeType type = MarqueeType.horizontal,
    Duration interval = const Duration(milliseconds: 1000),
  }) {
    return Marquee(
      children: texts
          .map((e) => Text(
                e,
                style: style,
              ))
          .toList(),
      key: key,
      auto: auto,
      times: times,
      onCreated: onCreated,
      onStart: onStart,
      onEnd: onEnd,
      velocity: velocity,
      type: type,
      interval: interval,
    );
  }

  @override
  _MarqueeState createState() => _MarqueeState();
}

class _MarqueeState extends State<Marquee> {
  @override
  Widget build(BuildContext context) {
    if (widget.type == MarqueeType.horizontal) {
//      return Container();
      return HorizontalMarquee._(
        children: widget.children,
        auto: widget.auto,
        times: widget.times,
        onCreated: widget.onCreated,
        onStart: widget.onStart,
        onEnd: widget.onEnd,
        velocity: widget.velocity,
        interval: widget.interval,
      );
    } else {
      return VerticalMarquee._(
        children: widget.children,
        auto: widget.auto,
        times: widget.times,
        onCreated: widget.onCreated,
        onStart: widget.onStart,
        onEnd: widget.onEnd,
        velocity: widget.velocity,
        interval: widget.interval,
      );
    }
  }
}

abstract class MarqueeController {
  void start();

  void end();
}

/// 跑馬燈類型
enum MarqueeType {
  /// 移動到尾部之後, 往下替
  vertical,

  /// 開頭 ～～～ 結尾   開頭 ～～～ 結尾
  horizontal,
}
