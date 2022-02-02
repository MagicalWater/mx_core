import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'multi_touch_drag.dart';

/// 多點觸控手勢
class MultiTouchGestureRecognizer extends MultiDragGestureRecognizer {
  final void Function(int pointer, DragStartDetails details)? onTouchDown;
  final void Function(int pointer)? onTouchCancel;

  /// 用於取得裝載此按鍵處理的RawGestureDector
  /// 目的是將globalPostion轉化為localPosition
  final GlobalKey<RawGestureDetectorState>? transformPositionKey;

  MultiTouchGestureRecognizer({
    required this.transformPositionKey,
    Object? debugOwner,
    Set<PointerDeviceKind>? supportedDevices,
    this.onTouchDown,
    void Function(int pointer, DragUpdateDetails details)? onTouchUpdate,
    void Function(int pointer, DragEndDetails details)? onTouchUp,
    this.onTouchCancel,
  }) : super(
          debugOwner: debugOwner,
          supportedDevices: supportedDevices,
        ) {
    onStart = (offset) {
      final eventEntry = _pointerEvent.entries
          .firstWhere((element) => element.value.position == offset);
      final pointer = eventEntry.key;

      // 自暫存移除事件
      _pointerEvent.remove(pointer);

      return MultiTouchDrag(
        pointer: pointer,
        onUpdate: (details) {
          // 由於MultiDragGestureRecognizer的拖拉訊息缺少local
          // 因此獲取到的位置將會是global的, 在此需要進行轉化
          final renderBox = transformPositionKey?.currentContext
              ?.findRenderObject() as RenderBox?;
          final Offset localPosition;
          if (renderBox != null) {
            localPosition = renderBox.globalToLocal(details.globalPosition);
          } else {
            localPosition = details.localPosition;
          }
          onTouchUpdate?.call(
            pointer,
            DragUpdateDetails(
              sourceTimeStamp: details.sourceTimeStamp,
              delta: details.delta,
              primaryDelta: details.primaryDelta,
              globalPosition: details.globalPosition,
              localPosition: localPosition,
            ),
          );
        },
        onEnd: (details) {
          onTouchUp?.call(pointer, details);
        },
        onCancel: () {
          onTouchCancel?.call(pointer);
        },
      );
    };
  }

  static GestureRecognizerFactory factory({
    required GlobalKey<RawGestureDetectorState>? transformPositionKey,
    void Function(int pointer, DragStartDetails details)? onTouchStart,
    void Function(int pointer, DragUpdateDetails details)? onTouchUpdate,
    void Function(int pointer, DragEndDetails details)? onTouchEnd,
    void Function(int pointer)? onTouchCancel,
  }) {
    return GestureRecognizerFactoryWithHandlers<MultiTouchGestureRecognizer>(
      () => MultiTouchGestureRecognizer(
        transformPositionKey: transformPositionKey,
        onTouchDown: onTouchStart,
        onTouchUpdate: onTouchUpdate,
        onTouchUp: onTouchEnd,
        onTouchCancel: onTouchCancel,
      ),
      (MultiTouchGestureRecognizer instance) {},
    );
  }

  final _pointerEvent = <int, PointerDownEvent>{};

  @override
  MultiDragPointerState createNewPointerState(PointerDownEvent event) {
    _pointerEvent[event.pointer] = event;

    // print('按下囉: ${event.position}, ${event.localPosition}');

    onTouchDown?.call(
      event.pointer,
      DragStartDetails(
        sourceTimeStamp: event.timeStamp,
        globalPosition: event.position,
        localPosition: event.localPosition,
        kind: event.kind,
      ),
    );

    return _MultiTouchState(
      initialPosition: event.position,
      kind: event.kind,
      deviceGestureSettings: gestureSettings,
      onCancelWithNoDrag: () {
        _pointerEvent.remove(event.pointer);
        onTouchCancel?.call(event.pointer);
      },
    );
  }

  @override
  String get debugDescription => 'multi touch';
}

class _MultiTouchState extends MultiDragPointerState {
  /// 是否已初始化Drag
  var isDragInit = false;

  /// 尚未拖拉之前就取消了觸摸, 那麼觸摸取消手勢就會從此發出
  final VoidCallback onCancelWithNoDrag;

  _MultiTouchState({
    required Offset initialPosition,
    required PointerDeviceKind kind,
    DeviceGestureSettings? deviceGestureSettings,
    required this.onCancelWithNoDrag,
  }) : super(initialPosition, kind, deviceGestureSettings);

  @override
  void checkForResolutionAfterMove() {
    assert(pendingDelta != null);
    // 無論距離為何, 一律接受移動
    resolve(GestureDisposition.accepted);
    // if (pendingDelta!.distance > computeHitSlop(kind, gestureSettings)) {
    //   resolve(GestureDisposition.accepted);
    // }
  }

  @override
  void accepted(GestureMultiDragStartCallback starter) {
    starter(initialPosition);
    isDragInit = true;
  }

  @override
  void dispose() {
    if (!isDragInit) {
      onCancelWithNoDrag();
    }
    super.dispose();
  }
}
