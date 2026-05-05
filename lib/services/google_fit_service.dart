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
  Future<FitnessSnapshot> getTodaySnapshot();

  // Using Real service now that Manifest is fixed with correct intent filters
  factory GoogleFitService() => RealGoogleFitService();
}

// Mock service returns fake data for testing UI without Health Connect data
class MockGoogleFitService implements GoogleFitService {
  @override
  Future<FitnessSnapshot> getTodaySnapshot() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    return const FitnessSnapshot(
      steps:          5420,
      caloriesBurned: 320,
      workoutMinutes: 45,
      activities:     [],
    );
  }
}

// Real service that reads from Health Connect
// Requires Health Connect to be installed and permissions granted
class RealGoogleFitService implements GoogleFitService {
  final Health _health = Health();

  // Data types we want to read from Health Connect
  static const _types = [
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.WORKOUT,
    HealthDataType.DISTANCE_DELTA,
  ];

  // All types require READ access only
  static final _permissions = List.generate(
    _types.length,
    (_) => HealthDataAccess.READ,
  );

  @override
  Future<FitnessSnapshot> getTodaySnapshot() async {
    try {
      print('🏃 Fetching health data...');

      final now      = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      // Check if Health Connect SDK is available on this device
      // This prevents the Permission launcher not found crash
      final sdkStatus = await _health.getHealthConnectSdkStatus();
      print('Health Connect SDK Status: $sdkStatus');

      // If Health Connect is not installed or not available return zeros
      if (sdkStatus != HealthConnectSdkStatus.sdkAvailable) {
        print('❌ Health Connect not available on this device: $sdkStatus');
        return const FitnessSnapshot(
          steps:          0,
          caloriesBurned: 0,
          workoutMinutes: 0,
          activities:     [],
        );
      }

      // Request permissions from Health Connect
      // This will now show the proper permission screen because of the intent filter in Manifest
      final granted = await _health.requestAuthorization(
        _types,
        permissions: _permissions,
      );

      print('✅ Permissions granted: $granted');

      if (!granted) {
        print('❌ Health permissions denied by user');
        return const FitnessSnapshot(
          steps:          0,
          caloriesBurned: 0,
          workoutMinutes: 0,
          activities:     [],
        );
      }

      // Fetch all health data points for today
      final data = await _health.getHealthDataFromTypes(
        types:     _types,
        startTime: midnight,
        endTime:   now,
      );

      print('📊 Health data points: ${data.length}');

      // Remove duplicate data points from multiple sources
      final cleaned = Health().removeDuplicates(data);
      print('📊 After removing duplicates: ${cleaned.length}');

      int steps        = 0;
      int calories     = 0;
      int workoutMins  = 0;
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

              // Get the workout type name from Health Connect
              String workoutType = 'Workout';
              if (point.value is WorkoutHealthValue) {
                final workoutValue = point.value as WorkoutHealthValue;
                workoutType = workoutValue.workoutActivityType.name;
              }

              // Get calories burned during this workout if available
              int workoutCalories = 0;
              if (point.value is NumericHealthValue) {
                final value = point.value as NumericHealthValue;
                workoutCalories = value.numericValue.toInt();
              }

              // Use timestamp as id for Health Connect activities
              // Cubit will detect these large timestamp ids and skip backend calls
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
          print('⚠️ Error processing health data point: $e');
          continue;
        }
      }

      print('✅ Steps: $steps');
      print('✅ Calories: $calories');
      print('✅ Workout minutes: $workoutMins');
      print('✅ Activities: ${activities.length}');

      return FitnessSnapshot(
        steps:          steps,
        caloriesBurned: calories,
        workoutMinutes: workoutMins,
        activities:     activities,
      );
    } catch (e) {
      // Return zeros if anything fails so the app does not crash
      print('❌ Error fetching health data: $e');
      return const FitnessSnapshot(
        steps:          0,
        caloriesBurned: 0,
        workoutMinutes: 0,
        activities:     [],
      );
    }
  }

  // Format workout type from Health Connect enum name to readable display name
  // Example: RUNNING_TREADMILL becomes Running Treadmill
  String _formatWorkoutType(String type) {
    final formatted = type.replaceAll('_', ' ').toLowerCase();
    return formatted
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}