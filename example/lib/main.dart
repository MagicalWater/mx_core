import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mx_core/mx_core.dart';

import 'bloc/application_bloc.dart';
import 'router/route.dart';

void main() {
//  print("螢幕高: ${Screen.height}");

//  timeDilation = 25;

  // 設定基底初始化
  ProjectCore.setting(
    // 設計稿尺寸
    designSize: DesignSize(414, 896, density: 2),

    // 專案擁有的 route
    routeSetting: RouteSetting(
      mixinImpl: ApplicationBloc.getInstance(),
      widgetImpl: RouteWidget.getInstance(),
    ),
  );

  // 設定預設 app bar
  PageScaffold.setDefaultAppBar((context, leading, title, actions) {
    Widget titleWidget = Text(
      title,
      style: TextStyle(
        color: Colors.white,
        fontSize: Screen.scaleA(16),
      ),
    );
    return PreferredSize(
      preferredSize: Size.fromHeight(
        kToolbarHeight,
      ),
      child: AppBar(
        brightness: Brightness.light,
        leading: leading,
        title: titleWidget,
        iconTheme: IconThemeData(
          color: Colors.black,
          size: Screen.scaleA(20),
        ),
        actions: actions,
      ),
    );
  });

  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
//    WebView();
    return LoadProvider(
      root: true,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        onGenerateTitle: (context) {
          return 'MxCore範例';
        },
        theme: ThemeData.from(
          colorScheme: const ColorScheme.light(),
        ).copyWith(
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
              TargetPlatform.android: ZoomPageTransitionsBuilder(),
            },
          ),
        ),
        home: ApplicationBloc.getInstance().getPage(
          Pages.introduction,
          entryPoint: true,
        ),
//        home: BB(),
      ),
    );
  }
}

class BB extends StatefulWidget {
  @override
  _BBState createState() => _BBState();
}

class _BBState extends State<BB> {
  StreamController<double> streamController = StreamController();

  @override
  void initState() {
    Future.delayed(Duration(seconds: 5)).then((_) {
      streamController.add(100);
    });
    super.initState();
  }

  @override
  void dispose() {
    streamController.close();
    super.dispose();
  }

  var bKey = ValueKey(10);
  var cKey = ValueKey(11);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GridView.count(
          crossAxisCount: 3,
          childAspectRatio: 1.0,
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            Container(
              color: Colors.blue,
              width: 100,
            ),
            Container(
              color: Colors.green,
              width: 100,
            ),
            Container(
              color: Colors.redAccent,
              width: 100,
            ),
            Container(
              color: Colors.redAccent,
              width: 100,
            ),
            Container(
              color: Colors.green,
              width: 100,
            ),
            Container(
              color: Colors.blue,
              width: 100,
            ),
          ],
        ),
      ),
    );
//    return Scaffold(
//      body: SafeArea(
//        child: Container(
//          color: Colors.blue.withAlpha(100),
//          child: SingleChildScrollView(
//            scrollDirection: Axis.horizontal,
//            child: SpanGrid(
//              direction: Axis.horizontal,
//              segmentCount: 3,
//              horizontalSpace: 10,
//              verticalSpace: 10,
//              align: AlignType.free,
//              children: <Widget>[
//                Span(
//                  span: 1,
//                  child: Container(
//                    color: Colors.redAccent,
//                    width: 100,
//                  ),
//                ),
//                Span(
//                  span: 1,
//                  fill: true,
//                  child: Container(
//                    color: Colors.green,
//                    width: 100,
//                  ),
//                ),
//              ],
//            ),
//          ),
//        ),
//      ),
//    );
  }
}
