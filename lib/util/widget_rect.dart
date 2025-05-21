import 'package:flutter/material.dart';

class WidgetRectResult {
  final Rect? fullRect;
  final Rect? visibleRect;

  const WidgetRectResult({
    required this.fullRect,
    required this.visibleRect,
  });

  @override
  String toString() =>
      'WidgetRectResult(fullRect: $fullRect, visibleRect: $visibleRect)';
}

class WidgetRectUtils {
  /// 取得 widget 在 **螢幕座標系** 中的位置資訊。
  ///
  /// - [fullRect]：該 widget 在螢幕中的完整位置。
  /// - [visibleRect]：該 widget 實際可見的範圍（與螢幕相交的部分），若完全不可見則為 null。
  ///
  /// 用途：當 widget 可能被遮擋或部分滾出螢幕時，可用來判斷實際可見區域。
  static WidgetRectResult rectOnScreen(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) {
      return const WidgetRectResult(fullRect: null, visibleRect: null);
    }

    final Offset topLeft = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;
    final Rect fullRect = topLeft & size;

    final Size screenSize = MediaQuery.of(context).size;
    final Rect screenRect = Offset.zero & screenSize;

    final Rect visibleRect = fullRect.intersect(screenRect);

    return WidgetRectResult(
      fullRect: fullRect,
      visibleRect: visibleRect.isEmpty ? null : visibleRect,
    );
  }

  /// 取得 widget 在其最近的 **ScrollView 座標系** 中的位置資訊。
  ///
  /// - [fullRect]：該 widget 相對於其 ScrollView 的完整位置。
  /// - [visibleRect]：該 widget 在 ScrollView 中實際可見的區域，若完全滾出可視範圍則為 null。
  ///
  /// 用途：適合用於需要得知 widget 是否被滾出視野，或只部分出現在 scrollView 中的情境。
  /// 若需要再轉為螢幕上的實際位置, 後續再自行呼叫 [WidgetRectUtils.convertToGlobalFromScroll]
  static WidgetRectResult rectInScroll(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) {
      return const WidgetRectResult(fullRect: null, visibleRect: null);
    }

    final scrollableState = Scrollable.maybeOf(context);
    if (scrollableState == null) {
      return const WidgetRectResult(fullRect: null, visibleRect: null);
    }

    final scrollBox = scrollableState.context.findRenderObject() as RenderBox?;
    if (scrollBox == null || !scrollBox.hasSize) {
      return const WidgetRectResult(fullRect: null, visibleRect: null);
    }

    final Offset topLeft =
        renderBox.localToGlobal(Offset.zero, ancestor: scrollBox);
    final Size size = renderBox.size;
    final Rect fullRect = topLeft & size;

    final Rect scrollViewRect = Offset.zero & scrollBox.size;
    final Rect visibleRect = fullRect.intersect(scrollViewRect);

    return WidgetRectResult(
      fullRect: fullRect,
      visibleRect: visibleRect.isEmpty ? null : visibleRect,
    );
  }

  /// 把 scrollView 裡的 rect 轉成螢幕上位置
  /// 若找不到上層的 scroll container 則回傳null
  static Rect? convertToGlobalFromScroll(
    BuildContext context,
    Rect localRectInScroll,
  ) {
    final scrollableState = Scrollable.maybeOf(context);
    if (scrollableState == null) {
      return null;
    }

    final scrollBox = scrollableState.context.findRenderObject() as RenderBox?;
    if (scrollBox == null || !scrollBox.hasSize) return localRectInScroll;

    final Offset scrollOriginGlobal = scrollBox.localToGlobal(Offset.zero);
    return localRectInScroll.shift(scrollOriginGlobal);
  }
}
