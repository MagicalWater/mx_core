import 'package:flutter/material.dart';

/// 鍵盤外層 Widget
/// 控制鍵盤動畫進入/退出
class KeyboardPage extends StatefulWidget {
  final Widget child;
  final double height;

  const KeyboardPage({
    Key? key,
    required this.child,
    required this.height,
  }) : super(key: key);

  @override
  KeyboardPageState createState() => KeyboardPageState();
}

class KeyboardPageState extends State<KeyboardPage>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> doubleAnimation;

  @override
  void initState() {
    animationController = AnimationController(
      reverseDuration: Duration(milliseconds: 500),
      duration: Duration(milliseconds: 500),
      vsync: this,
    )..addListener(() {
//        print("觸發動畫");
        setState(() {});
      });
    final Animation<double> curve = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeOut,
    );
    doubleAnimation = Tween(
      begin: 0.0,
      end: widget.height,
    ).animate(curve);
    animationController.forward(from: 0.0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
        child: IntrinsicHeight(child: widget.child),
        bottom: (widget.height - doubleAnimation.value) * -1);
  }

  @override
  void dispose() {
    print("動畫 dispose");

    /// 當動畫狀態為正在執行時, 呼叫動畫狀態為 dismissed
    if (animationController.status == AnimationStatus.forward ||
        animationController.status == AnimationStatus.reverse) {
      animationController.notifyStatusListeners(AnimationStatus.dismissed);
    }
    animationController.dispose();
    super.dispose();
  }

  /// 動畫隱藏 keyboard
  void hideKeyboard() {
    print("動畫 hideKeyboard");
    animationController.reverse();
  }
}
