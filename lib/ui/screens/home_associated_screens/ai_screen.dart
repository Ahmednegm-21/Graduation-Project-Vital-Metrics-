// ui/screens/home_associated_screens/ai_screen.dart
// ─── REDESIGNED VERSION ──────────────────────────────────────────────────────

import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:vital_metrics/data/config/ai_api_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HTTP HELPERS
// ─────────────────────────────────────────────────────────────────────────────

Map<String, String> get _headers => AiApiConfig.headers;

Future<Map<String, dynamic>> _get(String path,
    {Map<String, String>? query}) async {
  final uri = Uri.parse('${AiApiConfig.baseUrl}$path')
      .replace(queryParameters: query);
  final res = await http
      .get(uri, headers: _headers)
      .timeout(AiApiConfig.aiModelTimeout);
  return jsonDecode(res.body) as Map<String, dynamic>;
}

Future<Map<String, dynamic>> _post(
    String path, Map<String, dynamic> body) async {
  final uri = Uri.parse('${AiApiConfig.baseUrl}$path');
  final res = await http
      .post(uri, headers: _headers, body: jsonEncode(body))
      .timeout(AiApiConfig.aiModelTimeout);
  return jsonDecode(res.body) as Map<String, dynamic>;
}

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────────────────────────────────────

class FoodItem {
  final String food;
  final double calories, protein, fat, carbohydrates;
  final double? similarity;

  const FoodItem({
    required this.food,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbohydrates,
    this.similarity,
  });

 static double _n(Map<String, dynamic> j, List<String> keys) {
  for (final k in keys) {
    final v = j[k];
    if (v != null) return (v as num).toDouble();
  }
  final lowerKeys = keys.map((k) => k.toLowerCase()).toSet();
  for (final entry in j.entries) {
    if (lowerKeys.contains(entry.key.toLowerCase()) && entry.value != null) {
      return (entry.value as num).toDouble();
    }
  }
  return 0.0;
}

factory FoodItem.fromJson(Map<String, dynamic> j) {
  debugPrint('[FoodItem] keys=${j.keys.toList()}');
  
  String foodName = '';
  for (final entry in j.entries) {
    final k = entry.key.toLowerCase();
    if ((k == 'food' || k == 'name' || k == 'food_name' || k == 'item') &&
        entry.value != null) {
      foodName = entry.value.toString();
      break;
    }
  }

  return FoodItem(
    food: foodName,
    calories: _n(j, ['calories', 'Calories', 'kcal', 'energy', 'Energy', 'cal']),
    protein:  _n(j, ['protein', 'Protein', 'protein_g', 'proteins', 'prot']),
    fat:      _n(j, ['fat', 'Fat', 'fat_g', 'total_fat', 'fats', 'lipid']),
    carbohydrates: _n(j, [
      'carbohydrates', 'Carbohydrates', 'carbs', 'Carbs',
      'carbohydrate',  'Carbohydrate',  'carbs_g', 'cho',
    ]),
    similarity: (j['similarity'] as num?)?.toDouble(),
  );
}
}

class SuggestResult {
  final String food;
  final double weightG, calories, protein, fat, carbohydrates;

  const SuggestResult({
    required this.food,
    required this.weightG,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbohydrates,
  });

  factory SuggestResult.fromJson(Map<String, dynamic> j) => SuggestResult(
        food: j['food']?.toString() ?? '',
        weightG: (j['weight_g'] as num?)?.toDouble() ?? 0.0,
        calories: (j['calories'] as num?)?.toDouble() ?? 0.0,
        protein: (j['protein'] as num?)?.toDouble() ?? 0.0,
        fat: (j['fat'] as num?)?.toDouble() ?? 0.0,
        carbohydrates: (j['carbohydrates'] as num?)?.toDouble() ?? 0.0,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// DESIGN TOKENS
// ─────────────────────────────────────────────────────────────────────────────

const _kBg       = Color(0xFF0A0F1E);
const _kSurface  = Color(0xFF141929);
const _kSurface2 = Color(0xFF1C2438);

const _kBlue   = Color(0xFF4361EE);
const _kGreen  = Color(0xFF1D9E75);
const _kOrange = Color(0xFFD85A30);
const _kAmber  = Color(0xFFBA7517);
const _kRed    = Color(0xFFE24B4A);

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────

Color _simColor(double? s) {
  if (s == null) return _kBlue;
  if (s >= .85) return _kGreen;
  if (s >= .70) return _kAmber;
  return _kOrange;
}

String _simLabel(double? s) {
  if (s == null) return '';
  if (s >= .85) return 'Excellent';
  if (s >= .70) return 'Good';
  return 'Fair';
}

String _foodEmoji(String name) {
  final n = name.toLowerCase();
  if (n.contains('chicken'))                                              return '🍗';
  if (n.contains('salmon') || n.contains('fish') || n.contains('tuna')) return '🐟';
  if (n.contains('beef') || n.contains('steak') || n.contains('lamb'))  return '🥩';
  if (n.contains('egg'))          return '🍳';
  if (n.contains('oat'))          return '🥣';
  if (n.contains('rice'))         return '🍚';
  if (n.contains('salad'))        return '🥗';
  if (n.contains('yogurt'))       return '🍦';
  if (n.contains('bread'))        return '🍞';
  if (n.contains('pasta'))        return '🍝';
  if (n.contains('turkey'))       return '🦃';
  if (n.contains('avocado'))      return '🥑';
  if (n.contains('banana'))       return '🍌';
  if (n.contains('sweet potato')) return '🍠';
  if (n.contains('lentil'))       return '🍲';
  if (n.contains('tofu'))         return '🧆';
  return '🍽️';
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED ANIMATION WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _FadeSlide extends StatefulWidget {
  final Widget child;
  final Duration delay;
  const _FadeSlide({required this.child, this.delay = Duration.zero});
  @override
  State<_FadeSlide> createState() => _FadeSlideState();
}

class _FadeSlideState extends State<_FadeSlide>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 500));
    _fade  = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _slide = Tween(begin: const Offset(0, .12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
    Future.delayed(widget.delay, () { if (mounted) _c.forward(); });
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) =>
      FadeTransition(opacity: _fade,
          child: SlideTransition(position: _slide, child: widget.child));
}

class _Float extends StatefulWidget {
  final Widget child;
  final Duration period;
  final double amplitude;
  const _Float({
    required this.child,
    this.period = const Duration(seconds: 4),
    this.amplitude = 4,
  });
  @override
  State<_Float> createState() => _FloatState();
}

class _FloatState extends State<_Float> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<Offset> _anim;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.period)
      ..repeat(reverse: true);
    _anim = Tween(begin: Offset.zero,
        end: Offset(0, -widget.amplitude / 100))
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) =>
      SlideTransition(position: _anim, child: widget.child);
}

class _Tap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _Tap({required this.child, this.onTap});
  @override
  State<_Tap> createState() => _TapState();
}

class _TapState extends State<_Tap> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _s;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 100),
        reverseDuration: const Duration(milliseconds: 200));
    _s = Tween<double>(begin: 1, end: .94)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: (_) => _c.forward(),
        onTapUp: (_) { _c.reverse(); widget.onTap?.call(); },
        onTapCancel: () => _c.reverse(),
        child: ScaleTransition(scale: _s, child: widget.child),
      );
}

class _PulseDot extends StatefulWidget {
  final Color color;
  const _PulseDot({required this.color});
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _a;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this,
        duration: const Duration(seconds: 2))..repeat(reverse: true);
    _a = Tween<double>(begin: .5, end: 1.0)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _a,
        builder: (_, __) => Container(
          width: 7, height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withOpacity(_a.value),
            boxShadow: [BoxShadow(
              color: widget.color.withOpacity(_a.value * .6),
              blurRadius: 6, spreadRadius: 1,
            )],
          ),
        ),
      );
}

class _MacroBar extends StatefulWidget {
  final String label;
  final double value;
  final double max;
  final Color color;
  const _MacroBar({
    required this.label,
    required this.value,
    required this.max,
    required this.color,
  });
  @override
  State<_MacroBar> createState() => _MacroBarState();
}

class _MacroBarState extends State<_MacroBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 900));
    _anim = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final pct = widget.max > 0
        ? (widget.value / widget.max).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(widget.label,
              style: TextStyle(fontSize: 10.sp, color: Colors.white38)),
          Text('${widget.value.toStringAsFixed(1)}g',
              style: TextStyle(
                  fontSize: 10.sp, color: widget.color,
                  fontWeight: FontWeight.w600)),
        ]),
        SizedBox(height: 4.h),
        AnimatedBuilder(
          animation: _anim,
          builder: (_, __) => ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: pct * _anim.value,
              minHeight: 5.h,
              backgroundColor: widget.color.withOpacity(.12),
              valueColor: AlwaysStoppedAnimation(widget.color),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AMBIENT ORB PAINTER
// ─────────────────────────────────────────────────────────────────────────────

class _OrbPainter extends CustomPainter {
  final double t;
  const _OrbPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    void orb(Offset center, double r, Color c) {
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [c.withOpacity(.25), c.withOpacity(0)],
        ).createShader(Rect.fromCircle(center: center, radius: r));
      canvas.drawCircle(center, r, paint);
    }

    final dy1 = math.sin(t * math.pi * 2) * 10;
    final dy2 = math.cos(t * math.pi * 2) * 12;

    orb(Offset(size.width - 60, -30 + dy1), 160, _kBlue);
    orb(Offset(-40, size.height * .55 + dy2), 130, _kGreen);
    orb(Offset(size.width * .4, size.height * .3), 100, _kBlue.withOpacity(.4));
  }

  @override
  bool shouldRepaint(_OrbPainter old) => old.t != t;
}

class _AmbientOrbs extends StatefulWidget {
  final Widget child;
  const _AmbientOrbs({required this.child});
  @override
  State<_AmbientOrbs> createState() => _AmbientOrbsState();
}

class _AmbientOrbsState extends State<_AmbientOrbs>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this,
        duration: const Duration(seconds: 8))..repeat();
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, child) => CustomPaint(
          painter: _OrbPainter(_c.value),
          child: child,
        ),
        child: widget.child,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED SMALL WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

Widget _chip(String label, double val, Color c) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: c.withOpacity(.12),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: c.withOpacity(.28)),
      ),
      child: Text('$label ${val.toStringAsFixed(1)}g',
          style: TextStyle(
              fontSize: 10.sp, color: c, fontWeight: FontWeight.w600)),
    );

Widget _sectionLabel(String t) => Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Text(t.toUpperCase(),
          style: TextStyle(
              fontSize: 10.sp, fontWeight: FontWeight.w600,
              color: Colors.white30, letterSpacing: 1.1)),
    );

Widget _sectionHeader(String title, {String? sub}) => Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(children: [
        Expanded(child: Text(title,
            style: TextStyle(
                fontSize: 13.sp, fontWeight: FontWeight.w700,
                color: Colors.white70))),
        if (sub != null)
          Text(sub,
              style: TextStyle(fontSize: 11.sp, color: Colors.white30)),
      ]),
    );

Widget _errorBanner(String msg) => Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: _kRed.withOpacity(.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _kRed.withOpacity(.25)),
      ),
      child: Row(children: [
        Icon(Icons.error_outline_rounded, color: _kRed, size: 16.sp),
        SizedBox(width: 8.w),
        Expanded(child: Text(msg,
            style: TextStyle(fontSize: 12.sp, color: _kRed))),
      ]),
    );

Widget _emptyState({String message = 'No results found'}) => Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Column(children: [
          Icon(Icons.search_off_rounded, size: 48.sp, color: Colors.white12),
          SizedBox(height: 12.h),
          Text(message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.sp, color: Colors.white30)),
        ]),
      ),
    );

Widget _primaryBtn({
  required String label,
  required VoidCallback? onTap,
  bool loading = false,
  IconData? icon,
}) =>
    _Tap(
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48.h,
        decoration: BoxDecoration(
          color: loading ? Colors.white10 : _kBlue,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: loading
              ? []
              : [BoxShadow(
                  color: _kBlue.withOpacity(.4),
                  blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Center(
          child: loading
              ? SizedBox(
                  width: 20.w, height: 20.w,
                  child: const CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : Row(mainAxisSize: MainAxisSize.min, children: [
                  if (icon != null) ...[
                    Icon(icon, color: Colors.white, size: 16.sp),
                    SizedBox(width: 6.w),
                  ],
                  Text(label,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700,
                          fontSize: 13.sp)),
                ]),
        ),
      ),
    );

AppBar _buildAppBar(BuildContext context, String title) => AppBar(
      backgroundColor: _kBg,
      elevation: 0,
      centerTitle: true,
      leading: _Tap(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          margin: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.white.withOpacity(.08)),
          ),
          child: Icon(Icons.arrow_back_ios_new_rounded,
              color: _kBlue, size: 18.sp),
        ),
      ),
      title: Text(title,
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w800,
              fontSize: 17.sp)),
    );

// ─────────────────────────────────────────────────────────────────────────────
// FOOD CARD
// ─────────────────────────────────────────────────────────────────────────────

Widget _foodCard({
  required BuildContext context,
  required FoodItem item,
  bool showSimilarity = false,
  VoidCallback? onTap,
}) {
  return _Tap(
    onTap: onTap,
    child: Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.white.withOpacity(.06)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 48.w, height: 48.w,
          decoration: BoxDecoration(
            color: _kSurface2,
            borderRadius: BorderRadius.circular(13.r),
          ),
          child: Center(
            child: Text(_foodEmoji(item.food),
                style: TextStyle(fontSize: 24.sp)),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(item.food,
                  style: TextStyle(
                      fontSize: 13.sp, fontWeight: FontWeight.w700,
                      color: Colors.white))),
              if (showSimilarity && item.similarity != null) ...[
                SizedBox(width: 6.w),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: _simColor(item.similarity).withOpacity(.12),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                        color: _simColor(item.similarity).withOpacity(.28)),
                  ),
                  child: Text(
                    '${(item.similarity! * 100).round()}% ${_simLabel(item.similarity)}',
                    style: TextStyle(
                        fontSize: 10.sp,
                        color: _simColor(item.similarity),
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ]),
            SizedBox(height: 4.h),
            Text('${item.calories.round()} kcal',
                style: TextStyle(fontSize: 11.sp, color: Colors.white38)),
            SizedBox(height: 7.h),
            Wrap(spacing: 5.w, runSpacing: 4.h, children: [
              _chip('P', item.protein, _kOrange),
              _chip('C', item.carbohydrates, _kGreen),
              _chip('F', item.fat, _kRed),
            ]),
            if (showSimilarity && item.similarity != null) ...[
              SizedBox(height: 7.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: LinearProgressIndicator(
                  value: item.similarity,
                  minHeight: 4.h,
                  backgroundColor:
                      _simColor(item.similarity).withOpacity(.12),
                  valueColor: AlwaysStoppedAnimation(
                      _simColor(item.similarity)),
                ),
              ),
            ],
          ]),
        ),
      ]),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// DARK FORM WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

InputDecoration _inputDeco({required String hint}) => InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 12.sp, color: Colors.white24),
      filled: true,
      fillColor: _kSurface2,
      contentPadding:
          EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: _kBlue.withOpacity(.5))),
    );

class _FormCard extends StatelessWidget {
  final Widget child;
  const _FormCard({required this.child});
  @override
  Widget build(BuildContext context) => Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.white.withOpacity(.07)),
        ),
        child: child,
      );
}

class _NumberField extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  const _NumberField({required this.label, required this.ctrl});
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 11.sp, color: Colors.white38)),
          SizedBox(height: 5.h),
          TextField(
            controller: ctrl,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))
            ],
            style: TextStyle(fontSize: 13.sp, color: Colors.white),
            decoration: _inputDeco(hint: '0'),
          ),
        ],
      );
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  const _FilterChip({required this.label, required this.active});
  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: active ? _kBlue : _kSurface2,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
              color: active
                  ? _kBlue.withOpacity(.6)
                  : Colors.white.withOpacity(.08)),
          boxShadow: active
              ? [BoxShadow(
                  color: _kBlue.withOpacity(.3),
                  blurRadius: 10, offset: const Offset(0, 4))]
              : [],
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : Colors.white38)),
      );
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmit;
  const _SearchBar({required this.controller, required this.onSubmit});
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.white.withOpacity(.07)),
        ),
        child: TextField(
          controller: controller,
          onSubmitted: onSubmit,
          textInputAction: TextInputAction.search,
          style: TextStyle(fontSize: 13.sp, color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search foods or describe what you want…',
            hintStyle: TextStyle(fontSize: 12.sp, color: Colors.white24),
            prefixIcon: Icon(Icons.search_rounded,
                color: Colors.white30, size: 20.sp),
            suffixIcon: Padding(
              padding: EdgeInsets.all(8.w),
              child: Container(
                width: 32.w, height: 32.w,
                decoration: BoxDecoration(
                  color: _kBlue,
                  borderRadius: BorderRadius.circular(9.r),
                ),
                child: Icon(Icons.arrow_forward_rounded,
                    color: Colors.white, size: 16.sp),
              ),
            ),
            border: InputBorder.none,
            contentPadding:
                EdgeInsets.symmetric(vertical: 14.h),
          ),
        ),
      );
}

// ═════════════════════════════════════════════════════════════════════════════
// SCREEN 1 – AI HUB
// ═════════════════════════════════════════════════════════════════════════════

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});
  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  bool _apiOnline = false;
  bool _checking  = true;

  @override
  void initState() {
    super.initState();
    _checkHealth();
  }

  Future<void> _checkHealth() async {
    setState(() => _checking = true);
    try {
      final res = await _get(AiApiConfig.health);
      setState(() {
        _apiOnline = res['success'] == true;
        _checking  = false;
      });
    } catch (_) {
      setState(() { _apiOnline = false; _checking = false; });
    }
  }

  static const _quickFoods = [
    ('🍗', 'Chicken'), ('🥩', 'Beef steak'), ('🥣', 'Oatmeal'),
    ('🐟', 'Salmon'),  ('🍳', 'Eggs'),       ('🥑', 'Avocado'),
    ('🍚', 'Rice'),    ('🍞', 'Bread'),
  ];

  // ── REMOVED: AiSimilarScreen from actions & screens ──
  static const _actions = [
    _HubAction(icon: Icons.search_rounded,       label: 'Food search',
        sub: 'Browse & filter foods',     color: _kBlue),
    _HubAction(icon: Icons.auto_awesome_rounded, label: 'Recommend',
        sub: 'AI meal suggestions',       color: _kGreen),
    _HubAction(icon: Icons.restaurant_rounded,   label: 'Meal planner',
        sub: 'Match by calories',         color: _kAmber),
  ];

  static const _screens = [
    AiFoodsScreen(), AiRecommendScreen(), AiSuggestScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: _AmbientOrbs(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 40.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Header ─────────────────────────────────────────────
                _FadeSlide(
                  delay: const Duration(milliseconds: 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('AI Assistant',
                              style: TextStyle(
                                  fontSize: 28.sp, fontWeight: FontWeight.w800,
                                  color: Colors.white, height: 1.1,
                                  letterSpacing: -.5)),
                          SizedBox(height: 5.h),
                          Text('Nutrition intelligence at your fingertips',
                              style: TextStyle(
                                  fontSize: 12.sp, color: Colors.white38)),
                        ],
                      )),
                      SizedBox(width: 12.w),
                      _checking
                          ? SizedBox(
                              width: 20.w, height: 20.w,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: _kBlue))
                          : _Tap(
                              onTap: _checkHealth,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 11, vertical: 7),
                                decoration: BoxDecoration(
                                  color: (_apiOnline ? _kGreen : _kRed)
                                      .withOpacity(.1),
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(
                                      color: (_apiOnline ? _kGreen : _kRed)
                                          .withOpacity(.28)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _PulseDot(
                                        color: _apiOnline ? _kGreen : _kRed),
                                    SizedBox(width: 5.w),
                                    Text(
                                      _apiOnline ? 'API online' : 'API offline',
                                      style: TextStyle(
                                          fontSize: 10.sp,
                                          color: _apiOnline ? _kGreen : _kRed,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ],
                  ),
                ),

                SizedBox(height: 22.h),

                // ── Search bar ─────────────────────────────────────────
                _FadeSlide(
                  delay: const Duration(milliseconds: 80),
                  child: _Tap(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const AiFoodsScreen())),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 14.h),
                      decoration: BoxDecoration(
                        color: _kSurface,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                            color: Colors.white.withOpacity(.07)),
                      ),
                      child: Row(children: [
                        Icon(Icons.search_rounded,
                            color: Colors.white30, size: 18.sp),
                        SizedBox(width: 10.w),
                        Expanded(child: Text(
                          'Search foods or describe what you want…',
                          style: TextStyle(
                              fontSize: 12.sp, color: Colors.white24),
                        )),
                        Container(
                          width: 30.w, height: 30.w,
                          decoration: BoxDecoration(
                            color: _kBlue,
                            borderRadius: BorderRadius.circular(9.r),
                            boxShadow: [BoxShadow(
                              color: _kBlue.withOpacity(.4),
                              blurRadius: 12, offset: const Offset(0, 4),
                            )],
                          ),
                          child: Icon(Icons.arrow_forward_rounded,
                              color: Colors.white, size: 14.sp),
                        ),
                      ]),
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                // ── Quick food chips ───────────────────────────────────
                _FadeSlide(
                  delay: const Duration(milliseconds: 140),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionLabel('Popular right now'),
                      SizedBox(
                        height: 38.h,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: _quickFoods.length,
                          separatorBuilder: (_, __) => SizedBox(width: 8.w),
                          itemBuilder: (_, i) {
                            final f = _quickFoods[i];
                            return _Tap(
                              onTap: () => Navigator.push(context,
                                  MaterialPageRoute(
                                      builder: (_) => const AiFoodsScreen())),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12.w, vertical: 8.h),
                                decoration: BoxDecoration(
                                  color: _kSurface,
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                      color: Colors.white.withOpacity(.07)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(f.$1,
                                        style: TextStyle(fontSize: 14.sp)),
                                    SizedBox(width: 6.w),
                                    Text(f.$2,
                                        style: TextStyle(
                                            fontSize: 11.sp,
                                            color: Colors.white60,
                                            fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 22.h),
                _FadeSlide(
                  delay: const Duration(milliseconds: 180),
                  child: _sectionLabel('Quick actions'),
                ),

                // ── Action cards grid (3 cards now) ───────────────────
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10.w,
                  mainAxisSpacing: 10.h,
                  childAspectRatio: 1.45,
                  children: List.generate(_actions.length, (i) {
                    final a = _actions[i];
                    return _FadeSlide(
                      delay: Duration(milliseconds: 220 + i * 60),
                      child: _Tap(
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(
                                builder: (_) => _screens[i])),
                        child: Container(
                          padding: EdgeInsets.all(14.w),
                          decoration: BoxDecoration(
                            color: _kSurface,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                                color: a.color.withOpacity(.18)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _Float(
                                    period: Duration(
                                        seconds: 4 + i),
                                    child: Container(
                                      width: 36.w, height: 36.w,
                                      decoration: BoxDecoration(
                                        color: a.color.withOpacity(.12),
                                        borderRadius:
                                            BorderRadius.circular(10.r),
                                      ),
                                      child: Center(child: Icon(a.icon,
                                          color: a.color, size: 18.sp)),
                                    ),
                                  ),
                                  Container(
                                    width: 22.w, height: 22.w,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(.05),
                                      borderRadius:
                                          BorderRadius.circular(6.r),
                                    ),
                                    child: Icon(Icons.north_east_rounded,
                                        color: Colors.white24, size: 12.sp),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(a.label,
                                      style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white)),
                                  SizedBox(height: 3.h),
                                  Text(a.sub,
                                      style: TextStyle(
                                          fontSize: 10.sp,
                                          color: Colors.white38)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                SizedBox(height: 24.h),

                // ── About info row ─────────────────────────────────────
                _FadeSlide(
                  delay: const Duration(milliseconds: 500),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionLabel('About the AI'),
                      Row(children: [
                        Expanded(child: _infoCard(
                            icon: Icons.bolt_rounded, color: _kAmber,
                            title: 'Fast', sub: 'Similarity search')),
                        SizedBox(width: 10.w),
                        Expanded(child: _infoCard(
                            icon: Icons.local_fire_department_rounded,
                            color: _kOrange,
                            title: 'Full macros', sub: 'P · C · F')),
                        SizedBox(width: 10.w),
                        Expanded(child: _infoCard(
                            icon: Icons.track_changes_rounded,
                            color: _kGreen,
                            title: 'Precise', sub: 'Calorie match')),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required Color color,
    required String title,
    required String sub,
  }) =>
      Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: Colors.white.withOpacity(.06)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _Float(child: Icon(icon, color: color, size: 20.sp)),
          SizedBox(height: 8.h),
          Text(title,
              style: TextStyle(
                  fontSize: 11.sp, fontWeight: FontWeight.w700,
                  color: Colors.white)),
          SizedBox(height: 2.h),
          Text(sub,
              style: TextStyle(fontSize: 9.sp, color: Colors.white30)),
        ]),
      );
}

class _HubAction {
  final IconData icon;
  final String label, sub;
  final Color color;
  const _HubAction({
    required this.icon, required this.label,
    required this.sub,  required this.color,
  });
}

// ═════════════════════════════════════════════════════════════════════════════
// SCREEN 2 – FOOD SEARCH
// ═════════════════════════════════════════════════════════════════════════════

class AiFoodsScreen extends StatefulWidget {
  const AiFoodsScreen({super.key});
  @override
  State<AiFoodsScreen> createState() => _AiFoodsScreenState();
}

class _AiFoodsScreenState extends State<AiFoodsScreen> {
  final _search = TextEditingController();
  bool _loading    = false;
  String? _error;
  List<FoodItem> _foods = [];
  String _activeFilter  = 'all';
  bool _isAiSearch      = false;

  static const _filters = [
    ('all',          'All'),
    ('high-protein', 'High protein'),
    ('low-cal',      'Low cal'),
    ('low-carb',     'Low carb'),
  ];

  @override
  void initState() { super.initState(); _fetchAll(); }

  @override
  void dispose() { _search.dispose(); super.dispose(); }

  Future<void> _fetchAll() async {
    setState(() { _loading = true; _error = null; _isAiSearch = false; });
    try {
      final res = await _get(AiApiConfig.foods);
      final raw = res['data'] as List<dynamic>;
      if (raw.isNotEmpty) {
        debugPrint('[AI_SCREEN] First food item keys: ${(raw.first as Map).keys.toList()}');
        debugPrint('[AI_SCREEN] First food item: ${raw.first}');
      }
      setState(() {
        _loading = false;
        _foods   = raw.map((e) =>
            FoodItem.fromJson(e as Map<String, dynamic>)).toList();
      });
    } catch (e) {
      setState(() { _loading = false; _error = e.toString(); });
    }
  }

  Future<void> _fetchAi(String query) async {
    setState(() { _loading = true; _error = null; _isAiSearch = true; });
    try {
      final res = await _post(AiApiConfig.recommend,
          {'query': query, 'top_n': 10000});
      if (res['success'] == true) {
        final raw = res['data'] as List<dynamic>;
        setState(() {
          _loading = false;
          _foods   = raw.map((e) =>
              FoodItem.fromJson(e as Map<String, dynamic>)).toList();
        });
      } else {
        setState(() { _loading = false; _error = res['error']?.toString(); });
      }
    } catch (e) {
      setState(() { _loading = false; _error = e.toString(); });
    }
  }

  void _onSearch(String v) {
    final q = v.trim();
    if (q.isEmpty) { _fetchAll(); return; }
    _fetchAi(q);
  }

  List<FoodItem> get _filtered {
    if (_isAiSearch) return _foods;
    return _foods.where((f) {
      if (_activeFilter == 'high-protein' && f.protein < 10)        return false;
      if (_activeFilter == 'low-cal'      && f.calories >= 200)     return false;
      if (_activeFilter == 'low-carb'     && f.carbohydrates >= 20) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: _kBg,
      appBar: _buildAppBar(context, 'Food database'),
      body: Column(children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
          child: _SearchBar(controller: _search, onSubmit: _onSearch),
        ),
        if (!_isAiSearch)
          SizedBox(
            height: 46.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              children: _filters.map((f) => Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: GestureDetector(
                  onTap: () => setState(() => _activeFilter = f.$1),
                  child: _FilterChip(
                      label: f.$2, active: _activeFilter == f.$1),
                ),
              )).toList(),
            ),
          ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
          child: Row(children: [
            Text('${filtered.length} food${filtered.length == 1 ? '' : 's'}',
                style: TextStyle(fontSize: 12.sp, color: Colors.white30)),
            if (_isAiSearch) ...[
              SizedBox(width: 6.w),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: _kGreen.withOpacity(.1),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: _kGreen.withOpacity(.3)),
                ),
                child: Text('AI results',
                    style: TextStyle(
                        fontSize: 10.sp, color: _kGreen,
                        fontWeight: FontWeight.w600)),
              ),
            ],
            const Spacer(),
            if (_loading)
              SizedBox(width: 14.w, height: 14.w,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: _kBlue)),
          ]),
        ),
        Expanded(
          child: _error != null
              ? Center(child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: _errorBanner(_error!)))
              : filtered.isEmpty && !_loading
                  ? _emptyState()
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding:
                          EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 32.h),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) => _FadeSlide(
                            delay: Duration(
                                milliseconds: (i * 30).clamp(0, 300)),
                            child: _foodCard(
                                context: context,
                                item: filtered[i],
                                showSimilarity: _isAiSearch),
                          ),
                    ),
        ),
      ]),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// SCREEN 3 – RECOMMEND
// ═════════════════════════════════════════════════════════════════════════════

class AiRecommendScreen extends StatefulWidget {
  const AiRecommendScreen({super.key});
  @override
  State<AiRecommendScreen> createState() => _AiRecommendScreenState();
}

class _AiRecommendScreenState extends State<AiRecommendScreen> {
  final _query = TextEditingController(text: 'high protein chicken');
  final _cals  = TextEditingController(text: '500');
  final _prot  = TextEditingController(text: '30');
  final _fat   = TextEditingController(text: '10');
  final _carbs = TextEditingController(text: '20');

  bool _loading = false;
  String? _error;
  List<FoodItem> _results = [];
  int _topN = 5;

  @override
  void dispose() {
    _query.dispose(); _cals.dispose(); _prot.dispose();
    _fat.dispose();   _carbs.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    if (_query.text.trim().isEmpty) return;
    setState(() { _loading = true; _error = null; });
    try {
      final body = <String, dynamic>{
        'query': _query.text.trim(), 'top_n': _topN,
      };
      if (_cals.text.isNotEmpty)  body['calories'] = double.parse(_cals.text);
      if (_prot.text.isNotEmpty)  body['protein']  = double.parse(_prot.text);
      if (_fat.text.isNotEmpty)   body['fat']      = double.parse(_fat.text);
      if (_carbs.text.isNotEmpty) body['carbs']    = double.parse(_carbs.text);

      final res = await _post(AiApiConfig.recommend, body);
      if (res['success'] == true) {
        final raw = res['data'] as List<dynamic>;
        setState(() {
          _loading = false;
          _results = raw.map((e) =>
              FoodItem.fromJson(e as Map<String, dynamic>)).toList();
        });
      } else {
        setState(() { _loading = false; _error = res['error']?.toString(); });
      }
    } catch (e) {
      setState(() { _loading = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: _buildAppBar(context, 'AI Recommend'),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 32.h),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _FormCard(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader('Describe what you want'),
              TextField(
                controller: _query,
                style: TextStyle(fontSize: 13.sp, color: Colors.white),
                decoration: _inputDeco(
                    hint: 'e.g. high protein breakfast, low carb dinner…'),
              ),
              SizedBox(height: 14.h),
              _sectionHeader('Nutrition targets (optional)'),
              Row(children: [
                Expanded(child: _NumberField(label: 'Max kcal', ctrl: _cals)),
                SizedBox(width: 10.w),
                Expanded(child: _NumberField(label: 'Protein g', ctrl: _prot)),
              ]),
              SizedBox(height: 10.h),
              Row(children: [
                Expanded(child: _NumberField(label: 'Fat g', ctrl: _fat)),
                SizedBox(width: 10.w),
                Expanded(child: _NumberField(label: 'Carbs g', ctrl: _carbs)),
              ]),
              SizedBox(height: 14.h),
              Row(children: [
                Text('Results:',
                    style: TextStyle(fontSize: 12.sp, color: Colors.white38)),
                SizedBox(width: 10.w),
                ...[3, 5, 10].map((n) => Padding(
                      padding: EdgeInsets.only(right: 6.w),
                      child: GestureDetector(
                        onTap: () => setState(() => _topN = n),
                        child: _FilterChip(label: '$n', active: _topN == n),
                      ),
                    )),
              ]),
              SizedBox(height: 16.h),
              _primaryBtn(
                label: 'Get recommendations',
                icon: Icons.auto_awesome_rounded,
                loading: _loading, onTap: _run,
              ),
            ],
          )),
          if (_error != null) _errorBanner(_error!),
          if (_results.isNotEmpty) ...[
            SizedBox(height: 6.h),
            _sectionHeader('${_results.length} suggestions',
                sub: 'sorted by similarity'),
            ..._results.asMap().entries.map((e) => _FadeSlide(
                  delay: Duration(milliseconds: e.key * 40),
                  child: _foodCard(
                      context: context, item: e.value, showSimilarity: true),
                )),
          ] else if (!_loading) ...[
            SizedBox(height: 20.h),
            _emptyState(
                message: 'Enter a query above and tap\n"Get recommendations"'),
          ],
        ]),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// SCREEN 4 – MEAL SUGGEST
// ═════════════════════════════════════════════════════════════════════════════

class AiSuggestScreen extends StatefulWidget {
  const AiSuggestScreen({super.key});
  @override
  State<AiSuggestScreen> createState() => _AiSuggestScreenState();
}

class _AiSuggestScreenState extends State<AiSuggestScreen> {
  final _cals   = TextEditingController(text: '500');
  final _weight = TextEditingController(text: '150');
  final _tol    = TextEditingController(text: '50');

  bool _loading = false;
  String? _error;
  SuggestResult? _result;
  bool _noResult = false;

  @override
  void dispose() {
    _cals.dispose(); _weight.dispose(); _tol.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    final cals = double.tryParse(_cals.text);
    if (cals == null) return;
    setState(() { _loading = true; _error = null; _noResult = false; });
    try {
      final body = <String, dynamic>{'calories': cals};
      if (_weight.text.isNotEmpty) body['weight']    = double.parse(_weight.text);
      if (_tol.text.isNotEmpty)    body['tolerance'] = double.parse(_tol.text);

      final res = await _post(AiApiConfig.suggest, body);
      if (res['success'] == true) {
        if (res['data'] == null) {
          setState(() { _loading = false; _noResult = true; _result = null; });
        } else {
          setState(() {
            _loading = false;
            _result  = SuggestResult.fromJson(
                res['data'] as Map<String, dynamic>);
          });
        }
      } else {
        setState(() { _loading = false; _error = res['error']?.toString(); });
      }
    } catch (e) {
      setState(() { _loading = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: _buildAppBar(context, 'Meal planner'),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 32.h),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _FormCard(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader('Target calories'),
              TextField(
                controller: _cals,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: TextStyle(fontSize: 13.sp, color: Colors.white),
                decoration: _inputDeco(hint: 'e.g. 500'),
              ),
              SizedBox(height: 14.h),
              Row(children: [
                Expanded(child: _NumberField(
                    label: 'Serving weight (g)', ctrl: _weight)),
                SizedBox(width: 10.w),
                Expanded(child: _NumberField(
                    label: 'Tolerance (kcal)', ctrl: _tol)),
              ]),
              SizedBox(height: 16.h),
              _primaryBtn(
                label: 'Find my meal',
                icon: Icons.restaurant_rounded,
                loading: _loading, onTap: _run,
              ),
            ],
          )),
          if (_error != null) _errorBanner(_error!),
          if (_noResult)
            _emptyState(
                message:
                    'No meal found in this calorie range.\nTry adjusting the tolerance.'),
          if (_result != null)
            _FadeSlide(
              delay: const Duration(milliseconds: 80),
              child: Container(
                padding: EdgeInsets.all(18.w),
                decoration: BoxDecoration(
                  color: _kSurface,
                  borderRadius: BorderRadius.circular(22.r),
                  border: Border.all(color: Colors.white.withOpacity(.07)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      _Float(
                        child: Text(_foodEmoji(_result!.food),
                            style: TextStyle(fontSize: 42.sp)),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_result!.food,
                              style: TextStyle(
                                  fontSize: 16.sp, fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                          SizedBox(height: 5.h),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: _kGreen.withOpacity(.1),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                  color: _kGreen.withOpacity(.3)),
                            ),
                            child: Text('Best match',
                                style: TextStyle(
                                    fontSize: 10.sp, color: _kGreen,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      )),
                    ]),
                    SizedBox(height: 18.h),
                    Row(children: [
                      _MacroTile(label: 'Calories',
                          value: '${_result!.calories.round()}',
                          unit: 'kcal', color: _kBlue),
                      SizedBox(width: 8.w),
                      _MacroTile(label: 'Protein',
                          value: _result!.protein.toStringAsFixed(1),
                          unit: 'g', color: _kOrange),
                      SizedBox(width: 8.w),
                      _MacroTile(label: 'Carbs',
                          value: _result!.carbohydrates.toStringAsFixed(1),
                          unit: 'g', color: _kGreen),
                      SizedBox(width: 8.w),
                      _MacroTile(label: 'Fat',
                          value: _result!.fat.toStringAsFixed(1),
                          unit: 'g', color: _kRed),
                    ]),
                    SizedBox(height: 16.h),
                    _MacroBar(label: 'Protein',
                        value: _result!.protein, max: 60, color: _kOrange),
                    SizedBox(height: 8.h),
                    _MacroBar(label: 'Carbs',
                        value: _result!.carbohydrates, max: 120, color: _kGreen),
                    SizedBox(height: 8.h),
                    _MacroBar(label: 'Fat',
                        value: _result!.fat, max: 40, color: _kRed),
                    SizedBox(height: 12.h),
                    Text('Serving: ${_result!.weightG.round()}g',
                        style: TextStyle(
                            fontSize: 11.sp, color: Colors.white30)),
                  ],
                ),
              ),
            ),
        ]),
      ),
    );
  }
}

class _MacroTile extends StatelessWidget {
  final String label, value, unit;
  final Color color;
  const _MacroTile({
    required this.label, required this.value,
    required this.unit,  required this.color,
  });
  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: color.withOpacity(.09),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(children: [
            Text(value,
                style: TextStyle(
                    fontSize: 15.sp, fontWeight: FontWeight.w800,
                    color: color)),
            Text(unit,
                style: TextStyle(
                    fontSize: 9.sp, color: color.withOpacity(.6))),
            SizedBox(height: 2.h),
            Text(label,
                style: TextStyle(fontSize: 9.sp, color: Colors.white30)),
          ]),
        ),
      );
}