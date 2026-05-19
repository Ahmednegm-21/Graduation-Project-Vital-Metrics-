import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vital_metrics/data/models/water_model.dart';
import 'package:vital_metrics/data/repositories/water_repository.dart';
import 'package:vital_metrics/logic/home/water_state.dart';
import 'package:vital_metrics/services/google_fit_service.dart';

export 'water_state.dart';

const _kGoalMl = 'water_goal_ml';
const _kDrinkMl = 'water_drink_amount_ml';
const _kUnit = 'water_unit';

// CACHE
const _kConsumedMl = 'water_consumed_ml';
const _kTodayIntakes = 'water_today_intakes';
const _kLastSavedDate = 'water_last_saved_date';

const _mlToOz = 0.033814;

class WaterCubit extends Cubit<WaterState> {
  final WaterRepository _repo;
  final GoogleFitService _fitService;

  WaterCubit({
    WaterRepository? repository,
    GoogleFitService? fitService,
  })  : _repo = repository ?? WaterRepository(),
        _fitService = fitService ?? GoogleFitService(),
        super(const WaterState()) {
    Future.microtask(() => _init());
  }

  // =====================================================
  // INIT
  // =====================================================

  Future<void> _init() async {
    emit(state.copyWith(isLoading: true));

    await _loadLocalCache();

    emit(state.copyWith(isLoading: false));

    // sync بعد ما UI يترسم
    Future.microtask(() async {
      await _fetchTodayIntakes();
    });
  }

  // =====================================================
  // LOCAL CACHE
  // =====================================================

  Future<void> _loadLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final goalMl = prefs.getInt(_kGoalMl) ?? 3200;

      final drinkMl = prefs.getInt(_kDrinkMl) ?? 250;

      final unit = prefs.getString(_kUnit) ?? 'ml';

      final savedDate = prefs.getString(_kLastSavedDate);

      final today = DateTime.now().toIso8601String().split('T').first;

      // يوم جديد
      if (savedDate != today) {
        await prefs.setInt(_kConsumedMl, 0);

        await prefs.setString(_kLastSavedDate, today);

        emit(
          state.copyWith(
            goalMl: goalMl,
            drinkAmountMl: drinkMl,
            unit: unit,
            consumedMl: 0,
            todayIntakes: [],
          ),
        );

        return;
      }

      final consumedMl =
          prefs.getInt(_kConsumedMl) ?? 0;

      final cachedIntakes =
          prefs.getStringList(_kTodayIntakes) ?? [];

      final intakes = cachedIntakes.map((e) {
        final map = jsonDecode(e);

        return WaterModel(
          id: map['id'],
          amountMl: map['amountMl'],
          time: DateTime.parse(map['time']),
        );
      }).toList();

      emit(
        state.copyWith(
          goalMl: goalMl,
          drinkAmountMl: drinkMl,
          unit: unit,
          consumedMl: consumedMl,
          todayIntakes: intakes,
        ),
      );

      print(
        '[WaterCubit] LOCAL CACHE => $consumedMl ml',
      );
    } catch (e) {
      print('[WaterCubit] load cache error: $e');
    }
  }

  Future<void> _saveLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setInt(_kGoalMl, state.goalMl);

      await prefs.setInt(
        _kDrinkMl,
        state.drinkAmountMl,
      );

      await prefs.setString(_kUnit, state.unit);

      await prefs.setInt(
        _kConsumedMl,
        state.consumedMl,
      );

      final today = DateTime.now()
          .toIso8601String()
          .split('T')
          .first;

      await prefs.setString(
        _kLastSavedDate,
        today,
      );

      final encoded =
          state.todayIntakes.map((e) {
        return jsonEncode({
          'id': e.id,
          'amountMl': e.amountMl,
          'time': e.time.toIso8601String(),
        });
      }).toList();

      await prefs.setStringList(
        _kTodayIntakes,
        encoded,
      );

      print(
        '[WaterCubit] CACHE SAVED => ${state.consumedMl} ml',
      );
    } catch (e) {
      print('[WaterCubit] save cache error: $e');
    }
  }

  // =====================================================
  // FETCH FROM BACKEND
  // =====================================================

  Future<void> _fetchTodayIntakes() async {
    try {
      final all = await _repo.getIntakes();

      final today = DateTime.now();

      final todayIntakes = all.where((e) {
        final local = e.time.toLocal();

        return local.year == today.year &&
            local.month == today.month &&
            local.day == today.day;
      }).toList();

      final backendConsumed =
          todayIntakes.fold<int>(
        0,
        (sum, e) => sum + e.amountMl,
      );

      // المهم هنا 👇
      // منخليش الباك يصفر اللي محلي

      final finalConsumed =
          backendConsumed > state.consumedMl
              ? backendConsumed
              : state.consumedMl;

      emit(
        state.copyWith(
          consumedMl: finalConsumed,
          todayIntakes: todayIntakes,
        ),
      );

      await _saveLocalCache();

      print(
        '[WaterCubit] BACKEND => $backendConsumed ml',
      );

      print(
        '[WaterCubit] FINAL => $finalConsumed ml',
      );
    } catch (e) {
      print('[WaterCubit] fetch error: $e');
    }
  }

  // =====================================================
  // DRINK
  // =====================================================

  bool _isDrinking = false;

  Future<void> drink() async {
    if (_isDrinking) return;

    _isDrinking = true;

    final previousConsumed =
        state.consumedMl;

    final updatedConsumed =
        state.consumedMl +
            state.drinkAmountMl;

    // UI فوري
    emit(
      state.copyWith(
        consumedMl: updatedConsumed,
      ),
    );

    await _saveLocalCache();

    try {
      final saved =
          await _repo.logIntake(
        amountMl: state.drinkAmountMl,
      );

      final updated = [
        ...state.todayIntakes,
        saved,
      ];

      emit(
        state.copyWith(
          todayIntakes: updated,
        ),
      );

      await _saveLocalCache();

      await _fitService.writeWater(
        saved.amountMl,
      );

      print(
        '[WaterCubit] DRINK SUCCESS => $updatedConsumed ml',
      );
    } catch (e) {
      print('[WaterCubit] drink error: $e');

      // rollback
      emit(
        state.copyWith(
          consumedMl: previousConsumed,
        ),
      );

      await _saveLocalCache();
    } finally {
      _isDrinking = false;
    }
  }

  // =====================================================
  // REMOVE
  // =====================================================

  Future<void> removeDrink() async {
    if (state.consumedMl <= 0) return;

    final updated =
        (state.consumedMl -
                state.drinkAmountMl)
            .clamp(0, 999999);

    final updatedList =
        List<WaterModel>.from(
      state.todayIntakes,
    );

    if (updatedList.isNotEmpty) {
      updatedList.removeLast();
    }

    emit(
      state.copyWith(
        consumedMl: updated,
        todayIntakes: updatedList,
      ),
    );

    await _saveLocalCache();
  }

  // =====================================================
  // RESET
  // =====================================================

  Future<void> reset() async {
    final oldIntakes =
        List<WaterModel>.from(
      state.todayIntakes,
    );

    final oldConsumed =
        state.consumedMl;

    emit(
      state.copyWith(
        consumedMl: 0,
        todayIntakes: [],
      ),
    );

    await _saveLocalCache();

    try {
      for (final intake in oldIntakes) {
        await _repo.deleteIntake(
          intake.id,
        );
      }
    } catch (e) {
      print('[WaterCubit] reset error: $e');

      emit(
        state.copyWith(
          consumedMl: oldConsumed,
          todayIntakes: oldIntakes,
        ),
      );

      await _saveLocalCache();
    }
  }

  // =====================================================
  // SETTINGS
  // =====================================================

  Future<void> updateDailyGoal(
    double valueInCurrentUnit,
  ) async {
    final ml = state.unit == 'oz'
        ? (valueInCurrentUnit / _mlToOz)
            .round()
        : valueInCurrentUnit.round();

    emit(
      state.copyWith(goalMl: ml),
    );

    await _saveLocalCache();
  }

  Future<void> updateDrinkAmount(
    double valueInCurrentUnit,
  ) async {
    final ml = state.unit == 'oz'
        ? (valueInCurrentUnit / _mlToOz)
            .round()
        : valueInCurrentUnit.round();

    emit(
      state.copyWith(
        drinkAmountMl: ml,
      ),
    );

    await _saveLocalCache();
  }

  Future<void> updateUnit(
    String unit,
  ) async {
    emit(
      state.copyWith(unit: unit),
    );

    await _saveLocalCache();
  }

  // =====================================================
  // REFRESH
  // =====================================================

  Future<void> refresh() async {
    await _fetchTodayIntakes();
  }
}