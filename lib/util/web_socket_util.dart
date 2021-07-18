import 'dart:async';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

class WebSocketUtil {
  /// 當發生錯誤時, 嘗試重新連接次數, 默認重試1次
  int errorRetry;

  /// 保持連線的 ping 間隔
  Duration? pingInterval;

  /// 等待 pong 回應的 timeout 時間
  Duration? pongTimeout;

  /// 重新嘗試連接的間隔, 默認 5 秒
  Duration retryInterval;

  /// 當時間到需要再進行 ping 時
  void Function()? onPing;

  WebSocketUtil({
    this.errorRetry = 1,
    this.pingInterval,
    this.pongTimeout,
    this.retryInterval = const Duration(seconds: 5),
    this.onPing,
  }) {
    this._statusSubject.add(SocketStatus.idle);
  }

  /// 當前連接的相關屬性, 給外部 get 看得
  String? get url => _url;

  Iterable<String>? get protocols => _protocols;

  Map<String, dynamic>? get headers => _headers;

  /// 狀態串流
  Stream<SocketStatus> get statusStream => _statusSubject.stream;

  /// 資料串流
  Stream<String> get dataStream => _dataSubject.stream;

  /// 結束通知串流
  Stream<bool> get doneStream => _doneSubject.stream;

  /// 錯誤通知串流
  Stream<dynamic> get errorStream => _errorSubject.stream;

  /// webSocket的狀態
  SocketStatus get status => _statusSubject.value ?? SocketStatus.idle;

  /// 當前是否是連線狀態
  bool get isConnecting => status == SocketStatus.connect;

  WebSocket? _webSocket;

  /// ping 的倒數監聽
  StreamSubscription? _pingSubscription;

  /// pong 的倒數監聽
  StreamSubscription? _pongSubscription;

  /// 重新嘗試連線的倒數監聽
  StreamSubscription? _retrySubscription;

  /// 當前發生錯誤的次數
  int _nowRetryCount = 0;

  BehaviorSubject<SocketStatus> _statusSubject = BehaviorSubject();

  /// 監聽到資料時
  BehaviorSubject<String> _dataSubject = BehaviorSubject();

  /// 連接結束時
  BehaviorSubject<bool> _doneSubject = BehaviorSubject();

  /// web socket 發生錯誤時
  BehaviorSubject<dynamic> _errorSubject = BehaviorSubject();

  /// 當前連接的相關屬性
  String? _url;
  Iterable<String>? _protocols;
  Map<String, dynamic>? _headers;

  StreamSubscription? _streamSubscription;

  /// 連接伺服器
  /// [autoRetry] 第一次連線失敗後是否自動嘗試重新連線
  Future<bool> connect({
    required String url,
    Iterable<String>? protocols,
    Map<String, dynamic>? headers,
    bool failRetry = true,
  }) async {
    disconnect();

    _statusSubject.add(SocketStatus.tryConnect);

    try {
      _webSocket = await WebSocket.connect(
        url,
        protocols: protocols,
        headers: headers,
      );
    } on WebSocketException catch (e) {
      print("WebSocketUtil 連接錯誤: ${e.message}");
      _webSocket = null;
      _statusSubject.add(SocketStatus.disconnect);
      _errorSubject.add(e);

      if (failRetry) {
        retryConnect(
          url: url,
          protocols: protocols,
          headers: headers,
        );
      }

      return false;
    } catch (e) {
      print('其餘錯誤: $e');
      return false;
    }

    _url = url;
    _protocols = protocols;
    _headers = headers;

    _statusSubject.add(SocketStatus.connect);
    print("連接成功");

    _startPingPeriodic(url);

    // 監聽訊息
    _streamSubscription = _webSocket?.listen((data) {
//      print("WebSocket 監聽: $data");
      /// 接收到資料, 重設 pingpong 倒數計時器
      _startPingPeriodic(url);
      _dataSubject.add(data);
    }, onError: (error) {
      print("WebSocket 錯誤: $error");
      _errorSubject.add(error);
      if (errorRetry > 0) {
        retryConnect(url: url);
      } else {
        disconnect();
      }
    }, onDone: () {
      print("WebSocket 結束");
      disconnect();
      _doneSubject.add(true);
    }, cancelOnError: true);

    return true;
  }

  /// 發送資料
  void send(String message) {
    if (_webSocket == null) {
      print("WebSocketUtil: socket 是 null, 無法發送訊息");
    }
    _webSocket?.add(message);
  }

  /// 斷開連接
  Future<Null> disconnect({int? closeCode, String? closeReason}) async {
    print('關閉 socket');
    await _streamSubscription?.cancel();
    await _webSocket?.close(closeCode, closeReason);
    _webSocket = null;
    _cancelCountdown();
    _url = null;
    _protocols = null;
    _headers = null;
  }

  /// 嘗試重新連線,
  void retryConnect({
    required String url,
    Iterable<String>? protocols,
    Map<String, dynamic>? headers,
  }) {
    _cancelCountdown();
    print(
        "WebSocketUtil 將在 ${retryInterval.inSeconds} 秒後嘗試重新連接: $_nowRetryCount/$errorRetry");
    _nowRetryCount += 1;
    _retrySubscription = TimerStream('', retryInterval).listen((_) async {
      var success = await connect(
        url: url,
        protocols: protocols,
        headers: headers,
        failRetry: false,
      );
      if (!success) {
        if (_nowRetryCount < errorRetry) {
          retryConnect(
            url: url,
            protocols: protocols,
            headers: headers,
          );
        } else {
          print(
              "WebSocketUtil 重新嘗試連線已達最大重新連接數: $_nowRetryCount/$errorRetry, 停止");
        }
      }
    });
  }

  /// 開始 ping 倒數
  void _startPingPeriodic(String url) {
    _cancelCountdown();
    final pPing = pingInterval;
    final pPong = pongTimeout;
    if (pPing != null && pPong != null && onPing != null) {
      _pingSubscription = TimerStream('', pPing).listen((_) {
        /// 請外部發送 ping
        onPing?.call();

        /// 等待 pong
        print("等待心跳");
        _startPongCountdown(url, pPong);
      });
    } else {
//      print("WebSocketUtil: pingInterval 或 onPing 是 null, 不進行 ping 間隔保活");
    }
  }

  /// 開始 pong timeout 倒數
  void _startPongCountdown(String url, Duration pongTimeout) {
    _pongSubscription = TimerStream('', pongTimeout).listen((_) {
      print("WebSocketUtil pong timeout: 斷線");
      if (errorRetry > 0) {
        retryConnect(url: url);
      } else {
        disconnect();
      }
    });
  }

  /// 取消 ping pong 倒數
  void _cancelCountdown() {
    _pingSubscription?.cancel();
    _pongSubscription?.cancel();
    _retrySubscription?.cancel();

    _pingSubscription = null;
    _pongSubscription = null;
    _retrySubscription = null;

  }
}

class SocketStatus {
  final int _value;

  const SocketStatus._internal(this._value);

  int get value => _value;

  /// 尚未發起過連線
  static const idle = SocketStatus._internal(SocketStatus._idle);

  /// 連線中
  static const connect = SocketStatus._internal(SocketStatus._connect);

  /// 斷線中
  static const disconnect = SocketStatus._internal(SocketStatus._disconnect);

  /// 正在發起連線
  static const tryConnect = SocketStatus._internal(SocketStatus._tryConnect);

  static const int _idle = 1;
  static const int _connect = 2;
  static const int _disconnect = 3;
  static const int _tryConnect = 4;

  @override
  int get hashCode => super.hashCode;

  @override
  bool operator ==(other) {
    if (other is SocketStatus) {
      return value == other.value;
    }
    return false;
  }
}
