import 'package:path/path.dart';

/// 路由相關計算方法
class RouteCompute {
  /// 傳入 [parent], [sub] 兩個擁有親子關西 route
  /// 取得 [parent] 路由下個節點 route
  static String getNextRoute({String parent, String sub}) {
    if (!isSubPage(parent, sub, depth: null)) {
      // parent 以及 sub 並非親子關西
      // 因此無法取得 parent 的下個節點
      return null;
    }

    var parentSplit = split(parent);
    var subSplit = split(sub);
    var next = subSplit[parentSplit.length];

    return "$parent/$next";
  }

  /// 檢查 [route] 是否為一個祖父節點
  static bool isAncestorRoute(String route) {
    var routeSplit = split(route);
    return routeSplit.length == 2 && routeSplit[0] == "/";
  }

  /// 取得 [route] 的根節點 route, 即是祖父節點
  static String getAncestorRoute(String route) {
//    print('rr = $route');
//    if (route == null) {
//      print(StackTrace.current);
//    }
    return "/${split(route)[1]}";
  }

  /// 取得 route 頁面層級
  static int getRouteLevel(String route) {
    return split(route).length - 1;
  }

  /// 取得 route 的上個節點路徑
  static String getParentRoute(String route) {
    if (isAncestorRoute(route)) {
      print('根節點沒有父親: $route');
      return null;
    }
    return "${(split(route)..removeLast()).join('/').substring(1)}";
  }

  /// 檢查 [sub] 是否為 [parent] 的子頁面
  /// [depth] 代表 [sub] 是否為 [parent] 下得第 [depth] 層子頁面
  /// 例如
  /// parent = /root
  /// sub = /root/sub
  /// 結果
  /// 當 depth = 1 時, 為 true
  /// 當 depth = 2 時, 為 false
  /// 當 depth = null 時, 代表不需要檢查深度, 只要深度較深即可
  static bool isSubPage(String parent, String sub, {int depth = 1}) {
    var parentSplit = split(parent);
    var subSplit = split(sub);

    if (depth != null && depth <= 0) {
      print("depth 必須大於0");
      return false;
    }

    if (subSplit.length <= parentSplit.length) {
      return false;
    }

    // 檢查節點長度是否正確
    bool isNodeLengthOk;
    if (depth == null) {
      isNodeLengthOk = subSplit.length > parentSplit.length;
    } else {
      isNodeLengthOk = subSplit.length == parentSplit.length + depth;
    }

    // 檢查節點名稱是否符合
    var isNodeNameOk = true;
    for (var i = 0; i < parentSplit.length; i++) {
      if (parentSplit[i] != subSplit[i]) {
        isNodeNameOk = false;
        break;
      }
    }
    return isNodeLengthOk && isNodeNameOk;
  }
}
