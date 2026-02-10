import 'package:flutter_bloc/flutter_bloc.dart';
import 'age_state.dart';

class AgeCubit extends Cubit<AgeState> {
  AgeCubit() : super(AgeState(age: 25.0));

  void updateAge(double newAge) {
    emit(state.copyWith(age: newAge));
  }
}
