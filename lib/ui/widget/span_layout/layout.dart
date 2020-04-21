//import 'dart:async';
//import 'dart:core';
//import 'dart:math';
//
//import 'package:flutter/foundation.dart';
//import 'package:flutter/material.dart';
//import 'package:flutter/rendering.dart';
//
//part 'axis.dart';
//
//part 'clipper.dart';
//
//part 'delegate.dart';
//
//part 'space.dart';
//
//class _LayoutErrorHook {
//  static final _singleton = _LayoutErrorHook._internal();
//
//  static _LayoutErrorHook getInstance() => _singleton;
//
//  factory _LayoutErrorHook() => _singleton;
//
//  int counter = 0;
//
//  _LayoutErrorHook._internal();
//
//  bool _isErrorHook = false;
//  FlutterExceptionHandler _defaultErrorHandler;
//
//  void increaseHookCounter() {
//    counter++;
//    _syncHookToggle();
//  }
//
//  void decreaseHookCounter() {
//    counter--;
//    if (counter < 0) counter = 0;
//    _syncHookToggle();
//  }
//
//  void _syncHookToggle() {
//    if (counter > 0) {
////      print('需要開啟 hook, 最後驗證: ${!_isErrorHook && !kReleaseMode}');
//      if (!_isErrorHook && !kReleaseMode) {
//        _isErrorHook = true;
//        _hookErrorHandle();
//      }
//    } else {
////      print('需要關閉 hook, 最後驗證: $_isErrorHook');
//      if (_isErrorHook) {
//        _isErrorHook = false;
//        _unhookErrorHandle();
//      }
//    }
//  }
//
//  void _hookErrorHandle() {
//    _defaultErrorHandler = FlutterError.onError;
//    FlutterError.onError = (FlutterErrorDetails details) {
//      var isOverflow = details.exceptionAsString().contains('overflowed');
//      if (isOverflow && details is FlutterErrorDetailsForRendering) {
//        var renderObj = details.renderObject;
//        var parentNode = renderObj.parent;
//        var isNeedHook = false;
//        while (parentNode != null) {
//          if (parentNode.runtimeType == _ClipOverflowRenderBox) {
//            isNeedHook = true;
//            break;
//          }
//          parentNode = parentNode.parent;
//        }
//        if (isNeedHook) {
//          return;
//        }
//      }
//      _defaultErrorHandler(details);
//    };
//  }
//
//  void _unhookErrorHandle() {
//    FlutterError.onError = _defaultErrorHandler;
//    _defaultErrorHandler = null;
//  }
//}
//
///// 直式 grid 佈局, 可設置 x 的 span
//class SpanGrid extends StatefulWidget {
//  /// 針對方向總共要切成幾等分
//  final int segmentCount;
//
//  /// 可帶入一般 Widget, 也可帶入 SpanX, 若帶入 SpanX 則可再設置 x 的跨欄寬度
//  final List<SpanX> children;
//
//  final EdgeInsets padding;
//
//  /// y軸每列空隙
//  final double ySpace;
//
//  /// x軸每行空隙
//  final double xSpace;
//
//  final Color color;
//
//  /// 是否處於一個無限高度的元件底下
//  final bool inInfinityHeightContainer;
//
//  /// 預期最大高度
//  final double estimatedMaxHeight;
//
//  /// 排列方向
//  final Axis direction;
//
//  /// 對齊
//  final SizeAlign sizeAlign;
//
//  SpanGrid({
//    this.padding,
//    this.color,
//    this.direction = Axis.vertical,
//    this.sizeAlign = SizeAlign.free,
//    @required this.segmentCount,
//    @required this.children,
//    this.xSpace,
//    this.ySpace,
//    this.inInfinityHeightContainer = false,
//    this.estimatedMaxHeight = 2000,
//  });
//
//  @override
//  SpanGridState createState() => SpanGridState();
//}
//
//class SpanGridState extends State<SpanGrid> {
//  double heightCompute;
//
//  List<SpanHandler> animMap = [];
//
//  @override
//  void initState() {
//    _LayoutErrorHook.getInstance().increaseHookCounter();
//    super.initState();
//  }
//
//  @override
//  void dispose() {
//    _LayoutErrorHook.getInstance().decreaseHookCounter();
//    super.dispose();
//  }
//
//  void registerWidget(Widget child, SpanHandler handler) {
//    var index = widget.children.indexOf(child);
//    if (index >= animMap.length) {
//      for (var i = animMap.length; i <= index; i++) {
//        animMap.add(null);
//      }
//    }
//
//    animMap[index] = handler;
//  }
//
//  void unregisterWidget(Widget child) {
//    var index = widget.children.indexOf(child);
//    if (index != -1) {
//      animMap[index] = null;
//    }
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    if (widget.children.isEmpty) return Container();
//
//    Widget widgetChain = Align(
//      child: Flow(
//        delegate: _VerticalDelegate(
//          xSpace: widget.xSpace,
//          ySpace: widget.ySpace,
//          items: widget.children,
//          sizeAlign: widget.sizeAlign,
//          segmentCount: widget.segmentCount,
//          inInfinityHeightContainer: widget.inInfinityHeightContainer,
//          estimatedMaxHeight: widget.estimatedMaxHeight,
//          updateHandler: (height) {
////              print("設置高度 updateHandler: ${height}");
//            if (height != null) {
//              heightCompute = height;
//            }
//            WidgetsBinding.instance.addPostFrameCallback((_) {
//              setState(() {});
//            });
//          },
//          animMap: animMap,
//          onPainted: (height) {
//            if (widget.inInfinityHeightContainer && heightCompute != height) {
////                print("設置高度 onPainted: ${height}");
////                oriHeight = heightCompute;
//              heightCompute = height;
//              WidgetsBinding.instance.addPostFrameCallback((_) {
//                setState(() {});
//              });
//              return false;
//            } else {
//              return true;
//            }
//          },
//        ),
//        children: widget.children,
//      ),
//    );
//
//    if (widget.inInfinityHeightContainer) {
//      widgetChain = Container(
//        height: heightCompute ?? widget.estimatedMaxHeight,
//        child: widgetChain,
//      );
//    }
//
//    return widgetChain;
//  }
//}
//
///// size 對齊
//enum SizeAlign {
//  max,
//  min,
//  free,
//}
//
////Iterable<String> tt(int n) sync* {
////  print('begin');
////  String k = 0;
////  while(k < n) yield k++;
////  print('end');
////}
