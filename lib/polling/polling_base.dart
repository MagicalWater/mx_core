import 'dart:async';

import 'package:meta/meta.dart';

/// 輪詢基底
abstract class PollingBase {
  /// 輪詢間隔
  Duration interval;

  /// 當前的 loop
  _PollLoop? _loop;

  /// 現在輪詢是否啟動中
  bool get isActive => _loop?.isLooping ?? false;

  /// 是否正在輪詢中
  bool get isPolling => _loop?.isPolling ?? false;

  /// 在這邊回傳需要進行輪詢的方法
  @protected
  Future<void> onPolling();

  PollingBase({this.interval = const Duration(minutes: 1)});

  /// 開始輪詢
  /// 開始之前先停止之前的
  /// [immediately] - 是否立刻執行一次輪詢
  void start([bool immediately = false]) {
    end();
    _loop = _PollLoop(interval: () => interval, onPoll: onPolling);
    _loop?.start(immediately);
  }

  /// 停止輪詢
  void end() {
    _loop?.end();
    _loop = null;
  }

  /// 釋放資源
  void dispose() {
    end();
  }
}

class _PollLoop {
  Duration Function() interval;
  Future<void> Function() onPoll;

  _PollLoop({required this.interval, required this.onPoll});

  /// 輪詢是否啟動中
  bool isLooping = false;

  /// 是否正在輪詢中
  bool isPolling = false;

  /// 是否要結束輪詢
  bool _isEnd = false;

  void start([bool immediately = false]) async {
    if (isLooping) {
      return;
    }

    isLooping = true;
    if (!immediately) {
      await Future.delayed(interval());
    }

    while (!_isEnd) {
      // print("開始輪詢");
      isPolling = true;
      await onPoll();
      isPolling = false;
      var waitDuration = interval();
      // print('輪詢結束 - 等待 $waitDuration');
      if (!_isEnd) {
        await Future.delayed(waitDuration);
      }
    }

    isLooping = false;
  }

  void end() {
    _isEnd = true;
  }
}
