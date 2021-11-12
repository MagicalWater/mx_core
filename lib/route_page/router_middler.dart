import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mx_core/extension/extension.dart';
import 'package:mx_core/router/router.dart';
import 'package:rxdart/rxdart.dart';

part 'page_router.dart';

class RouterMiddler extends StatefulWidget {
  RouterMiddler({
    Key? key,
    required this.childBuilder,
    required this.routeBuilder,
  }) : super(key: key);

  final PageRouter Function() routeBuilder;
  final WidgetBuilder childBuilder;

  @override
  RouterMiddlerState createState() => RouterMiddlerState();
}

class RouterMiddlerState extends State<RouterMiddler> {
  late PageRouter _route;

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
