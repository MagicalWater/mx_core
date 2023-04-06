import 'package:flutter/material.dart';

class PopupRouteOption {
  final bool maintainState;
  final bool opaque;
  final Color barrierColor;
  final bool barrierDismissible;
  final String? barrierLabel;
  final bool fullscreenDialog;
  final bool allowSnapshotting;

  const PopupRouteOption({
    this.maintainState = false,
    this.opaque = false,
    this.barrierColor = const Color(0x00ffffff),
    this.barrierDismissible = false,
    this.barrierLabel,
    this.fullscreenDialog = false,
    this.allowSnapshotting = true,
  });
}
