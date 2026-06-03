import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vital_metrics/logic/fitness/fitness_snapshot_cubit.dart';
import 'package:vital_metrics/logic/activity/activity_cubit.dart';

const _kStepsEnabled = 'hc_steps_enabled';
const _kSleepEnabled = 'hc_sleep_enabled';
const _kWaterEnabled = 'hc_water_enabled';

class StepsConnectToggle extends StatefulWidget {
  const StepsConnectToggle({super.key});

  @override
  State<StepsConnectToggle> createState() => _StepsConnectToggleState();
}

class _StepsConnectToggleState extends State<StepsConnectToggle> {
  bool _enabled = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _enabled = prefs.getBool(_kStepsEnabled) ?? true);
  }

  Future<void> _toggle() async {
    final prefs = await SharedPreferences.getInstance();
    final newVal = !_enabled;
    await prefs.setBool(_kStepsEnabled, newVal);
    setState(() => _enabled = newVal);

    if (newVal) {
      // Enabled: load a fresh snapshot from Health Connect
      context.read<FitnessSnapshotCubit>().enable();

      // Refresh ActivityCubit to include the new HC snapshot
      try {
        context.read<ActivityCubit>().refresh();
      } catch (_) {}
    } else {
      // Disabled: clear the HC snapshot from ActivityCubit immediately
      // so stale HC data does not remain visible after disabling
      // Do NOT remove activity_cached_list because it holds manually
      // logged activities that must be preserved
      context.read<FitnessSnapshotCubit>().disable();
      try {
        context.read<ActivityCubit>().clearSnapshot();
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ToggleBadge(
      label: _enabled ? 'Steps: ON' : 'Steps: OFF',
      color: _enabled ? const Color(0xFF63E6BE) : const Color(0xFF8A8A8A),
      onTap: () => _showConfirm(
        context,
        title: 'Steps & Activity Tracking',
        body: _enabled
            ? 'Disable Health Connect for steps and workout tracking?'
            : 'Enable Health Connect to auto-track steps and workouts?',
        onConfirm: _toggle,
      ),
    );
  }
}

class SleepConnectToggle extends StatefulWidget {
  const SleepConnectToggle({super.key});

  @override
  State<SleepConnectToggle> createState() => _SleepConnectToggleState();
}

class _SleepConnectToggleState extends State<SleepConnectToggle> {
  bool _enabled = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _enabled = prefs.getBool(_kSleepEnabled) ?? true);
  }

  Future<void> _toggle() async {
    final prefs = await SharedPreferences.getInstance();
    final newVal = !_enabled;
    await prefs.setBool(_kSleepEnabled, newVal);
    setState(() => _enabled = newVal);
    print('[HealthToggle] sleep hc enabled=$newVal');
  }

  @override
  Widget build(BuildContext context) {
    return _ToggleBadge(
      label: _enabled ? 'Sleep Sync: ON' : 'Sleep Sync: OFF',
      color: _enabled ? const Color(0xFF7B5EA7) : const Color(0xFF8A8A8A),
      onTap: () => _showConfirm(
        context,
        title: 'Sleep Sync',
        body: _enabled
            ? 'Stop syncing sleep data to Health Connect?'
            : 'Enable syncing sleep data to Health Connect?',
        onConfirm: _toggle,
      ),
    );
  }
}

class WaterConnectToggle extends StatefulWidget {
  const WaterConnectToggle({super.key});

  @override
  State<WaterConnectToggle> createState() => _WaterConnectToggleState();
}

class _WaterConnectToggleState extends State<WaterConnectToggle> {
  bool _enabled = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _enabled = prefs.getBool(_kWaterEnabled) ?? true);
  }

  Future<void> _toggle() async {
    final prefs = await SharedPreferences.getInstance();
    final newVal = !_enabled;
    await prefs.setBool(_kWaterEnabled, newVal);
    setState(() => _enabled = newVal);
    print('[HealthToggle] water hc enabled=$newVal');
  }

  @override
  Widget build(BuildContext context) {
    return _ToggleBadge(
      label: _enabled ? 'Water Sync: ON' : 'Water Sync: OFF',
      color: _enabled ? const Color(0xFF4CC9F0) : const Color(0xFF8A8A8A),
      onTap: () => _showConfirm(
        context,
        title: 'Water Sync',
        body: _enabled
            ? 'Stop syncing water intake to Health Connect?'
            : 'Enable syncing water intake to Health Connect?',
        onConfirm: _toggle,
      ),
    );
  }
}

class _ToggleBadge extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ToggleBadge({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7.w,
              height: 7.w,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(Icons.keyboard_arrow_down_rounded, color: color, size: 12.sp),
          ],
        ),
      ),
    );
  }
}

void _showConfirm(
  BuildContext context, {
  required String title,
  required String body,
  required VoidCallback onConfirm,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1A2340)
            : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Icon(Icons.favorite_rounded,
              color: const Color(0xFF63E6BE), size: 32.sp),
          SizedBox(height: 12.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : const Color(0xFF1A1A2E),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            body,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey, height: 1.5),
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 46.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Center(
                      child: Text('Cancel',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    onConfirm();
                  },
                  child: Container(
                    height: 46.h,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4361EE), Color(0xFF738EFF)],
                      ),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Center(
                      child: Text('Confirm',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Future<bool> isSleepHcEnabled() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_kSleepEnabled) ?? true;
}

Future<bool> isWaterHcEnabled() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_kWaterEnabled) ?? true;
}

Future<bool> isStepsHcEnabled() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_kStepsEnabled) ?? true;
}