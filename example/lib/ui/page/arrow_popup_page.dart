import 'package:annotation_route/route.dart';
import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/bloc/page/arrow_popup_bloc.dart';
import 'package:mx_core_example/ui/page/introduction_page.dart';

class ArrowPopupPage extends StatefulWidget {
  final RouteOption option;

  ArrowPopupPage(this.option) : super();

  @override
  _ArrowPopupPageState createState() => _ArrowPopupPageState();
}

class _ArrowPopupPageState extends State<ArrowPopupPage> {
  ArrowPopupBloc bloc;

  var title = "箭頭彈窗";
  var content = """
  箭頭彈窗
  1. 依照帶入的元件 context, 浮出的彈窗箭頭會指向元件
  """;

  var firstAction = PopupAction();

  @override
  void initState() {
    bloc = BlocProvider.of<ArrowPopupBloc>(context);
//    Future.delayed(Duration(seconds: 2)).then((_) {
//      bloc.setLoadState(true);
//    });

//    Future.delayed(Duration(seconds: 4)).then((_) {
//      firstAction.show();
//    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LoadProvider(
      loadStream: bloc.loadStream,
      child: PageScaffold(
        haveAppBar: true,
        title: title,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            buildIntroduction(content),
            GridView.builder(
              shrinkWrap: true,
              itemCount: 9,
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
              itemBuilder: (BuildContext context, int index) {
                switch (index) {
                  case 0:
                  case 1:
                  case 2:
                    return _buildArrowContainer(
                        AxisDirection.down, PopupScale.vertical);
                  case 3:
                    return _buildArrowContainer(
                        AxisDirection.right, PopupScale.horizontal);
                  case 4:
                    return _buildArrowContainer(
                      AxisDirection.up,
                      PopupScale.all,
                      controller: firstAction,
                    );
                  case 5:
                    return _buildArrowContainer(
                        AxisDirection.left, PopupScale.horizontal);
                  case 6:
                  case 7:
                  case 8:
                    return _buildArrowContainer(
                        AxisDirection.up, PopupScale.vertical);
                }
                return Container();
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildArrowContainer(
    AxisDirection direction,
    PopupScale popupScale, {
    PopupAction controller,
  }) {
    String showText;
    String showChildText;
    switch (direction) {
      case AxisDirection.up:
        showText = "此為上方彈出箭頭容器, 此為上方彈出箭頭容器此為上方彈出箭頭容器, 此為上方彈出箭頭容器";
        showChildText = "點擊跳出\n上方彈窗";
        break;
      case AxisDirection.right:
        showText = "此為右方彈出箭頭容器, 此為右方彈出箭頭容器\n此為右方彈出箭頭容器, 此為右方彈出箭頭容器";
        showChildText = "點擊跳出\n右方彈窗";
        break;
      case AxisDirection.down:
        showText = "此為下方彈出箭頭容器, 此為下方彈出箭頭容器\n此為下方彈出箭頭容器, 此為下方彈出箭頭容器";
        showChildText = "點擊跳出\n下方彈窗";
        break;
      case AxisDirection.left:
        showText = "此為左方彈出箭頭容器, 此為左方彈出箭頭容器此為左方彈出箭頭容器, 此為左方彈出箭頭容器";
        showChildText = "點擊跳出\n左方彈窗";
        break;
    }
    return Align(
      child: Container(
        child: Builder(
          builder: (context) => ArrowPopupButton(
            controller: controller,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xffcca068),
                    Color(0xff8c6018),
                  ],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: EdgeInsets.all(10),
              child: Text(showChildText),
            ),
            maskColor: Colors.black.withAlpha(100),
            feedback: HitFeedback(scale: 0.5),
            popupStyle: ArrowPopupStyle(
              direction: direction,
              arrowTargetPercent: 0.5,
              arrowSize: 10,
              backgroundColor: Colors.transparent,
              arrowSide: ArrowSide.line,
              gradient: LinearGradient(
                colors: [
                  Colors.indigo,
                  Colors.blueAccent,
                ],
              ),
              popupScale: popupScale,
              strokeGradient: LinearGradient(
                colors: [
                  Colors.blueAccent,
                  Colors.indigo,
                ],
              ),
            ),
            popupBuilder: (controller) {
              return MaterialLayer.single(
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    showText,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                onTap: () {
                  print("隱藏囉~~");
                  controller.remove();
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
