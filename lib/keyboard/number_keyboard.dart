import 'package:flutter/material.dart';
import 'package:mx_core/ui/widget/material_layer.dart';
import 'package:mx_core/util/screen_util.dart';

import 'keyboard_controller.dart';
import 'keyboard_intercept.dart';

/// 數字鍵盤
class NumberKeyboard extends StatelessWidget {
  static KeyboardInputType inputType =
      const KeyboardInputType(name: 'NumberKeyboard');

  /// 有快捷欄的鍵盤高度
  static const double _keyboardNoShortcutHeight = 250;

  /// 沒有快捷欄的鍵盤高度
  static const double _keyboardShortcutHeight = 300;

  /// 鍵盤高度
  static double keyboardHeight = _keyboardNoShortcutHeight;

  final KeyboardController keyboardController;

  /// 快捷按鈕
  final List<ShortcutPadButton>? shortcuts;

  final String confirmTitle;

  const NumberKeyboard({
    Key? key,
    required this.keyboardController,
    required this.confirmTitle,
    this.shortcuts,
  }) : super(key: key);

  /// 將此 keyboard 註冊到 keyboard intercept
  static void register({
    List<ShortcutPadButton> shortcuts = const [],
    String confirmTitle = '确认',
  }) {
    keyboardHeight =
        shortcuts.isEmpty ? _keyboardNoShortcutHeight : _keyboardShortcutHeight;
    KeyboardIntercept.addKeyboard(
      inputType,
      KeyboardConfig(
        height: keyboardHeight,
        builder: (context, controller) {
          return NumberKeyboard(
            keyboardController: controller,
            confirmTitle: confirmTitle,
            shortcuts: shortcuts,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: Screen.width,
      height: keyboardHeight,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Builder(builder: (context) {
            if (shortcuts == null || shortcuts!.isEmpty) return Container();
            return Expanded(
              flex: 1,
              child: Container(
                color: const Color(0xffefefef),
                padding: EdgeInsets.symmetric(vertical: Screen.scaleA(4)),
                child: Row(
                  children: List.generate(
                    shortcuts!.length,
                    (index) => _buildShortcutButton(
                      text: shortcuts![index].title,
                      onTap: shortcuts![index].onTap,
                    ),
                  ),
                ),
              ),
            );
          }),
          Expanded(
            flex: 4,
            child: Container(
              padding: EdgeInsets.all(Screen.scaleA(8)),
              child: Column(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: <Widget>[
                        _buildNumberButton(text: '1'),
                        _buildNumberButton(text: '2'),
                        _buildNumberButton(text: '3'),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: <Widget>[
                        _buildNumberButton(text: '4'),
                        _buildNumberButton(text: '5'),
                        _buildNumberButton(text: '6'),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: <Widget>[
                        _buildNumberButton(text: '7'),
                        _buildNumberButton(text: '8'),
                        _buildNumberButton(text: '9'),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: <Widget>[
                        _buildNumberButton(
                          icon: Icons.backspace,
                          onTap: () => keyboardController.deleteText(),
                        ),
                        _buildNumberButton(text: '0'),
                        _buildConfirmButton(text: confirmTitle),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(
            height: Screen.bottomBarHeight,
            color: Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutButton({
    required String text,
    required void Function(KeyboardController controller) onTap,
  }) {
    return Expanded(
      flex: 1,
      child: FractionallySizedBox(
        heightFactor: 1,
        child: Padding(
          padding: EdgeInsets.all(Screen.scaleA(8)),
          child: MaterialLayer.single(
            layer: LayerProperties(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: AlignmentDirectional.topCenter,
                  end: AlignmentDirectional.bottomCenter,
                  colors: [
                    Colors.white,
                    Color(0xffededed),
                  ],
                ),
                border: Border.all(
                  color: const Color(0xffd9d9d9),
                  width: Screen.scaleA(1),
                ),
              ),
            ),
            child: Center(
              child: Text(
                text,
                style:
                    TextStyle(color: Colors.black, fontSize: Screen.scaleA(16)),
              ),
            ),
            onTap: () => onTap(keyboardController),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberButton({
    String? text,
    IconData? icon,
    VoidCallback? onTap,
  }) {
    return Expanded(
      flex: 1,
      child: FractionallySizedBox(
        heightFactor: 1,
        child: Padding(
          padding: EdgeInsets.all(Screen.scaleA(4)),
          child: MaterialLayer.single(
            layer: LayerProperties(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: AlignmentDirectional.topCenter,
                  end: AlignmentDirectional.bottomCenter,
                  colors: [
                    Colors.white,
                    Color(0xffededed),
                  ],
                ),
                border: Border.all(
                  color: const Color(0xffd9d9d9),
                  width: Screen.scaleA(1),
                ),
              ),
            ),
            child: Center(
              child: text == null
                  ? Icon(
                      icon,
                      size: 25,
                      color: Colors.black,
                    )
                  : Text(
                      text,
                      style: TextStyle(
                          color: Colors.black, fontSize: Screen.scaleA(22)),
                    ),
            ),
            onTap: onTap ?? () => keyboardController.addText(text ?? ''),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton({required String text}) {
    return Expanded(
      flex: 1,
      child: FractionallySizedBox(
        heightFactor: 1,
        child: Padding(
          padding: EdgeInsets.all(Screen.scaleA(4)),
          child: MaterialLayer.single(
            layer: LayerProperties(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: AlignmentDirectional.topCenter,
                  end: AlignmentDirectional.bottomCenter,
                  colors: [
                    Color(0xfffcd098),
                    Color(0xfff85f62),
                  ],
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(Screen.scaleA(4)),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x89f96f78),
                    blurRadius: 1,
                  ),
                ],
              ),
            ),
            child: Center(
              child: Text(
                text,
                style:
                    TextStyle(color: Colors.white, fontSize: Screen.scaleA(22)),
              ),
            ),
            onTap: () => keyboardController.sendAction(TextInputAction.done),
          ),
        ),
      ),
    );
  }
}

/// 自定義 pad 的按鈕
class ShortcutPadButton {
  String title;

  void Function(KeyboardController controller) onTap;

  ShortcutPadButton({required this.title, required this.onTap});
}
