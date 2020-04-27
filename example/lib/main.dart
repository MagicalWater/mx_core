import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
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
    Slider;
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

class _BBState extends State<BB>  {

  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.green,
          child: CCRender(
            child: Container(
              color: Colors.amber,
              width: 100,
              height: 100,
            ),
          ),
        ),
      ),
    );
  }
}

class CCRender extends SingleChildRenderObjectWidget {
  CCRender({Widget child}) : super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return CCBox();
  }
}

class CCBox extends RenderBox with RenderObjectWithChildMixin<RenderBox> {
  @override
  void performLayout() {
    print('performLayout');
    child.layout(constraints, parentUsesSize: true);
    print('child = ${child.size}');
    size = Size(50, 50);
    print('設置完畢');
  }

  @override
  void performResize() {
    print('performResize');
    super.performResize();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final childParentData = child.parentData as BoxParentData;
    context.paintChild(child, childParentData.offset + offset);
  }

  @override
  double getMaxIntrinsicHeight(double width) {
    var compute = super.getMaxIntrinsicHeight(width);
    print('getMaxIntrinsicHeight - 來源: $width, 結果: $compute');
    return compute;
  }

  @override
  double getMaxIntrinsicWidth(double height) {
    var compute = super.getMaxIntrinsicWidth(height);
    print('getMaxIntrinsicWidth - 來源: $height, 結果: $compute');
    return compute;
  }

  @override
  double getMinIntrinsicHeight(double width) {
    var compute = super.getMinIntrinsicHeight(width);
    print('getMinIntrinsicHeight - 來源: $width, 結果: $compute');
    return compute;
  }

  @override
  double getMinIntrinsicWidth(double height) {
    var compute = super.getMinIntrinsicWidth(height);
    print('getMinIntrinsicWidth - 來源: $height, 結果: $compute');
    return compute;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    var compute = super.computeMaxIntrinsicHeight(width);
    print('computeMaxIntrinsicHeight - 來源: $width, 結果: $compute');
    return compute;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    var compute = super.computeMaxIntrinsicWidth(height);
    print('computeMaxIntrinsicWidth - 來源: $height, 結果: $compute');
    return compute;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    var compute = super.computeMinIntrinsicHeight(width);
    print('computeMinIntrinsicHeight - 來源: $width, 結果: $compute');
    return compute;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    var compute = super.computeMinIntrinsicWidth(height);
    print('computeMinIntrinsicWidth - 來源: $height, 結果: $compute');
    return compute;
  }
}
