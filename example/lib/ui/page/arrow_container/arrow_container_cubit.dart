import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'arrow_container_state.dart';

class ArrowContainerCubit extends Cubit<ArrowContainerState> {
  ArrowContainerCubit() : super(ArrowContainerInitial());
}
