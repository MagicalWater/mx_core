import 'package:annotation_route/route.dart';
import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/bloc/page/test_bloc.dart';

class TestPage extends StatefulWidget {
  final RouteOption option;

  TestPage(this.option) : super();

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage>
    with SingleTickerProviderStateMixin {
  TestBloc bloc;

  @override
  void initState() {
    bloc = BlocProvider.of<TestBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: RaisedButton(
          child: Text('文字按鈕'),
          onPressed: () {
            Popup.showRoute(
              builder: (controller) => Container(
                color: Colors.blueAccent,
                child: Text('aaaa'),
              ),
              option: PopupOption(
                bottom: 100,
                right: 100,
                maskColor: Colors.redAccent.withAlpha(100),
                alignment: Alignment.bottomRight,
              ),
              onTapSpace: (controller) {
                print('點擊空白處');
                controller.remove();
              },
              onTapBack: (controller) {
                print('點擊返回');
                controller.remove();
              },
            );
          },
        ),
      ),
    );
  }
}
