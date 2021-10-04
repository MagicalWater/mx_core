// export 'keyboard_controller.dart';
// export 'keyboard_intercept.dart';
// export 'keyboard_media_query.dart';
// export 'number_keyboard.dart';

/// 已棄用
/// 詳情可看 [KeyboardIntercept._intercept] 方法的解釋
/// 為方便查看註釋, 張貼於此
/// ===
///
/// 2021/10/04
/// 由於 flutter 2.5 之後將 setMessageHandler 方法移至 flutter_test 裡
/// 按照原作者的解法是自建兩個類(假設為A,B)分別繼承 [WidgetsFlutterBinding] 以及 [BinaryMessenger]
/// B類完全複製於flutter_test的[TestDefaultBinaryMessenger]
/// A類複寫變數 [WidgetsFlutterBinding.defaultBinaryMessenger], 將之返回B類
/// 個人擔心使用flutter_test的binary_messenger在運作上可能會產生一些意料之外的錯誤
/// 因此暫時不跟進使用, 自定鍵盤暫時棄用
