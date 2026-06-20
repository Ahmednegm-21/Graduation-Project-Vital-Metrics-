// lib/ui/widgets/daily_tip_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vital_metrics/core/themes/theme_context_extension.dart';
import 'package:vital_metrics/data/models/tip_model.dart';
import 'package:vital_metrics/logic/tips/tips_cubit.dart';
import 'package:vital_metrics/logic/tips/tips_state.dart';

class DailyTipDialog extends StatefulWidget {
  const DailyTipDialog({super.key});

  // ── استدعيه كده في home_screen.dart ───────────────────────────────────────
  // في initState أو بعد أول build:
  //
  // WidgetsBinding.instance.addPostFrameCallback((_) async {
  //   final cubit = context.read<TipsCubit>();
  //   await cubit.loadTodayTip();
  //   final should = await cubit.shouldShowTodayTip();
  //   if (should && mounted) {
  //     await DailyTipDialog.show(context);
  //     cubit.markTipShown();
  //   }
  // });

  static Future<void> show(BuildContext context) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'tip',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 420),
      pageBuilder: (_, __, ___) => const DailyTipDialog(),
      transitionBuilder: (_, anim, __, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: Tween(begin: 0.80, end: 1.0).animate(curved),
          child: FadeTransition(opacity: anim, child: child),
        );
      },
    );
  }

  @override
  State<DailyTipDialog> createState() => _DailyTipDialogState();
}

class _DailyTipDialogState extends State<DailyTipDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerCtrl;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: BlocBuilder<TipsCubit, TipsState>(
        builder: (context, state) {
          if (state is TipsLoading || state is TipsInitial) {
            return _loadingCard(isDark);
          }
          if (state is TipsLoaded) {
            return _tipCard(context, isDark, state.tip);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ── Loading skeleton ───────────────────────────────────────────────────────

  Widget _loadingCard(bool isDark) {
    final bg = isDark ? const Color(0xFF1A2340) : Colors.white;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _shimmerBox(isDark, width: 60, height: 60, radius: 30),
          const SizedBox(height: 16),
          _shimmerBox(isDark, width: 180, height: 18, radius: 9),
          const SizedBox(height: 10),
          _shimmerBox(isDark, width: double.infinity, height: 14, radius: 7),
          const SizedBox(height: 6),
          _shimmerBox(isDark, width: double.infinity, height: 14, radius: 7),
          const SizedBox(height: 6),
          _shimmerBox(isDark, width: 120, height: 14, radius: 7),
        ],
      ),
    );
  }

  Widget _shimmerBox(bool isDark,
      {required double width, required double height, required double radius}) {
    return AnimatedBuilder(
      animation: _shimmerCtrl,
      builder: (_, __) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF1E2D4A), const Color(0xFF253559), const Color(0xFF1E2D4A)]
                : [const Color(0xFFE8ECF4), const Color(0xFFF4F6FA), const Color(0xFFE8ECF4)],
            stops: [
              (_shimmerCtrl.value - 0.3).clamp(0.0, 1.0),
              _shimmerCtrl.value.clamp(0.0, 1.0),
              (_shimmerCtrl.value + 0.3).clamp(0.0, 1.0),
            ],
          ),
        ),
      ),
    );
  }

  // ── Tip card ───────────────────────────────────────────────────────────────

  Widget _tipCard(BuildContext context, bool isDark, TipModel tip) {
    final color  = tip.category == TipCategory.water    ? const Color(0xFF4CC9F0)
                 : tip.category == TipCategory.sleep     ? const Color(0xFF7B5EA7)
                 : tip.category == TipCategory.exercise  ? const Color(0xFF63E6BE)
                 : tip.category == TipCategory.nutrition ? const Color(0xFF51CF66)
                 :                                          const Color(0xFF4361EE);

    final bg     = isDark ? const Color(0xFF1A2340) : Colors.white;
    final textCol = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subCol  = isDark ? Colors.white60 : const Color(0xFF6B7280);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.25),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.5 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.20), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header gradient ───────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              gradient: LinearGradient(
                colors: [color.withOpacity(0.85), color.withOpacity(0.45)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                // Emoji icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      tip.category.emoji,
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Category badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.35)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('✨', style: TextStyle(fontSize: 11)),
                      const SizedBox(width: 5),
                      Text(
                        'Daily ${tip.category.label} Tip',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Body ─────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 8),
            child: Column(
              children: [
                Text(
                  tip.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textCol,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: color.withOpacity(isDark ? 0.10 : 0.07),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withOpacity(0.18)),
                  ),
                  child: Text(
                    tip.body,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: subCol,
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                ),
                if (tip.source != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.book, size: 11, color: color),
                      const SizedBox(width: 4),
                      Text(
                        tip.source!,
                        style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // ── Footer button ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 22),
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.75)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.40),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Got it! 👍', style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}