import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'water_state.dart';

export 'water_state.dart';

class WaterCubit extends Cubit<WaterState> {
  WaterCubit() : super(const WaterState()) {
    _loadData();
  }

  static const _keyConsumed = 'water_consumed';
  static const _keyGoal = 'water_goal';
  static const _keyDrinkAmount = 'water_drink_amount';
  static const _keyUnit = 'water_unit';

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    emit(state.copyWith(
      consumed: prefs.getDouble(_keyConsumed) ?? 0,
      dailyGoal: prefs.getDouble(_keyGoal) ?? 3208,
      drinkAmount: prefs.getDouble(_keyDrinkAmount) ?? 250,
      unit: prefs.getString(_keyUnit) ?? 'ml',
    ));
  }

  Future<void> drink() async {
    final newConsumed = state.consumed + state.drinkAmount;
    emit(state.copyWith(consumed: newConsumed));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyConsumed, newConsumed);
  }

  Future<void> updateDailyGoal(double goal) async {
    // Convert from current unit to ml for storage
    final goalInMl = state.unit == 'oz' ? goal * 29.5735 : goal;
    emit(state.copyWith(dailyGoal: goalInMl));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyGoal, goalInMl);
  }

  Future<void> updateDrinkAmount(double amount) async {
    // Convert from current unit to ml for storage
    final amountInMl = state.unit == 'oz' ? amount * 29.5735 : amount;
    emit(state.copyWith(drinkAmount: amountInMl));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyDrinkAmount, amountInMl);
  }

  Future<void> updateUnit(String unit) async {
    emit(state.copyWith(unit: unit));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUnit, unit);
  }

  Future<void> reset() async {
    emit(state.copyWith(consumed: 0));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyConsumed, 0);
  }
}