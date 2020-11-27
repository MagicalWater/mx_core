import 'package:flutter/material.dart';

NavigatorState get navigatorIns {
  var ins = _navigatorInitCallback?.call();
  assert(() {
    if (ins == null) {
      return false;
    }
    return true;
  }(), '''
  Need warp MaterialApp class with MxCoreInit
  example:
  MxCoreInit(
    child: MaterialApp(),
  )
  ''');
  return ins;
}

NavigatorState Function() _navigatorInitCallback;

/// 提供 mx_core 使用 navigator 的類別
/// 用於
/// 1. PopUtil 彈窗工具
/// 2. routeMixin 路由管理工具
///
/// 使用方式
/// 於 app 的入口類處添加
/// MxCoreInit(
///   child: MaterialApp(),
/// )
class MxCoreInit extends _NavigatorProvider {
  MxCoreInit({Key key, Widget child}) : super(key: key, child: child);

  @override
  _NavigatorProviderState createState() => _MxCoreInitState();
}

class _MxCoreInitState extends _NavigatorProviderState {
  @override
  void initState() {
    _navigatorInitCallback = _getNavigator;
    super.initState();
  }

  NavigatorState _getNavigator() {
    if (_needSearchNavigator) {
      _needSearchNavigator = false;
      _searchNavigatorState(context);
    }
    return _navigatorState;
  }
}

class _NavigatorProvider extends StatefulWidget {
  final Widget child;

  _NavigatorProvider({Key key, this.child}) : super(key: key);

  @override
  _NavigatorProviderState createState() => _NavigatorProviderState();
}

class _NavigatorProviderState extends State<_NavigatorProvider> {
  /// 是否需要搜索 navigator
  bool _needSearchNavigator;

  NavigatorState _navigatorState;

  @override
  void initState() {
    _needSearchNavigator = true;
    super.initState();
  }

  @override
  void didUpdateWidget(_NavigatorProvider oldWidget) {
    _needSearchNavigator = true;
    super.didUpdateWidget(oldWidget);
  }

  /// 往下找到 navigator
  void _searchNavigatorState(BuildContext context) {
    void visitor(Element element) {
      assert(() {
        if (element.widget is Localizations &&
            ((element as StatefulElement).state as dynamic).locale == null) {
          return false;
        }
        return true;
      }(), 'Initialization error : locale == null');
      if (element.widget is Navigator) {
        if (_navigatorState == null ||
            _navigatorState != (element as StatefulElement).state) {
          _navigatorState = (element as StatefulElement).state;
        }
      } else {
        element.visitChildElements(visitor);
      }
    }

    context.visitChildElements(visitor);
  }

  @override
  Widget build(BuildContext context) {
    _needSearchNavigator = true;
    return widget.child;
  }
}
