import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';

import 'builder.dart';

TextStyle _defaultTextStyle(index, selected) {
  if (selected) {
    return const TextStyle(color: Colors.white, fontSize: 16);
  } else {
    return TextStyle(color: Colors.grey[400], fontSize: 16);
  }
}

TextStyle get _defaultActionTextStyle {
  return const TextStyle(color: Colors.black, fontSize: 16);
}

class TextTabBuilder extends WidgetTabBuilder {
  final TabStyleBuilder<TextStyle>? tabTextStyle;
  final TextStyle? actionTextStyle;
  final Duration animationDuration = const Duration(milliseconds: 300);
  final Curve animationCurve = Curves.fastOutSlowIn;
  final TextAlign textAlign;

  TextTabBuilder({
    required List<String> texts,
    EdgeInsets? padding,
    EdgeInsets? margin,
    List<String>? actions,
    TabStyleBuilder<Decoration>? tabDecoration,
    this.textAlign = TextAlign.center,
    this.tabTextStyle,
    Decoration? actionDecoration,
    Duration textAnimationDuration = const Duration(milliseconds: 300),
    Curve textAnimationCurve = Curves.fastOutSlowIn,
    this.actionTextStyle,
  }) : super(
          tabBuilder: (
            BuildContext context,
            int index,
            bool selected,
            bool foreground,
          ) {
            var textStyle = tabTextStyle?.call(index, selected) ??
                _defaultTextStyle(index, selected);
            return Text(
              texts[index],
              textAlign: textAlign,
              style: textStyle,
              maxLines: 1,
              overflow: TextOverflow.clip,
            );
            // return AnimatedDefaultTextStyle(
            //   child: Text(
            //     texts[index],
            //     maxLines: 1,
            //   ),
            //   textAlign: textAlign,
            //   style: textStyle,
            //   duration: textAnimationDuration,
            //   curve: textAnimationCurve,
            //   maxLines: 1,
            // );
          },
          actionBuilder: (BuildContext context, int index) {
            var textStyle = actionTextStyle ?? _defaultActionTextStyle;
            return Text(
              actions![index],
              textAlign: textAlign,
              style: textStyle,
              maxLines: 1,
              overflow: TextOverflow.clip,
            );
          },
          tabDecoration: tabDecoration,
          actionDecoration: actionDecoration,
          padding: padding,
          margin: margin,
          tabCount: texts.length,
          actionCount: actions?.length ?? 0,
        );
}
