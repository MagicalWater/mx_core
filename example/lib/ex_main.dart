//import 'package:flutter/material.dart';
//import 'package:flutter_localizations/flutter_localizations.dart';
//import 'package:mx_core/mx_core.dart';
//
//import 'bloc/application_bloc.dart';
//import 'router/route.dart';
//
//void main() {
//
//  // 設定基底初始化
//  settingCore(
//    // 設計稿尺寸
//    designSize: DesignSize(414, 896, density: 2),
//
//    // 專案擁有的 route
//    routeSetting: RouteSetting(
//      mixinImpl: ApplicationBloc.getInstance(),
//      widgetImpl: RouteWidget.getInstance(),
//    ),
//  );
//
//  // 設定預設 app bar
//  PageScaffold.setDefaultAppBar((context, title, actions) {
//    Widget titleWidget;
//    if (title is Text) {
//      var titleText = title.data;
//      titleWidget = Text(
//        titleText,
//        style: TextStyle(
//          color: Colors.black,
//          fontSize: getScaleA(16, context),
//        ),
//      );
//    } else {
//      titleWidget = title;
//    }
//    return PreferredSize(
//      preferredSize: Size.fromHeight(
//        kToolbarHeight,
//      ),
//      child: AppBar(
//        brightness: Brightness.light,
//        backgroundColor: Colors.white70,
//        title: titleWidget,
//        iconTheme: IconThemeData(
//          color: Colors.black,
//          size: getScaleA(20, context),
//        ),
//        actions: actions,
//      ),
//    );
//  });
//
//  // 設定預設背景
//  PageScaffold.setDefaultBackground(
//    linearColors: [Colors.white70],
//  );
//
//  // 設定列表預設站位提示屬性
//  SliverView.setDefaultPlaceProperty(
//    PlaceProperty(),
//  );
//
//  // 設定列表預設佔位
//  SliverView.setDefaultPlace((context, state, place) {
//    switch (state) {
//      case SliverState.emptyBody:
//        return Container(
//          alignment: Alignment.center,
//          child: Column(
//            mainAxisSize: MainAxisSize.min,
//            children: <Widget>[
//              Text(
//                place.emptyBody,
//                style: TextStyle(color: Colors.brown),
//              ),
//            ],
//          ),
//        );
//      default:
//        return null;
//    }
//  });
//
//  runApp(App());
//}
//
//class App extends StatelessWidget {
//  @override
//  Widget build(BuildContext context) {
//    return LoadProvider(
//      root: true,
//      child: MaterialApp(
//        debugShowCheckedModeBanner: false,
//        onGenerateTitle: (context) {
//          return 'AppName';
//        },
//        theme: ThemeData(
//          primarySwatch: Colors.blue,
//        ),
//        localizationsDelegates: const [
//          S.delegate,
//          GlobalMaterialLocalizations.delegate,
//          GlobalWidgetsLocalizations.delegate,
//        ],
//        localeResolutionCallback: S.delegate.resolution(
//          // 當找不到對應語系時的默認語系
//          fallback: S.delegate.supportedLocales.first,
//          // 是否需要精確到國家
//          withCountry: false,
//        ),
//        supportedLocales: S.delegate.supportedLocales,
//        home: ApplicationBloc.getInstance().getPage(Pages.exLaunch, entryPoint: true),
//      ),
//    );
//  }
//}