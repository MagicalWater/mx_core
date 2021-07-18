import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

/// 計時核心
/// 倒數計時核心分成 [_tickTimer] 以及 [_lastTimer]
/// [_tickTimer] - 依照 tickInterval 跳動的 timer
/// [_lastTimer] - 當 tickInterval 大於剩餘的倒數時間時, [_tickTimer] 會將剩餘的任務轉交 [_lastTimer] 執行
class TimerCore {
  /// 取得當前 tick 觸發間隔
  Duration get tickInterval => _tickInterval;

  /// 取得當前總倒數時間
  Duration get totalTime => _totalTime;

  /// ㄒ剩餘的倒數時間
  Duration get remainingTime => _remainingTime;

  /// 取得當前計時器狀態
  TimerStatus get status => _status;

  /// tick 觸發間隔
  late Duration _tickInterval;

  /// 依據 tick 跳動的 timer
  Timer? _tickTimer;

  /// 設定總倒數時間
  late Duration _totalTime;

  /// 經過時間
  Duration get elapsedTime => _totalTime - _remainingTime;

  /// 剩餘的倒數時間
  late Duration _remainingTime;

  /// 最後衝刺倒數計時
  Timer? _lastTimer;

  /// 計時器狀態
  TimerStatus _status = TimerStatus.standby;

  /// tick 事件回調
  BehaviorSubject<TickData> _timerEventSubject = BehaviorSubject();

  /// tick 事件串流
  Stream<TickData> get timerStream => _timerEventSubject.stream;

  /// 倒數計時結束串流
  Stream<TickData> get doneStream =>
      timerStream.where((e) => e.status == TimerStatus.complete);

  TimerCore({
    required Duration totalTime,
    required Duration tickInterval,
  }) {
    this._tickInterval = tickInterval;
    this._totalTime = totalTime;
    this._remainingTime = _totalTime;

    if (this._remainingTime.inMilliseconds > this._totalTime.inMilliseconds) {
      // 剩餘時間不得超過總時間
      print(
          "剩餘時間(${this._remainingTime})不得超過總時間(${this._totalTime}), 強制將剩餘時間設定為總時間");
      this._remainingTime = this._totalTime;
    }

    _sendTickEvent();
  }

  /// 變更倒數計時時間
  /// 只有在非倒數計時期間才可以變更
  void modify({
    Duration? totalTime,
    Duration? remainingTime,
    Duration? tickInterval,
  }) {
    if (_status == TimerStatus.active) {
      print("當前正在倒數計時, 禁止修改時間");
      return;
    }
    if (totalTime != null) {
      this._totalTime = totalTime;
    }
    if (remainingTime != null) {
      this._remainingTime = remainingTime;
    }

    if (this._remainingTime.inMilliseconds > this._totalTime.inMilliseconds) {
      // 剩餘時間不得超過總時間
      print(
          "此次修改剩餘時間(${this._remainingTime})將會超過總時間(${this._totalTime}), 強制將剩餘時間設定為總時間");
      this._remainingTime = this._totalTime;
    }

    if (tickInterval != null) {
      this._tickInterval = tickInterval;
    }
  }

  /// 開始倒數計時
  void start() {
    print("開始倒數計時");

    // 當前狀態正在倒數時, 不做任何反應
    if (_status == TimerStatus.active) {
      print("當前已在倒數計時, 忽略此次呼叫");
      return;
    }

    _endTicker();
    _endRemainingTimer();

    // 依照當前狀態判斷是否需要重置剩餘時間
    // [TimerStatus.complete] - 重置
    // [TimerStatus.pause] - 接續
    if (_status == TimerStatus.complete) {
      print("重置倒數時間: $_totalTime");
      // 需要重置剩餘時間
      _remainingTime = _totalTime;
    }

    _status = TimerStatus.active;
    _sendTickEvent();

    // 檢查剩餘時間是否大於 [tickInterval]
    // 若不大於, 則直接呼叫 [startRemainingTimer] 啟動最後計時
    if (_remainingTime < _tickInterval) {
      print("剩餘時間小於 tick, 啟動最後倒數計時");
      _startRemainingTimer();
      return;
    }

    _tickTimer = Timer.periodic(_tickInterval, (t) {
      // 減去 time 的時間
      var remaining =
          _remainingTime.inMicroseconds - _tickInterval.inMicroseconds;
      _remainingTime = Duration(microseconds: remaining);

//      print("觸發 ticker, 剩餘: ${remainingTime.inMicroseconds} 秒");

      if (_remainingTime < _tickInterval && _remainingTime.inMicroseconds > 0) {
//        print("最後衝刺");
        _endTicker();
        _startRemainingTimer();
      } else if (_remainingTime.inMicroseconds == 0) {
        end();
      } else {
        _sendTickEvent();
      }
    });
  }

  /// 暫停倒數計時
  void pause() {
    _endTicker();
    _endRemainingTimer();
    _status = TimerStatus.pause;
    _sendTickEvent();
  }

  /// 結束倒數計時
  void end() {
    _endTicker();
    _endRemainingTimer();
    _status = TimerStatus.complete;
    _sendTickEvent();
  }

  /// 發送狀態變更事件
  void _sendTickEvent() {
    _timerEventSubject.add(TickData(
      status: _status,
      elapsedTime: elapsedTime,
      remainingTime: _remainingTime,
    ));
  }

  /// 執行剩餘時間倒數計時
  void _startRemainingTimer() {
    _sendTickEvent();
    _endRemainingTimer();
    _lastTimer = Timer(_remainingTime, () {
      _remainingTime = Duration.zero;
      end();
    });
  }

  /// 結束 tick timer
  void _endTicker() {
    if (_tickTimer?.isActive == true) {
      _tickTimer?.cancel();
    }
    _tickTimer = null;
  }

  void _endRemainingTimer() {
    if (_lastTimer?.isActive == true) {
      _lastTimer?.cancel();
    }
    _lastTimer = null;
  }

  /// 釋放 core
  void dispose() {
    _endTicker();
    _endRemainingTimer();
    _timerEventSubject.close();
  }
}

enum TimerStatus {
  /// 剛初始化完成, 隨時可以準備重新倒數
  standby,

  /// 正在倒數
  active,

  /// 暫停中
  pause,

  /// 完成
  complete,
}

/// 計時 tick 資料
class TickData {
  final TimerStatus status;
  final Duration remainingTime;
  final Duration elapsedTime;

  TickData(
      {required this.status,
      required this.elapsedTime,
      required this.remainingTime});

  @override
  bool operator ==(Object other) {
    if (other is TickData) {
      return status == other.status &&
          remainingTime == other.remainingTime &&
          elapsedTime == other.elapsedTime;
    }
    return false;
  }

  @override
  int get hashCode => super.hashCode;
}
