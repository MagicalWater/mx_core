part of 'compute.dart';

class _HorizontalSpace implements _AlignSpace<_HorizontalSpace> {
  int y;
  int span;

  /// 開始y軸位置
  double left;

  /// 真正開始的y軸位置
  double realLeft;

  double width;

  _HorizontalSpace({
    this.y,
    this.span,
    this.left,
    this.realLeft,
    this.width = double.infinity,
  }) {
    if (realLeft == null) this.realLeft = left;
  }

  /// 假如此空間可以容納 [info] 時, 取得將會佔用的空間, 否則返回 null
  @override
  _HorizontalSpace getSpaceIfContain(AlignChildInfo info, double space) {
    // 寬度佔位不夠
    if (span < info.span) return null;

    var needWidthSpace = left != 0;

//    print('是否需要頂部高度: $needHeightSpace, 頂部起始: $top');

    // 高度有限, 需要檢查是否可以容納
    if (left.isFinite) {
      var needWidth = info.size.width;
      if (needWidthSpace) {
        needWidth += space;
      }
      if (needWidth > width) {
        return null;
      }
    }

    return _HorizontalSpace(
      y: y,
      span: info.span,
      left: left,
      realLeft: needWidthSpace ? left + space : left,
      width: info.size.width,
    );
  }

  /// 從此空間切下一部分空間, 回傳剩餘的空間
  @override
  List<_HorizontalSpace> cut(_HorizontalSpace other) {
    // 先檢測兩個空間是否有重疊的地方
    if (!overlaps(other)) {
      // 沒有重疊, 所以返回完整的空間
      return [this];
    }

    // 取得兩個空間重疊的 space
    _HorizontalSpace intersectSpace = intersect(other);
    
//    print('從 $this 取出');
//    print('空間 $other');
//    print('交集 $intersectSpace');

    // 剩餘的空間
    List<_HorizontalSpace> remainings = [];

    var topSpan = intersectSpace.y - this.y;
    var leftWidth = intersectSpace.left - this.left;
    var bottomSpan =
        (this.y + this.span) - (intersectSpace.y + intersectSpace.span);
    var rightWidth = (this.realLeft + this.width) -
        (intersectSpace.realLeft + intersectSpace.width);

    // 檢查起始點有沒有剩餘的寬度
    if (topSpan > 0) {
//      print("上方有寬度");
      // 上方有剩餘的寬度, 因此切掉的空間沒有接續上方邊界
      // 因此切割的空間上邊要返回
      var topSpace = _HorizontalSpace(
        y: y,
        left: leftWidth,
        span: topSpan,
        width: width,
      );
      remainings.add(topSpace);
    }

    // 檢查起始點有沒有剩餘的高度
    if (leftWidth > 0) {
//      print("左邊有寬度");
      // 左邊有剩餘的寬度, 因此切掉的空間沒有接續左邊邊界
      // 因此切割的空間左邊要返回
      var leftSpace = _HorizontalSpace(
        y: y,
        left: left,
        span: span,
        width: leftWidth,
      );
      remainings.add(leftSpace);
    }

    // 檢查下邊有沒有剩餘的高度
    if (bottomSpan > 0) {
//      print("下方有高度");
      var bottomSpace = _HorizontalSpace(
        y: intersectSpace.y + intersectSpace.span,
        left: left,
        span: bottomSpan,
        width: width,
      );
      remainings.add(bottomSpace);
    }

    // 檢查右方還有沒有剩餘的寬度
    if (rightWidth > 0) {
//      print("右方有寬度");
      var rightSpace = _HorizontalSpace(
        y: y,
        left: intersectSpace.realLeft + intersectSpace.width,
        span: span,
        width: rightWidth,
      );
      remainings.add(rightSpace);
    }

//    print("結果是: $remainings");
    return remainings;
  }

  /// 將 space 轉為 rect
  @override
  Rect toRect() {
    return Rect.fromPoints(
      Offset(left, y.toDouble()),
      Offset(realLeft + width, (y + span).toDouble()),
    );
  }

  /// 比較兩個空間是否有重疊
  @override
  bool overlaps(_HorizontalSpace other) {
    return this.toRect().overlaps(other.toRect());
  }

  /// 取得兩個 [_HorizontalSpace] 的交集
  @override
  _HorizontalSpace intersect(_HorizontalSpace other) {
    var rect = this.toRect().intersect(other.toRect());
    return _HorizontalSpace(
      y: rect.top.toInt(),
      span: rect.bottom.toInt() - rect.top.toInt(),
      left: rect.left,
      width: rect.right - rect.left,
    );
  }

  /// 是否完全包含某個space
  @override
  bool contains(_HorizontalSpace other) {
    var isXContain = (this.left <= other.left) &&
        (this.realLeft + this.width >= other.realLeft + other.width);
    var isYContain =
        (this.y <= other.y) && (this.y + this.span >= other.y + other.span);
    return isXContain && isYContain;
  }

  @override
  String toString() {
    return 'y: $y, span: $span, left: $realLeft, width: $width';
  }

  @override
  int compareTo(_HorizontalSpace other) {
    if (this.left < other.left) {
      return -1;
    } else if (this.left > other.left) {
      return 1;
    } else if (this.y > other.y) {
      return 1;
    } else if (this.y < other.y) {
      return -1;
    } else {
      return 0;
    }
  }
}
