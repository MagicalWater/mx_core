import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/ui/page/arrow_container/arrow_container_cubit.dart';
import 'package:mx_core_example/ui/widget/top_desc.dart';

class ArrowContainerPage extends StatefulWidget {
  final RouteOption option;

  ArrowContainerPage(this.option) : super();

  @override
  _ArrowContainerPageState createState() => _ArrowContainerPageState();
}

class _ArrowContainerPageState extends State<ArrowContainerPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ArrowContainerCubit(),
      child: _view(),
    );
  }

  Widget _view() {
    return BlocBuilder<ArrowContainerCubit, ArrowContainerState>(
      builder: (context, state) {
        return PageScaffold(
          haveAppBar: true,
          title: state.title,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TopDesc(content: state.content),
              GridView.builder(
                shrinkWrap: true,
                itemCount: 9,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3),
                itemBuilder: (BuildContext context, int index) {
                  switch (index) {
                    case 0:
                    case 1:
                    case 2:
                      return _item(AxisDirection.down);
                    case 3:
                      return _item(AxisDirection.right);
                    case 4:
                      return Container();
                    case 5:
                      return _item(AxisDirection.left);
                    case 6:
                    case 7:
                    case 8:
                      return _item(AxisDirection.up);
                  }
                  return Container();
                },
              )
            ],
          ),
        );
      },
    );
  }

  Widget _item(AxisDirection direction) {
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
