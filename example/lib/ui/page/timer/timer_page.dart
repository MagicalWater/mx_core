import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/ui/widget/base_app_bar.dart';
import 'package:mx_core_example/ui/widget/top_desc.dart';

/// 倒數計時元件
class TimerPage extends StatefulWidget {
  final RouteOption option;

  const TimerPage(this.option, {super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  var timerCore = TimerCore(
    totalTime: const Duration(seconds: 10),
    tickInterval: const Duration(milliseconds: 1000),
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
      time: const Duration(seconds: 10),
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
            begin = const Color(0xffcca068);
            end = const Color(0xff8c6018);
            break;
          case TimerStatus.active:
            text = "${time.inSeconds} 秒, 點擊暫停";
            begin = const Color(0xffcc6633);
            end = const Color(0xffaa4411);
            break;
          case TimerStatus.pause:
            text = "暫停中, 點擊繼續倒數";
            begin = const Color(0xff999999);
            end = const Color(0xff777777);
            break;
          case TimerStatus.stop:
            text = "已停止, 點擊重新倒數";
            begin = const Color(0xffcca068);
            end = const Color(0xff8c6018);
            break;
          case TimerStatus.complete:
            text = "完成, 點擊重新倒數";
            begin = const Color(0xffcca068);
            end = const Color(0xff8c6018);
            break;
        }

        return AnimatedComb(
          type: AnimatedType.tap,
          duration: 500,
          animatedList: [
            Comb.scale(
              end: const Size.square(0.8),
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
              case TimerStatus.stop:
                timerCore.start();
                break;
            }
          },
          child: Container(
            margin: const EdgeInsets.all(20),
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
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
        );
      },
    );
  }
}
