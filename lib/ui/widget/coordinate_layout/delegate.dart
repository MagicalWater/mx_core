part of 'layout.dart';

class _CoordinateDelegate extends FlowDelegate {
  ValueChanged<double> onUpdate;

  final int segmentCount;

  /// child 列表, 包含需要的位置資訊
  List<AxisItem> items;

  /// 每個 item 對應的 [_Space]
  List<_Space> _spaces = [];

  /// 空間位置計算資訊
  _SpaceCompute _spaceCompute = _SpaceCompute();

  /// 每列的高度, 沒有意外將以第 0 個child為主
  double rowHeight;

  /// 每行的寬度
  double columnWidth;

  /// 空隙高度
  double ySpace;

  /// 空隙寬度
  double xSpace;

  /// 是否需要重繪
  bool needReLayout = false;

  /// 資料是否和舊有的不同
  final bool isDataDifference;

  /// 共佔用的高度
  double allHeight;

  /// 最後一個 child 是否佔滿剩下的空間
  bool lastFillWidth;

  _CoordinateDelegate({
    this.segmentCount,
    this.items,
    this.onUpdate,
    this.rowHeight,
    this.isDataDifference,
    this.lastFillWidth,
    double ySpace,
    double xSpace,
  })  : this.ySpace = ySpace ?? 0,
        this.xSpace = xSpace ?? 0;

  /// 針對每個 child 的 constraint 再予以複寫
  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) {
    var maxWidth, maxHeight;
    var itemIndex = i;
    var item = items[itemIndex];
    if (rowHeight != null) {
      if (_spaces.length > itemIndex) {
        maxHeight = _spaces[itemIndex].ySpan * rowHeight +
            (_spaces[itemIndex].ySpan - 1) * ySpace;
      } else {
        maxHeight = item.ySpan * rowHeight + (item.ySpan - 1) * ySpace;
      }
    }
    if (columnWidth != null) {
      if (_spaces.length > itemIndex) {
        maxWidth = _spaces[itemIndex].xSpan * columnWidth +
            (_spaces[itemIndex].xSpan - 1) * xSpace;
      } else {
        maxWidth = item.xSpan * columnWidth + (item.xSpan - 1) * xSpace;
      }
    }
//    print("打印: ${maxWidth}, ${maxHeight}, ${constraints}");
//    print(
//        "設置 $i 約束: ${constraints.copyWith(minWidth: maxWidth, minHeight: maxHeight, maxWidth: maxWidth, maxHeight: maxHeight)}}");
    return constraints.copyWith(
        minWidth: maxWidth,
        minHeight: maxHeight,
        maxWidth: maxWidth,
        maxHeight: maxHeight);
  }

  /// 給定每個 child size, 若 size 不能符合 constraint
  /// 則會盡可能接近
  @override
  Size getSize(BoxConstraints constraints) {
    return constraints.biggest;
  }

  /// 繪製每個 child 應該存在的位置
  @override
  void paintChildren(FlowPaintingContext context) {
    // 先取得裝載widget的總寬度
    final totalWidth = context.size.width;
    final totalHeight = context.size.height;

    // 每段的寬度需要更新
    var newColumnWidth =
        (totalWidth - (segmentCount - 1) * xSpace) / segmentCount;
    if (columnWidth != newColumnWidth) {
      columnWidth = newColumnWidth;
      needReLayout = true;
      onUpdate(null);
      return;
    }

    // 每個分段的寬度
    columnWidth = (totalWidth - (segmentCount - 1) * xSpace) / segmentCount;

//    _spaces.clear();

    needReLayout = false;

    if (context.childCount > 0 && rowHeight == null) {
      // 沒有指定高度, 因此遍歷 children, 取得以哪個 children 為主
      for (var i = 0; i < context.childCount; i++) {
        if (items[i].heightBase) {
          rowHeight = context.getChildSize(i).height;
//          print("指定高度基底: ${i} = $rowHeight");
        }
//        print("高度: ${i} = ${context.getChildSize(i).height}");
      }

      // 沒有 children 指定為準的高度, 默認取用第一個
      if (rowHeight == null) {
        rowHeight = context.getChildSize(0).height;
      }

//      print(
//          "GridDelegate rowHeight 無值, 初始化設置, 並設置 needLayout 為 true: ${rowHeight}");

      needReLayout = true;
    }

    // 設定初始屬性
    _spaceCompute.setTotal(totalWidth, totalHeight, segmentCount, rowHeight);

    // 開始依照屬性計算每個位置
    for (int i = 0; i < context.childCount; i++) {
//      final childSize = context.getChildSize(i);
      final gridInfo = items[i];
//      print("開始計算位置: $i: ${gridInfo.x}, ${gridInfo.y}");
      if (_spaces.length <= i) {
        _Space space = _spaceCompute.getFreeSpace(
          gridInfo,
          i == (context.childCount - 1) ? lastFillWidth : false,
        );
        _spaces.add(space);
      }
    }

    // 遍歷所有空間, 取得最高的高度
    double maxHeight = 0;

    _spaces.forEach((e) {
      var itemHeight =
          (e.y * rowHeight) + (e.ySpan * rowHeight) + (e.y * ySpace);
      maxHeight = max(maxHeight, itemHeight);
    });

    // 假如 maxHeight 不同於 allHeight, 也要進行畫面更新
    if (allHeight != maxHeight) {
      allHeight = maxHeight;
      needReLayout = true;
    }

    // 計算完畢, 開始進行繪製
    // 若畫面需要刷新, 則不進行繪製
    if (!needReLayout && !_spaces.any((e) => e.isForce)) {
      print("開始繪製");
      for (int i = 0; i < context.childCount; i++) {
        _Space space = _spaces[i];
        context.paintChild(
          i,
          transform: Matrix4.translationValues(
            space.x * columnWidth + space.x * xSpace,
            space.y * rowHeight + space.y * ySpace,
            0,
          ),
        );
      }
    } else {
      print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
      print(
          "畫面需要刷新, 不繪製: need = $needReLayout, space = ${_spaces.any((e) => e.isForce)}");
    }

    if (needReLayout || _spaces.any((e) => e.isForce)) {
//      print("因為有強制變更的, 需要重新更新");
      _spaces.forEach((e) => e.isForce = false);
      needReLayout = true;
      onUpdate(allHeight);
    }
  }

  /// 確認是否重新布局以及繼承資料
  bool _needRelayout(_CoordinateDelegate old) {
//    void inheritData() {
//      print("新的 rowHeight = ${rowHeight}, 舊有: ${old.rowHeight}");
//
//      this._spaces = old._spaces;
//      this._spaceCompute = old._spaceCompute;
//      this.rowHeight = old.rowHeight;
//      this.columnWidth = old.columnWidth;
//      this.allHeight = old.allHeight;
//
//      print("置換後新的 rowHeight = ${rowHeight}, 舊有: ${old.rowHeight}");
//    }

    if (isDataDifference) {
      print("資料不同, 不繼承舊有資料, 需要刷新");
      return true;
    } else {
      print("資料相同, 繼承舊有資料, 是否刷新: ${old.needReLayout}");
//      inheritData();

      // 依據舊有的 [needRelayout] 參數決定是否刷新
      return old.needReLayout;
    }
  }

  @override
  bool shouldRelayout(FlowDelegate oldDelegate) {
    var old = oldDelegate as _CoordinateDelegate;
    return _needRelayout(old);
  }

  /// 是否需要重新繪製
  @override
  bool shouldRepaint(FlowDelegate oldDelegate) {
    var old = oldDelegate as _CoordinateDelegate;
    return _needRelayout(old);
  }
}