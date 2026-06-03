import 'package:shared_preferences/shared_preferences.dart';

/// بيمسح كل الداتا المحلية المرتبطة بالـ user
/// يُستدعى عند logout أو عند login يوزر جديد
class LocalDataClearService {
  LocalDataClearService._();

  /// مسح داتا اليوزر بس — بدون الـ Health Connect preferences
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();

    // ── Water ──────────────────────────────────────────
    await prefs.remove('water_goal_ml');
    await prefs.remove('water_drink_amount_ml');
    await prefs.remove('water_unit');
    await prefs.remove('water_consumed_ml');
    await prefs.remove('water_today_intakes');
    await prefs.remove('water_last_saved_date');
    await prefs.remove('water_goal_set_from_profile');

    // ── Sleep ──────────────────────────────────────────
    await prefs.remove('cached_sleep_hours');
    await prefs.remove('cached_sleep_id');
    await prefs.remove('cached_sleep_date');

    // ── Calories ───────────────────────────────────────
    await prefs.remove('cached_meals');
    await prefs.remove('cached_budget');
    await prefs.remove('cached_date');

    // ── Activity ───────────────────────────────────────
    await prefs.remove('activity_original_types');
    await prefs.remove('activity_level');
    await prefs.remove('activity_cached_list');
    await prefs.remove('activity_cached_date');

    // ── Personal Info ──────────────────────────────────
    await prefs.remove('pi_gender');
    await prefs.remove('pi_weight');
    await prefs.remove('pi_height');
    await prefs.remove('pi_year');

    // ← لا نمسح hc_permission_granted ولا hc_*_enabled
    // عشان اليوزر ميضطرش يوافق على permissions كل مرة

    print('[LocalDataClearService] all user data cleared');
  }

  /// مسح كامل شامل الـ HC permissions — عند تغيير الجهاز أو reinstall
  static Future<void> clearAllIncludingHC() async {
    await clearAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('hc_permission_granted');
    await prefs.remove('hc_steps_enabled');
    await prefs.remove('hc_sleep_enabled');
    await prefs.remove('hc_water_enabled');
    print('[LocalDataClearService] full clear including HC preferences');
  }
}