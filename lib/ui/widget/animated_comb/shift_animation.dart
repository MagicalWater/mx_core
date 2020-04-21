part of 'animated_comb.dart';

//class ShiftTween extends CurvedAnimation {
//
//}

/// 基準時間偏移Animation
/// 內部直接將 [CurvedAnimation] 部分計算動畫時間的私有方法複製
/// 只是在基礎時間上做的推移
class ShiftAnimation extends CurvedAnimation {
  /// 由此參數紀錄動畫運行的方式
  final AnimationMethod Function() _methodGetter;

  /// 推移百分比
  final double shift;

  String lastShow = '';

  /// 當前狀態是否為往前
  bool _isCurrentForward;

  /// 是否已經達到頂峰
  bool _isTimeUpperBound = false;

  /// 是否已經達到底風
  bool _isTimeLowerBound = false;

  /// 記錄最後一個 t 值, 由此的增減判斷當前的動畫狀態
  /// 因為 [status] 再 repeat(reverse: true) 時並不會變更
  double _lastT = 0;

  /// 此延遲開始時間並非是等待 [shift] 個百分比後開始
  /// 而是會在一開始的動畫時間基礎上, 往前推 [shift] 個的百分比
  ShiftAnimation({
    Animation<double> parent,
    Curve curve,
    this.shift = 0,
    AnimationMethod Function() methodGetter,
    Curve reverseCurve,
  })  : this._methodGetter = methodGetter,
        super(
          parent: parent,
          curve: curve,
          reverseCurve: reverseCurve,
        ) {
    parent.addStatusListener(_updateCurveDirection);
  }

  @override
  double get value {
    // 取得當前的 t
    final double t = parent.value;

//    var newShow = t.toStringAsFixed(1);

    // 依照偏移, 進行偏移的 t 百分比
    if (parent is AnimationController) {
      // 上下界必須為 0 ~ 1.0
      final upperBound = (parent as AnimationController).upperBound;
      final lowerBound = (parent as AnimationController).lowerBound;

      assert(lowerBound == 0 && upperBound == 1.0);
    }

    var shiftT = getShiftT(t);

//    if (lastShow != newShow) {
//      print("印出 t = ${t.toStringAsFixed(1)}, 偏移後: ${newT.toStringAsFixed(1)}");
//      lastShow = newShow;
//    }

//    print("最後t = $newT");
    return getSuperValue(shiftT);
  }

  /// 取得 t 位移後的新值
  double getShiftT(double t) {
    // 檢查時間是否達到頂峰
    if (!_isTimeUpperBound && _lastT > t) {
//      print("頂峰: old = ${lastT}, new = ${t}");
      _isTimeUpperBound = true;
      _isTimeLowerBound = false;
    } else if (!_isTimeLowerBound && t > _lastT) {
//      print("底: old = ${lastT}, new = ${t}");
      _isTimeUpperBound = false;
      _isTimeLowerBound = true;
    }

    _lastT = t;

    final currentMethod = _methodGetter();
// 依照當前的動畫狀態做偏移
    switch (status) {
      case AnimationStatus.reverse:
      case AnimationStatus.completed:
//        print("反向動畫");
        // 反向動畫
        switch (currentMethod) {
          case AnimationMethod.repeatReverse:
            return _evaluateShiftValue(currentMethod, t - shift);
            break;
          case AnimationMethod.onceReverse:
            if (shift > t - shift) {
              return shift;
            }
            return _evaluateShiftValue(currentMethod, t - shift);
            break;
          case AnimationMethod.toggle:
            if (shift >= t) {
              return shift;
            }
            return _evaluateShiftValue(currentMethod, t);
            break;
          default:
            return 1;
            break;
        }
        break;
      default:
//        print("正向動畫");
        // 除了 reverse 的動畫之外, 全都為此
        if (!(_isCurrentForward ?? true) && _isTimeUpperBound) {
          return _evaluateShiftValue(currentMethod, t - shift);
        } else {
          return _evaluateShiftValue(currentMethod, t + shift);
        }
        break;
    }
  }

  /// 計算偏移後的新值
  double _evaluateShiftValue(AnimationMethod method, double t) {
    // 當偏移後的新值超過 1, 需要再計算反向值
    if (t > 1) {
      switch (method) {
        case AnimationMethod.repeat:
          // 直接重0再開始計算
//          _isCurrentForward = true;
          return _evaluateShiftValue(method, t - 1.0);
          break;
        case AnimationMethod.repeatReverse:
          // 需要反向
          _isCurrentForward = false;
          return _evaluateShiftValue(method, 1.0 - (t - 1.0));
          break;
        case AnimationMethod.once:
          // 需要需要停留在最後的位置
//          _isCurrentForward = true;
          return 1;
          break;
        case AnimationMethod.toggle:
          return 1;
          break;
        case AnimationMethod.onceReverse:
          // 需要反向
          _isCurrentForward = false;
          return _evaluateShiftValue(method, 1.0 - (t - 1.0));
          break;
        default:
          print("未知的動畫 Method = $method");
          throw FlutterError("未知的動畫 Method = $method");
          break;
      }
    } else if (t < 0) {
      switch (method) {
        case AnimationMethod.repeat:
          // 從 1 開始往前
          return _evaluateShiftValue(method, 1.0 - (0 - t));
          break;
        case AnimationMethod.repeatReverse:
          // 需要轉為正向
          return _evaluateShiftValue(method, 0 + (0 - t));
          break;
        case AnimationMethod.once:
          // 需要需要停留在最後的位置
          return 1;
          break;
        case AnimationMethod.onceReverse:
          // 停留在剛開始的位置
          return shift;
          break;
        case AnimationMethod.toggle:
          return shift;
        default:
          print("未知的動畫 Method = $method");
          throw FlutterError("未知的動畫 Method = $method");
          break;
      }
    } else {
      return t;
    }
  }

  //========== 以下直接複製 [CurvedAnimation] 的方法及參數
  AnimationStatus _curveDirection;

  void _updateCurveDirection(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.dismissed:
      case AnimationStatus.completed:
        _curveDirection = null;
        break;
      case AnimationStatus.forward:
        _curveDirection ??= AnimationStatus.forward;
        break;
      case AnimationStatus.reverse:
        _curveDirection ??= AnimationStatus.reverse;
        break;
    }
  }

  bool get _useForwardCurve {
    return reverseCurve == null ||
        (_curveDirection ?? parent.status) != AnimationStatus.reverse;
  }

  /// 此方法內容為 [CurvedAnimation] 的 value getter 內容
  /// 差別在於 [t] 為經過時間偏移後得出的
  double getSuperValue(double t) {
    final Curve activeCurve = _useForwardCurve ? curve : reverseCurve;

    if (activeCurve == null) return t;
    if (t == 0.0 || t == 1.0) {
      assert(() {
        final double transformedValue = activeCurve.transform(t);
        final double roundedTransformedValue =
            transformedValue.round().toDouble();
        if (roundedTransformedValue != t) {
          throw FlutterError('Invalid curve endpoint at $t.\n'
              'Curves must map 0.0 to near zero and 1.0 to near one but '
              '${activeCurve.runtimeType} mapped $t to $transformedValue, which '
              'is near $roundedTransformedValue.');
        }
        return true;
      }());
      return t;
    }
    return activeCurve.transform(t);
  }
}

// 呼叫的動畫方式
enum AnimationMethod {
  repeat,
  repeatReverse,
  onceReverse,
  once,
  toggle,
}
