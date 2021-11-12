import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mx_core/mx_core.dart';

part 'refresh_view_state.dart';

class RefreshViewCubit extends Cubit<RefreshViewState> {
  RefreshViewCubit() : super(RefreshViewState());
}
