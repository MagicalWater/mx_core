import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';

PreferredSizeWidget baseAppBar(String title) {
  Widget titleWidget = Text(
    title ?? '',
    style: TextStyle(
      color: Colors.white,
      fontSize: 16.scaleA,
    ),
  );
  return PreferredSize(
    preferredSize: Size.fromHeight(
      kToolbarHeight,
    ),
    child: AppBar(
      title: titleWidget,
      iconTheme: IconThemeData(
        color: Colors.black,
        size: 20.scaleA,
      ),
    ),
  );
}
