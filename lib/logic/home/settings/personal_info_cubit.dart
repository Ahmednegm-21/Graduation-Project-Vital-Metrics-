import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'personal_info_state.dart';

export 'personal_info_state.dart';

class PersonalInfoCubit extends Cubit<PersonalInfoState> {
  PersonalInfoCubit() : super(const PersonalInfoState()) {
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    emit(PersonalInfoState(
      gender:      p.getString('pi_gender') ?? 'male',
      weight:      p.getDouble('pi_weight') ?? 70.0,
      height:      p.getDouble('pi_height') ?? 170.0,
      yearOfBirth: p.getInt('pi_year')      ?? 2000,
    ));
  }

  Future<void> save({
    required String gender,
    required double weight,
    required double height,
    required int    yearOfBirth,
  }) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('pi_gender', gender);
    await p.setDouble('pi_weight', weight);
    await p.setDouble('pi_height', height);
    await p.setInt('pi_year',     yearOfBirth);
    emit(state.copyWith(
      gender:      gender,
      weight:      weight,
      height:      height,
      yearOfBirth: yearOfBirth,
    ));
  }
}