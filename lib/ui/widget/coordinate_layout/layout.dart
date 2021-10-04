import 'dart:core';
import 'dart:math';

import 'package:flutter/material.dart';

part 'axis.dart';
part 'delegate.dart';
part 'space.dart';

/// 座標式佈局
/// 可自訂 x, y 位置, 並且設置 x, y 的 span(佔用寬度數量, 高度數量)
class CoordinateLayout extends StatefulWidget {
  /// 寬度總共要切成幾等分
  final int segmentCount;

  final List<AxisItem> children;

  final EdgeInsets? padding;

  /// 每列高度
  final double? rowHeight;

  /// y軸每列空隙
  final double verticalSpace;

  /// x軸每行空隙
  final double horizontalSpace;

  /// 最後一個 child 是否自動填滿剩下的寬度
  final bool lastFillWidth;

  final Color? color;

  /// 預估高度(當外層是個 scrollView / column 這種沒有限界高度的元件時, 請給一個大約預測高度, 可以超過元件總高度, 但別小於)
  final double? estimatedHeight;

  CoordinateLayout({
    required this.segmentCount,
    required this.children,
    this.padding,
    this.color,
    this.rowHeight,
    this.horizontalSpace = 0,
    this.verticalSpace = 0,
    this.lastFillWidth = false,
    this.estimatedHeight,
  }) {
    // 依照是否有指定位置來排序
    children.sort((item1, item2) {
      var isSpecialPos1 = item1._specialPosition;
      var isSpecialPos2 = item2._specialPosition;
      if (isSpecialPos1 && !isSpecialPos2) {
        return -1;
      } else if (!isSpecialPos1 && isSpecialPos2) {
        return 1;
      } else {
        return 0;
      }
    });

//    var text = children
//        .map((e) => (e.child as Container))
//        .map((e) => (e.child as Align))
//        .map((e) => (e.child as MaterialWidget))
//        .map((e) => (e.child as Text))
//        .map((e) => e.data);
//
//    print("排列後: $text");
  }

  @override
  _CoordinateLayoutState createState() => _CoordinateLayoutState();
}

class _CoordinateLayoutState extends State<CoordinateLayout> {
  double? flowHeight;

  /// 新舊資料是否不同
  bool isDataDifference = false;

  /// 當前 delegate
  _CoordinateDelegate? currentDelegate;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(CoordinateLayout oldWidget) {
    // 先檢查資料是否不同
    bool difference = false;

    if (widget.children.length == oldWidget.children.length) {
      for (var i = 0; i < oldWidget.children.length; i++) {
        var newItem = widget.children[i];
        var oldItem = oldWidget.children[i];
        if (!newItem._isSame(oldItem)) {
          difference = true;
          break;
        }
      }
    } else {
      difference = true;
    }

    isDataDifference = difference;

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.children.isEmpty) return Container();

    double? specialHeight;

    // 只有在有確定內容高度以及資料一樣的情況下, 才設置整體高度
    if (flowHeight != null && !isDataDifference) {
//      print("指定高度: ${flowHeight}, ${widget.padding?.top}, ${widget.padding?.bottom}");
      specialHeight = flowHeight! +
          (widget.padding?.top ?? 0) +
          (widget.padding?.bottom ?? 0);
    }

    print(
        "指定高度: $specialHeight, 是否需要隱藏 :${(flowHeight == null) || isDataDifference}");

    var container = Container(
      padding: widget.padding,
      height: specialHeight ?? widget.estimatedHeight,
      color: widget.color,
      child: Align(
        child: Flow(
          delegate: inheritDelegate(),
          children: widget.children,
        ),
      ),
    );

    return container;
  }

  /// 取得新顯示的delegate
  _CoordinateDelegate inheritDelegate() {
    var newDelegate = _CoordinateDelegate(
      segmentCount: widget.segmentCount,
      items: widget.children,
      ySpace: widget.verticalSpace,
      xSpace: widget.horizontalSpace,
      rowHeight: widget.rowHeight,
      isDataDifference: isDataDifference,
      lastFillWidth: widget.lastFillWidth,
      onUpdate: (allHeight) {
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          isDataDifference = false;
          flowHeight = allHeight;
          setState(() {});
        });
      },
    );
    if (currentDelegate != null) {
      if (isDataDifference) {
        // 資料不同, 只繼承 rowHeight
        newDelegate.rowHeight = currentDelegate!.rowHeight;
        currentDelegate = newDelegate;
      } else {
        newDelegate._spaces = currentDelegate!._spaces;
        newDelegate._spaceCompute = currentDelegate!._spaceCompute;
        newDelegate.rowHeight = currentDelegate!.rowHeight;
        newDelegate.columnWidth = currentDelegate!.columnWidth;
        newDelegate.allHeight = currentDelegate!.allHeight;
        newDelegate.needReLayout = currentDelegate!.needReLayout;
        currentDelegate = newDelegate;
      }
    } else {
      currentDelegate = newDelegate;
    }
    return currentDelegate!;
  }
}
