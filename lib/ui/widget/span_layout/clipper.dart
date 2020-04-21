//part of 'layout.dart';
//
//class ClipOverflow extends SingleChildRenderObjectWidget {
//  ClipOverflow({Widget child}) : super(child: child);
//
//  @override
//  RenderObject createRenderObject(BuildContext context) {
//    return _ClipOverflowRenderBox();
//  }
//}
//
//class _ClipOverflowRenderBox extends RenderShiftedBox {
//  _ClipOverflowRenderBox() : super(null);
//
//  @override
//  void performLayout() {
//    var parSize = constraints.biggest;
//    child.layout(constraints, parentUsesSize: true);
//    size = Size(parSize.width, parSize.height);
//  }
//}
//
//abstract class ClipSync {
//  void syncLayout(Size size);
//}
