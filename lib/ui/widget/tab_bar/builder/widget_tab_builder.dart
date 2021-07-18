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
  final int tabCount;

  @override
  final int actionCount;

  final TabWidgetBuilder tabBuilder;
  final IndexedWidgetBuilder? actionBuilder;

  final TabStyleBuilder<Decoration>? tabDecoration;
  final Decoration? actionDecoration;

  @override
  final EdgeInsetsGeometry? padding;

  @override
  final EdgeInsetsGeometry? margin;

  WidgetTabBuilder({
    required this.tabBuilder,
    required this.tabCount,
    this.actionBuilder,
    this.tabDecoration,
    this.actionDecoration,
    this.padding,
    this.margin,
    this.actionCount = 0,
  }) : assert(tabCount > 0 &&
            ((actionCount > 0 && actionBuilder != null) || actionCount == 0));

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
  Widget buildActionBackground(
      {required BuildContext context, required int index}) {
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
            child: actionBuilder!(context, index),
          ),
        ),
      ),
    );
  }

  @override
  Widget buildActionForeground(
      {required BuildContext context,
      required Size size,
      required int index,
      required VoidCallback onTap}) {
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
              child: actionBuilder!(context, index),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget buildTabBackground(
      {required BuildContext context,
      required bool selected,
      required int index}) {
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
      {required BuildContext context,
      required Size size,
      required bool selected,
      required int index,
      required VoidCallback onTap}) {
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
      return (decoration.borderRadius as BorderRadius?) ??
          BorderRadius.circular(9999);
    }
    return BorderRadius.zero;
  }
}
