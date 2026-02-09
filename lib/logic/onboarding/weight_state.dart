class WeightState {
  final double weight;

  WeightState({required this.weight});

  WeightState copyWith({double? weight}) {
    return WeightState(
      weight: weight ?? this.weight,
    );
  }
}
