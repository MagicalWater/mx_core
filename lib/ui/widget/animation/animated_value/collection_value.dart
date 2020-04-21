part of '../animated_core.dart';

/// 並行動畫, 此群組下的動畫接遵循此 [duration], 以及在此之上的 [delayed]
/// list 內的 duration 失效, 但 delay 仍有效
class _CollectionValue extends AnimatedValue {
  List<AnimatedValue> animatedList;

  /// [defaultDuration] - 在此動畫群組底下的動畫, 預設動畫時間
  /// [defaultCurve] - 在此動畫群組底下的動畫, 預設動插值器
  _CollectionValue._({
    this.delayed,
    int defaultDuration,
    Curve defaultCurve,
    Alignment defaultAlignment,
    this.animatedList = const [],
  }) {
    duration = defaultDuration;
    curve = defaultCurve;
    alignment = defaultAlignment;
    _checkList();
  }

  @override
  int get hashCode => super.hashCode;

  @override
  bool operator ==(dynamic other) {
    if (other is _CollectionValue) {
      var isLenSame = animatedList.length == other.animatedList.length;
      var isInsSame = true;
      if (isLenSame) {
        for (var i = 0; i < animatedList.length; i++) {
          isInsSame = animatedList[i] == other.animatedList[i];
          if (!isInsSame) break;
        }
      }
      return isLenSame && isInsSame;
    }
    return false;
  }

  /// 檢查 底下的動畫列表, list內不能再包含 [_CollectionValue]
  void _checkList() {
    if (animatedList.any((e) => e is _CollectionValue)) {
      print("錯誤 - AnimatedCore: CollectionValue 底下的並行動畫不得嵌套 CollectionValue");
      throw "錯誤 - AnimatedCore: CollectionValue 底下的並行動畫不得嵌套 CollectionValue";
    }
  }

  @override
  int totalDuration(int defaultDuration) {
    var duration = 0;
    animatedList.forEach((e) {
      duration = max(
          duration,
          ((e.delayed ?? 0) +
              (e.duration ?? this.duration ?? defaultDuration)));
//      print(
//          "duration = ${duration}, 當前: ${((e.delayed ?? 0) + (e.duration ?? this.duration ?? defaultDuration))}");
    });
    return duration;
  }

  @override
  var begin;

  @override
  Curve curve;

  @override
  int delayed;

  @override
  int duration;

  @override
  var end;

  @override
  Alignment alignment;
}
