import 'package:flutter/material.dart';

export 'text_tab_builder.dart';
export 'widget_tab_builder.dart';

abstract class _BaseBuilder {
  int get tabCount;

  int get actionCount;
}

abstract class TabBuilder implements _BaseBuilder {
  Widget buildTab({bool isSelected, int index, VoidCallback onTap});

  Widget buildAction({int index, VoidCallback onTap});
}

abstract class SwipeTabBuilder implements _BaseBuilder {
  Decoration get swipeDecoration;

  Widget buildTabBackground({bool isSelected, int index});

  Widget buildTabForeground(
      {Size size, bool isSelected, int index, VoidCallback onTap});

  Widget buildActionBackground({int index});

  Widget buildActionForeground({Size size, int index, VoidCallback onTap});
}
