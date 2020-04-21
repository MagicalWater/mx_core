import 'dart:math';

import 'package:annotation_route/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/bloc/page/particle_animation_bloc.dart';
import 'package:mx_core_example/router/route.dart';
import 'package:mx_core_example/ui/page/introduction_page.dart';

@ARoute(url: Pages.particleAnimation)
class ParticleAnimationPage extends StatefulWidget {
  final RouteOption option;

  ParticleAnimationPage(this.option) : super();

  @override
  _ParticleAnimationPageState createState() => _ParticleAnimationPageState();
}

class _ParticleAnimationPageState extends State<ParticleAnimationPage> {
  ParticleAnimationBloc bloc;

  var title = "粒子碎裂動畫";
  var content = """
  粒子碎裂動畫
  a. 有兩種使用方式 
    1. ParticleAnimation.particle
    2. ParticleAnimation.cover
  
  b. particle 為單純粒子, 目前擁有以下粒子
    1. BallParticle
    
  c. cover 為粒子碎裂動畫, 帶入 child, 點擊後會將 child 這個元件使用粒子動畫爆開
  """;

  var pictureGlobalKey = GlobalKey();

  @override
  void initState() {
    bloc = BlocProvider.of<ParticleAnimationBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      haveAppBar: true,
      title: title,
      child: SafeArea(
        child: Column(
          children: <Widget>[
            buildIntroduction(content),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: buildParticleCover(),
                  ),
                  Container(
                    width: 8,
                  ),
                  Expanded(
                    flex: 1,
                    child: buildParticle(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildParticleCover() {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: <Widget>[
          Text(
            "粒子碎裂動畫",
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          BombAnimation(
            width: 200,
            height: 200,
            splitWidth: 15,
            splitHeight: 15,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0xffcca068),
                    Color(0xff8c6018),
                  ],
                ),
              ),
              child: Align(
                child: Text(
                  "點我",
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildParticle() {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: <Widget>[
          Text(
            "粒子動畫",
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          ParticleAnimation(
            width: 150,
            height: 200,
            particles: [
              BallParticle(
                color: Colors.brown,
                radius: 20,
                x: 100,
                y: 100,
                velocityY: -1,
                accY: Random().nextDouble() + 0.2,
                restitution: 1,
                boundLimit: null,
              )..random(),
              BallParticle(
                color: Colors.brown,
                radius: 20,
                x: 100,
                y: 100,
                velocityY: -1,
                accY: Random().nextDouble() + 0.2,
                restitution: 1,
                boundLimit: null,
              )..random(),
            ],
            auto: false,
          ),
        ],
      ),
    );
  }
}
