import 'package:mx_core/http/http_util.dart';

class NetworkUtil {
  NetworkUtil._();

  /// 取得外網ip
  static Future<String?> getPublicIP() {
    var ip = HttpUtil().get("https://api.ipify.org");
    return ip.then((response) => response.getString());
  }
}
