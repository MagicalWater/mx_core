import 'package:flutter/material.dart';
import 'package:mx_core/keyboard/keyboard_intercept.dart';

/// 自訂義鍵盤的 mediaQuery, 用來套在鍵盤佈局的最外層
/// <p>目的為控制鍵盤出現時, 是否要升起佈局</>
class KeyboardMediaQuery extends StatefulWidget {
  final Widget child;

  KeyboardMediaQuery({@required this.child});

  @override
  KeyboardMediaQueryState createState() => KeyboardMediaQueryState();
}

class KeyboardMediaQueryState extends State<KeyboardMediaQuery> {
  @override
  Widget build(BuildContext context) {
    // 取得當前的 mediaQuery
    final mediaQuery = MediaQuery.of(context);

    final currentKeyboardHeight =
        KeyboardIntercept.getInstance().currentKeyboardHeight;

    final mediaQueryData = mediaQuery.copyWith(
      viewInsets: mediaQuery.viewInsets.copyWith(
        bottom: currentKeyboardHeight,
      ),
    );

    // 使用 AnimatedSwitcher 達成鍵盤內容切換時的動畫顯示
    // 只有在外層是 ScrollView 時有作用
    // 其餘無法以動畫切換
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 500),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeOut,
      child: WillPopScope(
        onWillPop: () async {
          if (KeyboardIntercept.getInstance().isKeyboardShow) {
            KeyboardIntercept.getInstance().hideKeyboard(animation: true);
          }
          return true;
        },
        child: MediaQuery(
          data: mediaQueryData,
          child: Builder(builder: (context) {
            // 在此進行當前鍵盤context的綁定
            KeyboardIntercept.getInstance().intercept(context);
            return widget.child;
          }),
        ),
      ),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return SizeTransition(
          sizeFactor: animation,
          child: child,
        );
      },
    );
  }

  /// 鍵盤狀態改變後呼叫 widget 進行刷新
  void update() {
    WidgetsBinding.instance
        .addPostFrameCallback((Duration _) => setState(() {}));
  }
}
