//part of 'layout.dart';
//
//class _VerticalDelegate extends FlowDelegate {
//  /// 元件
//  List<SpanX> items;
//
//  _VerticalSpaceCompute spaceCompute;
//
//  List<_VerticalSpace> _spaces = [];
//
//  // 儲存舊的 child size
//  List<Size> _childSize = [];
//
//  List<ChildChanged> _childChanged = [];
//
//  int segmentCount;
//
//  /// 繪製完成
//  bool Function(double height) onPainted;
//
//  /// 外部需要更新高度
//  ValueChanged<double> updateHandler;
//
//  bool _needUpdate = false;
//
//  bool _needRepaint = false;
//
//  SizeAlign sizeAlign;
//
//  /// 是否處於一個無限高度的元件底下
//  final bool inInfinityHeightContainer;
//
//  /// 預期最大高度
//  final double estimatedMaxHeight;
//
//  List<SpanHandler> animMap;
//
//  _VerticalDelegate({
//    double xSpace,
//    double ySpace,
//    this.sizeAlign,
//    this.items,
//    this.segmentCount,
//    this.updateHandler,
//    this.inInfinityHeightContainer,
//    this.estimatedMaxHeight,
//    this.onPainted,
//    this.animMap,
//  }) : spaceCompute = _VerticalSpaceCompute(
//          xSpace: xSpace ?? 0,
//          ySpace: ySpace ?? 0,
//        );
//
//  @override
//  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) {
////    print("是否處於無限高度: $inInfinityHeightContainer");
//    if (spaceCompute.totalWidth != null && spaceCompute.totalHeight != null) {
////      print("擺放 constraint");
//      return constraints.copyWith(
//        minWidth: spaceCompute.segmentWidth,
//        maxWidth: spaceCompute.segmentWidth,
//        maxHeight: inInfinityHeightContainer ? estimatedMaxHeight : null,
//      );
//    } else {
////      print("預設 constraint");
//      return super.getConstraintsForChild(i, constraints);
//    }
//  }
//
//  @override
//  Size getSize(BoxConstraints constraints) {
//    if (spaceCompute.totalWidth != null && spaceCompute.totalHeight != null) {
////      print("擺放 size");
//      return constraints
//          .copyWith(
//            maxHeight: inInfinityHeightContainer ? estimatedMaxHeight : null,
//          )
//          .biggest;
//    } else {
////      print("預設 size");
//      return constraints.biggest;
//    }
//  }
//
//  @override
//  void paintChildren(FlowPaintingContext context) {
//    // 先取得裝載widget的總寬度
//    final totalWidth = context.size.width;
//    final totalHeight = context.size.height;
//
//    // 屬性是否變更
//    final isTotalDiff = spaceCompute.setTotal(
//      totalWidth,
//      inInfinityHeightContainer ? estimatedMaxHeight : totalHeight,
//      segmentCount,
//    );
//
//    final allChildSize = getChildSize(context);
//
//    for (int i = 0; i < allChildSize.length; i++) {
//      animMap[i].heightCheck(allChildSize[i].height);
//    }
//
//    if (isTotalDiff) {
////      print("總高度不同, 重繪");
//      resetSpace(allChildSize, context);
//      markNeedUpdate();
//      return;
//    } else {
//      final isSizeDiff = !isChildSizeSame(allChildSize);
//      if (isSizeDiff) {
////        print("有 size 不同");
////        print("size 前後不同");
//        resetSpace(allChildSize, context);
////        markNeedUpdate();
////        return;
//      } else {
////        print("size 全相同");
//      }
//    }
//
//    var maxHeight = getMaxHeight();
//
//    if (onPainted(maxHeight)) {
//      _childChanged.clear();
//      _childChanged.removeWhere((e) => e.progress == 1);
//      var markRepaint = _childChanged.any((e) => e.progress != 1);
//      for (int i = 0; i < context.childCount; i++) {
//        _VerticalSpace space = _spaces[i];
//        var matrix = Matrix4.identity();
//        matrix.translate(
//          space.x * spaceCompute.segmentWidth + space.x * spaceCompute.xSpace,
//          space.realY,
//        );
//
////          print("第 $i 個元件起始y = ${space.realY}, 終點y = ${space.realY + space.height}");
//
//        var changed = _childChanged.firstWhere(
//          (e) => e.index == i,
//          orElse: () => null,
//        );
//
//        if (changed != null) {
//          var bounceProgress =
//              ((0.5 - changed.progress).abs() * 2).clamp(0.0, 1.0);
////            print("進度: $bounceProgress");
//          matrix.scale(1.0, bounceProgress);
//          context.paintChild(
//            i,
//            transform: matrix,
//            opacity: 1,
//          );
//
//          if (changed.progress >= 1) {
//            changed.progress -= 0.05;
//          } else {
//            changed.progress += 0.05;
//          }
//
//          // 防止double相加後丟失精準度
//          changed.progress =
//              double.tryParse(changed.progress.toStringAsFixed(2));
//        } else {
//          context.paintChild(
//            i,
//            transform: matrix,
//          );
//        }
//      }
//
//      if (markRepaint) {
//        _needRepaint = true;
//        updateHandler(null);
//      }
//    }
//  }
//
//  void resetSpace(List<Size> allChildSize, FlowPaintingContext context) {
//    spaceCompute._resetSpace();
//
//    // 總屬性改變, 或者子元件 size 不同, 都需要重新計算空間
//    _spaces.clear();
//    _childSize = allChildSize;
//
//    // 開始依照屬性計算每個位置
//    for (int i = 0; i < context.childCount; i++) {
////      final childSize = context.getChildSize(i);
//      final spanInfo = items[i];
//      if (_spaces.length <= i) {
//        var space = spaceCompute.getFreeSpace(
//          spanInfo,
//          allChildSize[i].height,
//        );
//        _spaces.add(space);
//      }
//    }
//  }
//
//  /// 取得新舊兩個 child size 是否一樣
//  bool isChildSizeSame(List<Size> newSize) {
//    var isSame = true;
//    if (_childSize.length != newSize.length) {
//      print("size長度不同: ${_childSize.length} <> ${newSize.length}");
//      isSame = false;
//    } else {
//      for (int i = 0; i < _childSize.length; i++) {
//        var oSize = _childSize[i];
//        var nSize = newSize[i];
//        if (oSize != nSize) {
////          print("特定size不同: index = $i, ori = $oSize, new = $nSize");
//          var oldChanged =
//              _childChanged.firstWhere((e) => e.index == i, orElse: () => null);
//          isSame = false;
//          if (oldChanged != null) {
//            oldChanged.newSize = nSize;
//          } else {
//            var changed = ChildChanged(
//              currentSize: oSize,
//              newSize: nSize,
//              index: i,
//            );
//            _childChanged.add(changed);
//          }
////          print("size直接不同: $oSize <> $nSize");
//        }
//      }
//
////      print("檢測到不同");
////      _childChanged.forEach((e) {
////        var widget = items[e.index];
////        animMap[widget]();
////      });
//    }
//    return isSame;
//  }
//
//  List<Size> getChildSize(FlowPaintingContext context) {
//    List<Size> sizes = [];
//    double maxSize;
//    double minSize;
//    for (int i = 0; i < context.childCount; i++) {
//      final size = animMap[i].sizeGet();
//      maxSize = max(maxSize ?? 0.0, size.height);
//      if (minSize != null) {
//        minSize = min(minSize, size.height);
//      } else {
//        minSize = size.height;
//      }
//      sizes.add(size);
//    }
//    switch (sizeAlign) {
//      case SizeAlign.max:
//        sizes = sizes.map((e) => Size(e.width, maxSize)).toList();
//        break;
//      case SizeAlign.min:
//        sizes = sizes.map((e) => Size(e.width, minSize)).toList();
//        break;
//      default:
//        break;
//    }
//    return sizes;
//  }
//
//  void markNeedUpdate() {
//    _needUpdate = true;
//    updateHandler(getMaxHeight());
//  }
//
//  void paintComplete() {
//    onPainted(getMaxHeight());
//  }
//
//  double getMaxHeight() {
//    var maxHeight = 0.0;
//    _spaces.forEach((e) {
//      maxHeight = max(maxHeight, e.y + e.height);
//    });
////    print("在 ${_spaces.length} 個空間取最高 - $maxHeight");
//    return maxHeight;
//  }
//
//  bool updateRelayout(FlowDelegate oldDelegate) {
//    if (oldDelegate is _VerticalDelegate) {
//      this.spaceCompute = oldDelegate.spaceCompute;
//      this._spaces = oldDelegate._spaces;
//      this._childSize = oldDelegate._childSize;
//      this._childChanged = oldDelegate._childChanged;
//      return oldDelegate._needUpdate;
//    }
//    return false;
//  }
//
//  bool updateRepaint(FlowDelegate oldDelegate) {
//    if (oldDelegate is _VerticalDelegate) {
//      this.spaceCompute = oldDelegate.spaceCompute;
//      this._spaces = oldDelegate._spaces;
//      this._childSize = oldDelegate._childSize;
//      this._childChanged = oldDelegate._childChanged;
//      return oldDelegate._needRepaint;
//    }
//    return false;
//  }
//
//  @override
//  bool shouldRelayout(FlowDelegate oldDelegate) {
////    print("是否需要更新: ${(oldDelegate as _VerticalDelegate)._needUpdate}");
//    return updateRelayout(oldDelegate);
//  }
//
//  /// 是否需要重新繪製
//  @override
//  bool shouldRepaint(FlowDelegate oldDelegate) {
////    print("是否需要繪製: ${(oldDelegate as _VerticalDelegate)._needUpdate}");
//    return updateRepaint(oldDelegate);
//  }
//}
//
//class ChildChanged {
//  Size newSize;
//  int index;
//
//  Size currentSize;
//
//  double progress;
//
//  bool get isAnimatedEnd => progress == 1;
//
//  ChildChanged({this.currentSize, this.newSize, this.index})
//      : this.progress = 0 {
////    print("當前高度: $currentSize, 新高度: $newSize");
////    var scoff = currentSize.height / newSize.height;
////    var initProgress = double.tryParse(scoff.toStringAsFixed(1));
////    progress = initProgress;
//  }
//}
