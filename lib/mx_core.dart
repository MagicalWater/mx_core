import 'router/router.dart';
import 'util/screen_util.dart';

export 'extension/extension.dart';
export 'keyboard/keyboard.dart';
export 'polling/polling.dart';
export 'popup/popup.dart';
export 'route_page/route_page.dart';
export 'router/router.dart';
export 'storage/storage.dart';
export 'ui/widget/widget.dart';
export 'util/util.dart';

/// 專案初始化核心
class ProjectCore {
  /// 初始化設定基底
  /// [designSize] - 設計版面 size
  /// [routeSetting] - 專案若有用到跳頁面以及route相關的事情, 則需要帶入
  static void setting({
    required DesignSize designSize,
    RouteSetting? routeSetting,
  }) {
    // 設定設計版面size
    Screen.setDesignWHD(
      w: designSize.width,
      h: designSize.height,
      density: designSize.density,
    );

    // 檢查是否需要加入 route 設定
    if (routeSetting != null) {
      _settingRoute(
        routeWidget: routeSetting.widgetImpl,
      );
    }
  }

  /// 設置route
  /// [routeWidget] - 上層專案 使用  RouteMixin 的實現類別
  /// 通常為 RouteWidget.getInstance()
  static void _settingRoute({
    required RouteWidgetBase routeWidget,
  }) {
    routeWidgetImpl = routeWidget;
  }
}

/// 設計版面size
class DesignSize {
  /// 寬 / 高
  double width, height;

  /// 密度
  double density;

  DesignSize(
    this.width,
    this.height, {
    this.density = 3.0,
  });
}

/// [RouteWidgetBase] - 上層專案, 構建 route 與 widget 對應的類別
/// 通常為 RouteWidget.getInstance()
class RouteSetting {
  RouteWidgetBase widgetImpl;

  RouteSetting({
    required this.widgetImpl,
  });
}
