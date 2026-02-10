import 'package:flutter_bloc/flutter_bloc.dart';
import 'weight_state.dart';

class WeightCubit extends Cubit<WeightState> {
  WeightCubit() : super(WeightState(weight: 70.0));

  void updateWeight(double newWeight) {
    emit(state.copyWith(weight: newWeight));
  }
}
