import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:mx_core/mx_core.dart';

import 'router/route_widget.dart';
import 'router/routes.dart';

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
      widgetImpl: RouteWidget.getInstance(),
    ),
  );

  // 設定預設 app bar
  PageScaffold.setDefaultAppBar((context, leading, title, actions) {
    Widget titleWidget = Text(
      title ?? '',
      style: TextStyle(
        color: Colors.white,
        fontSize: Screen.scaleA(16),
      ),
    );
    return PreferredSize(
      preferredSize: const Size.fromHeight(
        kToolbarHeight,
      ),
      child: AppBar(
        leading: leading,
        title: titleWidget,
        iconTheme: IconThemeData(
          color: Colors.black,
          size: 20.scaleA,
        ),
        actions: actions,
      ),
    );
  });

  appRouter.pageDetailStream.listen((e) {
    print('''
歷史 - ${appRouter.pageHistory.map((el) => el.route).toList()}
當前 - ${appRouter.currentDetailPage}
    ''');
  });

  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LoadProvider.root(
      child: MxCoreInit(
        child: MaterialApp(
          builder: BotToastInit(),
          navigatorObservers: [
            BotToastNavigatorObserver(),
            appRouter.observable,
          ],
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (context) {
            return 'MxCore範例';
          },
          theme: ThemeData.from(
            colorScheme: const ColorScheme.light(),
          ).copyWith(
            platform: TargetPlatform.android,
            // pageTransitionsTheme: const PageTransitionsTheme(
            //   builders: <TargetPlatform, PageTransitionsBuilder>{
            //     TargetPlatform.android: ZoomPageTransitionsBuilder(),
            //   },
            // ),
          ),
          home: appRouter.getPage(Pages.introduction, entryPoint: true),
        ),
      ),
    );
  }
}
