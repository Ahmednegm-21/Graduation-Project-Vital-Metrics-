import 'package:flutter_bloc/flutter_bloc.dart';
import 'height_state.dart';

class HeightCubit extends Cubit<HeightState> {
  HeightCubit() : super(HeightState(height: 170.0));

  void updateHeight(double newHeight) {
    emit(state.copyWith(height: newHeight));
  }
}
