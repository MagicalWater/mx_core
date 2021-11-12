import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/ui/widget/base_app_bar.dart';
import 'package:mx_core_example/ui/widget/top_desc.dart';

/// 跑馬燈範例頁面
class MarqueePage extends StatefulWidget {
  final RouteOption option;

  MarqueePage(this.option) : super();

  @override
  _MarqueePageState createState() => _MarqueePageState();
}

class _MarqueePageState extends State<MarqueePage> {
  var title = "跑馬燈";
  var content = """
  跑馬燈
  1. 可放入純文字, 也可放入Widget
  2. 為了使跑馬燈無限循環, 有以下限制
    a. 若使用Widget跑馬燈, 則首個 Widget 不得加入Key
  """;

  @override
  void initState() {
    marqueeReset(false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: baseAppBar(title),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            TopDesc(content: content),
            TextButton(
              onPressed: () {
                print('移除跑馬燈');
                marqueeReset(false);
                setState(() {});
              },
              child: Container(
                margin: EdgeInsets.only(top: 20),
                child: Text(
                  "直式切換跑馬燈",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                print('添加跑馬燈');
                marqueeReset(true);
                setState(() {});
              },
              child: Container(
                margin: EdgeInsets.only(top: 20),
                child: Text(
                  "添加跑馬燈",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                print('變更邊界');
                changeSide = !changeSide;
                setState(() {});
              },
              child: Container(
                margin: EdgeInsets.only(top: 20),
                child: Text(
                  "變更邊界",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
            Container(
              height: 60,
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: Colors.brown[700],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Marquee.text(
                velocity: 100,
                style: TextStyle(fontSize: 20, color: Colors.white),
                preset: changeSide ? '哈囉哈' : '看屁歐',
                texts: marqueeList,
                nextDuration: Duration(seconds: 1),
                height: 40.scaleA,
                onCreated: (_) {},
                onEnd: (times) {
                  // print('跑馬燈結束通知: $times');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  late List<String> marqueeList;
  int step = 0;
  int diff = 1;
  bool changeSide = false;

  void marqueeReset(bool increase) {
    step++;
    if (increase) {
      diff--;
    } else {
      diff++;
    }

    if (diff < 0) {
      diff = 0;
    } else if (diff > 6) {
      diff = 6;
    }

    marqueeList = [
      '這個是跑馬(0): (0): (0): (0): (0): (0): (0): (0): ',
      '跑馬燈第二段來囉～(1): (1): (1): (1): (1): (1): (1): (1): ',
      '你認真? (2): (2): (2): (2): (2): (2): (2): (2): ',
      '這個是跑(3): (3): (3): (3): (3): (3): (3): (3): ',
      '跑馬燈第五段來囉～(4): (4): (4): (4): (4): (4): (4): (4): ',
      '你認真? (5): (5): (5): (5): (5): (5): (5): (5): ',
    ];

    marqueeList.removeRange(0, diff);
  }
}
