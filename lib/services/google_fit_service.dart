import 'package:health/health.dart';
import 'package:vital_metrics/data/models/activity_model.dart';

// Snapshot of today's fitness data from Health Connect
class FitnessSnapshot {
  final int steps;
  final int caloriesBurned;
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
  // Read today's activity snapshot from Health Connect
  Future<FitnessSnapshot> getTodaySnapshot();

  // Write water intake to Health Connect so it shows in Google Fit
  Future<void> writeWater(int amountMl);

  // Write sleep session to Health Connect so it shows in Google Fit
  Future<void> writeSleep(int durationMinutes);

  factory GoogleFitService() => RealGoogleFitService();
}

// Mock service for testing UI without Health Connect
class MockGoogleFitService implements GoogleFitService {
  @override
  Future<FitnessSnapshot> getTodaySnapshot() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return const FitnessSnapshot(
      steps:          5420,
      caloriesBurned: 320,
      workoutMinutes: 45,
      activities:     [],
    );
  }

  @override
  Future<void> writeWater(int amountMl) async {}

  @override
  Future<void> writeSleep(int durationMinutes) async {}
}

// Real service that reads from and writes to Health Connect
class RealGoogleFitService implements GoogleFitService {
  final Health _health = Health();

  // Types we READ — activity data only
  static const _readTypes = [
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.WORKOUT,
    HealthDataType.DISTANCE_DELTA,
  ];

  // Types we WRITE — water and sleep entered by user in app
  static const _writeTypes = [
    HealthDataType.WATER,
    HealthDataType.SLEEP_SESSION,
  ];

  // Combined types list for authorization request
  static final _allTypes = [..._readTypes, ..._writeTypes];

  // Read for activity types, read/write for water and sleep
  static final _permissions = [
    ..._readTypes.map((_) => HealthDataAccess.READ),
    ..._writeTypes.map((_) => HealthDataAccess.READ_WRITE),
  ];

  // Request all needed permissions once
  Future<bool> _requestPermissions() async {
    final sdkStatus = await _health.getHealthConnectSdkStatus();
    if (sdkStatus != HealthConnectSdkStatus.sdkAvailable) {
      print('Health Connect not available: $sdkStatus');
      return false;
    }
    final granted = await _health.requestAuthorization(
      _allTypes,
      permissions: _permissions,
    );
    print('Health Connect permissions granted: $granted');
    return granted;
  }

  @override
  Future<FitnessSnapshot> getTodaySnapshot() async {
    try {
      final granted = await _requestPermissions();
      if (!granted) {
        return const FitnessSnapshot(
          steps:          0,
          caloriesBurned: 0,
          workoutMinutes: 0,
          activities:     [],
        );
      }

      final now      = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      final data = await _health.getHealthDataFromTypes(
        types:     _readTypes,
        startTime: midnight,
        endTime:   now,
      );

      final cleaned = Health().removeDuplicates(data);

      int steps       = 0;
      int calories    = 0;
      int workoutMins = 0;
      final activities = <ActivityModel>[];

      for (final point in cleaned) {
        try {
          switch (point.type) {

            case HealthDataType.STEPS:
              final value = point.value as NumericHealthValue;
              steps += value.numericValue.toInt();
              break;

            case HealthDataType.ACTIVE_ENERGY_BURNED:
              final value = point.value as NumericHealthValue;
              calories += value.numericValue.toInt();
              break;

            case HealthDataType.WORKOUT:
              final mins = point.dateTo.difference(point.dateFrom).inMinutes;
              workoutMins += mins;

              String workoutType = 'Workout';
              if (point.value is WorkoutHealthValue) {
                final wv = point.value as WorkoutHealthValue;
                workoutType = wv.workoutActivityType.name;
              }

              int workoutCalories = 0;
              if (point.value is NumericHealthValue) {
                final value = point.value as NumericHealthValue;
                workoutCalories = value.numericValue.toInt();
              }

              activities.add(ActivityModel(
                id:              '${point.dateFrom.millisecondsSinceEpoch}',
                type:            _formatWorkoutType(workoutType),
                durationMinutes: mins,
                caloriesBurned:  workoutCalories,
                timestamp:       point.dateFrom,
              ));
              break;

            default:
              break;
          }
        } catch (e) {
          print('Error processing health point: $e');
          continue;
        }
      }

      return FitnessSnapshot(
        steps:          steps,
        caloriesBurned: calories,
        workoutMinutes: workoutMins,
        activities:     activities,
      );
    } catch (e) {
      print('Error fetching health data: $e');
      return const FitnessSnapshot(
        steps:          0,
        caloriesBurned: 0,
        workoutMinutes: 0,
        activities:     [],
      );
    }
  }

  @override
  Future<void> writeWater(int amountMl) async {
    try {
      final granted = await _requestPermissions();
      if (!granted) return;

      final now = DateTime.now();

      // Health Connect stores water in liters
      await _health.writeHealthData(
        value:     amountMl / 1000.0,
        type:      HealthDataType.WATER,
        startTime: now,
        endTime:   now,
        unit:      HealthDataUnit.LITER,
      );

      print('Water written to Health Connect: $amountMl ml');
    } catch (e) {
      // Write failure should not affect app flow
      print('Failed to write water to Health Connect: $e');
    }
  }

  @override
  Future<void> writeSleep(int durationMinutes) async {
    try {
      final granted = await _requestPermissions();
      if (!granted) return;

      final now        = DateTime.now();
      // Calculate sleep start by subtracting duration from now
      final sleepStart = now.subtract(Duration(minutes: durationMinutes));

      await _health.writeHealthData(
        value:     0,
        type:      HealthDataType.SLEEP_SESSION,
        startTime: sleepStart,
        endTime:   now,
      );

      print('Sleep written to Health Connect: $durationMinutes minutes');
    } catch (e) {
      // Write failure should not affect app flow
      print('Failed to write sleep to Health Connect: $e');
    }
  }

  // Format workout type from Health Connect enum to readable name
  String _formatWorkoutType(String type) {
    final formatted = type.replaceAll('_', ' ').toLowerCase();
    return formatted
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}