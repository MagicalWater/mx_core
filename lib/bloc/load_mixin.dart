import 'package:flutter/cupertino.dart';
import 'package:mx_core/bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';

mixin LoadMixin  {

  BehaviorSubject<bool> get _lazyLoadSubject {
    return _loadSubject ??= BehaviorSubject();
  }

  /// LoadProvider loading 狀態串流
  BehaviorSubject<bool> _loadSubject;

  /// 當前一般元件的 loading 狀態
  bool get currentLoadState {
    return _lazyLoadSubject.value ?? false;
  }

  /// LoadProvider subject 以及 stream
  Stream<bool> get loadStream {
    return _lazyLoadSubject.stream;
  }

  /// 一般元件 loading 狀態
  void setLoadState(bool state) {
    _lazyLoadSubject.add(state);
  }

  Future<void> loadDispose() async {
    _loadSubject?.drain();
    _loadSubject?.close();
    _loadSubject = null;
  }
}