import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:mx_core/mx_core.dart';

class Rotation3DPage extends StatefulWidget {
  final RouteOption option;

  Rotation3DPage(this.option, {Key? key}) : super(key: key);

  @override
  _Rotation3DPageState createState() => _Rotation3DPageState();
}

class _Rotation3DPageState extends State<Rotation3DPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  PageController _pageController = PageController(initialPage: 1);
  double animationRotationValue = 0;
  double screenWidth = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _pageController.addListener(() {
      if (_pageController.page == 0) {
        // 循环滚动
        _pageController.jumpToPage(4);
      }
      if (_pageController.page == 5) {
        // 循环滚动
        _pageController.jumpToPage(1);
      }
      double offset = _pageController.offset / screenWidth * 0.25;
      setState(() {
        animationRotationValue = offset * math.pi * 2;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool isOnLeft(double rotation) => math.cos(rotation) > 0;

  @override
  Widget build(BuildContext context) {
    final numberOfTexts = 4;
    final size = MediaQuery.of(context).size;
    screenWidth = size.width;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: List.generate(
                    numberOfTexts,
                    (index) {
                      return AnimatedBuilder(
                        animation: _animationController,
                        child: Container(
                          height: 300,
                          width: 200,
                          alignment: Alignment.center,
                          child: Transform(
                            /// 翻转页面
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..translate(20.0)
                              ..rotateY(math.pi),
                            child: Text(
                              "$index",
                              style: TextStyle(
                                  fontSize: 30,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.blue.withOpacity(0.9),
                                Colors.transparent
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              stops: [0.0, 0, 1],
                            ),
                          ),
                        ),
                        builder: (context, child) {
                          double rotation =
                              2 * math.pi * index / numberOfTexts +
                                  math.pi / 2 +
                                  animationRotationValue;
                          // if (isOnLeft(rotation)) {
                          //   rotation = -rotation +
                          //       2 * animationRotationValue -
                          //       math.pi * 2 / numberOfTexts;
                          // }
                          return Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateY(rotation)
                              ..translate(.0, 0.0, 150.0),
                            child: child,
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
            Positioned.fill(
                child: PageView.builder(
                    itemCount: numberOfTexts + 2,
                    controller: _pageController,
                    itemBuilder: (context, index) {
                      return Container();
                    }))
          ],
        ),
      ),
    );
  }
}
