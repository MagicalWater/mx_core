import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';

typedef StatefulButtonTapCallback = Function(
    StatefulButtonController controller);

/// 有狀態的按鈕
/// 現可針對 load 狀態做顯示
class StatefulButton extends StatefulWidget {
  /// 按鈕長寬
  final double width;
  final double height;

  final Widget? child;

  /// 按鈕的 feed back
  final TapFeedback? tapStyle;

  /// 按鈕裝飾
  final Decoration? decoration;

  /// 讀取狀態流監聽
  final Stream<bool>? loadStream;

  /// 動畫時間
  final Duration duration;

  /// 初始化的 load 狀態
  final bool initLoad;

  /// 初始化的動畫狀態
  final bool initAnimated;

  /// loading 狀態時的 size
  final StateStyle? loadStyle;

  /// 在元件初始化時, 會將讀取狀態控制器打出去
  final void Function(StatefulButtonController controller)? onCreated;

  /// 按鈕點擊時觸發
  final StatefulButtonTapCallback? onTap;

  final Duration changeInterval;

  const StatefulButton({
    Key? key,
    required this.width,
    required this.height,
    this.tapStyle,
    this.child,
    this.decoration,
    this.initLoad = false,
    this.initAnimated = false,
    this.duration = const Duration(milliseconds: 100),
    this.loadStyle,
    this.loadStream,
    this.changeInterval = const Duration(seconds: 1),
    this.onCreated,
    this.onTap,
  }) : super(key: key);

  @override
  _StatefulButtonState createState() => _StatefulButtonState();
}

class _StatefulButtonState extends State<StatefulButton>
    implements StatefulButtonController {
  /// 當前是否正在開放狀態[非讀取]
  late bool _isStandby;

  /// 真正控制 loading 狀態的控制器
  late AnimatedSyncTick _controller;

  /// 監聽 load stream 的訂閱
  StreamSubscription? _loadSubscription;

  /// 當前是否讀取中
  @override
  bool get isLoading => !_isStandby;

  /// 讀取的 style
  StateStyle get _loadStyle {
    return widget.loadStyle ??
        StateStyle(
          color: Colors.blueAccent,
          size: min(widget.width, widget.height),
        );
  }

  /// 動畫時間
  Duration get _animDuration {
    return widget.duration;
  }

  /// 動畫時間
  Duration get _sizeDuration {
    return widget.duration;
  }

  bool? willEnable;

  @override
  void initState() {
    _isStandby = !widget.initLoad;
    _controller = AnimatedSyncTick.identity(
      initToggle: _isStandby,
      initAnimated: widget.initAnimated,
      type: AnimatedType.toggle,
    )..addStatusListener((status) {
        print('狀態變更: $status');

        if (status == AnimationStatus.dismissed ||
            status == AnimationStatus.completed) {
          // 當動畫結束時, 發現開關不同時需要進行同步

          if (willEnable != null) {
            print('動畫結束, 檢測到有需要執行的開關, 倒數計時開始');
            _startSyncTimer();
          }
        }
      });
    // 如果有 load 狀態 stream, 進行監聽
    _loadSubscription = widget.loadStream?.listen((enable) {
      setLoad(enable);
    });

    widget.onCreated?.call(this);
    super.initState();
  }

  Timer? _syncTimer;

  void _startSyncTimer() {
    _endSyncTimer();
    _syncTimer = Timer(
      widget.changeInterval,
      () {
        _syncTimer = null;
        if (!_controller.isAnimating && willEnable != null) {
          _isStandby = !willEnable!;
          willEnable = null;
          _syncLoadState();
        }
      },
    );
  }

  void _endSyncTimer() {
    if (_syncTimer != null && _syncTimer!.isActive) {
      _syncTimer!.cancel();
    }
    _syncTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    print('動畫時間: $_animDuration');
    return Center(
      child: AnimatedComb(
        sync: _controller,
        curve: Curves.fastOutSlowIn,
        builder: (context, anim) {
          var child = MaterialLayer.single(
            tapStyle: anim.toggle!
                ? widget.tapStyle
                : TapFeedback(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                  ),
            layer: LayerProperties(decoration: widget.decoration),
            child: AnimatedSwitcher(
              child: anim.toggle!
                  ? (widget.child ?? Container())
                  : Loading.circle(
                      size: _loadStyle.size * 3 / 4,
                      color: _loadStyle.color,
                    ),
              duration: _animDuration,
              switchInCurve: const Interval(0.7, 1.0),
              switchOutCurve: const Interval(0.7, 1.0),
            ),
            onTap: () {
              widget.onTap?.call(this);
            },
          );
          return anim.component(child);
        },
        animatedList: [
          Comb.width(
            begin: _loadStyle.size,
            end: widget.width,
            height: _loadStyle.size,
            duration: _sizeDuration.inMilliseconds ~/ 2,
          ),
          if (_loadStyle.size != widget.height)
            Comb.height(
              begin: _loadStyle.size,
              end: widget.height,
              width: widget.width,
              duration: _sizeDuration.inMilliseconds ~/ 2,
            ),
        ],
      ),
    );
  }

  /// 同步讀取狀態顯示
  void _syncLoadState() {
    _controller.toggle(_isStandby);
  }

  /// 設置按鈕讀取狀態
  @override
  void setLoad(bool load) {
    var isWaitForTimer = _syncTimer?.isActive ?? false;
    if (isWaitForTimer) {
      print('動畫等待調用中, 不動作進入等待區');
      willEnable = load;
    } else if (_controller.isAnimating) {
      _endSyncTimer();
      print('動畫中, 不動作進入等待區');
      willEnable = load;
    } else {
      _endSyncTimer();
      print('執行動畫變更');
      willEnable = null;
      _isStandby = !load;
      _syncLoadState();
    }
  }

  @override
  void dispose() {
    _endSyncTimer();
    _loadSubscription?.cancel();
    _loadSubscription = null;
    super.dispose();
  }
}

abstract class StatefulButtonController {
  /// 設置按鈕讀取狀態
  void setLoad(bool load);

  /// 當前是否讀取中
  bool get isLoading;
}

/// 讀取狀態時的 loading style
class StateStyle {
  Color color;
  double size;

  StateStyle({required this.color, required this.size});
}
