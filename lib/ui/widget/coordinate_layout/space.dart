part of 'layout.dart';

/// 空間計算
class _SpaceCompute {
  late double totalWidth;
  late double totalHeight;

  var xSegmentCount;
  var ySegmentCount;

  late double rowHeight;

  /// 空閒的空間
  List<_Space> freeSpace = [];

  /// 設定 container 寬高
  void setTotal(
      double width, double height, int xSegmentCount, double rowHeight) {
    this.totalWidth = width;
    this.totalHeight = height;
    this.xSegmentCount = xSegmentCount;
    this.rowHeight = rowHeight;
    this.ySegmentCount = (totalHeight / rowHeight).floor();

    freeSpace.clear();

    var totalSpace =
    _Space(x: 0, y: 0, xSpan: xSegmentCount, ySpan: ySegmentCount);

    print("設置總範圍: $totalSpace - $totalHeight, $rowHeight");

    /// 給最大遍的範圍
    freeSpace.add(totalSpace);
  }

  /// 取得空置的空間
  /// [fillLast] - 填滿剩下的寬度, 若當前無剩下寬度, 則填滿新的一列
  _Space getFreeSpace(AxisItem item, bool fillLast) {
    _Space? findSpace;

    if (fillLast && freeSpace.isNotEmpty) {
      // 需要填滿剩下的寬度, 尋找當下 空閑空間 最尾端

      // 先尋找所有有擴張到最底部的space
      var fullSpace = freeSpace.where((e) {
        var extendBottom = e.y + e.ySpan == ySegmentCount;
        var extendRight = e.x + e.xSpan == xSegmentCount;
        return extendBottom && extendRight;
      }).toList();

      if (fullSpace.isNotEmpty) {
        _Space space;

        // 如果擴張到最底部的 space > 2, 則選擇倒數第二個
        if (fullSpace.length >= 2) {
          space = fullSpace[fullSpace.length - 2];
        } else {
          space = fullSpace.last;
        }
        item = AxisItem(
          xSpan: space.xSpan,
          ySpan: item.ySpan,
        );

        findSpace = space.getSpaceForce(item);
      }
    } else {
      // 遍歷
      for (int i = 0; i < freeSpace.length; i++) {
        var space = freeSpace[i];
        findSpace = space.getSpaceIfContain(item);

//      print("在 $space 搜索 ${item.x}, ${item.xSpan} & ${item.y}, ${item.ySpan}");

        if (findSpace != null) {
          // 空間可以容納 item 放置
          // 退出遍歷
          break;
        }
      }
    }

    if (findSpace == null) {
      print("沒有找到可以放置的地方, 因此刪除指定位置信息, 再尋找一次");

      // 沒有找到可以裝載的地方
      // 拋棄指定位置的資訊, 再跑一次
      for (int i = 0; i < freeSpace.length; i++) {
        var space = freeSpace[i];
        item = AxisItem(
          xSpan: item.xSpan,
          ySpan: item.ySpan,
        );
        findSpace = space.getSpaceIfContain(item);

        if (findSpace != null) {
          // 空間可以容納 item 放置
          // 退出遍歷
          break;
        }
      }
    }

    if (findSpace == null) {
      // 仍然沒找到可以包裹 item 的位置
      // 尋找當前是否還有空間, 若還有空間則排入
      if (freeSpace.isEmpty) {
        // 當前已無空餘空間, 塞入左上角
        print('GridWidget 警告 - 沒有找到可以使用的位置, 默認塞入左上角');
        findSpace = _Space(x: 0, y: 0, xSpan: item.xSpan, ySpan: item.ySpan);
        return findSpace;
      } else {
        print('GridWidget 警告 - 位置空間不夠, 塞入其餘空間位置');
        findSpace = freeSpace[0].getSpaceForce(item);
      }
    }

//    print("尋找到空間: $findSpace");

    // 最後在遍歷所有空間, 將重複的空間 cut 掉
    var step1 = freeSpace.map((e) {
      return e.cut(findSpace!);
    });

    var step2 = step1.expand((e) => e).toList();

    freeSpace = step2;

//    print("剩餘空間: $freeSpace");

    // 合併重複空間的按鈕
    for (int i = 0; i < freeSpace.length; i++) {}
    freeSpace = freeSpace.where((e) {
      // 至少找到兩個以上包含自己的才算(因為包含自己)
      return freeSpace.where((e2) => e2.contains(e)).toList().length < 2;
    }).toList();

//    print("合併: $freeSpace");

    // 重新排序剩餘空間
    freeSpace.sort((space1, space2) {
      if (space1.y < space2.y) {
        return -1;
      } else if (space1.y > space2.y) {
        return 1;
      } else if (space1.x > space2.x) {
        return 1;
      } else if (space1.x < space2.x) {
        return -1;
      } else {
        return 0;
      }
    });

    return findSpace;
  }
}

class _Space {
  int x;
  int y;
  int xSpan;
  int ySpan;

  /// 是否為強制塞入的空間(代表空間不夠需要重新update)
  bool isForce;

  _Space({
    required this.x,
    required this.y,
    required this.xSpan,
    required this.ySpan,
    this.isForce = false,
  });

  @override
  String toString() => "x($x, $xSpan), y($y, $ySpan)";

  /// 從此空間中強制取出空間給 item
  /// 此將導致無法完全顯示 item
  _Space getSpaceForce(AxisItem item) {
    print("取得強制空間");
    return _Space(
      x: this.x,
      y: this.y,
      xSpan: min(xSpan, item.xSpan),
      ySpan: min(ySpan, item.ySpan),
      isForce: true,
    );
  }

  /// 判斷是否能包含某個位置
  /// 可以 => 返回 [_Space]
  /// 不行 => 返回 null
  _Space? getSpaceIfContain(AxisItem item) {
    // 先確認 width, height 空間夠不夠
    if (xSpan < item.xSpan || ySpan < item.ySpan) {
      return null;
    }

    if (item.x == null && item.y == null) {
      // x 跟 y 都沒限制, 代表包含在裡面
      return _Space(
        x: x,
        y: y,
        xSpan: item.xSpan,
        ySpan: item.ySpan,
      );
    }

    bool isXOk = true;
    bool isYOk = true;

    if (item.x != null) {
      // x 有限制位置
      isXOk = item.x! >= x && item.x! + item.xSpan <= x + xSpan;
    }

    if (item.y != null) {
      // y 有限制位置
      isXOk = item.y! >= y && item.y! + item.ySpan <= y + ySpan;
    }

    if (isXOk && isYOk) {
      return _Space(
        x: item.x ?? x,
        y: item.y ?? y,
        xSpan: item.xSpan,
        ySpan: item.ySpan,
      );
    }
    return null;
  }

  /// 將 space 轉為 rect
  Rect _toRect() {
    return Rect.fromPoints(Offset(x.toDouble(), y.toDouble()),
        Offset((x + xSpan).toDouble(), (y + ySpan).toDouble()));
  }

  /// 比較兩個空間是否有重疊
  bool overlaps(_Space other) {
    return this._toRect().overlaps(other._toRect());
  }

  /// 是否為一模一樣的空間
  bool sames(_Space other) {
    return this.x == other.x &&
        this.y == other.y &&
        this.xSpan == other.xSpan &&
        this.ySpan == other.ySpan;
  }

  /// 是否完全包含某個space
  bool contains(_Space other) {
    var isXContain =
        (this.x <= other.x) && (this.x + this.xSpan >= other.x + other.xSpan);
    var isYContain =
        (this.y <= other.y) && (this.y + this.ySpan >= other.y + other.ySpan);
    return isXContain && isYContain;
  }

  /// 取得兩個 [_Space] 的交集
  _Space intersect(_Space other) {
    var rect = this._toRect().intersect(other._toRect());
    return _Space(
      x: rect.left.toInt(),
      y: rect.top.toInt(),
      xSpan: rect.right.toInt() - rect.left.toInt(),
      ySpan: rect.bottom.toInt() - rect.top.toInt(),
    );
  }

  /// 從此空間切下一部分空間, 回傳剩餘的空間
  List<_Space> cut(_Space other) {
    // 先檢測兩個空間是否有重疊的地方
    if (!overlaps(other)) {
      // 沒有重疊, 所以返回完整的空間
      return [this];
    }

//    print("於: ${this} 剪下: $other");

    // 取得兩個空間重疊的 space
    _Space intersectSpace = intersect(other);

    // 剩餘的空間
    List<_Space> remainings = [];

    var leftSpan = intersectSpace.x - this.x;
    var topSpan = intersectSpace.y - this.y;
    var rightSpan =
        (this.x + this.xSpan) - (intersectSpace.x + intersectSpace.xSpan);
    var bottomSpan =
        (this.y + this.ySpan) - (intersectSpace.y + intersectSpace.ySpan);

    // 檢查起始點有沒有剩餘的寬度
    if (leftSpan > 0) {
//      print("左方有寬度");
      // 左邊有剩餘的寬度, 因此切掉的空間沒有接續左邊邊界
      // 因此切割的空間左邊要返回
      var leftSpace = _Space(
        x: x,
        y: y,
        xSpan: leftSpan,
        ySpan: ySpan,
      );
      remainings.add(leftSpace);
    }

    // 檢查起始點有沒有剩餘的高度
    if (topSpan > 0) {
//      print("上方有高度");
      // 上方有剩餘的寬度, 因此切掉的空間沒有接續上方邊界
      // 因此切割的空間上邊要返回
      var topSpace = _Space(
        x: x,
        y: y,
        xSpan: xSpan,
        ySpan: topSpan,
      );
      remainings.add(topSpace);
    }

    // 檢查右邊有沒有剩餘的寬度
    if (rightSpan > 0) {
//      print("右方有寬度");
      var rightSpace = _Space(
        x: intersectSpace.x + intersectSpace.xSpan,
        y: y,
        xSpan: rightSpan,
        ySpan: ySpan,
      );
      remainings.add(rightSpace);
    }

    // 檢查下方還有沒有剩餘的寬度
    if (bottomSpan > 0) {
//      print("下方有高度");
      var bottomSpace = _Space(
        x: x,
        y: intersectSpace.y + intersectSpace.ySpan,
        xSpan: xSpan,
        ySpan: bottomSpan,
      );
      remainings.add(bottomSpace);
    }

//    print("結果是: $remainings");
    return remainings;
  }
}
