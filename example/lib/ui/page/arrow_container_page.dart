import 'package:flutter/material.dart';
import 'package:annotation_route/route.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/bloc/page/arrow_container_bloc.dart';
import 'package:mx_core_example/bloc/app_bloc.dart';
import 'package:mx_core_example/ui/page/introduction_page.dart';

class ArrowContainerPage extends StatefulWidget {
  final RouteOption option;

  ArrowContainerPage(this.option) : super();

  @override
  _ArrowContainerPageState createState() => _ArrowContainerPageState();
}

class _ArrowContainerPageState extends State<ArrowContainerPage> {
  ArrowContainerBloc bloc;

  var title = "箭頭容器";
  var content = """
  箭頭容器
  1. 一個包含箭頭的元件
  """;

  @override
  void initState() {
    bloc = BlocProvider.of<ArrowContainerBloc>(context);
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
                    return _buildArrowContainer(AxisDirection.down);
                  case 3:
                    return _buildArrowContainer(AxisDirection.right);
                  case 4:
                    return Container();
                  case 5:
                    return _buildArrowContainer(AxisDirection.left);
                  case 6:
                  case 7:
                  case 8:
                    return _buildArrowContainer(AxisDirection.up);
                }
                return Container();
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildArrowContainer(AxisDirection direction) {
    String showChildText;
    switch (direction) {
      case AxisDirection.up:
        showChildText = "此為上方箭頭容器";
        break;
      case AxisDirection.right:
        showChildText = "此為右方箭頭容器";
        break;
      case AxisDirection.down:
        showChildText = "此為下方箭頭容器";
        break;
      case AxisDirection.left:
        showChildText = "此為左方箭頭容器";
        break;
    }
    return Align(
      child: Container(
        child: Builder(
          builder: (context) => GestureDetector(
            onTap: () {
              print('點點檢測');
            },
            child: ArrowContainer(
              gradient: LinearGradient(
                colors: [
                  Color(0xffcca068),
                  Color(0xff8c6018),
                ],
              ),
              shiftRootPercent: 0.5,
              shiftLeafPercent: 0.5,
              direction: direction,
              child: Container(
                padding: EdgeInsets.all(10),
                child: Text(showChildText),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
