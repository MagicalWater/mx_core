part of 'compute.dart';

class _VerticalSpace implements _AlignSpace<_VerticalSpace> {
  int x;
  int span;

  /// 開始y軸位置
  double top;

  /// 真正開始的y軸位置
  late double realTop;

  double height;

  _VerticalSpace({
    required this.x,
    required this.top,
    this.span = 1,
    double? realTop,
    this.height = double.infinity,
  }) : this.realTop = realTop ?? top;

  /// 假如此空間可以容納 [info] 時, 取得將會佔用的空間, 否則返回 null
  @override
  _VerticalSpace? getSpaceIfContain(AlignChildInfo info, double verticalSpace) {
    // 寬度佔位不夠
    if (span < info.span) return null;

    var needHeightSpace = top != 0;

//    print('是否需要頂部高度: $needHeightSpace, 頂部起始: $top');

    // 高度有限, 需要檢查是否可以容納
    if (height.isFinite) {
      var needHeight = info.size.height;
      if (needHeightSpace) {
        needHeight += verticalSpace;
      }
      if (needHeight > height) {
        return null;
      }
    }

    return _VerticalSpace(
      x: x,
      span: info.span,
      top: top,
      realTop: needHeightSpace ? top + verticalSpace : top,
      height: info.size.height,
    );
  }

  /// 從此空間切下一部分空間, 回傳剩餘的空間
  @override
  List<_VerticalSpace> cut(_VerticalSpace other) {
    // 先檢測兩個空間是否有重疊的地方
    if (!overlaps(other)) {
      // 沒有重疊, 所以返回完整的空間
      return [this];
    }

    // 取得兩個空間重疊的 space
    _VerticalSpace intersectSpace = intersect(other);

    // 剩餘的空間
    List<_VerticalSpace> remainings = [];

    var leftSpan = intersectSpace.x - this.x;
    var topHeight = intersectSpace.top - this.top;
    var rightSpan =
        (this.x + this.span) - (intersectSpace.x + intersectSpace.span);
    var bottomHeight = (this.realTop + this.height) -
        (intersectSpace.realTop + intersectSpace.height);

    // 檢查起始點有沒有剩餘的寬度
    if (leftSpan > 0) {
//      print("左方有寬度");
      // 左邊有剩餘的寬度, 因此切掉的空間沒有接續左邊邊界
      // 因此切割的空間左邊要返回
      var leftSpace = _VerticalSpace(
        x: x,
        top: top,
        span: leftSpan,
        height: height,
      );
      remainings.add(leftSpace);
    }

    // 檢查起始點有沒有剩餘的高度
    if (topHeight > 0) {
//      print("上方有高度");
      // 上方有剩餘的寬度, 因此切掉的空間沒有接續上方邊界
      // 因此切割的空間上邊要返回
      var topSpace = _VerticalSpace(
        x: x,
        top: top,
        span: span,
        height: topHeight,
      );
      remainings.add(topSpace);
    }

    // 檢查右邊有沒有剩餘的寬度
    if (rightSpan > 0) {
//      print("右方有寬度");
      var rightSpace = _VerticalSpace(
        x: intersectSpace.x + intersectSpace.span,
        top: top,
        span: rightSpan,
        height: height,
      );
      remainings.add(rightSpace);
    }

    // 檢查下方還有沒有剩餘的寬度
    if (bottomHeight > 0) {
//      print("下方有高度");
      var bottomSpace = _VerticalSpace(
        x: x,
        top: intersectSpace.realTop + intersectSpace.height,
        span: span,
        height: bottomHeight,
      );
      remainings.add(bottomSpace);
    }

//    print("結果是: $remainings");
    return remainings;
  }

  /// 將 space 轉為 rect
  @override
  Rect toRect() {
    return Rect.fromPoints(
      Offset(x.toDouble(), top),
      Offset((x + span).toDouble(), realTop + height),
    );
  }

  /// 比較兩個空間是否有重疊
  @override
  bool overlaps(_VerticalSpace other) {
    return this.toRect().overlaps(other.toRect());
  }

  /// 取得兩個 [_VerticalSpace] 的交集
  @override
  _VerticalSpace intersect(_VerticalSpace other) {
    var rect = this.toRect().intersect(other.toRect());
    return _VerticalSpace(
      x: rect.left.toInt(),
      span: rect.right.toInt() - rect.left.toInt(),
      top: rect.top,
      height: rect.bottom - rect.top,
    );
  }

  /// 是否完全包含某個space
  @override
  bool contains(_VerticalSpace other) {
    var isXContain =
        (this.x <= other.x) && (this.x + this.span >= other.x + other.span);
    var isYContain = (this.top <= other.top) &&
        (this.realTop + this.height >= other.realTop + other.height);
    return isXContain && isYContain;
  }

  @override
  String toString() {
    return 'x: $x, span: $span, top: $realTop, height: $height';
  }

  @override
  int compareTo(_VerticalSpace other) {
    if (this.top < other.top) {
      return -1;
    } else if (this.top > other.top) {
      return 1;
    } else if (this.x > other.x) {
      return 1;
    } else if (this.x < other.x) {
      return -1;
    } else {
      return 0;
    }
  }
}
