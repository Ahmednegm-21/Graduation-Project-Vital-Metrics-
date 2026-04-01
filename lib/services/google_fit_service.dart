import 'package:vital_metrics/data/models/activity_model.dart';

/// Simple DTO returned from any data source (mock or real Google Fit).
class FitnessSnapshot {
  final int steps;
  final int caloriesBurned; // kcal
  final int workoutMinutes;
  final List<ActivityModel> activities;

  const FitnessSnapshot({
    required this.steps,
    required this.caloriesBurned,
    required this.workoutMinutes,
    required this.activities,
  });
}

abstract class GoogleFitService {
  /// Returns today's fitness data.
  Future<FitnessSnapshot> getTodaySnapshot();

  /// Factory: swap [MockGoogleFitService] ↔ [RealGoogleFitService] here.
  factory GoogleFitService() => MockGoogleFitService();
}

// ─── MOCK ────────────────────────────────────────────────────────────────────
class MockGoogleFitService implements GoogleFitService {
  @override
  Future<FitnessSnapshot> getTodaySnapshot() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    return FitnessSnapshot(
      steps: 0,
      caloriesBurned: 0,
      workoutMinutes: 0,
      activities: const [],
    );
  }
}

// ─── REAL (Google Fit) ────────────────────────────────────────────────────────
/// TODO: فعّل الـ class ده لما تربط Google Fit
///
/// خطوات الربط:
/// 1. أضف في pubspec.yaml:
///      health: ^10.2.0 
///
/// 2. Android – في android/app/src/main/AndroidManifest.xml أضف:
///      <uses-permission android:name="android.permission.ACTIVITY_RECOGNITION"/>
///      <uses-permission android:name="com.google.android.gms.permission.ACTIVITY_RECOGNITION"/>
///
/// 3. iOS – في Info.plist أضف:
///      NSHealthShareUsageDescription  → سبب الوصول للـ Health
///      NSHealthUpdateUsageDescription → لو هتكتب بيانات
///
/// 4. Google Cloud Console:
///    - فعّل Fitness API
///    - أضف OAuth 2.0 client ID للأندرويد والـ iOS
///    - أضف SHA-1 fingerprint للأندرويد
///
/// 5. استبدل [GoogleFitService()] factory بـ [RealGoogleFitService()]

/*
import 'package:health/health.dart';

class RealGoogleFitService implements GoogleFitService {
  final HealthFactory _health = HealthFactory();

  final _types = [
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.WORKOUT,
  ];

  @override
  Future<FitnessSnapshot> getTodaySnapshot() async {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    final granted = await _health.requestAuthorization(_types);
    if (!granted) throw Exception('Health permissions denied');

    final data = await _health.getHealthDataFromTypes(midnight, now, _types);

    int steps = 0;
    int calories = 0;
    int workoutMins = 0;

    for (final point in data) {
      switch (point.type) {
        case HealthDataType.STEPS:
          steps += (point.value as NumericHealthValue).numericValue.toInt();
          break;
        case HealthDataType.ACTIVE_ENERGY_BURNED:
          calories += (point.value as NumericHealthValue).numericValue.toInt();
          break;
        case HealthDataType.WORKOUT:
          workoutMins += point.dateTo.difference(point.dateFrom).inMinutes;
          break;
        default:
          break;
      }
    }

    return FitnessSnapshot(
      steps: steps,
      caloriesBurned: calories,
      workoutMinutes: workoutMins,
      activities: const [], // TODO: map workouts → ActivityModel
    );
  }
}
*/