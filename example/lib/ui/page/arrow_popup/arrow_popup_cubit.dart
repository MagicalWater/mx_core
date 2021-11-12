import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'arrow_popup_state.dart';

class ArrowPopupCubit extends Cubit<ArrowPopupState> {
  ArrowPopupCubit() : super(ArrowPopupInitial());
}
