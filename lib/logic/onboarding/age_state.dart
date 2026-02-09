class AgeState {
  final double age;

  AgeState({required this.age});

  AgeState copyWith({double? age}) {
    return AgeState(
      age: age ?? this.age,
    );
  }
}
