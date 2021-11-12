import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';

class TopDesc extends StatelessWidget {
  final String content;

  const TopDesc({required this.content});

  @override
  Widget build(BuildContext context) {
    return InfoPopup(
      child: FractionallySizedBox(
        widthFactor: 1,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xff2b9eda),
                Color(0xff68c3fb),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.all(12),
          padding: EdgeInsets.all(12),
          child: Text(
            content,
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ),
    );
  }
}
