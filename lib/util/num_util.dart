import 'dart:math';

import 'package:decimal/decimal.dart';


/// 來源 https://github.com/Sky24n
/// 原作者 Sky24n
/// 修改者 Water
///
/// 數字工具
class NumUtil {
  /// 加 (精确相加,防止精度丢失).
  static double add(num a, num b) {
    return addDec(a, b).toDouble();
  }

  /// 减 (精确相减,防止精度丢失).
  static double subtract(num a, num b) {
    return subtractDec(a, b).toDouble();
  }

  /// 乘 (精确相乘,防止精度丢失).
  /// multiply (without loosing precision).
  static double multiply(num a, num b) {
    return multiplyDec(a, b).toDouble();
  }

  /// 除 (精确相除,防止精度丢失).
  /// divide (without loosing precision).
  static double divide(num a, num b) {
    return divideDec(a, b).toDouble();
  }

  /// 加 (精确相加,防止精度丢失).
  /// add (without loosing precision).
  static Decimal addDec(num a, num b) {
    return addDecStr(a.toString(), b.toString());
  }

  /// 减 (精确相减,防止精度丢失).
  /// subtract (without loosing precision).
  static Decimal subtractDec(num a, num b) {
    return subtractDecStr(a.toString(), b.toString());
  }

  /// 乘 (精确相乘,防止精度丢失).
  /// multiply (without loosing precision).
  static Decimal multiplyDec(num a, num b) {
    return multiplyDecStr(a.toString(), b.toString());
  }

  /// 除 (精确相除,防止精度丢失).
  /// divide (without loosing precision).
  static Decimal divideDec(num a, num b) {
    return divideDecStr(a.toString(), b.toString());
  }

  /// 余数
  static Decimal remainder(num a, num b) {
    return remainderDecStr(a.toString(), b.toString());
  }

  /// 加
  static Decimal addDecStr(String a, String b) {
    return Decimal.parse(a) + Decimal.parse(b);
  }

  /// 减
  static Decimal subtractDecStr(String a, String b) {
    return Decimal.parse(a) - Decimal.parse(b);
  }

  /// 乘
  static Decimal multiplyDecStr(String a, String b) {
    return Decimal.parse(a) * Decimal.parse(b);
  }

  /// 除
  static Decimal divideDecStr(String a, String b) {
    return Decimal.parse(a) / Decimal.parse(b);
  }

  /// 余数
  static Decimal remainderDecStr(String a, String b) {
    return Decimal.parse(a) % Decimal.parse(b);
  }
}

extension DoubleCalculate on double {
  double add(num other) => NumUtil.add(this, other);

  double subtract(num other) => NumUtil.subtract(this, other);

  double multiply(num other) => NumUtil.multiply(this, other);

  double divide(num other) => NumUtil.divide(this, other);

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
    var showString = toString();
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
