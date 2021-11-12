part of 'animated_core_cubit.dart';

@immutable
abstract class AnimatedCoreState {

  final String title;
  final String content;

  AnimatedCoreState({required this.title, required this.content});

}

class AnimatedCoreInitial extends AnimatedCoreState {
  AnimatedCoreInitial() : super(
    title: "動畫核心",
    content: """
  動畫核心
  a. 所有的動畫皆基於此之上製作, 包含以下
    1. LoadingAnimation - 讀取動畫
    2. ParticleAnimation - 粒子動畫
    
  b. 動畫有以下幾種行為
    1. AnimatedType.tap - 點擊
    2. AnimatedType.toggle - 開關
    3. AnimatedType.once - 入場時執行一次
    4. AnimatedType.repeat - 不斷重複執行
  """,
  );

}
