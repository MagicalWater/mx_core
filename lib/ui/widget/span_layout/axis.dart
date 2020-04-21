//part of 'layout.dart';
//
//class SpanExpanded extends StatelessWidget {
//  final Widget child;
//  final int flex;
//
//  SpanExpanded({
//    this.child,
//    this.flex = 1,
//  });
//
//  @override
//  Widget build(BuildContext context) {
//    if (_SpanExpandedInherited.of(context).isExpand) {
//      return Expanded(
//        flex: flex,
//        child: child,
//      );
//    } else {
//      return child;
//    }
//  }
//}
//
///// 在此處若需要在元件對其實自動填補空餘位置
///// 使用 [SpanExpanded] 元件代替 [Expanded]
///// 參數與用法完全一樣
//class SpanX extends StatefulWidget {
//  /// 第 x 的位置, null 代表自動
//  final int span;
//
//  /// 回傳需要構建的紫元件
//  /// 若有元件擴展的需求, 則在元件裡面加入 [SpanExpanded] 元件
//  /// 效果如同 [Expanded]
//  final Widget child;
//
//  SpanX({
//    this.child,
//    this.span = 1,
//  });
//
//  @override
//  _SpanXState createState() => _SpanXState();
//}
//
//class _SpanXState extends State<SpanX> {
//  StreamController<double> heightStreamController = StreamController();
//  Size _currentSize;
//
//  SpanGridState _parentWidgetState;
//
//  @override
//  void initState() {
//    var parentWidget = context.findAncestorStateOfType<SpanGridState>();
//    parentWidget.registerWidget(
//      this.widget,
//      SpanHandler(heightCheck: expendAnim, sizeGet: currentSize),
//    );
//    super.initState();
//  }
//
//  /// 執行伸展動畫
//  void expendAnim(double heightShould) {
////    print("賦值: $heightShould");
//    heightStreamController.add(heightShould);
//  }
//
//  Size currentSize() => _currentSize;
//
//  @override
//  Widget build(BuildContext context) {
//    return Stack(
//      children: <Widget>[
//        NotificationListener<_SizeAllLayoutNotification>(
//          child: _SizeAllLayoutNotifier(
//            child: IndexedStack(
//              index: 0,
//              children: <Widget>[
//                Container(
//                  width: 0,
//                  height: 0,
//                ),
//                _SpanExpandedInherited(
//                  isExpand: false,
//                  child: widget.child,
//                ),
//              ],
//            ),
//          ),
//          onNotification: (notification) {
////            print("size = ${notification.size}");
//            _currentSize = notification.size;
//            heightStreamController.add(0);
//            return false;
//          },
//        ),
//        StreamBuilder<double>(
//          stream: heightStreamController.stream,
//          builder: (context, snapshot) {
//            if (!snapshot.hasData || snapshot.data == 0) {
//              return Container(
//                width: 0,
//                height: 0,
//              );
//            } else {
//              var clipSize = Size(_currentSize.width, snapshot.data);
//              return SizedBox(
//                width: clipSize.width,
//                height: clipSize.height,
//                child: ClipOverflow(
//                  child: _SpanExpandedInherited(
//                    isExpand: true,
//                    child: widget.child,
//                  ),
//                ),
//              );
//            }
//          },
//        ),
//      ],
//    );
//  }
//
//  @override
//  String toString({DiagnosticLevel minLevel = DiagnosticLevel.debug}) {
//    return "VerticalSpan.toString()";
//  }
//
//  @override
//  void deactivate() {
//    var tempFinded = context.findAncestorStateOfType<SpanGridState>();
//    if (tempFinded != null) {
//      _parentWidgetState = tempFinded;
//    }
//    super.deactivate();
//  }
//
//  @override
//  void dispose() {
//    _parentWidgetState?.unregisterWidget(this.widget);
//    heightStreamController.close();
//    super.dispose();
//  }
//}
//
//class SpanHandler {
//  ValueChanged<double> heightCheck;
//  Size Function() sizeGet;
//
//  SpanHandler({this.heightCheck, this.sizeGet});
//}
//
//class _SizeAllLayoutNotification extends LayoutChangedNotification {
//  final Size size;
//
//  _SizeAllLayoutNotification(this.size);
//}
//
//class _SizeAllLayoutNotifier extends SingleChildRenderObjectWidget {
//  _SizeAllLayoutNotifier({
//    Key key,
//    Widget child,
//  }) : super(key: key, child: child);
//
//  @override
//  _RenderSizeAllCallback createRenderObject(BuildContext context) {
//    return _RenderSizeAllCallback(onLayoutChangedCallback: (size) {
//      _SizeAllLayoutNotification(size).dispatch(context);
//    });
//  }
//}
//
//class _RenderSizeAllCallback extends RenderProxyBox {
//  _RenderSizeAllCallback({
//    RenderBox child,
//    @required this.onLayoutChangedCallback,
//  })  : assert(onLayoutChangedCallback != null),
//        super(child);
//
//  final ValueChanged<Size> onLayoutChangedCallback;
//
//  Size _oldSize;
//
//  @override
//  void performLayout() {
//    super.performLayout();
//    if (size != _oldSize) onLayoutChangedCallback(size);
//    _oldSize = size;
//  }
//}
//
//class _SpanExpandedInherited extends InheritedWidget {
//  final bool isExpand;
//
//  _SpanExpandedInherited({
//    this.isExpand = false,
//    Widget child,
//  }) : super(child: child);
//
//  static _SpanExpandedInherited of(BuildContext context) {
//    return context.dependOnInheritedWidgetOfExactType();
//  }
//
//  @override
//  bool updateShouldNotify(_SpanExpandedInherited oldWidget) {
//    return isExpand != oldWidget.isExpand;
//  }
//}
