import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

/// 輪詢基底
abstract class PollingBase {
  /// 輪詢間隔
  Duration interval;

  /// 輪詢的訂閱
  StreamSubscription _subscription;

  /// 在這邊回傳需要進行輪詢的方法
  @protected
  Future<void> onPolling();

  PollingBase({this.interval = const Duration(minutes: 1)});

  /// 開始輪詢
  /// 開始之前先停止之前的
  void start() {
    print("開始倒數");
    end();
    _subscription = TimerStream('', interval).listen((_) async {
      print("時間到了 給我立刻輪詢");
      await onPolling();
      start();
    });
    print("逃出 start");
  }

  /// 停止輪詢
  void end() {
    _subscription?.cancel();
    _subscription = null;
  }

  /// 釋放資源
  void dispose() {
    end();
  }
}
