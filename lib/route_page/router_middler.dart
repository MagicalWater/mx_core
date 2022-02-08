import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:collection/collection.dart';
import 'package:mx_core/router/router.dart';
import 'package:rxdart/rxdart.dart';

part 'page_router.dart';

typedef _RouterBuilder<T extends PageRouter> = T Function();

extension RouteContext on BuildContext {
  T? pageRoute<T extends PageRouter>() {
    return RouterMiddler.of(this);
  }
}

class RouterMiddler<T extends PageRouter> extends StatefulWidget {
  const RouterMiddler({
    Key? key,
    required this.childBuilder,
    required this.routeBuilder,
  }) : super(key: key);

  final _RouterBuilder<T> routeBuilder;
  final WidgetBuilder childBuilder;

  @override
  RouterMiddlerState<T> createState() => RouterMiddlerState<T>();

  static T? of<T extends PageRouter>(BuildContext context) {
    var providerState =
        context.findAncestorStateOfType<RouterMiddlerState<T>>();
    return providerState?._route;
  }
}

class RouterMiddlerState<T extends PageRouter> extends State<RouterMiddler<T>> {
  late T _route;

  @override
  void initState() {
    _route = widget.routeBuilder();
    _route._registerSubPageStream(
      defaultRoute: _route.defaultSubPage(),
    );
    super.initState();
  }

  @override
  void dispose() {
    _route.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.childBuilder(context);
  }
}
