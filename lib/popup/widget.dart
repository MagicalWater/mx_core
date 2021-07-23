part of 'impl.dart';

class _DetectWidget extends SingleChildRenderObjectWidget {
  _DetectWidget({
    Key? key,
    Widget? child,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _DetectBox(null);
  }
}

class _DetectBox extends RenderShiftedBox {
  _DetectBox(RenderBox? child) : super(child);

  @override
  void performLayout() {
    child?.layout(constraints, parentUsesSize: false);
    size = Size(
      constraints.maxWidth,
      constraints.maxHeight,
    );
  }
}

class _TapWidget extends SingleChildRenderObjectWidget {
  final HitRule hitRule;

  _TapWidget({
    Key? key,
    Widget? child,
    required this.hitRule,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _TapBox(hitRule: hitRule);
  }
}

class _TapBox extends RenderShiftedBox {
  final HitRule hitRule;

  _TapBox({
    RenderBox? child,
    required this.hitRule,
  }) : super(child);

  @override
  void performLayout() {
    child?.layout(constraints, parentUsesSize: false);
    size = Size(
      constraints.maxWidth,
      constraints.maxHeight,
    );
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (!hasSize) {
      // 如果尚未有 size, 依照正常會拋出錯誤
      // 這邊不處理直接往上丟
      return super.hitTest(result, position: position);
    }

    // 我們要處理除了目標之外的所有點擊, 目標是點擊穿透
//    print('是否接受點擊: $position');

    switch (hitRule) {
      case HitRule.through:
        // 完全穿透
        return false;
      case HitRule.childIntercept:
        // 子元件不穿透, 其餘穿透
        if (child!.size.contains(position)) {
          // 在子元件範圍
          // 檢查結果列表是否包含 _DetectBox
          var resultHandle = super.hitTest(result, position: position);
          var isDetected = result.path
              .whereType<BoxHitTestEntry>()
              .any((e) => e.target is _DetectBox);
//          print("是否包含需要檢測的子元件: $isDetected");
          if (isDetected) {
            return resultHandle;
          } else {
            (result.path as List).clear();
//            print("清除結果: ${result.path.length}");
            return false;
          }
        }
        return false;
      case HitRule.intercept:
        // 完全攔截
        return super.hitTest(result, position: position);
    }
  }
}
