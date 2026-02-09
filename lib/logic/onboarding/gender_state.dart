import 'package:flutter/material.dart';

class GenderState {
  final String? selectedGender;
  final Color accent;

  const GenderState({
    required this.selectedGender,
    required this.accent,
  });

  factory GenderState.initial() {
    return const GenderState(
      selectedGender: null,
      accent: Color(0xFF005EBD),
    );
  }

  GenderState copyWith({
    String? selectedGender,
    Color? accent,
  }) {
    return GenderState(
      selectedGender: selectedGender ?? this.selectedGender,
      accent: accent ?? this.accent,
    );
  }
}
