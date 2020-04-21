//part of 'layout.dart';
//
///// 空間計算
//class _VerticalSpaceCompute {
//  double totalWidth;
//  double totalHeight;
//
//  /// 空隙寬度
//  double xSpace;
//
//  /// 空隙高度
//  double ySpace;
//
//  _VerticalSpaceCompute({this.xSpace, this.ySpace});
//
//  int segmentCount;
//
//  double get segmentWidth =>
//      (totalWidth - (segmentCount - 1) * xSpace) / segmentCount;
//
//  /// 空閒的空間
//  List<_VerticalSpace> freeSpace = [];
//
//  /// 取得當前是否已設定總空間
//  bool isTotalSpaceSet() {
//    return totalWidth != null && segmentCount != null;
//  }
//
//  /// 設定總空間
//  /// 回傳新舊空間是否不同
//  bool setTotal(
//    double width,
//    double height,
//    int segmentCount,
//  ) {
//    bool isDiff;
//    if (isTotalSpaceSet()) {
//      isDiff = this.totalWidth != width || this.segmentCount != segmentCount;
//    } else {
//      isDiff = true;
//    }
//
//    if (!isDiff) {
//      return false;
//    }
//
//    this.totalWidth = width;
//    this.totalHeight = height;
//    this.segmentCount = segmentCount;
//
//    _resetSpace();
//
//    return isDiff;
//  }
//
//  /// 重設空餘空間
//  void _resetSpace() {
//    freeSpace.clear();
//    var totalSpace = _VerticalSpace(
//      x: 0,
//      y: 0,
//      xSpan: segmentCount,
//      height: totalHeight,
//    );
////    print("設置總範圍: $totalSpace");
//
//    // 給最大遍的範圍
//    freeSpace.add(totalSpace);
//  }
//
//  /// 取得空置的空間
//  /// [fillLast] - 填滿剩下的寬度, 若當前無剩下寬度, 則填滿新的一列
//  _VerticalSpace getFreeSpace(SpanX span, double height) {
//    _VerticalSpace findSpace;
//
//    // 遍歷
//    for (int i = 0; i < freeSpace.length; i++) {
//      var space = freeSpace[i];
//      findSpace = space.getSpaceIfContain(span, height, ySpace);
//
//      if (findSpace != null) {
//        // 空間可以容納 item 放置
//        // 退出遍歷
////        print("在: $space 中尋找到 - $findSpace");
//        break;
//      }
//    }
//
//    if (findSpace == null) {
//      // 仍然沒找到可以包裹 item 的位置
//      // 尋找當前是否還有空間, 若還有空間則排入
//      if (freeSpace.isEmpty) {
//        // 當前已無空餘空間, 塞入左上角
//        print('_VerticalSpaceCompute 警告 - 沒有找到可以使用的位置, 默認塞入左上角');
//        findSpace = _VerticalSpace(
//          x: 0,
//          y: 0,
//          xSpan: span.span,
//          height: height,
//          realY: 0,
//        );
//        return findSpace;
//      } else {
//        print('_VerticalSpaceCompute 警告 - 位置空間不夠, 塞入其餘空間位置');
//        findSpace = freeSpace[0].getSpaceForce(span, height);
//      }
//    }
//
//    // 最後在遍歷所有空間, 將重複的空間 cut 掉
//    var step1 = freeSpace.map((e) {
//      return e.cut(findSpace);
//    });
//
//    var step2 = step1.expand((e) => e).toList();
//
//    freeSpace = step2;
//
////    print("剩餘空間: $freeSpace");
//
//    // 合併重複空間的按鈕
//    for (int i = 0; i < freeSpace.length; i++) {}
//    freeSpace = freeSpace.where((e) {
//      // 至少找到兩個以上包含自己的才算(因為包含自己)
//      return freeSpace.where((e2) => e2.contains(e)).toList().length < 2;
//    }).toList();
//
//    //TODO: 目前尚缺少, 連續空間也可能需要進行合併
//
//    // 重新排序剩餘空間
//    freeSpace.sort((space1, space2) {
//      if (space1.y < space2.y) {
//        return -1;
//      } else if (space1.y > space2.y) {
//        return 1;
//      } else if (space1.x > space2.x) {
//        return 1;
//      } else if (space1.x < space2.x) {
//        return -1;
//      } else {
//        return 0;
//      }
//    });
//
//    return findSpace;
//  }
//}
//
//class _VerticalSpace {
//  /// x 代表第幾個位置
//  int x;
//  int xSpan;
//
//  /// y 代表座標
//  double y;
//  double height;
//
//  /// 真實的 y 座標(再減去了 ySpace後的空間)
//  double realY;
//
//  /// 是否為強制塞入的空間(代表空間不夠需要重新update)
//  bool isForce;
//
//  _VerticalSpace({
//    this.x,
//    this.xSpan,
//    this.y,
//    this.height,
//    this.isForce = false,
//    this.realY,
//  });
//
//  @override
//  String toString() => "x($x, $xSpan), y($y, $height)";
//
//  /// 從此空間中強制取出空間給 item
//  /// 此將導致無法完全顯示 item
//  _VerticalSpace getSpaceForce(SpanX span, double height) {
//    print("取得強制空間");
//    return _VerticalSpace(
//      x: this.x,
//      y: this.y,
//      xSpan: min(xSpan, span.span),
//      height: min(this.height, height),
//      isForce: true,
//      realY: this.y,
//    );
//  }
//
//  /// 判斷是否能包含某個位置
//  /// 可以 => 返回 [_VerticalSpace]
//  /// 不行 => 返回 null
//  _VerticalSpace getSpaceIfContain(SpanX span, double height, double ySpace) {
//    // 先確認 width, height 空間夠不夠
//    if (xSpan < span.span || this.height < height) {
//      return null;
//    }
//
//    // 假如 y 不為0, 則代表並非第一列的空間, 需要再減去 ySpace 空間
//    var isFirstRow = y == 0;
//    var yTranslate = isFirstRow ? 0 : ySpace;
//    if (!isFirstRow && (this.height - ySpace) < height) {
//      return null;
//    }
//
////    print("y起始位置: $yTranslate, y 結尾位置: ${y + height}");
//
//    return _VerticalSpace(
//      x: x,
//      xSpan: span.span,
//      y: y,
//      height: yTranslate + height,
//      realY: y + yTranslate,
//    );
//  }
//
//  /// 將 space 轉為 rect
//  Rect _toRect() {
//    return Rect.fromPoints(
//      Offset(x.toDouble(), y),
//      Offset((x + xSpan).toDouble(), y + height),
//    );
//  }
//
//  /// 比較兩個空間是否有重疊
//  bool overlaps(_VerticalSpace other) {
//    return this._toRect().overlaps(other._toRect());
//  }
//
//  /// 是否為一模一樣的空間
//  bool sames(_VerticalSpace other) {
//    return this.x == other.x &&
//        this.y == other.y &&
//        this.xSpan == other.xSpan &&
//        this.height == other.height;
//  }
//
//  /// 是否完全包含某個space
//  bool contains(_VerticalSpace other) {
//    var isXContain =
//        (this.x <= other.x) && (this.x + this.xSpan >= other.x + other.xSpan);
//    var isYContain =
//        (this.y <= other.y) && (this.y + this.height >= other.y + other.height);
//    return isXContain && isYContain;
//  }
//
//  /// 取得兩個 [_VerticalSpace] 的交集
//  _VerticalSpace intersect(_VerticalSpace other) {
//    var rect = this._toRect().intersect(other._toRect());
//    return _VerticalSpace(
//      x: rect.left.toInt(),
//      xSpan: rect.right.toInt() - rect.left.toInt(),
//      y: rect.top,
//      height: rect.bottom - rect.top,
//    );
//  }
//
//  /// 從此空間切下一部分空間, 回傳剩餘的空間
//  List<_VerticalSpace> cut(_VerticalSpace other) {
//    // 先檢測兩個空間是否有重疊的地方
//    if (!overlaps(other)) {
//      // 沒有重疊, 所以返回完整的空間
//      return [this];
//    }
//
////    print("於: ${this} 剪下: $other");
//
//    // 取得兩個空間重疊的 space
//    _VerticalSpace intersectSpace = intersect(other);
//
//    // 剩餘的空間
//    List<_VerticalSpace> remainings = [];
//
//    var leftSpan = intersectSpace.x - this.x;
//    var topHeight = intersectSpace.y - this.y;
//    var rightSpan =
//        (this.x + this.xSpan) - (intersectSpace.x + intersectSpace.xSpan);
//    var bottomHeight =
//        (this.y + this.height) - (intersectSpace.y + intersectSpace.height);
//
//    // 檢查起始點有沒有剩餘的寬度
//    if (leftSpan > 0) {
////      print("左方有寬度");
//      // 左邊有剩餘的寬度, 因此切掉的空間沒有接續左邊邊界
//      // 因此切割的空間左邊要返回
//      var leftSpace = _VerticalSpace(
//        x: x,
//        y: y,
//        xSpan: leftSpan,
//        height: height,
//      );
//      remainings.add(leftSpace);
//    }
//
//    // 檢查起始點有沒有剩餘的高度
//    if (topHeight > 0) {
////      print("上方有高度");
//      // 上方有剩餘的寬度, 因此切掉的空間沒有接續上方邊界
//      // 因此切割的空間上邊要返回
//      var topSpace = _VerticalSpace(
//        x: x,
//        y: y,
//        xSpan: xSpan,
//        height: topHeight,
//      );
//      remainings.add(topSpace);
//    }
//
//    // 檢查右邊有沒有剩餘的寬度
//    if (rightSpan > 0) {
////      print("右方有寬度");
//      var rightSpace = _VerticalSpace(
//        x: intersectSpace.x + intersectSpace.xSpan,
//        y: y,
//        xSpan: rightSpan,
//        height: height,
//      );
//      remainings.add(rightSpace);
//    }
//
//    // 檢查下方還有沒有剩餘的寬度
//    if (bottomHeight > 0) {
////      print("下方有高度");
//      var bottomSpace = _VerticalSpace(
//        x: x,
//        y: intersectSpace.y + intersectSpace.height,
//        xSpan: xSpan,
//        height: bottomHeight,
//      );
//      remainings.add(bottomSpace);
//    }
//
////    print("結果是: $remainings");
//    return remainings;
//  }
//}
