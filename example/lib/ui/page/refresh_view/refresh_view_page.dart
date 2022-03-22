import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/ui/widget/base_app_bar.dart';

class RefreshViewPage extends StatefulWidget {
  final RouteOption option;

  RefreshViewPage(this.option) : super();

  @override
  _RefreshViewPageState createState() => _RefreshViewPageState();
}

class _RefreshViewPageState extends State<RefreshViewPage> {
  double hh = 100;

  bool isDisposed = false;

  RefreshController _controller = RefreshController();

  @override
  void initState() {
    _controller.refreshStart();
    Future.delayed(Duration(seconds: 1)).then((_) {
      _controller.refreshEnd(success: true);
    });
    Future.delayed(Duration(seconds: 2)).then((_) {
      _loopDetect();
    });
    super.initState();
  }

  void _loopDetect() async {
    Future.delayed(Duration(seconds: 1)).then((_) {
      if (!isDisposed) {
        _loopDetect();
      }
    });
  }

  @override
  void dispose() {
    isDisposed = true;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _view();
  }

  Widget _view() {
    return Scaffold(
      appBar: baseAppBar('RefreshView'),
      body: RefreshView(
        refreshController: _controller,
        child: Container(
          width: 100,
          height: hh,
          color: Colors.red,
        ),
        onRefresh: () {
//            print("觸發 refresh");
          Future.delayed(Duration(milliseconds: 100)).then((_) {
            setState(() {
              hh = 100;
            });
            _controller.refreshEnd(success: true);
          });
        },
        onLoadMore: () {
          Future.delayed(Duration(milliseconds: 100)).then((_) {
            if (isDisposed) {
              return;
            }
            setState(() {
              hh += 10;
            });
            _controller.loadMoreEnd(success: true, empty: true);
          });
        },
      ),
    );
  }
}
