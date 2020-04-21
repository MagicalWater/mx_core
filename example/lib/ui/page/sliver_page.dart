import 'dart:async';
import 'dart:math';

import 'package:annotation_route/route.dart';
import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/bloc/application_bloc.dart';
import 'package:mx_core_example/bloc/page/sliver_bloc.dart';
import 'package:mx_core_example/router/route.dart';
import 'package:mx_core_example/ui/page/introduction_page.dart';

@ARoute(url: Pages.sliver)
class SliverPage extends StatefulWidget {
  final RouteOption option;

  SliverPage(this.option) : super();

  @override
  _SliverPageState createState() => _SliverPageState();
}

class _SliverPageState extends State<SliverPage> {
  SliverBloc bloc;

  var title = "有狀態的列表元件";
  var content = """
  有狀態的列表元件
  a. 根據列表狀態有不同的佔位顯示  
  b. 可自訂佔位顯示內容
  """;

  Color get randomColor {
    return Color.fromARGB(
      255,
      Random().nextInt(155),
      Random().nextInt(155),
      Random().nextInt(155),
    );
  }

  @override
  void initState() {
    bloc = BlocProvider.of<SliverBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LoadProvider(
      loadStream: bloc.loadStream,
      child: PageScaffold(
        color: Colors.black,
        haveAppBar: true,
        title: title,
        child: Column(
          children: <Widget>[
            buildIntroduction(content),
            AnimatedCore.tap(
              child: Container(
                margin: EdgeInsets.all(16),
                alignment: Alignment.center,
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xffcca068),
                      Color(0xff8c6018),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: StreamBuilder<SliverState>(
                  initialData: SliverState.standby,
                  stream: bloc.sliverStateStream,
                  builder: (context, snapshot) {
                    return Text(
                      "切換狀態 [當前: ${snapshot.data}]",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    );
                  },
                ),
              ),
              animatedList: [
                AnimatedValue.collection(
                  animatedList: [
                    AnimatedValue.scale(end: 0.8),
                    AnimatedValue.opacity(end: 0.8),
                  ],
                ),
              ],
              onTap: () {
                print("觸發切換狀態");
                bloc.changeState();
              },
            ),
            Expanded(
              child: StreamBuilder<int>(
                initialData: 0,
                stream: bloc.itemStream,
                builder: (context, snapshot) {
                  return SliverView(
                    refresh: true,
                    loadMore: true,
                    onRefresh: () async {
                      await Future.delayed(Duration(seconds: 2));
                      bloc.changeState();
                    },
                    onLoadMore: () async {
                      await Future.delayed(Duration(seconds: 2));
                      bloc.changeState();
                    },
                    stateStream: bloc.sliverStateStream,
                    placeProperties: PlaceProperties(
                      textStyle: TextStyle(color: Colors.white),
                    ),
                    slivers: <Widget>[
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return Container(
                              margin: EdgeInsets.only(
                                left: 20,
                                right: 20,
                                bottom: 20,
                              ),
                              child: AnimatedComb.quick(
                                type: AnimatedType.once,
                                duration: 500,
                                translate: Comb.translate(
                                  begin: Offset(
                                      -MediaQuery.of(context).size.width, 0),
                                  end: Offset.zero,
                                ),
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [randomColor, randomColor],
                                    ),
                                  ),
                                ),
                                multipleAnimationController: true,
                              ),
                            );
                          },
                          childCount: snapshot.data,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
