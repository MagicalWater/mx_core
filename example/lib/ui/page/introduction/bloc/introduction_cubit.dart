import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mx_core_example/router/router.dart';
import 'package:mx_core_example/ui/page/introduction/model/page_info.dart';

export '../model/page_info.dart';

part 'introduction_state.dart';

class IntroductionCubit extends Cubit<IntroductionState> {
  IntroductionCubit() : super(IntroductionInitial());
}
