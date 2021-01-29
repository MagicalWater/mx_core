import 'package:meta/meta.dart';

import 'router/router.dart';
import 'util/screen_util.dart';

export 'bloc/bloc.dart';
export 'extension/extension.dart';
export 'http/http.dart';
export 'keyboard/keyboard.dart';
export 'polling/polling.dart';
export 'popup/popup.dart';
export 'request/request.dart';
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
    @required DesignSize designSize,
    RouteSetting routeSetting,
  }) {
    // 設定設計版面size
    Screen.setDesignWHD(
      w: designSize.width,
      h: designSize.height,
      density: designSize.density,
    );

    // 檢查是否需要加入 route 設定
    if (routeSetting != null) {
      settingRoute(
        routeMixin: routeSetting.mixinImpl,
        routeWidget: routeSetting.widgetImpl,
      );
    }
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

/// 上層呼叫此方法設置route
/// [RouteMixin] - 上層專案 使用 routeMixinBase 的實現類別
/// 通常為 ApplicationBloc.getInstance()
///
/// [RouteWidgetBase] - 上層專案 使用  RouteMixin 的實現類別
/// 通常為 RouteWidget.getInstance()
class RouteSetting {
  RouteMixin mixinImpl;
  RouteWidgetBase widgetImpl;

  RouteSetting({
    @required this.mixinImpl,
    @required this.widgetImpl,
  });
}
