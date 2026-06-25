import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vital_metrics/core/themes/theme_context_extension.dart';
import 'package:vital_metrics/data/config/api_config.dart';
import 'package:vital_metrics/data/exceptions/api_exception.dart';
import 'package:vital_metrics/logic/auth/auth_cubit.dart';
import 'package:vital_metrics/logic/auth/auth_state.dart';
import 'package:vital_metrics/services/api_service.dart';
import 'package:vital_metrics/services/device_token_manager.dart';
import 'package:vital_metrics/services/token_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _api          = ApiService();
  final _tokenStorage = TokenStorageService();

  Map<String, int>? _stats;
  bool   _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  // ── Fetch overview stats from the backend ──────────────────────────────────
  Future<void> _loadStats() async {
    setState(() {
      _loading = true;
      _error   = null;
    });
    try {
      final token = await _tokenStorage.getToken();
      if (token == null) throw UnauthorizedException('No token found');

      final headers = ApiConfig.headers(token: token);
      final res     = await _api.get(ApiConfig.adminOverview, headers: headers);

      setState(() {
        _stats = {
  'Users':          (res['totalUsers']               as num?)?.toInt() ?? 0,
  'Meals':          (res['totalMeals']               as num?)?.toInt() ?? 0,
  'Daily Metrics':  (res['totalDailyMetricsRecords'] as num?)?.toInt() ?? 0,
};
        _loading = false;
      });
    } on ApiException catch (e) {
      setState(() { _error = e.message; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  // ── Sign-out flow with confirmation dialog ─────────────────────────────────
  Future<void> _signOut() async {
    final ok = await showCupertinoDialog<bool>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title:   const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (ok != true || !mounted) return;

    // 1. Unregister FCM token
    await DeviceTokenManager.instance.unregisterOnLogout();

    // 2. Clear all stored tokens
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('accessToken');
    await prefs.remove('token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_id');

    // 3. Notify AuthCubit → BlocListener navigates to /signin
    if (mounted) context.read<AuthCubit>().signOut();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bg     = isDark ? const Color(0xFF0F1221) : const Color(0xFFF0F3FF);

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) context.go('/signin');
      },
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: Column(
            children: [
              // ── Header row: badge + refresh + sign-out ──────────────────
              FadeInDown(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
                  child: Row(
                    children: [
                      // Admin badge
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4361EE), Color(0xFF4CC9F0)],
                            begin: Alignment.topLeft,
                            end:   Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14.r),
                          boxShadow: [
                            BoxShadow(
                              color:      const Color(0xFF4361EE).withOpacity(0.35),
                              blurRadius: 12,
                              offset:     const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.admin_panel_settings,
                                color: Colors.white, size: 18.sp),
                            SizedBox(width: 6.w),
                            Text(
                              'Admin Panel',
                              style: TextStyle(
                                color:      Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize:   13.sp,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Refresh button
                      GestureDetector(
                        onTap: _loadStats,
                        child: Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1A2340)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color:      Colors.black.withOpacity(
                                    isDark ? 0.3 : 0.07),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Icon(Icons.refresh,
                              color: const Color(0xFF4361EE), size: 20.sp),
                        ),
                      ),

                      SizedBox(width: 8.w),

                      // Sign-out button
                      GestureDetector(
                        onTap: _signOut,
                        child: Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1A2340)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color:      Colors.black.withOpacity(
                                    isDark ? 0.3 : 0.07),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Icon(Icons.logout,
                              color: const Color(0xFFFF4757), size: 20.sp),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Title section ────────────────────────────────────────────
              FadeInDown(
                delay: const Duration(milliseconds: 80),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dashboard',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1A1A2E),
                            fontWeight: FontWeight.bold,
                            fontSize:   26.sp,
                          ),
                        ),
                        Text(
                          'Vital Metrics Overview',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white38
                                : const Color(0xFF9B9B9B),
                            fontSize: 13.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Main body: loading / error / grid ───────────────────────
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color:       Color(0xFF4361EE),
                          strokeWidth: 2.5,
                        ),
                      )
                    : _error != null
                        ? _ErrorWidget(
                            message: _error!,
                            onRetry: _loadStats,
                          )
                        : _StatsGrid(
                            stats:  _stats!,
                            isDark: isDark,
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Stats Grid ────────────────────────────────────────────────────────────────
class _StatsGrid extends StatelessWidget {
  final Map<String, int> stats;
  final bool isDark;

  const _StatsGrid({required this.stats, required this.isDark});

  static const _icons = {
  'Users':         Icons.people_outline,
  'Meals':         Icons.restaurant_menu_outlined,
  'Daily Metrics': Icons.bar_chart,
};

  static const _colors = {
  'Users':         Color(0xFF4361EE),
  'Meals':         Color(0xFF63E6BE),
  'Daily Metrics': Color(0xFF4CC9F0),
};

  @override
  Widget build(BuildContext context) {
    final entries = stats.entries.toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GridView.builder(
        physics:  const BouncingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:   2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing:  12.h,
          // Use a fixed item height instead of aspect ratio to avoid overflow.
          // mainAxisExtent gives each card exactly 140.h regardless of screen size.
          mainAxisExtent: 140.h,
        ),
        itemCount: entries.length,
        itemBuilder: (_, i) {
          final label = entries[i].key;
          final value = entries[i].value;
          final color = _colors[label] ?? const Color(0xFF4361EE);
          final icon  = _icons[label]  ?? Icons.info_outline;

          return FadeInUp(
            delay: Duration(milliseconds: 80 * i),
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color:        isDark ? const Color(0xFF1A2340) : Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border:       Border.all(color: color.withOpacity(0.18)),
                boxShadow: [
                  BoxShadow(
                    color:      isDark
                        ? Colors.black38
                        : Colors.black.withOpacity(0.06),
                    blurRadius: 14,
                    offset:     const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                children: [
                  // Icon badge
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color:        color.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(icon, color: color, size: 20.sp),
                  ),

                  // Value + label
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$value',
                        style: TextStyle(
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1A1A2E),
                          fontSize:   28.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        label,
                        style: TextStyle(
                          color:    isDark
                              ? Colors.white38
                              : const Color(0xFF9B9B9B),
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Error Widget ──────────────────────────────────────────────────────────────
class _ErrorWidget extends StatelessWidget {
  final String       message;
  final VoidCallback onRetry;

  const _ErrorWidget({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFF4757).withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline,
                  color: const Color(0xFFFF4757), size: 44.sp),
            ),
            SizedBox(height: 16.h),
            Text(
              'Failed to load stats',
              style: TextStyle(
                color:      isDark ? Colors.white : const Color(0xFF1A1A2E),
                fontWeight: FontWeight.bold,
                fontSize:   16.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              style: TextStyle(
                color:    isDark ? Colors.white54 : const Color(0xFF9B9B9B),
                fontSize: 13.sp,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4361EE),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
                padding: EdgeInsets.symmetric(
                    horizontal: 28.w, vertical: 12.h),
              ),
              child: Text(
                'Retry',
                style: TextStyle(
                  color:      Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize:   14.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}