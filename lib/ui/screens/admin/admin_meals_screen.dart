// lib/ui/screens/admin/admin_meals_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vital_metrics/core/themes/theme_context_extension.dart';
import 'package:vital_metrics/data/config/api_config.dart';
import 'package:vital_metrics/data/exceptions/api_exception.dart';
import 'package:vital_metrics/services/api_service.dart';
import 'package:vital_metrics/services/token_storage_service.dart';
import 'package:vital_metrics/data/models/egyptian_meals_data.dart';

// ── Meal model ─────────────────────────────────────────────────────────────────
class _Meal {
  final int    id;
  final String name;
  final String description;
  final int    calories;
  final double protein, carbs, fat;

  const _Meal({
    required this.id,
    required this.name,
    required this.description,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory _Meal.fromJson(Map<String, dynamic> j) => _Meal(
        id:          (j['meal_id']     as num?)?.toInt() ?? 0,
        name:         j['name']        as String? ?? '',
        description:  j['description'] as String? ?? '',
        calories:    (j['calories']    as num?)?.toInt() ?? 0,
        protein:     double.tryParse(j['protein'].toString()) ?? 0,
        carbs:       double.tryParse(j['carbs'].toString())   ?? 0,
        fat:         double.tryParse(j['fat'].toString())     ?? 0,
      );

  // Simple emoji picker based on meal name keywords
  String get emoji {
    final n = name.toLowerCase();
    if (n.contains('chicken'))                        return '🍗';
    if (n.contains('beef') || n.contains('steak'))    return '🥩';
    if (n.contains('fish') || n.contains('salmon'))   return '🐟';
    if (n.contains('egg'))                            return '🥚';
    if (n.contains('rice'))                           return '🍚';
    if (n.contains('pasta'))                          return '🍝';
    if (n.contains('salad'))                          return '🥗';
    if (n.contains('oat'))                            return '🥣';
    if (n.contains('yogurt'))                         return '🥛';
    if (n.contains('pizza'))                          return '🍕';
    if (n.contains('burger'))                         return '🍔';
    if (n.contains('avocado'))                        return '🥑';
    if (n.contains('nut'))                            return '🥜';
    return '🍽️';
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// AdminMealsScreen
// ══════════════════════════════════════════════════════════════════════════════
class AdminMealsScreen extends StatefulWidget {
  const AdminMealsScreen({super.key});

  @override
  State<AdminMealsScreen> createState() => _AdminMealsScreenState();
}

class _AdminMealsScreenState extends State<AdminMealsScreen> {
  final _api          = ApiService();
  final _tokenStorage = TokenStorageService();
  final _searchCtrl   = TextEditingController();

  List<_Meal> _meals    = [];
  List<_Meal> _filtered = [];
  bool        _loading  = true;
  String?     _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // Build auth headers using the stored token
  Future<Map<String, String>> get _headers async {
    final token = await _tokenStorage.getToken();
    return ApiConfig.headers(token: token);
  }

  // ── Fetch all meals from the backend ────────────────────────────────────────
  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final headers = await _headers;
      final raw     = await _api.getAsList(ApiConfig.getMeals, headers: headers);
      final meals   = raw
          .map((e) => _Meal.fromJson(e as Map<String, dynamic>))
          .toList();
      setState(() {
        _meals    = meals;
        _filtered = meals;
        _loading  = false;
      });
    } on ApiException catch (e) {
      setState(() { _error = e.message; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  // ── Filter meals by name or id ───────────────────────────────────────────────
  void _onSearch(String q) {
    setState(() {
      _filtered = _meals.where((m) =>
        m.name.toLowerCase().contains(q.toLowerCase()) ||
        m.id.toString().contains(q),
      ).toList();
    });
  }

  // ── Delete a single meal with confirmation ──────────────────────────────────
  Future<void> _deleteMeal(_Meal meal) async {
    final ok = await showCupertinoDialog<bool>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title:   const Text('Delete Meal'),
        content: Text('Delete "${meal.name}"?\nThis cannot be undone.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    try {
      final headers = await _headers;
      await _api.delete(ApiConfig.deleteMeal(meal.id), headers: headers);
      setState(() {
        _meals.removeWhere((m)    => m.id == meal.id);
        _filtered.removeWhere((m) => m.id == meal.id);
      });
      _snack('"${meal.name}" deleted', error: false);
    } catch (e) {
      _snack(e.toString(), error: true);
    }
  }

  // ── Open add/edit bottom sheet ──────────────────────────────────────────────
  void _showForm({_Meal? meal}) {
    showModalBottomSheet(
      context:            context,
      isScrollControlled: true,
      backgroundColor:    Colors.transparent,
      builder: (_) => _MealForm(
        meal:   meal,
        onSave: (data) async {
          final headers = await _headers;
          if (meal == null) {
            // Create new meal
            final res     = await _api.post(
                ApiConfig.createMeal, headers: headers, body: data);
            final created = _Meal.fromJson(res);
            setState(() {
              _meals.add(created);
              _filtered = _meals;
            });
            _snack('Meal added!', error: false);
          } else {
            // Update existing meal
            final res     = await _api.put(
                ApiConfig.updateMeal(meal.id), headers: headers, body: data);
            final updated = _Meal.fromJson(res);
            setState(() {
              final idx = _meals.indexWhere((m) => m.id == meal.id);
              if (idx != -1) _meals[idx] = updated;
              _filtered = _meals;
            });
            _snack('Meal updated!', error: false);
          }
        },
      ),
    );
  }

  // ── Import pre-defined Egyptian meals, skipping duplicates ──────────────────
  Future<void> _importEgyptianMeals() async {
    // Step 1: confirm before doing anything — prevents accidental double import
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title:   const Text('Import Egyptian Meals'),
        content: const Text(
          'This will add all Egyptian meals not already in the catalog.\n\n'
          'If you have imported before, duplicates will be skipped automatically.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Import'),
          ),
        ],
      ),
    );

    // User tapped Cancel — abort
    if (confirmed != true || !mounted) return;

    try {
      final headers = await _headers;

      // Show loading spinner while working
      showDialog(
        context:            context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      // Step 2: fetch the latest meal list directly from the server
      // so duplicate check reflects real DB state, not stale local cache
      final raw   = await _api.getAsList(ApiConfig.getMeals, headers: headers);
      final fresh = raw
          .map((e) => _Meal.fromJson(e as Map<String, dynamic>))
          .toList();

      final existingNames = fresh
          .map((e) => e.name.trim().toLowerCase())
          .toSet();

      int imported = 0;
      int skipped  = 0;

      for (final meal in egyptianMeals()) {
        // Skip any meal whose name already exists in the server list
        if (existingNames.contains(meal.name.trim().toLowerCase())) {
          skipped++;
          continue;
        }

        try {
          await _api.post(
            ApiConfig.createMeal,
            headers: headers,
            body: {
              'name':        meal.name,
              'description': meal.description,
              'calories':    meal.calories,
              'protein':     meal.protein,
              'carbs':       meal.carbs,
              'fat':         meal.fat,
            },
          );
          imported++;
        } catch (_) {
          // Continue even if a single meal fails
        }
      }

      if (mounted && Navigator.canPop(context)) Navigator.pop(context);

      await _load();

      // Inform the admin how many were added vs skipped
      _snack(
        imported == 0
            ? 'All meals already exist — $skipped skipped'
            : '$imported meals imported, $skipped already existed',
        error: false,
      );
    } catch (e) {
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      _snack('Import failed: $e', error: true);
    }
  }

  // ── Show a floating snack bar ───────────────────────────────────────────────
  void _snack(String msg, {required bool error}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:         Text(msg),
      backgroundColor: error
          ? const Color(0xFFFF4757)
          : const Color(0xFF63E6BE),
      behavior: SnackBarBehavior.floating,
      shape:    RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bg     = isDark ? const Color(0xFF0F1221) : const Color(0xFFF0F3FF);
    final card   = isDark ? const Color(0xFF1A2340) : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header: two rows to avoid horizontal overflow ────────────
            FadeInDown(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
                child: Column(
                  children: [
                    // ── Row 1: title + catalog count + refresh ───────────
                    Row(
                      children: [
                        // Screen title + catalog count
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Meals',
                              style: TextStyle(
                                color:      isDark
                                    ? Colors.white
                                    : const Color(0xFF1A1A2E),
                                fontWeight: FontWeight.bold,
                                fontSize:   24.sp,
                              ),
                            ),
                            Text(
                              '${_filtered.length} meals in catalog',
                              style: TextStyle(
                                color:    isDark
                                    ? Colors.white38
                                    : const Color(0xFF9B9B9B),
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        // Refresh icon button
                        GestureDetector(
                          onTap: _load,
                          child: Container(
                            padding: EdgeInsets.all(9.w),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1A2340)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10.r),
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
                      ],
                    ),

                    SizedBox(height: 12.h),

                    // ── Row 2: import + add meal (full width, no overflow) ─
                    Row(
                      children: [
                        // Import Egyptian meals button — takes half the width
                        Expanded(
                          child: GestureDetector(
                            onTap: _importEgyptianMeals,
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 11.h),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF10B981),
                                    Color(0xFF34D399),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.file_download,
                                      color: Colors.white, size: 16.sp),
                                  SizedBox(width: 6.w),
                                  Text(
                                    'Import Meals',
                                    style: TextStyle(
                                      color:      Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize:   13.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: 10.w),

                        // Add meal button — takes the other half
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _showForm(),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 11.h),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF4361EE), Color(0xFF4CC9F0)],
                                  begin:  Alignment.topLeft,
                                  end:    Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12.r),
                                boxShadow: [
                                  BoxShadow(
                                    color:      const Color(0xFF4361EE)
                                        .withOpacity(0.35),
                                    blurRadius: 10,
                                    offset:     const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add,
                                      color: Colors.white, size: 16.sp),
                                  SizedBox(width: 6.w),
                                  Text(
                                    'Add Meal',
                                    style: TextStyle(
                                      color:      Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize:   13.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Search bar ───────────────────────────────────────────────
            FadeInDown(
              delay: const Duration(milliseconds: 60),
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
                child: Container(
                  decoration: BoxDecoration(
                    color:        card,
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(
                        color:      Colors.black
                            .withOpacity(isDark ? 0.3 : 0.06),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged:  _onSearch,
                    style: TextStyle(
                      color:    isDark ? Colors.white : const Color(0xFF1A1A2E),
                      fontSize: 14.sp,
                    ),
                    decoration: InputDecoration(
                      hintText:  'Search meals...',
                      hintStyle: TextStyle(
                        color:    isDark ? Colors.white30 : Colors.grey,
                        fontSize: 14.sp,
                      ),
                      prefixIcon: Icon(CupertinoIcons.search,
                          color: const Color(0xFF4361EE), size: 20.sp),
                      border:         InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 14.h),
                    ),
                  ),
                ),
              ),
            ),

            // ── Meal list / loading / error / empty state ────────────────
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color:       Color(0xFF4361EE),
                        strokeWidth: 2.5,
                      ),
                    )
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.error_outline,
                                  color: const Color(0xFFFF4757), size: 48.sp),
                              SizedBox(height: 12.h),
                              Text(
                                _error!,
                                style: TextStyle(
                                  color:    isDark
                                      ? Colors.white70
                                      : const Color(0xFF2D3142),
                                  fontSize: 14.sp,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 16.h),
                              ElevatedButton(
                                onPressed: _load,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4361EE)),
                                child: Text('Retry',
                                    style: TextStyle(
                                      color:    Colors.white,
                                      fontSize: 14.sp,
                                    )),
                              ),
                            ],
                          ),
                        )
                      : _filtered.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('🍽️',
                                      style: TextStyle(fontSize: 48.sp)),
                                  SizedBox(height: 12.h),
                                  Text(
                                    'No meals yet',
                                    style: TextStyle(
                                      color:    isDark
                                          ? Colors.white38
                                          : Colors.grey,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                  SizedBox(height: 16.h),
                                  ElevatedButton.icon(
                                    onPressed: () => _showForm(),
                                    icon:  Icon(Icons.add, size: 16.sp),
                                    label: const Text('Add First Meal'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4361EE),
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              physics:   const BouncingScrollPhysics(),
                              padding:   EdgeInsets.fromLTRB(
                                  16.w, 0, 16.w, 30.h),
                              itemCount: _filtered.length,
                              itemBuilder: (_, i) {
                                final m = _filtered[i];
                                return FadeInLeft(
                                  delay: Duration(milliseconds: 40 * i),
                                  child: Container(
                                    margin:  EdgeInsets.only(bottom: 10.h),
                                    padding: EdgeInsets.all(14.w),
                                    decoration: BoxDecoration(
                                      color:        card,
                                      borderRadius: BorderRadius.circular(16.r),
                                      border: isDark
                                          ? Border.all(
                                              color: Colors.white
                                                  .withOpacity(0.05))
                                          : null,
                                      boxShadow: [
                                        BoxShadow(
                                          color:      Colors.black.withOpacity(
                                              isDark ? 0.3 : 0.06),
                                          blurRadius: 10,
                                          offset:     const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        // Meal emoji icon
                                        Text(m.emoji,
                                            style: TextStyle(fontSize: 30.sp)),
                                        SizedBox(width: 12.w),

                                        // Meal info: name, description, macros
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                m.name,
                                                style: TextStyle(
                                                  color: isDark
                                                      ? Colors.white
                                                      : const Color(0xFF1A1A2E),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize:   14.sp,
                                                ),
                                              ),
                                              if (m.description.isNotEmpty)
                                                Text(
                                                  m.description,
                                                  style: TextStyle(
                                                    color:    isDark
                                                        ? Colors.white38
                                                        : const Color(
                                                            0xFF9B9B9B),
                                                    fontSize: 11.sp,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              SizedBox(height: 6.h),
                                              // Macro badges row
                                              Wrap(
                                                spacing:  4.w,
                                                runSpacing: 4.h,
                                                children: [
                                                  _MacroBadge(
                                                      '${m.calories} kcal',
                                                      const Color(0xFFFF9A3C)),
                                                  _MacroBadge(
                                                      'P ${m.protein.toStringAsFixed(0)}g',
                                                      const Color(0xFFFFA94D)),
                                                  _MacroBadge(
                                                      'C ${m.carbs.toStringAsFixed(0)}g',
                                                      const Color(0xFF63E6BE)),
                                                  _MacroBadge(
                                                      'F ${m.fat.toStringAsFixed(0)}g',
                                                      const Color(0xFFFF8787)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Edit + delete action buttons
                                        Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () =>
                                                  _showForm(meal: m),
                                              child: Container(
                                                padding: EdgeInsets.all(7.w),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF4361EE)
                                                      .withOpacity(0.12),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.r),
                                                ),
                                                child: Icon(
                                                  Icons.edit_outlined,
                                                  color: const Color(0xFF4361EE),
                                                  size: 16.sp,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 6.h),
                                            GestureDetector(
                                              onTap: () => _deleteMeal(m),
                                              child: Container(
                                                padding: EdgeInsets.all(7.w),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFFF4757)
                                                      .withOpacity(0.12),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.r),
                                                ),
                                                child: Icon(
                                                  CupertinoIcons.trash,
                                                  color: const Color(0xFFFF4757),
                                                  size: 16.sp,
                                                ),
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
            ),
          ],
        ),
      ),
    );
  }
}

// ── Macro badge chip ──────────────────────────────────────────────────────────
class _MacroBadge extends StatelessWidget {
  final String label;
  final Color  color;

  const _MacroBadge(this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
        decoration: BoxDecoration(
          color:        color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            color:      color,
            fontSize:   10.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
}

// ── Meal add/edit form (bottom sheet) ─────────────────────────────────────────
class _MealForm extends StatefulWidget {
  final _Meal?                              meal;
  final Future<void> Function(Map<String, dynamic>) onSave;

  const _MealForm({this.meal, required this.onSave});

  @override
  State<_MealForm> createState() => _MealFormState();
}

class _MealFormState extends State<_MealForm> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name, _desc, _cal, _prot, _carbs, _fat;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final m = widget.meal;
    _name  = TextEditingController(text: m?.name ?? '');
    _desc  = TextEditingController(text: m?.description ?? '');
    _cal   = TextEditingController(text: m != null ? '${m.calories}' : '');
    _prot  = TextEditingController(text: m != null ? '${m.protein}'  : '');
    _carbs = TextEditingController(text: m != null ? '${m.carbs}'    : '');
    _fat   = TextEditingController(text: m != null ? '${m.fat}'      : '');
  }

  @override
  void dispose() {
    for (final c in [_name, _desc, _cal, _prot, _carbs, _fat]) c.dispose();
    super.dispose();
  }

  // ── Validate and submit the form ─────────────────────────────────────────────
  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.onSave({
        'name':        _name.text.trim(),
        'description': _desc.text.trim(),
        'calories':    int.parse(_cal.text.trim()),
        'protein':     double.parse(_prot.text.trim()),
        'carbs':       double.parse(_carbs.text.trim()),
        'fat':         double.parse(_fat.text.trim()),
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:         Text(e.toString()),
        backgroundColor: const Color(0xFFFF4757),
        behavior:        SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bg     = isDark ? const Color(0xFF1A2340) : Colors.white;

    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color:        bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 30.h),
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width:  40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color:        isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 18.h),

              Text(
                widget.meal == null ? 'Add New Meal' : 'Edit Meal',
                style: TextStyle(
                  color:      isDark ? Colors.white : const Color(0xFF1A1A2E),
                  fontWeight: FontWeight.bold,
                  fontSize:   18.sp,
                ),
              ),
              SizedBox(height: 20.h),

              _field(_name,  'Meal Name *',    isDark, required: true),
              SizedBox(height: 10.h),
              _field(_desc,  'Description',    isDark),
              SizedBox(height: 10.h),

              Row(children: [
                Expanded(child: _field(_cal,  'Calories *',   isDark,
                    num: true, required: true)),
                SizedBox(width: 10.w),
                Expanded(child: _field(_prot, 'Protein (g) *', isDark,
                    num: true, required: true)),
              ]),
              SizedBox(height: 10.h),

              Row(children: [
                Expanded(child: _field(_carbs, 'Carbs (g) *', isDark,
                    num: true, required: true)),
                SizedBox(width: 10.w),
                Expanded(child: _field(_fat,   'Fat (g) *',   isDark,
                    num: true, required: true)),
              ]),
              SizedBox(height: 20.h),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4361EE),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r)),
                    padding: EdgeInsets.symmetric(vertical: 15.h),
                  ),
                  child: _saving
                      ? SizedBox(
                          width:  20.w,
                          height: 20.h,
                          child: const CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          widget.meal == null ? 'Add Meal' : 'Save Changes',
                          style: TextStyle(
                            color:      Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize:   15.sp,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Reusable text field with validation ──────────────────────────────────────
  Widget _field(
    TextEditingController ctrl,
    String label,
    bool isDark, {
    bool num      = false,
    bool required = false,
  }) =>
      TextFormField(
        controller:  ctrl,
        keyboardType: num ? TextInputType.number : TextInputType.text,
        style: TextStyle(
          color:    isDark ? Colors.white : const Color(0xFF1A1A2E),
          fontSize: 14.sp,
        ),
        validator: (v) {
          if (required && (v == null || v.trim().isEmpty)) return 'Required';
          if (num && v != null && v.isNotEmpty &&
              double.tryParse(v) == null)               return 'Must be a number';
          return null;
        },
        decoration: InputDecoration(
          labelText:  label,
          labelStyle: TextStyle(
              color: isDark ? Colors.white38 : Colors.grey, fontSize: 13.sp),
          filled:    true,
          fillColor: isDark
              ? Colors.white.withOpacity(0.06)
              : const Color(0xFFF5F7FF),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide:   BorderSide(
                color: isDark ? Colors.white12 : Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide:   BorderSide(
                color: isDark ? Colors.white12 : Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide:   const BorderSide(color: Color(0xFF4361EE)),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide:   const BorderSide(color: Color(0xFFFF4757)),
          ),
          isDense: true,
        ),
      );
}
