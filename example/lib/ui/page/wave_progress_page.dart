import 'package:annotation_route/route.dart';
import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/bloc/page/wave_progress_bloc.dart';

import 'introduction_page.dart';

class WaveProgressPage extends StatefulWidget {
  final RouteOption option;

  WaveProgressPage(this.option) : super();

  @override
  _WaveProgressPageState createState() => _WaveProgressPageState();
}

class _WaveProgressPageState extends State<WaveProgressPage> {
  WaveProgressBloc bloc;

  var title = "波浪進度條";
  var content = """
  波浪進度條
  1. 可根據進度構建內容
  2. 可完整控制元件的構成
  """;

  /// 圓形的進度條控制器
  ProgressController circleProgressController;

  /// 方詳的進度條控制器
  ProgressController rectProgressController;

  @override
  void initState() {
    bloc = BlocProvider.of<WaveProgressBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      haveAppBar: true,
      color: Colors.black,
      title: title,
      child: Container(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              buildIntroduction(content),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  buildControlProgress("進度 -10%", () {
                    var progress = circleProgressController.currentProgress;
                    print("設置進度: 當前: $progress");
                    circleProgressController.setProgress(
                      progress - 10,
                    );
                    rectProgressController.setProgress(
                      progress - 10,
                    );
                  }),
                  Container(
                    width: 20,
                  ),
                  buildControlProgress("進度 +10%", () {
                    var progress = circleProgressController.currentProgress;
                    print("設置進度: 當前: $progress");
                    circleProgressController.setProgress(
                      progress + 10,
                    );
                    rectProgressController.setProgress(
                      progress + 10,
                    );
                  }),
                ],
              ),
              Divider(
                color: Colors.transparent,
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  buildProgress(BoxShape.circle, 100, 100),
                  buildProgress(BoxShape.rectangle, 100, 100),
                ],
              ),
              Divider(
                color: Colors.transparent,
                height: 20,
              ),
              buildProgress(BoxShape.rectangle, 300, 50),
            ],
          ),
        ),
      ),
    );
  }

  /// 構建控制進度的按鈕元件
  Widget buildControlProgress(String title, VoidCallback onTap) {
    return RaisedButton(
      child: Text(title),
      onPressed: onTap,
    );
  }

  /// 構建進度條元件
  Widget buildProgress(BoxShape shape, double width, double height) {
    return Container(
      alignment: Alignment.center,
      child: Container(
        width: width,
        height: height,
        child: WaveProgress(
          shape: shape,
          style: WaveStyle(color: Colors.white, borderColor: Colors.green),
          initProgress: 50,
          builder: (context, progress, total) {
            return Container(
              alignment: Alignment.center,
              child: Text(
                "${((progress / total) * 100).toInt()}%",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            );
          },
          onCreated: (controller) {
            switch (shape) {
              case BoxShape.rectangle:
                rectProgressController = controller;
                break;
              case BoxShape.circle:
                circleProgressController = controller;
                break;
            }
          },
        ),
      ),
    );
  }
}
