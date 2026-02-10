class HeightState {
  final double height;

  HeightState({required this.height});

  HeightState copyWith({double? height}) {
    return HeightState(
      height: height ?? this.height,
    );
  }
}
