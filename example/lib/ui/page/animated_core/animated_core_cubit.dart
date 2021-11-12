import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'animated_core_state.dart';

class AnimatedCoreCubit extends Cubit<AnimatedCoreState> {
  AnimatedCoreCubit() : super(AnimatedCoreInitial());
}
