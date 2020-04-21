import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';

class ExDialog extends Dialog {
  ExDialog() : super();

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.8,
      child: Align(
        heightFactor: 1,
        child: Card(
          child: Material(
            color: Colors.transparent,
            child: Container(
              child: _BodyWidget(),
            ),
          ),
        ),
      ),
    );
  }
}

class _BodyWidget extends StatelessWidget {
  _BodyWidget();

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
