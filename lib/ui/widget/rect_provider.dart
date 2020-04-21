import 'dart:async';

import 'package:flutter/widgets.dart';

/// 封裝好取得 widget 的 rect
/// <p> 原作者: best-flutter </p>
/// <p> 參考: https://github.com/best-flutter/binding_helper </p>
/// <p> 共有兩種方式可取得 rect </p>
/// <p> 修改者: Water </p>
/// 1. RectProviderMixin => 取得自己的 rect
/// 2. RectProvider => 取得子元件的 rect
mixin RectProviderMixin<T extends StatefulWidget> on State<T> {
  StreamController<Rect> _rectController = StreamController();

  Stream<Rect> get widgetRectStream => _rectController.stream;

  Rect _widgetRect;

  Rect get widgetRect => _widgetRect;

  /// 延遲多久取得 rect, 一般延遲越久越準確
  Duration delayGetRect() => Duration(milliseconds: 300);

  @override
  void didUpdateWidget(T oldWidget) {
    _rectDetect();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    _rectDetect();
    super.didChangeDependencies();
  }

  Future<void> _rectDetect() async {
    var rect = await getWidgetRect(context, delay: delayGetRect());
    if (rect != null) {
      if (_widgetRect != null && rect == _widgetRect) {
        return;
      }
      _widgetRect = rect;
      _rectController.add(rect);
    }
  }

  void clearWidgetRect() {
    _widgetRect = null;
  }

  @override
  void dispose() {
    _rectController.close();
    super.dispose();
  }
}

/// 在取得 child 的 Rect 時會回調 [onGetRect]
class RectProvider extends StatefulWidget {
  final Widget child;

  final void Function(Rect rect) onRect;

  final void Function(Stream<Rect> rectStream) onCreated;

  final Duration delayGetRect;

  RectProvider({
    @required this.child,
    this.onCreated,
    this.onRect,
    this.delayGetRect,
  });

  @override
  State<StatefulWidget> createState() {
    return _RectProviderState();
  }
}

class _RectProviderState extends State<RectProvider>
    with RectProviderMixin<RectProvider> {
  StreamSubscription subscription;

  @override
  Duration delayGetRect() {
    return widget.delayGetRect ?? super.delayGetRect();
  }

  @override
  void initState() {
    if (widget.onCreated != null) {
      widget.onCreated(widgetRectStream);
    }
    if (widget.onRect != null) {
      subscription = widgetRectStream.listen((rect) {
        widget.onRect(rect);
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }
}

/// 取得元件的rect
/// 若 [delay] 不為 null, 則會進行等待一定時間後再進行 rect 的獲取
/// 因此會需要等待
FutureOr<Rect> getWidgetRect(
  BuildContext context, {
  Duration delay,
}) async {
  Rect rect;
  if (delay != null) {
    await Future.delayed(delay);
  }
  RenderBox renderObject = context?.findRenderObject();
  if (renderObject != null && renderObject.attached && renderObject.hasSize) {
    Size size = renderObject.paintBounds.size;
    var vector3 = renderObject.getTransformTo(null)?.getTranslation();
    rect = Rect.fromLTWH(vector3?.x, vector3?.y, size?.width, size?.height);
  }
  return rect;
}
