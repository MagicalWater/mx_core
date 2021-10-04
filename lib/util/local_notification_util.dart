import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// 本地推送工具
class LocalNotificationUtil {
  LocalNotificationUtil({
    required String androidIcon,
  }) {
    /// 初始化通知設定
    FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();
    var settingsAndroid = AndroidInitializationSettings(androidIcon);
    var settingsIOS = IOSInitializationSettings(
      onDidReceiveLocalNotification: onReceiveIOS,
    );
    var settings = InitializationSettings(
      android: settingsAndroid,
      iOS: settingsIOS,
    );
    plugin.initialize(
      settings,
      onSelectNotification: onSelectNotification,
    );
  }

  /// 當 iOS 版本 < 10.0, 並且應用位於前台時, 在此處可收到通知, 但是並不會顯示在螢幕上, 因此需要手動呼叫
  Future<dynamic> onReceiveIOS(
      int id, String? title, String? body, String? payload) async {
    print("收到前台通知: 標題 - $title, 內容 - $body");
  }

  /// 當通知被點擊時, 觸發此方法
  Future<dynamic> onSelectNotification(String? payload) async {
    print("通知被點擊: payload - ${payload ?? "null"}");
  }

  /// 顯示一個通知
  Future<void> showNotification({
    required int id,
    required String title,
    required String content,
    String? payload,
  }) {
    FlutterLocalNotificationsPlugin notificationsPlugin =
        FlutterLocalNotificationsPlugin();
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      '12345',
      '這是通道名稱',
      '這是通道說明',
      importance: Importance.max,
      priority: Priority.high,
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var channelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
//    print("觸發通知開始");
    return notificationsPlugin.show(
      id,
      title,
      content,
      channelSpecifics,
      payload: payload,
    );
//    print("觸發通知結束");
  }
}
