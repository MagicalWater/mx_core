import 'dart:math';
import 'package:decimal/decimal.dart';

import 'num_util.dart';

extension DoubleCalculate on double {
  double add(double other) => NumUtil.add(this, other);

  double subtract(double other) => NumUtil.subtract(this, other);

  double multiply(double other) => NumUtil.multiply(this, other);

  double divide(double other) => NumUtil.divide(this, other);

  /// 四捨五入到固定小數點
  double roundToFixed(int fractionDigits) {
    var fac = pow(10, fractionDigits).toInt();
    return (this * fac).round() / fac;
  }

  /// 無條件捨去到固定小數點
  double floorToFixed(int fractionDigits) {
    var fac = pow(10, fractionDigits).toInt();
    return (this * fac).floor() / fac;
  }

  /// 無條件進位到固定小數點
  double ceilToFixed(int fractionDigits) {
    var fac = pow(10, fractionDigits).toInt();
    return (this * fac).ceil() / fac;
  }

  /// 取得小數點有幾位
  /// 小數點尾數為0則會去除
  /// 例如
  /// (10.0).decimalLength 會得到 0
  /// (10.10).decimalLength 會得到 1
  int get decimalLength {
    final convertedNum = Decimal.parse(toString());
    var showString = convertedNum.toString();
    var pointIndex = showString.indexOf('.');
    if (pointIndex == -1) {
      return 0;
    } else {
      var decString = showString.substring(pointIndex);
      var len = decString.length;
      if (len == 2 && decString[1] == '0') {
        return 0;
      }
      return len - 1;
    }
  }
}
