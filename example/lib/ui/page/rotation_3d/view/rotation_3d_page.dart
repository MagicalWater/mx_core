import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:mx_core/mx_core.dart';
import 'package:vector_math/vector_math_64.dart' as v;

class Rotation3DPage extends StatefulWidget {
  final RouteOption option;

  Rotation3DPage(this.option, {Key? key}) : super(key: key);

  @override
  _Rotation3DPageState createState() => _Rotation3DPageState();
}

class _Rotation3DPageState extends State<Rotation3DPage>
    with SingleTickerProviderStateMixin {
  final numberOfTexts = 4;
  PageController _pageController = PageController(initialPage: 0);
  double animationRotationValue = 0;
  double screenWidth = 0;

  @override
  void initState() {
    // final mm = Matrix4.identity();
    // mm.setTranslationRaw(x, y, z)
    // v.Vector4.identity()
    super.initState();
    _pageController.addListener(() {
      // if (_pageController.page == 0) {
      //   // 循环滚动
      //   print('循環4');
      //   _pageController.jumpToPage(4);
      // }
      // if (_pageController.page == 5) {
      //   // 循环滚动
      //   print('循環1');
      //   _pageController.jumpToPage(1);
      // }
      double offset = _pageController.offset / screenWidth;
      print('offset = ${offset}');
      setState(() {
        // animationRotationValue = offset * math.pi * 2;
        animationRotationValue = offset;
      });
    });
  }

  @override
  void dispose() {
    // _animationController.dispose();
    super.dispose();
  }

  bool isOnLeft(double rotation) => math.cos(rotation) > 0;

  @override
  Widget build(BuildContext context) {
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
                    2,
                    (index) {
                      // 與當前顯示元件的距離
                      final distance = animationRotationValue - index;

                      // 每個列表之間的距離
                      final oneStep = math.pi / 2;

                      final rotationY = distance * oneStep;

                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(rotationY)
                          ..translate(0.0, 0.0, -50),
                        child: Container(
                          height: 200,
                          width: 100,
                          alignment: Alignment.center,
                          child: Text(
                            index.toString(),
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            gradient: LinearGradient(
                              colors: [
                                index == 0 ? Colors.blueAccent : Colors.greenAccent,
                                index == 0 ? Colors.blueAccent : Colors.greenAccent,
                                index == 0 ? Colors.blueAccent : Colors.greenAccent,
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              stops: [0.0, 0, 1],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Positioned.fill(
                child: PageView.builder(
                    itemCount: numberOfTexts,
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
