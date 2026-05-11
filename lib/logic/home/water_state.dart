import 'package:equatable/equatable.dart';
import 'package:vital_metrics/data/models/water_model.dart';

const _mlToOz = 0.033814;

class WaterState extends Equatable {
  final int consumedMl;
  final int goalMl;
  final String unit;
  final int drinkAmountMl;
  final List<WaterModel> todayIntakes;
  final bool isLoading;

  const WaterState({
    this.consumedMl    = 0,
    this.goalMl        = 3208,
    this.unit          = 'ml',
    this.drinkAmountMl = 240,
    this.todayIntakes  = const [],
    this.isLoading     = false,
  });

  // Converted values for UI
  double get consumedInUnit    => unit == 'oz' ? consumedMl * _mlToOz    : consumedMl.toDouble();
  double get goalInUnit        => unit == 'oz' ? goalMl * _mlToOz        : goalMl.toDouble();
  double get drinkAmountInUnit => unit == 'oz' ? drinkAmountMl * _mlToOz : drinkAmountMl.toDouble();
  double get progress          => goalMl > 0 ? (consumedMl / goalMl).clamp(0.0, 1.0) : 0.0;

  WaterState copyWith({
    int? consumedMl,
    int? goalMl,
    String? unit,
    int? drinkAmountMl,
    List<WaterModel>? todayIntakes,
    bool? isLoading,
  }) {
    return WaterState(
      consumedMl:    consumedMl    ?? this.consumedMl,
      goalMl:        goalMl        ?? this.goalMl,
      unit:          unit          ?? this.unit,
      drinkAmountMl: drinkAmountMl ?? this.drinkAmountMl,
      todayIntakes:  todayIntakes  ?? this.todayIntakes,
      isLoading:     isLoading     ?? this.isLoading,
    );
  }

  @override
  List<Object> get props =>
      [consumedMl, goalMl, unit, drinkAmountMl, todayIntakes, isLoading];
}