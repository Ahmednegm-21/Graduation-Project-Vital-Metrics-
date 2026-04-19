import 'package:flutter/material.dart';
import 'app_colors.dart';

extension ThemeContextX on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  _AppThemeColors get colors => _AppThemeColors(isDark);
}

class _AppThemeColors {
  final bool _dark;
  const _AppThemeColors(this._dark);

  // ── Backgrounds ────────────────────────────────────────────────────────────
  Color get bg      => _dark ? AppColors.darkBg      : AppColors.lightBg;
  Color get card    => _dark ? AppColors.darkCard    : AppColors.lightCard;

  // ── Text ───────────────────────────────────────────────────────────────────
  Color get text    => _dark ? AppColors.darkText    : AppColors.lightText;
  Color get subText => _dark ? AppColors.darkSubText : AppColors.lightSubText;

  // ── Shadows & Dividers ─────────────────────────────────────────────────────
  Color get shadow  => _dark ? Colors.black45        : Colors.black12;
  Color get divider => _dark ? Colors.white12        : const Color(0xFFEEEEEE);

  // ── Input fields ───────────────────────────────────────────────────────────
  Color get inputFill  => _dark ? AppColors.darkBg   : AppColors.lightBg;
  Color get inputLabel => _dark ? Colors.white54     : Colors.grey;

  // ── Dialog ─────────────────────────────────────────────────────────────────
  Color get dialogBg => _dark ? AppColors.darkCard   : Colors.white;

  // ── Nav bar ────────────────────────────────────────────────────────────────
  Color get navBg       => _dark ? AppColors.darkCard    : Colors.white;
  Color get navInactive => _dark ? Colors.white38         : Colors.grey;

  // ── Icon buttons (header, appbar) ─────────────────────────────────────────
  Color get iconBtnBg => _dark ? const Color(0xFF1E2D50) : Colors.white;
}