import 'package:flutter_bloc/flutter_bloc.dart';

import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeState());


  void addWaterCup() {
    state.nutritionData.addWaterCup();

    emit(
      state.copyWith(
        nutritionData: state.nutritionData,
      ),
    );
  }

  void resetWater() {
    state.nutritionData.resetWater();

    emit(
      state.copyWith(
        nutritionData: state.nutritionData,
      ),
    );
  }


  void resetDailyData() {
    emit(
      HomeState(),
    );
  }
}