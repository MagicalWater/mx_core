import 'package:flutter/material.dart';
import 'package:mx_core/keyboard/keyboard_client.dart';
import 'package:mx_core/keyboard/keyboard_intercept.dart';

class KeyboardController extends TextEditingController {
  KeyboardClient client;

  KeyboardController({String text, this.client}) : super(text: text);

  /// 在光標位置加入文字
  void addText(String insertText) {
    String newText;
    int selectionIndex;
    if (selection.start == -1) {
      newText = text + insertText;
      selectionIndex = newText.length;
    } else {
      newText =
          selection.textBefore(text) + insertText + selection.textAfter(text);
      selectionIndex = selection.baseOffset + insertText.length;
    }
    value = TextEditingValue(
      text: newText,
      selection: selection.copyWith(
        baseOffset: selectionIndex,
        extentOffset: selectionIndex,
      ),
    );
  }

  void setText(String newText) {
    value = TextEditingValue(
      text: newText,
      selection: selection.copyWith(
        baseOffset: newText.length,
        extentOffset: newText.length,
      ),
    );
  }

  /// 在除當前光標位置執行刪除的動作
  /// 當前光標
  ///  * 範圍高亮 => 整段範圍刪除
  ///  * 未選擇範圍 => 在光標位置往前刪除一個字
  ///  * 沒有 selection 是 -1 => 直接刪除最後一個字
  void deleteText() {
    if (selection.baseOffset == 0) return;

    String newText = '';

    if (selection.baseOffset != selection.extentOffset) {
      // 高亮範圍 之前的文字 + 之後的文字
      newText = selection.textBefore(text) + selection.textAfter(text);
      value = TextEditingValue(
        text: newText,
        selection: selection.copyWith(
          baseOffset: selection.baseOffset,
          extentOffset: selection.baseOffset,
        ),
      );
    } else if (selection.baseOffset == -1) {
      // 檢查當前光標, 若為 -1, 則從最後面開始刪除
      newText = text.substring(0, text.length - 1);
      value = TextEditingValue(
          text: newText,
          selection: selection.copyWith(
              baseOffset: newText.length, extentOffset: newText.length));
    } else {
      // 未選擇範圍
      newText = text.substring(0, selection.baseOffset - 1) +
          selection.textAfter(text);
      value = TextEditingValue(
          text: newText,
          selection: selection.copyWith(
              baseOffset: selection.baseOffset - 1,
              extentOffset: selection.baseOffset - 1));
    }
  }

  /// 發送鍵盤動作 (刪除/換行/確認之類)
  void sendAction(TextInputAction action) {
    KeyboardIntercept.getInstance().sendPerformAction(action);
  }
}
