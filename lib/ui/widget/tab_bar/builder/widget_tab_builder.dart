import 'package:flutter/material.dart';

import 'builder.dart';

typedef Widget TabWidgetBuilder(
  BuildContext context,
  int index,
  bool selected,
  bool foreground,
);

typedef T TabStyleBuilder<T>(
  int index,
  bool selected,
);

class WidgetTabBuilder implements SwipeTabBuilder {
  @override
  int get actionCount => _actionCount;

  @override
  int get tabCount => _tabCount;

  final int _tabCount;
  final int _actionCount;

  final TabWidgetBuilder tabBuilder;
  final IndexedWidgetBuilder actionBuilder;

  final TabStyleBuilder<Decoration> tabDecoration;
  final Decoration actionDecoration;

  @override
  final EdgeInsetsGeometry padding;

  @override
  final EdgeInsetsGeometry margin;

  WidgetTabBuilder({
    @required this.tabBuilder,
    this.actionBuilder,
    this.tabDecoration,
    this.actionDecoration,
    this.padding,
    this.margin,
    @required int tabCount,
    int actionCount = 0,
  })  : this._tabCount = tabCount,
        this._actionCount = actionCount;

  TabStyleBuilder<Decoration> get swipeDecoration =>
      tabDecoration ?? _defaultDecoration;

  Decoration get _defaultActionDecoration {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      color: Colors.grey,
      border: Border.all(color: Colors.grey),
    );
  }

  TabStyleBuilder<Decoration> _defaultDecoration = (index, selected) {
    if (selected) {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.blueAccent,
        border: Border.all(color: Colors.blueAccent),
      );
    } else {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.transparent,
        border: Border.all(color: Colors.blueAccent),
      );
    }
  };

  @override
  Widget buildActionBackground({BuildContext context, int index}) {
    var decoration = actionDecoration ?? _defaultActionDecoration;
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Container(
        decoration: decoration,
        height: double.infinity,
        alignment: Alignment.center,
        padding: padding,
        child: IgnorePointer(
          ignoring: true,
          child: Opacity(
            opacity: 0,
            child: actionBuilder(context, index),
          ),
        ),
      ),
    );
  }

  @override
  Widget buildActionForeground(
      {BuildContext context, Size size, int index, onTap}) {
    var decoration = actionDecoration ?? _defaultActionDecoration;

    return SizedOverflowBox(
      alignment: Alignment.center,
      size: Size(size.width, size.height),
      child: Padding(
        padding: margin ?? EdgeInsets.zero,
        child: Material(
          type: MaterialType.transparency,
          color: Colors.transparent,
          child: InkWell(
            borderRadius: getBorderRadius(decoration),
            onTap: onTap,
            child: Container(
              width: size.width + 0.5,
              height: size.height,
              alignment: Alignment.center,
              padding: padding,
              child: actionBuilder(context, index),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget buildTabBackground({BuildContext context, bool selected, int index}) {
    var decoration = tabDecoration?.call(index, false) ??
        _defaultDecoration(index, selected);

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Container(
        decoration: decoration,
        padding: padding,
        height: double.infinity,
        alignment: Alignment.center,
        child: IgnorePointer(
          ignoring: true,
          child: Opacity(
            opacity: 0,
            child: tabBuilder(context, index, selected, false),
          ),
        ),
      ),
    );
  }

  @override
  Widget buildTabForeground(
      {BuildContext context, Size size, bool selected, int index, onTap}) {
    var decoration =
        tabDecoration?.call(index, false) ?? _defaultDecoration(index, false);

    return SizedOverflowBox(
      alignment: Alignment.center,
      size: Size(size.width, size.height),
      child: Padding(
        padding: margin ?? EdgeInsets.zero,
        child: Material(
          type: MaterialType.transparency,
          color: Colors.transparent,
          child: InkWell(
            borderRadius: getBorderRadius(decoration),
            onTap: onTap,
            child: Container(
              padding: padding,
              width: size.width + 0.5,
              height: size.height,
              alignment: Alignment.center,
              child: tabBuilder(context, index, selected, true),
            ),
          ),
        ),
      ),
    );
  }

  BorderRadius getBorderRadius(Decoration decoration) {
    if (decoration is BoxDecoration) {
      return decoration.borderRadius;
    }
    return BorderRadius.zero;
  }
}
