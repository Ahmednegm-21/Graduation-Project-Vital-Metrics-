// lib/ui/screens/admin/admin_settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vital_metrics/core/themes/theme_context_extension.dart';
import 'package:vital_metrics/logic/auth/auth_cubit.dart';
import 'package:vital_metrics/logic/auth/auth_state.dart';
import 'package:vital_metrics/logic/home/theme_cubit.dart';
import 'package:vital_metrics/services/device_token_manager.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bg     = isDark ? const Color(0xFF0F1221) : const Color(0xFFF0F3FF);
    final card   = isDark ? const Color(0xFF1A2340) : Colors.white;
    final shadow = isDark ? Colors.black38 : Colors.black.withOpacity(0.07);

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        // لما الـ signOut يخلص → روح على signin
        if (state is AuthInitial) {
          context.go('/signin');
        }
      },
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Header ──────────────────────────────────────────────────
                FadeInDown(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                    child: Row(children: [
                      Container(
                        width: 52, height: 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4361EE), Color(0xFF4CC9F0)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(
                            color: const Color(0xFF4361EE).withOpacity(0.35),
                            blurRadius: 12, offset: const Offset(0, 4),
                          )],
                        ),
                        child: const Icon(Icons.admin_panel_settings,
                            color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Admin',
                              style: TextStyle(
                                color: isDark ? Colors.white
                                    : const Color(0xFF1A1A2E),
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              )),
                          Text('Vital Metrics Control',
                              style: TextStyle(
                                color: isDark ? Colors.white38
                                    : const Color(0xFF9B9B9B),
                                fontSize: 12,
                              )),
                        ],
                      ),
                    ]),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Appearance ───────────────────────────────────────────────
                FadeInDown(
                  delay: const Duration(milliseconds: 80),
                  child: _SectionLabel('Appearance', isDark),
                ),
                FadeInDown(
                  delay: const Duration(milliseconds: 100),
                  child: _SettingsCard(
                    isDark: isDark, card: card, shadow: shadow,
                    child: _DarkModeRow(isDark: isDark),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Account ───────────────────────────────────────────────────
                FadeInDown(
                  delay: const Duration(milliseconds: 140),
                  child: _SectionLabel('Account', isDark),
                ),
                FadeInDown(
                  delay: const Duration(milliseconds: 160),
                  child: _SettingsCard(
                    isDark: isDark, card: card, shadow: shadow,
                    child: _SignOutRow(isDark: isDark),
                  ),
                ),

                const SizedBox(height: 30),

                // ── Version ───────────────────────────────────────────────────
                FadeInDown(
                  delay: const Duration(milliseconds: 200),
                  child: Center(
                    child: Text('Admin Panel v1.0.0',
                        style: TextStyle(
                          color: isDark
                              ? Colors.white24
                              : Colors.grey.shade400,
                          fontSize: 12,
                        )),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final bool   isDark;
  const _SectionLabel(this.label, this.isDark);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
    child: Text(label,
        style: TextStyle(
          color: isDark ? Colors.white38 : const Color(0xFF9B9B9B),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        )),
  );
}

// ── Settings Card ─────────────────────────────────────────────────────────────
class _SettingsCard extends StatelessWidget {
  final bool   isDark;
  final Color  card, shadow;
  final Widget child;
  const _SettingsCard({
    required this.isDark, required this.card,
    required this.shadow, required this.child,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
    decoration: BoxDecoration(
      color: card,
      borderRadius: BorderRadius.circular(18),
      border: isDark
          ? Border.all(color: Colors.white.withOpacity(0.06), width: 1)
          : null,
      boxShadow: [
        BoxShadow(color: shadow, blurRadius: 14, offset: const Offset(0, 4))
      ],
    ),
    child: child,
  );
}

// ── Dark Mode Row ─────────────────────────────────────────────────────────────
class _DarkModeRow extends StatelessWidget {
  final bool isDark;
  const _DarkModeRow({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, bool>(
      builder: (context, darkMode) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF7B5EA7).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(CupertinoIcons.moon_fill,
                color: Color(0xFF7B5EA7), size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dark Mode',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    )),
                Text(darkMode ? 'Dark theme enabled' : 'Light theme enabled',
                    style: TextStyle(
                      color: isDark ? Colors.white38 : const Color(0xFF9B9B9B),
                      fontSize: 12,
                    )),
              ],
            ),
          ),
          CupertinoSwitch(
            value: darkMode,
            activeColor: const Color(0xFF4361EE),
            onChanged: (_) => context.read<ThemeCubit>().toggle(),
          ),
        ]),
      ),
    );
  }
}

// ── Sign Out Row ──────────────────────────────────────────────────────────────
class _SignOutRow extends StatefulWidget {
  final bool isDark;
  const _SignOutRow({required this.isDark});

  @override
  State<_SignOutRow> createState() => _SignOutRowState();
}

class _SignOutRowState extends State<_SignOutRow> {
  bool _loading = false;

  Future<void> _signOut() async {
    final ok = await showCupertinoDialog<bool>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Sign Out'),
        content: const Text(
            'Are you sure you want to sign out of the admin panel?'),
        actions: [
          CupertinoDialogAction(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sign Out')),
        ],
      ),
    );

    if (ok != true || !mounted) return;

    setState(() => _loading = true);

    try {
      // 1. حذف الـ FCM token
      await DeviceTokenManager.instance.unregisterOnLogout();

      // 2. مسح الـ tokens من SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('accessToken');
      await prefs.remove('token');
      await prefs.remove('refresh_token');
      await prefs.remove('user_id');

      // 3. إخبار الـ AuthCubit → هيـ emit AuthInitial
      //    والـ BlocListener في AdminSettingsScreen هيروح /signin
      if (mounted) {
        context.read<AuthCubit>().signOut();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Sign out failed: $e'),
          backgroundColor: const Color(0xFFFF4757),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _loading ? null : _signOut,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFFF4757).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: _loading
                ? const Padding(
                    padding: EdgeInsets.all(10),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFFF4757),
                    ),
                  )
                : const Icon(Icons.logout, color: Color(0xFFFF4757), size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sign Out',
                    style: TextStyle(
                      color: Color(0xFFFF4757),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    )),
                Text('Sign out of admin account',
                    style: TextStyle(
                      color: widget.isDark
                          ? Colors.white38
                          : const Color(0xFF9B9B9B),
                      fontSize: 12,
                    )),
              ],
            ),
          ),
          const Icon(CupertinoIcons.chevron_right,
              color: Color(0xFFFF4757), size: 16),
        ]),
      ),
    );
  }
}