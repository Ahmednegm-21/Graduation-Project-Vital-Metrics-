// lib/logic/home/locale_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Global app language state.
// true = Arabic, false = English.
// Persisted in SharedPreferences so it survives app restarts.
class LocaleCubit extends Cubit<bool> {
  LocaleCubit() : super(true) {
    _loadSaved();
  }

  static const _prefKey = 'is_arabic';

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool(_prefKey);
    if (saved != null) emit(saved);
  }

  Future<void> setArabic(bool isArabic) async {
    emit(isArabic);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, isArabic);
  }

  void toggle() => setArabic(!state);
}