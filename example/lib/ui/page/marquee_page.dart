import 'package:flutter/material.dart';
import 'package:annotation_route/route.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/router/route.dart';
import 'package:mx_core_example/bloc/page/load_provider_bloc.dart';
import 'package:mx_core_example/bloc/app_bloc.dart';
import 'package:mx_core_example/ui/page/introduction_page.dart';

/// 跑馬燈範例頁面
@ARoute(url: Pages.marquee)
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
  Widget build(BuildContext context) {
    return PageScaffold(
      title: title,
      color: Colors.black,
      child: SafeArea(
        child: Column(
          children: <Widget>[
            buildIntroduction(content),
            Container(
              child: Text(
                "橫式切換跑馬燈",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            Container(
              height: 60,
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Marquee.text(
                velocity: 400,
                style: TextStyle(fontSize: 20),
                texts: [
                  '這個是跑馬',
                  '跑馬燈第二段來囉～',
                  '你認真? 跑馬燈結尾了!!! 不～～～～～～～～～～',
                  '這個是跑馬燈第四段, 這個是跑馬燈第四段, 這個是跑馬燈第四段',
                  '跑馬燈第五段來囉～',
                  '你認真? 跑馬燈真正的結尾了!!! 不～～～～～～～～～～',
                ],
                type: MarqueeType.horizontal,
                onCreated: (_) {},
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20),
              child: Text(
                "直式切換跑馬燈",
                style: TextStyle(color: Colors.white, fontSize: 20),
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
                velocity: 400,
                style: TextStyle(fontSize: 20, color: Colors.white),
                texts: [
                  '這個是跑馬',
                  '跑馬燈第二段來囉～',
                  '你認真? 跑馬燈結尾了!!! 不～～～～～～～～～～',
                  '這個是跑馬燈第四段, 這個是跑馬燈第四段, 這個是跑馬燈第四段',
                  '跑馬燈第五段來囉～',
                  '你認真? 跑馬燈真正的結尾了!!! 不～～～～～～～～～～',
                ],
                type: MarqueeType.vertical,
                onCreated: (_) {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
