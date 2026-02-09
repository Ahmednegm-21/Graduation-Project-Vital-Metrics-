import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'gender_state.dart';

class GenderCubit extends Cubit<GenderState> {
  static const Color primaryBlue = Color(0xFF005EBD);
  static const Color femalePink = Color(0xFFFF7EB9);

  final AnimationController animCtrl;

  GenderCubit({required this.animCtrl})
      : super(GenderState.initial());

  void selectGender(String gender) {
    if (gender == state.selectedGender) return;

    if (gender == 'female') {
      animCtrl.forward();
    } else {
      animCtrl.reverse();
    }

    emit(
      state.copyWith(
        selectedGender: gender,
        accent: gender == 'male' ? primaryBlue : femalePink,
      ),
    );
  }
}
