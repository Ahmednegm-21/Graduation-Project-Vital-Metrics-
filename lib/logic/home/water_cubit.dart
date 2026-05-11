import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vital_metrics/data/models/water_model.dart';
import 'package:vital_metrics/data/repositories/water_repository.dart';
import 'package:vital_metrics/logic/home/water_state.dart';
import 'package:vital_metrics/services/google_fit_service.dart';

export 'water_state.dart';

// SharedPreferences keys for local settings only
const _kGoalMl  = 'water_goal_ml';
const _kDrinkMl = 'water_drink_amount_ml';
const _kUnit    = 'water_unit';

const _mlToOz = 0.033814;

class WaterCubit extends Cubit<WaterState> {
  final WaterRepository  _repo;
  final GoogleFitService _fitService;

  WaterCubit({
    WaterRepository?  repository,
    GoogleFitService? fitService,
  })  : _repo       = repository ?? WaterRepository(),
        _fitService = fitService ?? GoogleFitService(),
        super(const WaterState()) {
    _init();
  }

  // Load prefs then fetch today from backend
  Future<void> _init() async {
    emit(state.copyWith(isLoading: true));
    await _loadPrefs();
    await _fetchTodayIntakes();
  }

  // Load goal, drinkAmount, unit from SharedPreferences
  Future<void> _loadPrefs() async {
    final prefs   = await SharedPreferences.getInstance();
    final goalMl  = prefs.getInt(_kGoalMl)  ?? 3208;
    final drinkMl = prefs.getInt(_kDrinkMl) ?? 240;
    final unit    = prefs.getString(_kUnit)  ?? 'ml';
    emit(state.copyWith(goalMl: goalMl, drinkAmountMl: drinkMl, unit: unit));
  }

  // GET all intakes and filter by today using local time
  Future<void> _fetchTodayIntakes() async {
    try {
      final all   = await _repo.getIntakes();
      final today = DateTime.now();

      final todayIntakes = all.where((e) {
        final local = e.time.toLocal();
        return local.year  == today.year  &&
               local.month == today.month &&
               local.day   == today.day;
      }).toList();

      final consumed = todayIntakes.fold<int>(0, (sum, e) => sum + e.amountMl);

      emit(state.copyWith(
        consumedMl:   consumed,
        todayIntakes: todayIntakes,
        isLoading:    false,
      ));
    } catch (_) {
      // Keep current local state if backend fails
      emit(state.copyWith(isLoading: false));
    }
  }

  // POST one drink — optimistic update then sync backend + Health Connect
  Future<void> drink() async {
    // Optimistic update for instant UI
    emit(state.copyWith(consumedMl: state.consumedMl + state.drinkAmountMl));

    try {
      final saved   = await _repo.logIntake(amountMl: state.drinkAmountMl);
      final updated = [...state.todayIntakes, saved];
      emit(state.copyWith(todayIntakes: updated));

      // Write to Health Connect so it shows in Google Fit
      // Fire and forget — failure here should not block the UI
      _fitService.writeWater(state.drinkAmountMl);
    } catch (_) {
      // Revert optimistic update on failure
      emit(state.copyWith(consumedMl: state.consumedMl - state.drinkAmountMl));
    }
  }

  // DELETE all today intakes then reset local state
  Future<void> reset() async {
    final oldIntakes  = List<WaterModel>.from(state.todayIntakes);
    final oldConsumed = state.consumedMl;

    // Optimistic reset
    emit(state.copyWith(consumedMl: 0, todayIntakes: []));

    try {
      for (final intake in oldIntakes) {
        await _repo.deleteIntake(intake.id);
      }
    } catch (_) {
      // Revert if any delete fails
      emit(state.copyWith(consumedMl: oldConsumed, todayIntakes: oldIntakes));
    }
  }

  // Update daily goal — store internally in ml
  Future<void> updateDailyGoal(double valueInCurrentUnit) async {
    final ml = state.unit == 'oz'
        ? (valueInCurrentUnit / _mlToOz).round()
        : valueInCurrentUnit.round();
    emit(state.copyWith(goalMl: ml));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kGoalMl, ml);
  }

  // Update drink amount — store internally in ml
  Future<void> updateDrinkAmount(double valueInCurrentUnit) async {
    final ml = state.unit == 'oz'
        ? (valueInCurrentUnit / _mlToOz).round()
        : valueInCurrentUnit.round();
    emit(state.copyWith(drinkAmountMl: ml));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kDrinkMl, ml);
  }

  // Update display unit ml or oz
  Future<void> updateUnit(String unit) async {
    emit(state.copyWith(unit: unit));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUnit, unit);
  }

  // Pull to refresh
  Future<void> refresh() => _fetchTodayIntakes();
}