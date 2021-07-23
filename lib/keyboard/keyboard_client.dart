import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mx_core/keyboard/keyboard_intercept.dart';

/// 在鍵盤需要生成時
/// <p>將攔截到 [KeyboardMessageMethod.setClient] 消息的內容轉為此類</p>
class KeyboardClient {
  final int connectionId;
  final TextInputConfiguration configuration;

  KeyboardClient({
    required this.connectionId,
    required this.configuration,
  });

  factory KeyboardClient.fromArgs(List<dynamic> args) {
    Map<String, dynamic> inputTypeMap = args[1]['inputType'];
    return KeyboardClient(
      connectionId: args[0],
      configuration: TextInputConfiguration(
        inputType: KeyboardInputType(
          name: inputTypeMap['name'],
          signed: inputTypeMap['signed'],
          decimal: inputTypeMap['decimal'],
        ),
        obscureText: args[1]['obscureText'],
        autocorrect: args[1]['autocorrect'],
        actionLabel: args[1]['actionLabel'],
        inputAction: _toTextInputAction(args[1]['inputAction']),
        textCapitalization:
            _toTextCapitalization(args[1]['textCapitalization']),
        keyboardAppearance: _toBrightness(args[1]['keyboardAppearance']),
      ),
    );
  }
}

/// ************* 以下為底層的消息轉換直接複製 *************
/// 將 json 的 bean 裡的 action 轉成對應有意義的 action
TextInputAction _toTextInputAction(String action) {
  switch (action) {
    case 'TextInputAction.none':
      return TextInputAction.none;
    case 'TextInputAction.unspecified':
      return TextInputAction.unspecified;
    case 'TextInputAction.go':
      return TextInputAction.go;
    case 'TextInputAction.search':
      return TextInputAction.search;
    case 'TextInputAction.send':
      return TextInputAction.send;
    case 'TextInputAction.next':
      return TextInputAction.next;
    case 'TextInputAction.previuos':
      return TextInputAction.previous;
    case 'TextInputAction.continue_action':
      return TextInputAction.continueAction;
    case 'TextInputAction.join':
      return TextInputAction.join;
    case 'TextInputAction.route':
      return TextInputAction.route;
    case 'TextInputAction.emergencyCall':
      return TextInputAction.emergencyCall;
    case 'TextInputAction.done':
      return TextInputAction.done;
    case 'TextInputAction.newline':
      return TextInputAction.newline;
  }
  throw FlutterError('Unknown text input action: $action');
}

TextCapitalization _toTextCapitalization(String capitalization) {
  switch (capitalization) {
    case 'TextCapitalization.none':
      return TextCapitalization.none;
    case 'TextCapitalization.characters':
      return TextCapitalization.characters;
    case 'TextCapitalization.sentences':
      return TextCapitalization.sentences;
    case 'TextCapitalization.words':
      return TextCapitalization.words;
  }

  throw FlutterError('Unknown text capitalization: $capitalization');
}

Brightness _toBrightness(String brightness) {
  switch (brightness) {
    case 'Brightness.dark':
      return Brightness.dark;
    case 'Brightness.light':
      return Brightness.light;
  }

  throw FlutterError('Unknown Brightness: $brightness');
}
