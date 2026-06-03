import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vital_metrics/data/models/sleep_model.dart';
import 'package:vital_metrics/data/repositories/daily_metrics_repository.dart';
import 'package:vital_metrics/data/repositories/sleep_repository.dart';
import 'package:vital_metrics/logic/home/sleep_state.dart';
import 'package:vital_metrics/logic/progress/progress_cubit.dart';
import 'package:vital_metrics/services/google_fit_service.dart';

export 'sleep_state.dart';

const _kSleepHours = 'cached_sleep_hours';
const _kSleepId = 'cached_sleep_id';
const _kSleepDate = 'cached_sleep_date';

class SleepCubit extends Cubit<SleepState> {
  final SleepRepository _repo;
  final GoogleFitService _fitService;
  final DailyMetricsRepository _metricsRepo;

  // ← ProgressCubit reference (اختياري، يتربط بعد الإنشاء)
  ProgressCubit? _progressCubit;

  SleepCubit({
    SleepRepository? repository,
    GoogleFitService? fitService,
    DailyMetricsRepository? metricsRepo,
  })  : _repo = repository ?? SleepRepository(),
        _fitService = fitService ?? GoogleFitService(),
        _metricsRepo = metricsRepo ?? DailyMetricsRepository(),
        super(const SleepState()) {
    Future.microtask(() => _init());
  }

  // =====================================================
  // ربط ProgressCubit — يُستدعى من main.dart أو providers
  // =====================================================

  void setProgressCubit(ProgressCubit cubit) {
    _progressCubit = cubit;
  }

  // =====================================================
  // INIT
  // =====================================================

  Future<void> _init() async {
    emit(state.copyWith(isLoading: true));
    await _loadLocalCache();
    await _fetchFromBackend();
    emit(state.copyWith(isLoading: false));
  }

  // =====================================================
  // LOAD CACHE
  // =====================================================

  Future<void> _loadLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T').first;
      final savedDate = prefs.getString(_kSleepDate);

      // يوم جديد — صفّر الكاش
      if (savedDate != today) {
        await prefs.setString(_kSleepDate, today);
        await prefs.setDouble(_kSleepHours, 0);
        await prefs.remove(_kSleepId);
        emit(state.copyWith(sleepHours: 0, sleepId: null));
        return;
      }

      final cachedHours = prefs.getDouble(_kSleepHours) ?? 0;
      final cachedId = prefs.getInt(_kSleepId);
      emit(state.copyWith(sleepHours: cachedHours, sleepId: cachedId));
    } catch (e) {
      print('[SleepCubit] load cache error: $e');
    }
  }

  // =====================================================
  // SAVE CACHE
  // =====================================================

  Future<void> _saveLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T').first;
      await prefs.setString(_kSleepDate, today);
      await prefs.setDouble(_kSleepHours, state.sleepHours);
      if (state.sleepId != null) {
        await prefs.setInt(_kSleepId, state.sleepId!);
      }
    } catch (e) {
      print('[SleepCubit] save cache error: $e');
    }
  }

  // =====================================================
  // FETCH FROM BACKEND
  // =====================================================

  Future<void> _fetchFromBackend() async {
    try {
      final todayMetric = await _metricsRepo.getTodayMetric();
      final todayMetricsId = todayMetric?.metricId;
      if (todayMetricsId == null || todayMetricsId == 0) return;

      final allSleeps = await _repo.getSleeps();
      final todaySleeps =
          allSleeps.where((s) => s.metricsId == todayMetricsId).toList();
      if (todaySleeps.isEmpty) return;

      final firstSession = todaySleeps.first;

      // ← استخدم الـ session الأكبر بدل جمع كل الـ sessions
      // الباك ممكن يحفظ نفس الـ session أكتر من مرة
      final maxMinutes = todaySleeps
          .map((s) => s.durationMinutes)
          .reduce((a, b) => a > b ? a : b);

      final cappedMinutes = maxMinutes.clamp(0, 12 * 60);
      final hours = _roundToHalf(cappedMinutes / 60.0);

      emit(state.copyWith(sleepHours: hours, sleepId: firstSession.id));
      await _saveLocalCache();

      // ← بلّغ ProgressCubit بالقيمة الجديدة
      _progressCubit?.updateTodaySleep(cappedMinutes);

      print('[SleepCubit] synced from backend: ${hours}h');
    } catch (e) {
      print('[SleepCubit] backend error: $e');
    }
  }

  // =====================================================
  // UPDATE HOURS (من الـ slider — بدون حفظ للباك)
  // =====================================================

  void updateHours(double hours) {
    emit(state.copyWith(sleepHours: hours));
    _saveLocalCache();
  }

  // =====================================================
  // SAVE SLEEP (بعد ما المستخدم يرفع إيده عن الـ slider)
  // =====================================================

  Future<void> saveSleep() async {
    if (state.isSaving) return;

    emit(state.copyWith(isSaving: true));
    await _saveLocalCache();

    try {
      SleepModel result;

      if (state.hasTodaySleep) {
        result = await _repo.updateSleep(
          id: state.sleepId!,
          durationMinutes: state.durationMinutes,
          quality: state.quality,
        );
        print('[SleepCubit] updated sleep');
      } else {
        result = await _repo.createSleep(
          durationMinutes: state.durationMinutes,
          quality: state.quality,
        );
        print('[SleepCubit] created sleep');
      }

      // Health Connect — تحقق من الـ preference الأول
      final prefs = await SharedPreferences.getInstance();
      final sleepHcEnabled = prefs.getBool('hc_sleep_enabled') ?? true;
      if (sleepHcEnabled) {
        final end = DateTime.now();
        final start = end.subtract(Duration(minutes: state.durationMinutes));
        await _fitService.writeSleep(start: start, end: end);
      }

      emit(state.copyWith(sleepId: result.id, isSaving: false));
      await _saveLocalCache();

      // ← بلّغ ProgressCubit بعد الحفظ الناجح
      _progressCubit?.updateTodaySleep(state.durationMinutes);

      print('[SleepCubit] sleep saved & progress updated');
    } catch (e) {
      print('[SleepCubit] save error: $e');
      emit(state.copyWith(isSaving: false));
    }
  }

  // =====================================================
  // RESET
  // =====================================================

  Future<void> resetSleep() async {
    emit(state.copyWith(sleepHours: 0, sleepId: null));

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kSleepHours);
    await prefs.remove(_kSleepId);
    final today = DateTime.now().toIso8601String().split('T').first;
    await prefs.setString(_kSleepDate, today);

    // ← صفّر النوم في الـ progress كمان
    _progressCubit?.updateTodaySleep(0);
  }

  // =====================================================
  // REFRESH
  // =====================================================

  Future<void> refresh() async {
    await _fetchFromBackend();
  }

  // =====================================================
  // HELPERS
  // =====================================================

  double _roundToHalf(double value) {
    return (value * 2).round() / 2.0;
  }
}