import 'dart:async';

import 'package:flutter/material.dart';

import 'timer_core.dart';

/// TimerWidget 計時器 的 tick 構建元件 回調
/// [status] - 狀態
/// [time] - 剩餘時間
typedef Widget TimerWidgetBuilder(
  BuildContext context,
  TimerStatus status,
  Duration time,
);

/// 倒數計時元件
class TimerBuilder extends StatefulWidget {
  final TimerWidgetBuilder builder;

  /// 倒數時間, 當 [timerCore] 有值時失效
  final Duration? time;

  /// 觸發tick間隔, 當 [timerCore] 有值時失效
  final Duration? tickInterval;

  /// 由外部傳入 timer 倒數計時核心
  /// 此參數傳入時將忽略 [time] 以及 [tickInterval] 參數
  /// 此元件將不再自行創建
  /// 通常用於全局
  /// 生命週期由外部自行控制
  /// 此元件 dispose 時將不會自動 dispose timerCore
  final TimerCore? timerCore;

  /// 是否自動開始倒數
  final bool autoStart;

  TimerBuilder({
    this.time,
    this.tickInterval,
    this.timerCore,
    this.autoStart = false,
    required this.builder,
  }) : assert((time != null && tickInterval != null) || timerCore != null);

  @override
  _TimerBuilderState createState() => _TimerBuilderState();
}

class _TimerBuilderState extends State<TimerBuilder> {
  late TimerCore _timerCore;

  late StreamSubscription _timerEventSubscription;

  bool get isActive => _timerCore.status != TimerStatus.active;

  /// 是否由外部自行傳入的 timerCore
  late bool isCustomTimerCore;

  @override
  void initState() {
    isCustomTimerCore = widget.timerCore != null;
    _timerCore = widget.timerCore ??
        TimerCore(
          totalTime: widget.time!,
          tickInterval: widget.tickInterval!,
        );
    _timerEventSubscription = _timerCore.timerStream.listen((data) {
      setState(() {});
    });
    if (widget.autoStart) {
      start();
    }
    super.initState();
  }

  /// 控制器呼叫開始倒數計時
  void start() {
    _timerCore.start();
  }

  void pause() {
    _timerCore.pause();
  }

  void end() {
    _timerCore.end();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: widget.builder(
        context,
        _timerCore.status,
        _timerCore.remainingTime,
      ),
    );
  }

  @override
  void dispose() {
    _timerEventSubscription.cancel();
    // 若 timerCore 是由外部傳入, 則不動作
    if (!isCustomTimerCore) {
      _timerCore.dispose();
    }
    super.dispose();
  }
}
