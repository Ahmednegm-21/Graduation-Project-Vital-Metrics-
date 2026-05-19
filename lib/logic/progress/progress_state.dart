part of 'progress_cubit.dart';

abstract class ProgressState extends Equatable {
  const ProgressState();

  @override
  List<Object?> get props => [];
}

class ProgressInitial extends ProgressState {
  const ProgressInitial();
}

class ProgressLoading extends ProgressState {
  const ProgressLoading();
}

class ProgressLoaded extends ProgressState {
  final List<DailyMetricModel> weeklyMetrics;

  const ProgressLoaded({
    required this.weeklyMetrics,
  });

  // =====================================================
  // STEPS DATA
  // =====================================================

  List<int> get steps {
    return weeklyMetrics
        .map(
          (metric) => metric.totalSteps,
        )
        .toList();
  }

  // =====================================================
  // CALORIES CONSUMED DATA
  // =====================================================

  List<int> get calories {
    return weeklyMetrics
        .map(
          (metric) => metric.caloriesConsumed,
        )
        .toList();
  }

  // =====================================================
  // BURNED CALORIES DATA
  // =====================================================

  List<int> get burned {
    return weeklyMetrics
        .map(
          (metric) => metric.burnedTotal,
        )
        .toList();
  }

  // =====================================================
  // WATER DATA
  // =====================================================

  List<int> get waterMl {
    return weeklyMetrics
        .map(
          (metric) => metric.totalWaterMl,
        )
        .toList();
  }

  // =====================================================
  // SLEEP DATA
  // =====================================================

  List<double> get sleepHrs {
    return weeklyMetrics
        .map(
          (metric) => metric.sleepHours,
        )
        .toList();
  }

  // =====================================================
  // TODAY HELPERS
  // =====================================================

  DailyMetricModel? get todayMetric {
    if (weeklyMetrics.isEmpty) {
      return null;
    }

    final today = DateTime.now();

    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    try {
      return weeklyMetrics.firstWhere(
        (metric) =>
            metric.date.startsWith(
          todayStr,
        ),
      );
    } catch (_) {
      return weeklyMetrics.last;
    }
  }

  int get todaySteps {
    return todayMetric?.totalSteps ?? 0;
  }

  int get todayCaloriesConsumed {
    return todayMetric?.caloriesConsumed ?? 0;
  }

  int get todayBurnedCalories {
    return todayMetric?.burnedTotal ?? 0;
  }

  int get todayWaterMl {
    return todayMetric?.totalWaterMl ?? 0;
  }

  double get todaySleepHours {
    return todayMetric?.sleepHours ?? 0;
  }

  // =====================================================
  // WEEK TOTALS
  // =====================================================

  int get weeklyStepsTotal {
    return steps.fold(
      0,
      (sum, value) => sum + value,
    );
  }

  int get weeklyBurnedTotal {
    return burned.fold(
      0,
      (sum, value) => sum + value,
    );
  }

  int get weeklyCaloriesConsumedTotal {
    return calories.fold(
      0,
      (sum, value) => sum + value,
    );
  }

  // =====================================================
  // EQUATABLE
  // =====================================================

  @override
  List<Object?> get props => [
        weeklyMetrics,
      ];
}

class ProgressError extends ProgressState {
  final String message;

  const ProgressError(
    this.message,
  );

  @override
  List<Object?> get props => [
        message,
      ];
}