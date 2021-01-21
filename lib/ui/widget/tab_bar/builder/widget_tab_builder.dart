import 'package:flutter/material.dart';

import '../tab_style.dart';
import 'builder.dart';

typedef Widget TabWidgetBuilder(
  BuildContext context,
  int index,
  bool isSelected,
  bool foreground,
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
  final Duration duration;
  final Curve curve;

  final TabStyle<Decoration> tabDecoration;
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
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.fastOutSlowIn,
  })  : this._tabCount = tabCount,
        this._actionCount = actionCount;

  Decoration get swipeDecoration =>
      tabDecoration?.select ?? _defaultDecoration.select;

  Decoration get _defaultActionDecoration {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      color: Colors.grey,
      border: Border.all(color: Colors.grey),
    );
  }

  TabStyle<Decoration> get _defaultDecoration {
    return TabStyle<Decoration>(
      select: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.blueAccent,
        border: Border.all(color: Colors.blueAccent),
      ),
      unSelect: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.transparent,
        border: Border.all(color: Colors.blueAccent),
      ),
    );
  }

  @override
  Widget buildActionBackground({BuildContext context, int index}) {
    var decoration = actionDecoration ?? _defaultActionDecoration;
    return Container(
      height: double.infinity,
      padding: padding,
      margin: margin,
      decoration: decoration,
      alignment: Alignment.center,
      child: IgnorePointer(
        ignoring: true,
        child: Opacity(
          opacity: 0,
          child: actionBuilder(context, index),
        ),
      ),
    );
  }

  @override
  Widget buildActionForeground(
      {BuildContext context, Size size, int index, onTap}) {
    var decoration = actionDecoration ?? _defaultActionDecoration;

    return Container(
      padding: margin,
      child: Material(
        type: MaterialType.transparency,
        color: Colors.transparent,
        child: InkWell(
          borderRadius: getBorderRadius(decoration),
          onTap: onTap,
          child: SizedOverflowBox(
            alignment: Alignment.center,
            size: Size(size.width, size.height),
            child: Container(
              width: size.width + 0.5,
              height: size.height,
              padding: padding,
              alignment: Alignment.center,
              child: actionBuilder(context, index),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget buildTabBackground(
      {BuildContext context, bool isSelected, int index}) {
    var decoration = tabDecoration?.unSelect ?? _defaultDecoration.unSelect;
    return Container(
      decoration: decoration,
      height: double.infinity,
      padding: padding,
      margin: margin,
      child: IgnorePointer(
        ignoring: true,
        child: Opacity(
          opacity: 0,
          child: tabBuilder(context, index, isSelected, false),
        ),
      ),
    );
  }

  @override
  Widget buildTabForeground(
      {BuildContext context, Size size, bool isSelected, int index, onTap}) {
    var decoration = isSelected
        ? (tabDecoration?.select ?? _defaultDecoration.select)
        : (tabDecoration?.unSelect ?? _defaultDecoration.unSelect);

    return Container(
      padding: margin,
      child: Material(
        type: MaterialType.transparency,
        color: Colors.transparent,
        child: InkWell(
          borderRadius: getBorderRadius(decoration),
          onTap: onTap,
          child: SizedOverflowBox(
            alignment: Alignment.center,
            size: Size(size.width, size.height),
            child: Container(
              width: size.width + 0.5,
              height: size.height,
              padding: padding,
              child: tabBuilder(context, index, isSelected, true),
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
