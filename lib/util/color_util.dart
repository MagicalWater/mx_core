import 'package:flutter/material.dart';

class ColorUtil {
  ColorUtil._();

  /// 從 hex 字串取得 color
  static Color getColor(String hex) {
    hex = hex.replaceAll("#", "");
    switch (hex.length) {
      case 6:

        /// 無透明
        return Color(int.parse(hex, radix: 16) + 0xFF000000);
      case 8:

        /// 有透明
        return Color(int.parse(hex, radix: 16) + 0x00000000);
      default:
        throw FormatException("顏色代碼格式錯誤: $hex");
    }
  }
}
