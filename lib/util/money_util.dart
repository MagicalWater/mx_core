import 'package:intl/intl.dart';

/// 金錢工具相關
class MoneyUtil {
  MoneyUtil._();

  /// 每隔三位數加一個逗點, 保留多少逗點
  static String format(num money, {int fractionDigits}) {
    String numString;

    numString = fractionDigits != null
        ? money.toStringAsFixed(fractionDigits)
        : money.toString();

    // 分割整數與小數點
    var numSplit = numString.split('.');

    // 整數
    var intString = numSplit[0];

    // 小數點
    var fractionString = numSplit.length == 2 ? ".${numSplit[1]}" : '';

    List<String> splitIntString = [];
//    print("格式化: $money, $intString");

    int startLen = intString.length;

    for (var i = 3; i < intString.length; i += 3) {
      startLen = intString.length - i;
      var text = intString.substring(startLen, startLen + 3);
      splitIntString.add(text);
    }
    splitIntString.add(intString.substring(0, startLen));

    // 加入逗號
    var combine = splitIntString.reversed.toList().join(",");

    // 將處理好的字串接上小數點後
    return "$combine$fractionString";
  }

  /// 將數字字串轉為num
  static num convert(String numText) {
    // 驗證數字格式是否合法
    if (!verify(numText)) return null;

    var numString = numText.replaceAll(',', '');
    return num.tryParse(numString);
  }

  /// 驗證字串 [text] 是否可轉為 num
  static bool verify(String text) {
    bool illegal(String message) {
//      print(message);
      return false;
    }

    if (text.isEmpty) {
      // 空字串不得為數字
      return illegal("空字串不得為數字");
    }

    var splitText = text.split(".");
    if (splitText.length > 2) {
      // 一個數字不應該擁有超過一個小數點
      return illegal("一個數字不應該擁有超過一個小數點");
    }

    // 小數點部份數字
    String fractionText = '';

    // 分割字串長度為2, 代表有小數點
    if (splitText.length == 2) {
      fractionText = splitText[1];

      // 驗證小數點部份是否為全數字
      var isMatch = RegExp(r"^\d*$").hasMatch(fractionText);
      if (!isMatch) {
        return illegal("小數點部份應為全數字");
      }
    }

    // 整數部分數字
    String intText = splitText[0].isEmpty ? "0" : splitText[0];

    // 整數切割
    var intSplit = intText.split(",");
    if (intSplit.length == 1) {
      // 沒有逗點, 那應該要全數字
      var isMatch = RegExp(r"^\d+$").hasMatch(intSplit[0]);
      if (!isMatch) {
        return illegal("整數無逗點, 應為全數字");
      }
    } else {
      // 有逗點, 那開始針對每個區間的數字做檢測
      for (var i = 0; i < intSplit.length; i++) {
        var step = intSplit[i];
        bool isMatch;
        if (i == 0) {
          // 開頭數字可以匹配1~3個數字
          isMatch = RegExp(r"^\d{1,3}$").hasMatch(step);
        } else {
          // 非開頭數字必定匹配3個數字
          isMatch = RegExp(r"^\d{3}$").hasMatch(step);
        }
        if (!isMatch) {
          return illegal("整數部分逗點切割後數字格式不對");
        }
      }
    }

    return true;
  }
}

extension MoneyFormat on num {
  String moneyFormat() {
    var format = NumberFormat();
    return format.format(this);
  }
}
