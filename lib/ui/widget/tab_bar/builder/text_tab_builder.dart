import 'package:flutter/material.dart';

import '../tab_style.dart';
import 'builder.dart';

TabStyle<TextStyle> get _defaultTextStyle {
  return TabStyle<TextStyle>(
    select: TextStyle(color: Colors.white, fontSize: 16),
    unSelect: TextStyle(color: Colors.grey[400], fontSize: 16),
  );
}

TextStyle get _defaultActionTextStyle {
  return TextStyle(color: Colors.black, fontSize: 16);
}

class TextTabBuilder extends WidgetTabBuilder {
  final TabStyle<TextStyle> tabTextStyle;
  final TextStyle actionTextStyle;
  final Duration animationDuration = const Duration(milliseconds: 300);
  final Curve animationCurve = Curves.fastOutSlowIn;

  TextTabBuilder({
    List<String> texts,
    EdgeInsetsGeometry padding,
    EdgeInsetsGeometry margin,
    List<String> actions,
    TabStyle<Decoration> tabDecoration,
    this.tabTextStyle,
    Decoration actionDecoration,
    Duration textAnimationDuration = const Duration(milliseconds: 300),
    Curve textAnimationCurve = Curves.fastOutSlowIn,
    this.actionTextStyle,
  }) : super(
          tabBuilder: (
            BuildContext context,
            int index,
            bool isSelected,
            bool foreground,
          ) {
            var textStyle = isSelected
                ? (tabTextStyle?.select ?? _defaultTextStyle.select)
                : (tabTextStyle?.unSelect ?? _defaultTextStyle.unSelect);
            return AnimatedDefaultTextStyle(
              child: Text(texts[index]),
              style: textStyle,
              duration: textAnimationDuration,
              curve: textAnimationCurve,
            );
          },
          actionBuilder: (BuildContext context, int index) {
            var textStyle = actionTextStyle ?? _defaultActionTextStyle;
            return Text(
              actions[index],
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

// class TextTabBuilder implements TabBuilder, SwipeTabBuilder {
//   @override
//   int get tabCount => texts.length;
//
//   @override
//   int get actionCount => actions?.length ?? 0;
//
//   Decoration get swipeDecoration =>
//       tabDecoration?.select ?? _defaultDecoration.select;
//
//   BorderRadius getBorderRadius(Decoration decoration) {
//     if (decoration is BoxDecoration) {
//       return decoration.borderRadius;
//     }
//     return BorderRadius.zero;
//   }
//
//   final TabStyle<Decoration> tabDecoration;
//   final TabStyle<TextStyle> tabTextStyle;
//   final Decoration actionDecoration;
//   final TextStyle actionTextStyle;
//   final List<String> texts;
//   final List<String> actions;
//   final Duration duration;
//   final Curve curve;
//
//   @override
//   final EdgeInsetsGeometry padding;
//
//   @override
//   final EdgeInsetsGeometry margin;
//
//   TextTabBuilder({
//     this.texts,
//     this.padding,
//     this.margin,
//     this.actions,
//     this.tabDecoration,
//     this.tabTextStyle,
//     this.actionDecoration,
//     this.actionTextStyle,
//     this.duration = const Duration(milliseconds: 300),
//     this.curve = Curves.fastOutSlowIn,
//   });
//
//   Decoration get _defaultActionDecoration {
//     return BoxDecoration(
//       borderRadius: BorderRadius.circular(8),
//       color: Colors.grey,
//       border: Border.all(color: Colors.grey),
//     );
//   }
//
//   TextStyle get _defaultActionTextStyle {
//     return TextStyle(color: Colors.black, fontSize: 16);
//   }
//
//   TabStyle<Decoration> get _defaultDecoration {
//     return TabStyle<Decoration>(
//       select: BoxDecoration(
//         borderRadius: BorderRadius.circular(8),
//         color: Colors.blueAccent,
//         border: Border.all(color: Colors.blueAccent),
//       ),
//       unSelect: BoxDecoration(
//         borderRadius: BorderRadius.circular(8),
//         color: Colors.transparent,
//         border: Border.all(color: Colors.blueAccent),
//       ),
//     );
//   }
//

//
//   @override
//   Widget buildTab(
//       {BuildContext context, bool isSelected, int index, VoidCallback onTap}) {
//     var textStyle = isSelected
//         ? (tabTextStyle?.select ?? _defaultTextStyle.select)
//         : (tabTextStyle?.unSelect ?? _defaultTextStyle.unSelect);
//     var decoration = isSelected
//         ? (tabDecoration?.select ?? _defaultDecoration.select)
//         : (tabDecoration?.unSelect ?? _defaultDecoration.unSelect);
//
//     return AnimatedContainer(
//       duration: Duration(milliseconds: 200),
//       decoration: decoration,
//       child: Material(
//         type: MaterialType.transparency,
//         color: Colors.transparent,
//         child: InkWell(
//           borderRadius: getBorderRadius(decoration),
//           onTap: onTap,
//           child: Container(
//             height: double.infinity,
//             padding: padding,
//             margin: margin,
//             alignment: Alignment.center,
//             child: AnimatedDefaultTextStyle(
//               child: Text(texts[index]),
//               style: textStyle,
//               duration: duration,
//               curve: curve,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget buildAction({BuildContext context, int index, VoidCallback onTap}) {
//     var decoration = actionDecoration ?? _defaultActionDecoration;
//     var textStyle = actionTextStyle ?? _defaultActionTextStyle;
//     return MaterialLayer.single(
//       layer: LayerProperties(
//         decoration: decoration,
//       ),
//       onTap: onTap,
//       child: Container(
//         height: double.infinity,
//         padding: padding,
//         margin: margin,
//         alignment: Alignment.center,
//         child: Text(actions[index], style: textStyle),
//       ),
//     );
//   }
//
//   @override
//   Widget buildTabBackground(
//       {BuildContext context, bool isSelected, int index}) {
//     var textStyle = isSelected
//         ? (tabTextStyle?.select ?? _defaultTextStyle.select)
//         : (tabTextStyle?.unSelect ?? _defaultTextStyle.unSelect);
//     var decoration = tabDecoration?.unSelect ?? _defaultDecoration.unSelect;
//
//     return Padding(
//       padding: margin,
//       child: Container(
//         decoration: decoration,
//         padding: padding,
//         child: IgnorePointer(
//           ignoring: true,
//           child: Opacity(
//             opacity: 0,
//             child: AnimatedDefaultTextStyle(
//               child: Text(texts[index]),
//               style: textStyle.copyWith(color: Colors.transparent),
//               duration: duration,
//               curve: curve,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget buildTabForeground(
//       {BuildContext context,
//       Size size,
//       bool isSelected,
//       int index,
//       VoidCallback onTap}) {
//     var textStyle = isSelected
//         ? (tabTextStyle?.select ?? _defaultTextStyle.select)
//         : (tabTextStyle?.unSelect ?? _defaultTextStyle.unSelect);
//
//     var decoration = isSelected
//         ? (tabDecoration?.select ?? _defaultDecoration.select)
//         : (tabDecoration?.unSelect ?? _defaultDecoration.unSelect);
//
//     return SizedOverflowBox(
//       alignment: Alignment.center,
//       size: Size(size.width, size.height),
//       child: Container(
//         width: size.width + 0.5,
//         height: size.height,
//         padding: margin,
//         child: Material(
//           type: MaterialType.transparency,
//           color: Colors.transparent,
//           child: InkWell(
//             borderRadius: getBorderRadius(decoration),
//             onTap: onTap,
//             child: Padding(
//               padding: padding,
//               child: AnimatedDefaultTextStyle(
//                 child: Text(texts[index]),
//                 style: textStyle,
//                 duration: duration,
//                 curve: curve,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget buildActionBackground({BuildContext context, int index}) {
//     var textStyle = actionTextStyle ?? _defaultActionTextStyle;
//     var decoration = actionDecoration ?? _defaultActionDecoration;
//
//     return Padding(
//       padding: margin,
//       child: Container(
//         decoration: decoration,
//         padding: padding,
//         child: IgnorePointer(
//           ignoring: true,
//           child: Opacity(
//             opacity: 0,
//             child: Text(
//               actions[index],
//               style: textStyle.copyWith(color: Colors.transparent),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget buildActionForeground(
//       {BuildContext context, Size size, int index, VoidCallback onTap}) {
//     var textStyle = actionTextStyle ?? _defaultActionTextStyle;
//     var decoration = actionDecoration ?? _defaultActionDecoration;
//
//     return SizedOverflowBox(
//       alignment: Alignment.center,
//       size: Size(size.width, size.height),
//       child: Container(
//         width: size.width + 0.5,
//         height: size.height,
//         padding: margin,
//         child: Material(
//           type: MaterialType.transparency,
//           color: Colors.transparent,
//           child: InkWell(
//             borderRadius: getBorderRadius(decoration),
//             onTap: onTap,
//             child: Padding(
//               padding: padding,
//               child: Text(
//                 actions[index],
//                 style: textStyle,
//                 maxLines: 1,
//                 overflow: TextOverflow.clip,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
