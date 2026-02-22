import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<bool> {
  ThemeCubit() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    emit(prefs.getBool('dark_mode') ?? false);
  }

  Future<void> toggle() async {
    final next = !state;
    emit(next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', next);
  }
}