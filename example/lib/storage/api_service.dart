import 'package:mx_core/mx_core.dart';
import '../bean/bean_converter.dart';

class ApiService {
  /// 资料验证
  static T? convertBean<T>(String json) {
    return BeanConverter.convert<T>(json);
  }
}

/// 验证登入
extension ApiAuthVerify on Stream<ServerResponse> {
  Stream<ServerResponse> verifyOAuth() {
    return handleError(
          (error, stacktrace) {
        print('准备传出登入验证失败');
//        if (AccountStorage().onOAuthFail != null) {
//          print('传送');
//          AccountStorage().onOAuthFail();
//        } else {
          throw error;
//        }
      },
      test: (error) {
            // 401 通常是沒有登入權限, 驗證失敗
        return error is HttpError && error.response?.getStatusCode() == 401;
      },
    );
  }
}