import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:mx_core/mx_core.dart';

import 'bloc/application_bloc.dart';
import 'router/route.dart';
import 'package:path/path.dart';

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

  ApplicationBloc.getInstance().pageStream.listen((e) {
    print('''
歷史 - ${ApplicationBloc.getInstance().pageHistory.map((el) => el.route).toList()}
當前 - ${ApplicationBloc.getInstance().currentDetailPage}
    ''');
  });

  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LoadProvider(
      root: true,
      child: MaterialApp(
        builder: BotToastInit(),
        navigatorObservers: [
          BotToastNavigatorObserver(),
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

class _BBState extends State<BB> with SingleTickerProviderStateMixin {
  double w = 100, h = 100;

  @override
  void initState() {
    Future.delayed(Duration(seconds: 2)).then((_) {
      setState(() {
        w = 50;
        h = 50;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red),
                ),
                child: AnimatedSize(
                  duration: Duration(seconds: 2),
                  child: Container(
                    width: w,
                    height: h,
                  ),
                  vsync: this,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
