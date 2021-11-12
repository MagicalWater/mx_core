import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'assist_touch_state.dart';

class AssistTouchCubit extends Cubit<AssistTouchState> {
  AssistTouchCubit() : super(AssistTouchInitial());
}
