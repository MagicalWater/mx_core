import 'package:mx_core/http/http_util.dart';
import 'package:rxdart/rxdart.dart';

class NetworkUtil {
  NetworkUtil._();

  /// 取得外網ip
  static Stream<String> getPublicIP() {
    var ip = HttpUtil.getInstance().get("https://api.ipify.org");
    return ip.map((response) => response.getString());
  }
}
