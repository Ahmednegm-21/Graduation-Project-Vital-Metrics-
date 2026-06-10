// ui/screens/home_associated_screens/ai_screen.dart
//
// Replaces the old mock-data AiScreen with a full feature set wired to the
// AI Food API v2.  All five endpoints are covered:
//   GET  /foods          → AiFoodsScreen
//   POST /recommend      → AiRecommendScreen
//   POST /suggest        → AiSuggestScreen
//   POST /similar        → AiSimilarScreen
//   GET  /health         → checked on hub load
//
// Drop-in replacement – the router still points to AiScreen at /ai-assistant.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:vital_metrics/core/themes/theme_context_extension.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG  –  change baseUrl / apiKey to match your environment
// ─────────────────────────────────────────────────────────────────────────────
const String _kBaseUrl = 'http://10.0.2.2:8501'; // localhost for Android emulator
const String _kApiKey  = '';                      // leave empty if server has no key

// ─────────────────────────────────────────────────────────────────────────────
// SHARED HTTP HELPER
// ─────────────────────────────────────────────────────────────────────────────
Map<String, String> get _headers => {
  'Content-Type': 'application/json',
  if (_kApiKey.isNotEmpty) 'X-API-Key': _kApiKey,
};

Future<Map<String, dynamic>> _get(String path,
    {Map<String, String>? query}) async {
  final uri = Uri.parse('$_kBaseUrl$path').replace(queryParameters: query);
  final res  = await http.get(uri, headers: _headers)
      .timeout(const Duration(seconds: 12));
  return jsonDecode(res.body) as Map<String, dynamic>;
}

Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
  final uri = Uri.parse('$_kBaseUrl$path');
  final res  = await http.post(uri,
      headers: _headers, body: jsonEncode(body))
      .timeout(const Duration(seconds: 12));
  return jsonDecode(res.body) as Map<String, dynamic>;
}

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────────────────────────────────────
class FoodItem {
  final String food;
  final double calories;
  final double protein;
  final double fat;
  final double carbohydrates;
  final double? similarity;

  const FoodItem({
    required this.food,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbohydrates,
    this.similarity,
  });

  factory FoodItem.fromJson(Map<String, dynamic> j) => FoodItem(
    food:          j['food']          as String,
    calories:      (j['calories']     as num).toDouble(),
    protein:       (j['protein']      as num).toDouble(),
    fat:           (j['fat']          as num).toDouble(),
    carbohydrates: (j['carbohydrates'] as num).toDouble(),
    similarity:    j['similarity'] != null
        ? (j['similarity'] as num).toDouble()
        : null,
  );
}

class SuggestResult {
  final String food;
  final double weightG;
  final double calories;
  final double protein;
  final double fat;
  final double carbohydrates;

  const SuggestResult({
    required this.food,
    required this.weightG,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbohydrates,
  });

  factory SuggestResult.fromJson(Map<String, dynamic> j) => SuggestResult(
    food:          j['food']          as String,
    weightG:       (j['weight_g']     as num).toDouble(),
    calories:      (j['calories']     as num).toDouble(),
    protein:       (j['protein']      as num).toDouble(),
    fat:           (j['fat']          as num).toDouble(),
    carbohydrates: (j['carbohydrates'] as num).toDouble(),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// COLOURS & THEME HELPERS
// ─────────────────────────────────────────────────────────────────────────────
const _kBlue   = Color(0xFF4361EE);
const _kGreen  = Color(0xFF1D9E75);
const _kOrange = Color(0xFFD85A30);
const _kAmber  = Color(0xFFBA7517);
const _kRed    = Color(0xFFE24B4A);

Color _similarityColor(double? sim) {
  if (sim == null) return _kBlue;
  if (sim >= 0.85) return _kGreen;
  if (sim >= 0.70) return _kAmber;
  return _kOrange;
}

String _similarityLabel(double? sim) {
  if (sim == null) return '';
  if (sim >= 0.85) return 'Excellent';
  if (sim >= 0.70) return 'Good';
  return 'Fair';
}

String _foodEmoji(String name) {
  final n = name.toLowerCase();
  if (n.contains('chicken'))      return '🍗';
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
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────────────────
Widget _macroChip(String label, double val, Color color) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
  decoration: BoxDecoration(
    color: color.withOpacity(.12),
    borderRadius: BorderRadius.circular(8.r),
    border: Border.all(color: color.withOpacity(.3)),
  ),
  child: Text(
    '$label ${val.toStringAsFixed(1)}g',
    style: TextStyle(fontSize: 10.sp, color: color, fontWeight: FontWeight.w600),
  ),
);

Widget _macroBar(BuildContext context, String label, double val, double max,
    Color color, bool isDark) {
  final pct = max > 0 ? (val / max).clamp(0.0, 1.0) : 0.0;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 10.sp,
                  color: isDark ? Colors.white54 : const Color(0xFF6B7280))),
          Text('${val.toStringAsFixed(1)}g',
              style: TextStyle(
                  fontSize: 10.sp,
                  color: color,
                  fontWeight: FontWeight.w600)),
        ],
      ),
      const SizedBox(height: 3),
      ClipRRect(
        borderRadius: BorderRadius.circular(4.r),
        child: LinearProgressIndicator(
          value: pct.toDouble(),
          minHeight: 4.h,
          backgroundColor: color.withOpacity(.15),
          valueColor: AlwaysStoppedAnimation(color),
        ),
      ),
    ],
  );
}

Widget _foodCard({
  required BuildContext context,
  required FoodItem item,
  bool showSimilarity = false,
  VoidCallback? onTap,
}) {
  final isDark = context.isDark;
  final cardBg = isDark ? const Color(0xFF1A2340) : Colors.white;
  final shadow = isDark ? Colors.black38 : Colors.black.withOpacity(.06);

  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: shadow, blurRadius: 10, offset: const Offset(0, 3))],
        border: isDark
            ? Border.all(color: Colors.white.withOpacity(.05))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // emoji box
          Container(
            width: 46.w, height: 46.w,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF242D45) : const Color(0xFFF3F7FF),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Text(_foodEmoji(item.food),
                  style: TextStyle(fontSize: 22.sp)),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(item.food,
                          style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
                    ),
                    if (showSimilarity && item.similarity != null) ...[
                      SizedBox(width: 6.w),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: _similarityColor(item.similarity).withOpacity(.12),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                              color: _similarityColor(item.similarity).withOpacity(.3)),
                        ),
                        child: Text(
                          '${(item.similarity! * 100).round()}% ${_similarityLabel(item.similarity)}',
                          style: TextStyle(
                              fontSize: 10.sp,
                              color: _similarityColor(item.similarity),
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  '${item.calories.round()} kcal',
                  style: TextStyle(
                      fontSize: 11.sp,
                      color: isDark ? Colors.white54 : const Color(0xFF6B7280)),
                ),
                SizedBox(height: 6.h),
                Wrap(
                  spacing: 5.w,
                  runSpacing: 4.h,
                  children: [
                    _macroChip('P', item.protein, _kOrange),
                    _macroChip('C', item.carbohydrates, _kGreen),
                    _macroChip('F', item.fat, _kRed),
                  ],
                ),
                if (showSimilarity && item.similarity != null) ...[
                  SizedBox(height: 6.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: LinearProgressIndicator(
                      value: item.similarity,
                      minHeight: 4.h,
                      backgroundColor: _similarityColor(item.similarity).withOpacity(.15),
                      valueColor: AlwaysStoppedAnimation(_similarityColor(item.similarity)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildSectionHeader(String title, {String? subtitle}) => Padding(
  padding: EdgeInsets.only(bottom: 10.h),
  child: Row(
    children: [
      Expanded(
        child: Text(title,
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700,
                color: const Color(0xFF4A4A6A))),
      ),
      if (subtitle != null)
        Text(subtitle,
            style: TextStyle(fontSize: 11.sp, color: const Color(0xFF9CA3AF))),
    ],
  ),
);

Widget _errorBanner(String msg) => Container(
  margin: EdgeInsets.only(bottom: 12.h),
  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
  decoration: BoxDecoration(
    color: _kRed.withOpacity(.08),
    borderRadius: BorderRadius.circular(12.r),
    border: Border.all(color: _kRed.withOpacity(.25)),
  ),
  child: Row(
    children: [
      Icon(Icons.error_outline_rounded, color: _kRed, size: 16.sp),
      SizedBox(width: 8.w),
      Expanded(
          child: Text(msg,
              style: TextStyle(fontSize: 12.sp, color: _kRed))),
    ],
  ),
);

Widget _emptyState({String message = 'No results found'}) => Center(
  child: Padding(
    padding: EdgeInsets.symmetric(vertical: 40.h),
    child: Column(
      children: [
        Icon(Icons.search_off_rounded, size: 48.sp, color: Colors.grey.shade400),
        SizedBox(height: 12.h),
        Text(message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500)),
      ],
    ),
  ),
);

// Primary action button
Widget _primaryBtn({
  required String label,
  required VoidCallback? onTap,
  bool loading = false,
  IconData? icon,
}) => GestureDetector(
  onTap: loading ? null : onTap,
  child: AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    height: 46.h,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: loading
            ? [Colors.grey.shade400, Colors.grey.shade400]
            : [_kBlue, const Color(0xFF3451D1)],
      ),
      borderRadius: BorderRadius.circular(14.r),
      boxShadow: loading
          ? []
          : [BoxShadow(color: _kBlue.withOpacity(.3), blurRadius: 14, offset: const Offset(0, 4))],
    ),
    child: Center(
      child: loading
          ? SizedBox(
              width: 20.w, height: 20.w,
              child: const CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2))
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 16.sp),
                  SizedBox(width: 6.w),
                ],
                Text(label,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.sp)),
              ],
            ),
    ),
  ),
);

// AppBar factory
AppBar _buildAppBar(BuildContext context, String title) {
  final isDark = context.isDark;
  return AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    leading: GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        margin: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2340) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
                color: isDark ? Colors.black38 : Colors.black.withOpacity(.07),
                blurRadius: 8)
          ],
        ),
        child: Icon(Icons.arrow_back_ios_new_rounded,
            color: _kBlue, size: 18.sp),
      ),
    ),
    title: Text(title,
        style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            fontWeight: FontWeight.w800,
            fontSize: 17.sp)),
  );
}

// ═════════════════════════════════════════════════════════════════════════════
// SCREEN 1 – AI HUB  (entry point, replaces old AiScreen)
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
    try {
      final res = await _get('/health');
      setState(() {
        _apiOnline = res['success'] == true;
        _checking  = false;
      });
    } catch (_) {
      setState(() { _apiOnline = false; _checking = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark  = context.isDark;
    final cardBg  = isDark ? const Color(0xFF1A2340) : Colors.white;
    final shadow  = isDark ? Colors.black38 : Colors.black.withOpacity(.07);

    final actions = [
      _HubAction(
        icon: Icons.search_rounded,
        emoji: '🔍',
        label: 'Food search',
        sub: 'Browse & filter foods',
        color: _kBlue,
        screen: const AiFoodsScreen(),
      ),
      _HubAction(
        icon: Icons.auto_awesome_rounded,
        emoji: '✨',
        label: 'Recommend',
        sub: 'AI meal suggestions',
        color: _kGreen,
        screen: const AiRecommendScreen(),
      ),
      _HubAction(
        icon: Icons.restaurant_rounded,
        emoji: '🍽️',
        label: 'Meal planner',
        sub: 'Match by calories',
        color: _kAmber,
        screen: const AiSuggestScreen(),
      ),
      _HubAction(
        icon: Icons.swap_horiz_rounded,
        emoji: '🔄',
        label: 'Find similar',
        sub: 'Food alternatives',
        color: _kOrange,
        screen: const AiSimilarScreen(),
      ),
    ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF050816) : const Color(0xFFF3F7FF),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('AI Assistant',
                            style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
                        SizedBox(height: 4.h),
                        Text('Nutrition intelligence at your fingertips',
                            style: TextStyle(
                                fontSize: 12.sp,
                                color: isDark ? Colors.white54 : const Color(0xFF6B7280))),
                      ],
                    ),
                  ),
                  // API status dot
                  _checking
                      ? SizedBox(
                          width: 20.w, height: 20.w,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: _kBlue))
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: (_apiOnline ? _kGreen : _kRed).withOpacity(.1),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                                color: (_apiOnline ? _kGreen : _kRed).withOpacity(.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6, height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _apiOnline ? _kGreen : _kRed,
                                ),
                              ),
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
                ],
              ),
              SizedBox(height: 24.h),

              // Quick actions grid
              Text('Quick actions',
                  style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white38 : const Color(0xFF9CA3AF),
                      letterSpacing: .5)),
              SizedBox(height: 10.h),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10.w,
                mainAxisSpacing: 10.h,
                childAspectRatio: 1.55,
                children: actions.map((a) => GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => a.screen)),
                  child: Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(18.r),
                      boxShadow: [BoxShadow(color: shadow, blurRadius: 12, offset: const Offset(0, 4))],
                      border: isDark
                          ? Border.all(color: a.color.withOpacity(.15))
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 34.w, height: 34.w,
                          decoration: BoxDecoration(
                            color: a.color.withOpacity(.12),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Center(
                            child: Icon(a.icon, color: a.color, size: 18.sp),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a.label,
                                style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
                            Text(a.sub,
                                style: TextStyle(
                                    fontSize: 10.sp,
                                    color: isDark ? Colors.white38 : const Color(0xFF9CA3AF))),
                          ],
                        ),
                      ],
                    ),
                  ),
                )).toList(),
              ),
              SizedBox(height: 24.h),

              // Info cards row
              Text('About the AI',
                  style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white38 : const Color(0xFF9CA3AF),
                      letterSpacing: .5)),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(child: _infoCard(cardBg, shadow, isDark,
                      icon: Icons.bolt_rounded,
                      color: _kAmber,
                      title: 'Fast results',
                      sub: 'Similarity search')),
                  SizedBox(width: 10.w),
                  Expanded(child: _infoCard(cardBg, shadow, isDark,
                      icon: Icons.local_fire_department_rounded,
                      color: _kOrange,
                      title: 'Full macros',
                      sub: 'P · C · F breakdown')),
                  SizedBox(width: 10.w),
                  Expanded(child: _infoCard(cardBg, shadow, isDark,
                      icon: Icons.track_changes_rounded,
                      color: _kGreen,
                      title: 'Calorie match',
                      sub: 'Precise planning')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard(Color bg, Color shadow, bool isDark, {
    required IconData icon,
    required Color color,
    required String title,
    required String sub,
  }) => Container(
    padding: EdgeInsets.all(12.w),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(14.r),
      boxShadow: [BoxShadow(color: shadow, blurRadius: 8)],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 18.sp),
        SizedBox(height: 6.h),
        Text(title,
            style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
        Text(sub,
            style: TextStyle(
                fontSize: 9.sp,
                color: isDark ? Colors.white38 : const Color(0xFF9CA3AF))),
      ],
    ),
  );
}

class _HubAction {
  final IconData icon;
  final String emoji, label, sub;
  final Color color;
  final Widget screen;
  const _HubAction({
    required this.icon, required this.emoji, required this.label,
    required this.sub, required this.color, required this.screen,
  });
}

// ═════════════════════════════════════════════════════════════════════════════
// SCREEN 2 – FOOD SEARCH  GET /foods
// ═════════════════════════════════════════════════════════════════════════════
class AiFoodsScreen extends StatefulWidget {
  const AiFoodsScreen({super.key});
  @override
  State<AiFoodsScreen> createState() => _AiFoodsScreenState();
}

class _AiFoodsScreenState extends State<AiFoodsScreen> {
  final TextEditingController _search = TextEditingController();

  bool _loading = false;
  String? _error;
  List<FoodItem> _foods = [];
  String _activeFilter = 'all';
  int _limit = 20;

  static const _filters = [
    ('all', 'All'),
    ('high-protein', 'High protein'),
    ('low-cal', 'Low cal'),
    ('low-carb', 'Low carb'),
  ];

  @override
  void initState() {
    super.initState();
    _fetchFoods();
  }

  @override
  void dispose() { _search.dispose(); super.dispose(); }

  Future<void> _fetchFoods({String? search}) async {
    setState(() { _loading = true; _error = null; });
    try {
      final query = <String, String>{'limit': '$_limit'};
      if (search != null && search.isNotEmpty) query['search'] = search;
      final res  = await _get('/foods', query: query);
      final raw  = res['data'] as List<dynamic>;
      setState(() {
        _loading = false;
        _foods   = raw.map((e) => FoodItem.fromJson(e as Map<String, dynamic>)).toList();
      });
    } catch (e) {
      setState(() { _loading = false; _error = e.toString(); });
    }
  }

  List<FoodItem> get _filtered {
    return _foods.where((f) {
      if (_activeFilter == 'high-protein' && f.protein < 20) return false;
      if (_activeFilter == 'low-cal' && f.calories >= 200) return false;
      if (_activeFilter == 'low-carb' && f.carbohydrates >= 15) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark   = context.isDark;
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF050816) : const Color(0xFFF3F7FF),
      appBar: _buildAppBar(context, 'Food database'),
      body: Column(
        children: [
          // search bar
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
            child: _SearchBar(
              controller: _search,
              onSubmit: (v) => _fetchFoods(search: v),
            ),
          ),
          // filter chips
          SizedBox(
            height: 44.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              children: _filters.map((f) => Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: GestureDetector(
                  onTap: () => setState(() => _activeFilter = f.$1),
                  child: _FilterChip(label: f.$2, active: _activeFilter == f.$1),
                ),
              )).toList(),
            ),
          ),
          // count bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
            child: Row(
              children: [
                Text('${filtered.length} food${filtered.length == 1 ? '' : 's'}',
                    style: TextStyle(fontSize: 12.sp,
                        color: isDark ? Colors.white38 : const Color(0xFF9CA3AF))),
                const Spacer(),
                if (_loading)
                  SizedBox(width: 14.w, height: 14.w,
                      child: CircularProgressIndicator(strokeWidth: 2, color: _kBlue)),
              ],
            ),
          ),
          // list
          Expanded(
            child: _error != null
                ? Center(child: Padding(padding: EdgeInsets.all(20.w), child: _errorBanner(_error!)))
                : filtered.isEmpty && !_loading
                    ? _emptyState()
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 32.h),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) => _foodCard(context: context, item: filtered[i]),
                      ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// SCREEN 3 – RECOMMEND  POST /recommend
// ═════════════════════════════════════════════════════════════════════════════
class AiRecommendScreen extends StatefulWidget {
  const AiRecommendScreen({super.key});
  @override
  State<AiRecommendScreen> createState() => _AiRecommendScreenState();
}

class _AiRecommendScreenState extends State<AiRecommendScreen> {
  final _query  = TextEditingController(text: 'high protein chicken');
  final _cals   = TextEditingController(text: '500');
  final _prot   = TextEditingController(text: '30');
  final _fat    = TextEditingController(text: '10');
  final _carbs  = TextEditingController(text: '20');

  bool _loading = false;
  String? _error;
  List<FoodItem> _results = [];
  int _topN = 5;

  @override
  void dispose() {
    _query.dispose(); _cals.dispose();
    _prot.dispose(); _fat.dispose(); _carbs.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    if (_query.text.trim().isEmpty) return;
    setState(() { _loading = true; _error = null; });
    try {
      final body = <String, dynamic>{
        'query': _query.text.trim(),
        'top_n': _topN,
      };
      if (_cals.text.isNotEmpty)  body['calories'] = double.parse(_cals.text);
      if (_prot.text.isNotEmpty)  body['protein']  = double.parse(_prot.text);
      if (_fat.text.isNotEmpty)   body['fat']      = double.parse(_fat.text);
      if (_carbs.text.isNotEmpty) body['carbs']    = double.parse(_carbs.text);

      final res = await _post('/recommend', body);
      if (res['success'] == true) {
        final raw = res['data'] as List<dynamic>;
        setState(() {
          _loading = false;
          _results = raw.map((e) => FoodItem.fromJson(e as Map<String, dynamic>)).toList();
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
    final isDark = context.isDark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF050816) : const Color(0xFFF3F7FF),
      appBar: _buildAppBar(context, 'AI Recommend'),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 32.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FormCard(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Describe what you want'),
                  TextField(
                    controller: _query,
                    decoration: _inputDeco(context, isDark,
                        hint: 'e.g. high protein breakfast, low carb dinner...'),
                  ),
                  SizedBox(height: 14.h),
                  _buildSectionHeader('Nutrition targets (optional)'),
                  Row(children: [
                    Expanded(child: _NumberField(label: 'Max kcal', ctrl: _cals, isDark: isDark)),
                    SizedBox(width: 10.w),
                    Expanded(child: _NumberField(label: 'Protein g', ctrl: _prot, isDark: isDark)),
                  ]),
                  SizedBox(height: 10.h),
                  Row(children: [
                    Expanded(child: _NumberField(label: 'Fat g', ctrl: _fat, isDark: isDark)),
                    SizedBox(width: 10.w),
                    Expanded(child: _NumberField(label: 'Carbs g', ctrl: _carbs, isDark: isDark)),
                  ]),
                  SizedBox(height: 14.h),
                  Row(
                    children: [
                      Text('Results:',
                          style: TextStyle(fontSize: 12.sp,
                              color: isDark ? Colors.white54 : const Color(0xFF6B7280))),
                      SizedBox(width: 10.w),
                      ...[3, 5, 10].map((n) => Padding(
                        padding: EdgeInsets.only(right: 6.w),
                        child: GestureDetector(
                          onTap: () => setState(() => _topN = n),
                          child: _FilterChip(label: '$n', active: _topN == n),
                        ),
                      )),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  _primaryBtn(
                    label: 'Get recommendations',
                    icon: Icons.auto_awesome_rounded,
                    loading: _loading,
                    onTap: _run,
                  ),
                ],
              ),
            ),
            if (_error != null) _errorBanner(_error!),
            if (_results.isNotEmpty) ...[
              SizedBox(height: 6.h),
              _buildSectionHeader('${_results.length} suggestions', subtitle: 'sorted by similarity'),
              ..._results.map((f) => _foodCard(context: context, item: f, showSimilarity: true)),
            ] else if (!_loading) ...[
              SizedBox(height: 20.h),
              _emptyState(message: 'Enter a query above and tap\n"Get recommendations"'),
            ],
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// SCREEN 4 – MEAL SUGGEST  POST /suggest
// ═════════════════════════════════════════════════════════════════════════════
class AiSuggestScreen extends StatefulWidget {
  const AiSuggestScreen({super.key});
  @override
  State<AiSuggestScreen> createState() => _AiSuggestScreenState();
}

class _AiSuggestScreenState extends State<AiSuggestScreen> {
  final _cals    = TextEditingController(text: '500');
  final _weight  = TextEditingController(text: '150');
  final _tol     = TextEditingController(text: '50');

  bool _loading = false;
  String? _error;
  SuggestResult? _result;
  bool _noResult = false;

  @override
  void dispose() { _cals.dispose(); _weight.dispose(); _tol.dispose(); super.dispose(); }

  Future<void> _run() async {
    final cals = double.tryParse(_cals.text);
    if (cals == null) return;
    setState(() { _loading = true; _error = null; _noResult = false; });
    try {
      final body = <String, dynamic>{'calories': cals};
      if (_weight.text.isNotEmpty) body['weight']    = double.parse(_weight.text);
      if (_tol.text.isNotEmpty)    body['tolerance'] = double.parse(_tol.text);

      final res = await _post('/suggest', body);
      if (res['success'] == true) {
        if (res['data'] == null) {
          setState(() { _loading = false; _noResult = true; _result = null; });
        } else {
          setState(() {
            _loading = false;
            _result  = SuggestResult.fromJson(res['data'] as Map<String, dynamic>);
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
    final isDark = context.isDark;
    final cardBg = isDark ? const Color(0xFF1A2340) : Colors.white;
    final shadow = isDark ? Colors.black38 : Colors.black.withOpacity(.07);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF050816) : const Color(0xFFF3F7FF),
      appBar: _buildAppBar(context, 'Meal planner'),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 32.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FormCard(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Target calories'),
                  TextField(
                    controller: _cals,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: _inputDeco(context, isDark, hint: 'e.g. 500'),
                  ),
                  SizedBox(height: 14.h),
                  Row(children: [
                    Expanded(child: _NumberField(label: 'Serving weight (g)', ctrl: _weight, isDark: isDark)),
                    SizedBox(width: 10.w),
                    Expanded(child: _NumberField(label: 'Tolerance (kcal)', ctrl: _tol, isDark: isDark)),
                  ]),
                  SizedBox(height: 16.h),
                  _primaryBtn(
                    label: 'Find my meal',
                    icon: Icons.restaurant_rounded,
                    loading: _loading,
                    onTap: _run,
                  ),
                ],
              ),
            ),
            if (_error != null) _errorBanner(_error!),
            if (_noResult)
              _emptyState(message: 'No meal found in this calorie range.\nTry adjusting the tolerance.'),
            if (_result != null) ...[
              SizedBox(height: 6.h),
              // Result card
              Container(
                padding: EdgeInsets.all(18.w),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [BoxShadow(color: shadow, blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(_foodEmoji(_result!.food), style: TextStyle(fontSize: 40.sp)),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_result!.food,
                                  style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
                              SizedBox(height: 4.h),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _kGreen.withOpacity(.1),
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(color: _kGreen.withOpacity(.3)),
                                ),
                                child: Text('Best match',
                                    style: TextStyle(
                                        fontSize: 10.sp,
                                        color: _kGreen,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 18.h),
                    // Macro grid
                    Row(
                      children: [
                        _MacroTile(label: 'Calories', value: '${_result!.calories.round()}', unit: 'kcal', color: _kBlue, isDark: isDark),
                        SizedBox(width: 8.w),
                        _MacroTile(label: 'Protein', value: _result!.protein.toStringAsFixed(1), unit: 'g', color: _kOrange, isDark: isDark),
                        SizedBox(width: 8.w),
                        _MacroTile(label: 'Carbs', value: _result!.carbohydrates.toStringAsFixed(1), unit: 'g', color: _kGreen, isDark: isDark),
                        SizedBox(width: 8.w),
                        _MacroTile(label: 'Fat', value: _result!.fat.toStringAsFixed(1), unit: 'g', color: _kRed, isDark: isDark),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    _macroBar(context, 'Protein', _result!.protein, 60, _kOrange, isDark),
                    SizedBox(height: 8.h),
                    _macroBar(context, 'Carbs', _result!.carbohydrates, 120, _kGreen, isDark),
                    SizedBox(height: 8.h),
                    _macroBar(context, 'Fat', _result!.fat, 40, _kRed, isDark),
                    SizedBox(height: 14.h),
                    Text('Serving: ${_result!.weightG.round()}g',
                        style: TextStyle(
                            fontSize: 11.sp,
                            color: isDark ? Colors.white38 : const Color(0xFF9CA3AF))),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MacroTile extends StatelessWidget {
  final String label, value, unit;
  final Color color;
  final bool isDark;
  const _MacroTile({required this.label, required this.value, required this.unit,
      required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: color.withOpacity(.08),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: color)),
            Text(unit,
                style: TextStyle(
                    fontSize: 9.sp,
                    color: color.withOpacity(.7))),
            SizedBox(height: 2.h),
            Text(label,
                style: TextStyle(
                    fontSize: 9.sp,
                    color: isDark ? Colors.white38 : const Color(0xFF9CA3AF))),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// SCREEN 5 – SIMILAR FOODS  POST /similar
// ═════════════════════════════════════════════════════════════════════════════
class AiSimilarScreen extends StatefulWidget {
  const AiSimilarScreen({super.key});
  @override
  State<AiSimilarScreen> createState() => _AiSimilarScreenState();
}

class _AiSimilarScreenState extends State<AiSimilarScreen> {
  final _name = TextEditingController(text: 'Chicken Breast');
  bool _loading = false;
  String? _error;
  List<FoodItem> _results = [];
  int _topN = 5;

  @override
  void dispose() { _name.dispose(); super.dispose(); }

  Future<void> _run() async {
    if (_name.text.trim().isEmpty) return;
    setState(() { _loading = true; _error = null; });
    try {
      final res = await _post('/similar', {
        'food_name': _name.text.trim(),
        'top_n': _topN,
      });
      if (res['success'] == true) {
        final raw = res['data'] as List<dynamic>;
        setState(() {
          _loading = false;
          _results = raw.map((e) => FoodItem.fromJson(e as Map<String, dynamic>)).toList();
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
    final isDark = context.isDark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF050816) : const Color(0xFFF3F7FF),
      appBar: _buildAppBar(context, 'Find similar foods'),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 32.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FormCard(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Food name'),
                  TextField(
                    controller: _name,
                    decoration: _inputDeco(context, isDark,
                        hint: 'e.g. Chicken Breast, Oats...'),
                  ),
                  SizedBox(height: 14.h),
                  Row(
                    children: [
                      Text('Results:',
                          style: TextStyle(fontSize: 12.sp,
                              color: isDark ? Colors.white54 : const Color(0xFF6B7280))),
                      SizedBox(width: 10.w),
                      ...[3, 5, 10].map((n) => Padding(
                        padding: EdgeInsets.only(right: 6.w),
                        child: GestureDetector(
                          onTap: () => setState(() => _topN = n),
                          child: _FilterChip(label: '$n', active: _topN == n),
                        ),
                      )),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  _primaryBtn(
                    label: 'Find alternatives',
                    icon: Icons.swap_horiz_rounded,
                    loading: _loading,
                    onTap: _run,
                  ),
                ],
              ),
            ),
            if (_error != null) _errorBanner(_error!),
            if (_results.isNotEmpty) ...[
              SizedBox(height: 6.h),
              _buildSectionHeader(
                  '${_results.length} alternatives for "${_name.text}"',
                  subtitle: 'by similarity'),
              ..._results.map((f) => _foodCard(context: context, item: f, showSimilarity: true)),
            ] else if (!_loading) ...[
              SizedBox(height: 20.h),
              _emptyState(message: 'Enter a food name above and tap\n"Find alternatives"'),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SMALL REUSABLE WIDGETS
// ─────────────────────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmit;
  const _SearchBar({required this.controller, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2340) : Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
              color: isDark ? Colors.black38 : Colors.black.withOpacity(.06),
              blurRadius: 10)
        ],
      ),
      child: TextField(
        controller: controller,
        onSubmitted: onSubmit,
        textInputAction: TextInputAction.search,
        style: TextStyle(fontSize: 13.sp,
            color: isDark ? Colors.white : const Color(0xFF1A1A2E)),
        decoration: InputDecoration(
          hintText: 'Search foods...',
          hintStyle: TextStyle(color: isDark ? Colors.white38 : const Color(0xFF9CA3AF),
              fontSize: 13.sp),
          prefixIcon: Icon(Icons.search_rounded,
              color: isDark ? Colors.white38 : const Color(0xFF9CA3AF),
              size: 20.sp),
          suffixIcon: GestureDetector(
            onTap: () => onSubmit(controller.text),
            child: Icon(Icons.arrow_forward_rounded, color: _kBlue, size: 20.sp),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  const _FilterChip({required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: active
            ? _kBlue
            : (isDark ? const Color(0xFF1A2340) : Colors.white),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: active
              ? _kBlue
              : (isDark ? Colors.white.withOpacity(.1) : Colors.black.withOpacity(.08)),
        ),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: active
                  ? Colors.white
                  : (isDark ? Colors.white60 : const Color(0xFF6B7280)))),
    );
  }
}

class _FormCard extends StatelessWidget {
  final Widget child;
  final bool isDark;
  const _FormCard({required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
    margin: EdgeInsets.only(bottom: 16.h),
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
      color: isDark ? const Color(0xFF1A2340) : Colors.white,
      borderRadius: BorderRadius.circular(20.r),
      boxShadow: [
        BoxShadow(
            color: isDark ? Colors.black38 : Colors.black.withOpacity(.07),
            blurRadius: 16, offset: const Offset(0, 5))
      ],
      border: isDark
          ? Border.all(color: Colors.white.withOpacity(.05))
          : null,
    ),
    child: child,
  );
}

class _NumberField extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final bool isDark;
  const _NumberField({required this.label, required this.ctrl, required this.isDark});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label,
          style: TextStyle(fontSize: 10.sp,
              color: isDark ? Colors.white38 : const Color(0xFF9CA3AF))),
      SizedBox(height: 5.h),
      TextField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
        style: TextStyle(fontSize: 13.sp,
            color: isDark ? Colors.white : const Color(0xFF1A1A2E)),
        decoration: _inputDeco(context, isDark, hint: '0'),
      ),
    ],
  );
}

InputDecoration _inputDeco(BuildContext context, bool isDark, {String hint = ''}) =>
    InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
          fontSize: 13.sp,
          color: isDark ? Colors.white24 : const Color(0xFFBCC0CC)),
      filled: true,
      fillColor: isDark ? const Color(0xFF0D1428) : const Color(0xFFF3F7FF),
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: _kBlue, width: 1.5)),
    );