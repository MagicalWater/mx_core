part of 'arrow_popup_cubit.dart';

@immutable
abstract class ArrowPopupState {
  final String title;
  final String content;

  ArrowPopupState({required this.title, required this.content});
}

class ArrowPopupInitial extends ArrowPopupState {
  ArrowPopupInitial() : super(
    title: "箭頭彈窗",
    content: """
  箭頭彈窗
  1. 依照帶入的元件 context, 浮出的彈窗箭頭會指向元件
  """,
  );

}
