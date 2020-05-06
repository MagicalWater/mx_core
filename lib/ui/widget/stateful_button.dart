import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';

typedef StatefulButtonTapCallback(StatefulButtonController controller);

/// 有狀態的按鈕
/// 現可針對 load 狀態做顯示
class StatefulButton extends StatefulWidget {
  /// 按鈕長寬
  final double width;
  final double height;

  final Widget child;

  /// 按鈕的 feed back
  final TapFeedback tapStyle;

  /// 按鈕裝飾
  final Decoration decoration;

  /// 讀取狀態流監聽
  final Stream<bool> loadStream;

  /// 動畫時間
  final Duration duration;

  /// 初始化的 load 狀態
  final bool initLoad;

  /// loading 狀態時的 size
  final StateStyle loadStyle;

  /// 在元件初始化時, 會將讀取狀態控制器打出去
  final void Function(StatefulButtonController controller) onCreated;

  /// 按鈕點擊時觸發
  final StatefulButtonTapCallback onTap;

  StatefulButton({
    @required this.width,
    @required this.height,
    this.child,
    this.decoration,
    this.initLoad = false,
    this.duration,
    this.tapStyle,
    this.loadStyle,
    this.loadStream,
    this.onCreated,
    this.onTap,
  });

  @override
  _StatefulButtonState createState() => _StatefulButtonState();
}

class _StatefulButtonState extends State<StatefulButton>
    implements StatefulButtonController {
  /// 當前是否正在開放狀態[非讀取]
  bool _isStandby;

  /// 真正控制 loading 狀態的控制器
  AnimatedSyncTick _controller;

  /// 監聽 load stream 的訂閱
  StreamSubscription _loadSubscription;

  /// 當前是否讀取中
  @override
  bool get isLoading => !_isStandby;

  /// 讀取的 style
  StateStyle get _loadStyle {
    if (widget.loadStyle == null) {
      return StateStyle(
        color: Colors.blueAccent,
        size: min(widget.width, widget.height),
      );
    }

    return widget.loadStyle;
  }

  /// 動畫時間
  Duration get _animDuration {
    if (widget.duration == null) {
      return Duration(milliseconds: 1000);
    }
    return widget.duration;
  }

  @override
  void initState() {
    _isStandby = !widget.initLoad;
    _controller = AnimatedSyncTick.identity(initToggle: _isStandby);
    // 如果有 load 狀態 stream, 進行監聽
    if (widget.loadStream != null) {
      _loadSubscription = widget.loadStream.listen((enable) {
        _isStandby = !enable;
        _syncLoadState();
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedComb(
        sync: _controller,
        curve: Curves.elasticOut,
        type: AnimatedType.toggle,
        toggleBuilder: (context, toggle) {
          return MaterialLayer.single(
            tapStyle: toggle
                ? widget.tapStyle
                : TapFeedback(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                  ),
            layer: LayerProperties(decoration: widget.decoration),
            child: AnimatedSwitcher(
              child: toggle
                  ? (widget.child ?? Container())
                  : Loading.circle(
                      size: _loadStyle.size * 3 / 4,
                      color: _loadStyle.color,
                    ),
              duration: _animDuration,
              switchInCurve: Interval(0.7, 1.0),
              switchOutCurve: Interval(0.7, 1.0),
            ),
            onTap: () {
              if (widget.onTap != null) {
                widget.onTap(this);
              }
            },
          );
        },
        animatedList: [
          Comb.width(
            begin: _loadStyle.size,
            end: widget.width,
            height: _loadStyle.size,
            duration: _animDuration.inMilliseconds ~/ 2,
          ),
          Comb.height(
            begin: _loadStyle.size,
            end: widget.height,
            width: widget.width,
            duration: _animDuration.inMilliseconds ~/ 2,
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
    _isStandby = !load;
    _syncLoadState();
  }

  @override
  void dispose() {
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

  StateStyle({this.color, this.size});
}
