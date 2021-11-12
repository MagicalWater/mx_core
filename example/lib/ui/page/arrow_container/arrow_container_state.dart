part of 'arrow_container_cubit.dart';

@immutable
abstract class ArrowContainerState {
  final String title;
  final String content;

  ArrowContainerState({required this.title, required this.content});

}

class ArrowContainerInitial extends ArrowContainerState {

  ArrowContainerInitial() : super(
    title: "箭頭容器",
    content: """
  箭頭容器
  1. 一個包含箭頭的元件
  """,
  );

}
