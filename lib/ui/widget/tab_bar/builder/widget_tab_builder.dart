import 'package:flutter/material.dart';

import 'builder.dart';

class WidgetTabBuilder implements TabBuilder {
  @override
  int get actionCount => _actionCount;

  @override
  int get tabCount => _tabCount;

  final int _tabCount;
  final int _actionCount;

  final IndexedWidgetBuilder tabBuilder;
  final IndexedWidgetBuilder actionBuilder;
  final Duration duration;
  final Curve curve;

  WidgetTabBuilder({
    this.tabBuilder,
    this.actionBuilder,
    int tabCount,
    int actionCount,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.fastOutSlowIn,
  })  : this._tabCount = tabCount,
        this._actionCount = actionCount;

  @override
  Widget buildAction({int index, onTap}) {
    // TODO: implement buildAction
    throw UnimplementedError();
  }

  @override
  Widget buildTab({bool isSelected, int index, onTap}) {
    // TODO: implement buildTab
    throw UnimplementedError();
  }
}
