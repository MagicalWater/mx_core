import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:mx_core/mx_core.dart';

import 'bloc/app_bloc.dart';
import 'router/route.dart';

void main() {
  var aa = '/routePushSecond/routePushSub1';
  var bb = '/routePushSecond/routePushSub1';
  print('檢測: ${aa.matchAsPrefix(bb)}');

//  print("螢幕高: ${Screen.height}");

//  timeDilation = 25;

  // 設定基底初始化
  ProjectCore.setting(
    // 設計稿尺寸
    designSize: DesignSize(414, 896, density: 2),

    // 專案擁有的 route
    routeSetting: RouteSetting(
      mixinImpl: AppBloc(),
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

  AppBloc().pageDetailStream.listen((e) {
    print('''
歷史 - ${AppBloc().pageHistory.map((el) => el.route).toList()}
當前 - ${AppBloc().currentDetailPage}
    ''');
  });

  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LoadProvider(
      root: true,
      child: MxCoreInit(
        child: MaterialApp(
          builder: BotToastInit(),
          navigatorObservers: [
            BotToastNavigatorObserver(),
            MxCoreRouteObservable(),
          ],
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
          home: AppBloc().getPage(
            Pages.introduction,
            entryPoint: true,
          ),
//        home: BB(),
        ),
      ),
    );
  }
}

class BB extends StatefulWidget {
  @override
  _BBState createState() => _BBState();
}

class _BBState extends State<BB> with SingleTickerProviderStateMixin {
  AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(
      duration: Duration(seconds: 1),
      lowerBound: 0,
      upperBound: 300,
      vsync: this,
    )..addListener(() {
        setState(() {});
      });
    Future.delayed(Duration(seconds: 2)).then((_) {
      controller.forward();
    });
    super.initState();
  }

  void reset() {
    controller.reset();
  }

  void forward() {
    controller.forward();
  }

  void reversed() {
    controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                child: Text(
                  controller.value.toStringAsFixed(1),
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Container(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  RaisedButton(child: Text('Reset'), onPressed: reset),
                  RaisedButton(child: Text('Forward'), onPressed: forward),
                  RaisedButton(child: Text('Reversed'), onPressed: reversed),
                ],
              ),
              Container(height: 12),
              Stack(
                children: <Widget>[
                  Container(
                    height: 340,
                    width: 2,
                    color: Colors.black,
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    transform:
                        Matrix4.translationValues(10, controller.value, 0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blueAccent,
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
