import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';

export 'text_tab_builder.dart';
export 'widget_tab_builder.dart';

abstract class _BaseBuilder {
  int get tabCount;

  int get actionCount;
}

abstract class TabBuilder implements _BaseBuilder {
  Widget buildTab({
    BuildContext context,
    bool isSelected,
    int index,
    VoidCallback onTap,
  });

  Widget buildAction({
    BuildContext context,
    int index,
    VoidCallback onTap,
  });
}

abstract class SwipeTabBuilder implements _BaseBuilder {
  TabStyleBuilder<Decoration> get swipeDecoration;

  EdgeInsets? get padding;

  EdgeInsets? get margin;

  /// 是否需有點擊回饋
  bool get tapColorFeedback;

  Widget buildTabBackground({
    required BuildContext context,
    required bool selected,
    required int index,
  });

  Widget buildTabForeground({
    required BuildContext context,
    required Size size,
    required bool selected,
    required int index,
    required VoidCallback onTap,
  });

  Widget buildActionBackground({
    required BuildContext context,
    required int index,
  });

  Widget buildActionForeground({
    required BuildContext context,
    required Size size,
    required int index,
    required VoidCallback onTap,
  });
}
