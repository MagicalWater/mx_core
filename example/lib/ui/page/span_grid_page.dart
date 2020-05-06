import 'dart:async';

import 'package:annotation_route/route.dart';
import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/bloc/page/span_grid_bloc.dart';
import 'package:mx_core_example/router/route.dart';

@ARoute(url: Pages.spanGrid)
class SpanGridPage extends StatefulWidget {
  final RouteOption option;

  SpanGridPage(this.option) : super();

  @override
  _SpanGridPageState createState() => _SpanGridPageState();
}

class _SpanGridPageState extends State<SpanGridPage>
    with TickerProviderStateMixin {
  SpanGridBloc bloc;

  StreamController<List<String>> urlStreamController =
      StreamController.broadcast();

  List<String> imageUrl = [
    "https://img.ltn.com.tw/Upload/news/600/2019/02/14/phpxB7gOg.jpg",
    "https://miro.medium.com/max/676/1*XEgA1TTwXa5AvAdw40GFow.png",
    "https://miro.medium.com/max/676/1*XEgA1TTwXa5AvAdw40GFow.png",
    "https://miro.medium.com/max/676/1*XEgA1TTwXa5AvAdw40GFow.png",
    "https://miro.medium.com/max/676/1*XEgA1TTwXa5AvAdw40GFow.png",
  ];

  @override
  void initState() {
    bloc = BlocProvider.of<SpanGridBloc>(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
//      print("開始展示圖");
      urlStreamController.add(imageUrl);
    });

//    Future.delayed(Duration(seconds: 2)).then((_) {
//      imageUrl.insert(
//          2, 'https://img.ltn.com.tw/Upload/news/600/2019/02/14/phpxB7gOg.jpg');
//      urlStreamController.add(imageUrl);
//    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LoadProvider(
      child: PageScaffold(
        child: Container(
          child: StreamBuilder<List<String>>(
            stream: urlStreamController.stream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }
              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
                  color: Colors.amber.withAlpha(100),
                  child: GestureDetector(
                    onTap: () {
                      print('點點背景');
                    },
                    child: SpanGrid(
                        align: AlignType.max,
                        direction: Axis.vertical,
                        segmentCount: 2,
                        horizontalSpace: 10,
                        verticalSpace: 10,
                        children: snapshot.data
                            .map((e) => GestureDetector(
                                  onTap: () {
                                    print('點事件11');
                                  },
                                  child: SpanColumn(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Image.network(
                                        e,
                                        fit: BoxFit.contain,
                                      ),
                                      Expanded(
                                        child: Container(),
                                      ),
                                      Container(
                                        color: Colors.indigo,
                                        child: Text("抬頭～～"),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList()),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    urlStreamController.close();
    super.dispose();
  }
}
