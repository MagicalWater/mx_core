import 'package:flutter/material.dart';

class AlignExpandedConstraints extends BoxConstraints {
  final bool enableExpanded;

  AlignExpandedConstraints.from({
    required this.enableExpanded,
    BoxConstraints constraints = const BoxConstraints(),
  }) : super(
          minWidth: constraints.minWidth,
          maxWidth: constraints.maxWidth,
          minHeight: constraints.minHeight,
          maxHeight: constraints.maxHeight,
        );

  const AlignExpandedConstraints({
    required this.enableExpanded,
    double minWidth = 0.0,
    double maxWidth = double.infinity,
    double minHeight = 0.0,
    double maxHeight = double.infinity,
  }) : super(
          minWidth: minWidth,
          maxWidth: maxWidth,
          minHeight: minHeight,
          maxHeight: maxHeight,
        );

  @override
  AlignExpandedConstraints copyWith(
      {bool? enableExpanded,
      double? minWidth,
      double? maxWidth,
      double? minHeight,
      double? maxHeight}) {
    return super
        .copyWith(
          minWidth: minWidth,
          maxWidth: maxWidth,
          minHeight: minHeight,
          maxHeight: maxHeight,
        )
        .toAlignExpanded(enableExpanded ?? this.enableExpanded);
  }

  @override
  bool operator ==(dynamic other) {
    if (other is AlignExpandedConstraints) {
      return super == (other) && this.enableExpanded == other.enableExpanded;
    }
    return false;
  }

  @override
  int get hashCode => super.hashCode;
}

extension AlignConstaint on BoxConstraints {
  AlignExpandedConstraints toAlignExpanded([bool enableExpanded = false]) {
    return AlignExpandedConstraints.from(
      enableExpanded: enableExpanded,
      constraints: this,
    );
  }
}
