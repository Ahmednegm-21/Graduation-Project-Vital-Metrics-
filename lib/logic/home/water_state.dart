import 'package:equatable/equatable.dart';

class WaterState extends Equatable {
  final double consumed; // ml consumed today
  final double dailyGoal; // ml daily goal
  final double drinkAmount; // ml per drink action
  final String unit; // 'ml' or 'oz'

  const WaterState({
    this.consumed = 0,
    this.dailyGoal = 3208,
    this.drinkAmount = 250,
    this.unit = 'ml',
  });

  double get consumedInUnit =>
      unit == 'oz' ? consumed / 29.5735 : consumed;

  double get goalInUnit =>
      unit == 'oz' ? dailyGoal / 29.5735 : dailyGoal;

  double get drinkAmountInUnit =>
      unit == 'oz' ? drinkAmount / 29.5735 : drinkAmount;

  double get progress => dailyGoal > 0 ? (consumed / dailyGoal).clamp(0, 1) : 0;

  WaterState copyWith({
    double? consumed,
    double? dailyGoal,
    double? drinkAmount,
    String? unit,
  }) {
    return WaterState(
      consumed: consumed ?? this.consumed,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      drinkAmount: drinkAmount ?? this.drinkAmount,
      unit: unit ?? this.unit,
    );
  }

  @override
  List<Object> get props => [consumed, dailyGoal, drinkAmount, unit];
}