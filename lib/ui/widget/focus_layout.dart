import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mx_core/util/screen_util.dart';
import 'package:rxdart/rxdart.dart';

import 'timer/timer_core.dart';

/// 以 column 形式表現以及排序的 view
/// 通常需要在此外層包裹 [SingleChildScrollView]
class FocusLayout extends StatefulWidget {
  final List<Widget> children;

  /// 控制是否專注在某個 view
  final FocusController? controller;

  FocusLayout({
    required this.children,
    this.controller,
  });

  @override
  _FocusLayoutState createState() => _FocusLayoutState();
}

class _FocusLayoutState extends State<FocusLayout> implements FocusDelegate {
  PublishSubject<bool> _debounceSubject = PublishSubject();
  late TimerCore countdownDebounce;
  late StreamSubscription _subscription;

  bool _currentFocus = false;

  @override
  bool get isFocus => _currentFocus;

  set isFocus(bool _isFocus) {
    _currentFocus = _isFocus;
    _syncSystemUi();
  }

  @override
  void initState() {
    countdownDebounce = TimerCore(
      totalTime: Duration(seconds: 1),
      tickInterval: Duration(seconds: 3),
    );
    _delaySet();
    widget.controller?._bind(this);
    super.initState();
  }

  void _syncSystemUi() {
//    MediaQueryData mediaQuery = MediaQueryData.fromWindow(ui.window);
    if (_currentFocus) {
      _debounceSubject.add(true);
    } else {
      _debounceSubject.add(false);
    }
  }

  void _delaySet() {
    _subscription = _debounceSubject.stream.debounce((data) {
      if (countdownDebounce.status != TimerStatus.active) {
        countdownDebounce.start();
        return Stream.value(data);
      }

      return TimerStream(data, countdownDebounce.remainingTime);
    }).doOnData((data) {
      if (data) {
        print('配置全螢幕');
        SystemChrome.setEnabledSystemUIOverlays([]);
      } else {
        print('配置局部螢幕');
        SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
      }
    }).listen(null);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<bool>(
        stream: _debounceSubject.stream,
        builder: (context, snapshot) {
          List<Widget> children;
          print('當前: $_currentFocus');
          if (_currentFocus) {
            children = _convertChildren(focusHeight: Screen.height);
          } else {
            children = _convertChildren();
          }
          return Column(
            children: children,
          );
        },
      ),
    );
  }

  List<Widget> _convertChildren({double? focusHeight}) {
    return widget.children.map((e) {
      if (e is FocusChild) {
        var child = e.child;
        if (child is Expanded) {
          return SizedBox(
            height: focusHeight ?? e.height,
            child: child.child,
          );
        }
        return SizedBox(
          height: focusHeight ?? e.height,
          child: child,
        );
      } else {
        return e;
      }
    }).toList();
  }

  @override
  void dispose() {
    countdownDebounce.dispose();
    _debounceSubject.close();
    _subscription.cancel();
    super.dispose();
  }
}

class FocusChild extends StatelessWidget {
  final double? height;
  final Widget child;

  FocusChild({Key? key, required this.child, this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class FocusController implements FocusDelegate {
  FocusDelegate? _delegate;

  void _bind(FocusDelegate delegate) {
    _delegate = delegate;
  }

  @override
  bool get isFocus => _delegate?.isFocus ?? false;

  @override
  set isFocus(bool _isFocus) {
    _delegate?.isFocus = _isFocus;
  }
}

abstract class FocusDelegate {
  late bool isFocus;
}
