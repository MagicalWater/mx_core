import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/ui/widget/base_app_bar.dart';
import 'package:mx_core_example/ui/widget/top_desc.dart';

/// 倒數計時元件
class TimerPage extends StatefulWidget {
  final RouteOption option;

  TimerPage(this.option) : super();

  @override
  _TimerPageState createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  var timerCore = TimerCore(
    totalTime: Duration(seconds: 10),
    tickInterval: Duration(milliseconds: 1000),
  );

  var title = "倒數計時";
  var content = """
  倒數計時
  1. TimerCore 為倒數計時核心, 此類可單獨使用  
  2. TimerBuilder 可自行帶入 timerCore 達到全局/多個倒數計時同步
  """;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: baseAppBar(title),
      body: Column(
        children: <Widget>[
          TopDesc(content: content),
          _timer(),
        ],
      ),
    );
  }

  Widget _timer() {
    return TimerBuilder(
      autoStart: false,
      time: Duration(seconds: 10),
      timerCore: timerCore,
      builder: (
        BuildContext context,
        TimerStatus status,
        Duration time,
      ) {
        String text;
        Color begin, end;

        switch (status) {
          case TimerStatus.standby:
            text = "點擊開始倒數";
            begin = Color(0xffcca068);
            end = Color(0xff8c6018);
            break;
          case TimerStatus.active:
            text = "${time.inSeconds} 秒, 點擊暫停";
            begin = Color(0xffcc6633);
            end = Color(0xffaa4411);
            break;
          case TimerStatus.pause:
            text = "暫停中, 點擊繼續倒數";
            begin = Color(0xff999999);
            end = Color(0xff777777);
            break;
          case TimerStatus.complete:
            text = "完成, 點擊重新倒數";
            begin = Color(0xffcca068);
            end = Color(0xff8c6018);
        }

        return AnimatedComb(
          type: AnimatedType.tap,
          duration: 500,
          child: Container(
            margin: EdgeInsets.all(20),
            height: 80,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    begin,
                    end,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(20)),
            child: Align(
              child: Text(
                text,
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
          animatedList: [
            Comb.scale(
              end: Size.square(0.8),
              curve: Curves.bounceOut,
            ),
          ],
          onTapAfterAnimated: () {
            switch (status) {
              case TimerStatus.standby:
                timerCore.start();
                break;
              case TimerStatus.active:
                timerCore.pause();
                break;
              case TimerStatus.pause:
                timerCore.start();
                break;
              case TimerStatus.complete:
                timerCore.start();
                break;
            }
          },
        );
      },
    );
  }
}
