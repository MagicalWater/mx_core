part of 'compute.dart';

/// 剩餘的空間
class _RemainSpace {
  int segmentCount;
  Axis direction;
  double segmentHeight;
  double segmentWidth;
  double verticalSpace;
  double horizontalSpace;

  List<_AlignSpace> remainSpace;

  _RemainSpace({
    this.segmentCount,
    this.direction,
    this.segmentHeight,
    this.segmentWidth,
    this.verticalSpace,
    this.horizontalSpace,
  }) {
    switch (direction) {
      case Axis.horizontal:
        remainSpace = [
          _HorizontalSpace(y: 0, span: segmentCount, left: 0),
        ];
        break;
      case Axis.vertical:
        remainSpace = [
          _VerticalSpace(x: 0, span: segmentCount, top: 0),
        ];
        break;
    }
  }

  SpaceResult getFreeSpace(AlignChildInfo info) {
//    print('尋找需要空間: $info');

    // 遍歷所有的剩餘空間, 尋找可容納child的
    _AlignSpace findSpace;
    remainSpace.firstWhere((e) {
      findSpace = e.getSpaceIfContain(
        info,
        direction == Axis.horizontal ? horizontalSpace : verticalSpace,
      );
      return findSpace != null;
    });

//    print('尋找到空間: $findSpace');

    // 遍歷所有空間, 將重複的空間 cut 掉
    remainSpace = remainSpace
        .map((e) {
          return e.cut(findSpace).cast<_AlignSpace>();
        })
        .expand((e) => e)
        .toList();

    // 合併重複空間的按鈕
    for (int i = 0; i < remainSpace.length; i++) {}
    remainSpace = remainSpace.where((e) {
      // 至少找到兩個以上包含自己的才算(因為包含自己)
      return remainSpace.where((e2) => e2.contains(e)).toList().length < 2;
    }).toList();

    //TODO: 目前尚缺少, 連續空間也可能需要進行合併

    // 重新排序剩餘空間
    remainSpace.sort();

//        var needHorizontalSpace = findSpace.x != 0;
//    print('剩餘空間');
//    remainSpace.forEach((e) {
//      print(e);
//    });

    Offset offset;

    switch (direction) {
      case Axis.horizontal:
        var horizontalSpace = findSpace as _HorizontalSpace;
        offset = Offset(
          horizontalSpace.realLeft,
          horizontalSpace.y.toDouble() * segmentHeight +
              verticalSpace * horizontalSpace.y,
        );

        break;
      case Axis.vertical:
        var verticalSpace = findSpace as _VerticalSpace;
        offset = Offset(
          verticalSpace.x.toDouble() * segmentWidth +
              horizontalSpace * (verticalSpace.x),
          verticalSpace.realTop,
        );
        break;
      default:
        throw '未知的方向';
        break;
    }

    return SpaceResult(
      offset: offset,
      size: info.size,
    );
  }
}
