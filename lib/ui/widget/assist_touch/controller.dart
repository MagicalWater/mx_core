part of 'assist_touch.dart';

/// 輔助按鈕控制
class AssistTouchController {
  _AssistTouchState? _bind;

  bool get isExpand {
    if (_bind == null) {
      throw Exception('輔助按鈕尚未綁定到 _AssistTouchState');
    }

    return _bind!.isExpand;
  }

  /// 切換展開狀態
  /// [expand] - 是否展開, 若無賦予值, 則會按照當前是否展開來切換
  Future<void> toggleExpand({bool? expand}) {
    if (_bind == null) {
      throw Exception('輔助按鈕尚未綁定到 _AssistTouchState');
    }

    return _bind!.toggleExpand(expand: expand);
  }

  void dispose() {
    _bind = null;
  }
}