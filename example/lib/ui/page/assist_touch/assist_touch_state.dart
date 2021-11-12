part of 'assist_touch_cubit.dart';

@immutable
abstract class AssistTouchState {
  final String title;
  final String content;

  AssistTouchState({required this.title, required this.content});
}

class AssistTouchInitial extends AssistTouchState {
  AssistTouchInitial()
      : super(
          title: "箭頭容器",
          content: """
  箭頭容器
  1. 一個包含箭頭的元件
  """,
        );
}
