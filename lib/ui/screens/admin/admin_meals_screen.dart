import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:animate_do/animate_do.dart';
import 'package:vital_metrics/core/themes/theme_context_extension.dart';
import 'package:vital_metrics/data/config/api_config.dart';
import 'package:vital_metrics/data/exceptions/api_exception.dart';
import 'package:vital_metrics/services/api_service.dart';
import 'package:vital_metrics/services/token_storage_service.dart';

// ── Meal model ─────────────────────────────────────────────────────────────────
class _Meal {
  final int    id;
  final String name;
  final String description;
  final int    calories;
  final double protein, carbs, fat;

  const _Meal({
    required this.id, required this.name, required this.description,
    required this.calories, required this.protein,
    required this.carbs, required this.fat,
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

  String get emoji {
    final n = name.toLowerCase();
    if (n.contains('chicken'))  return '🍗';
    if (n.contains('beef') || n.contains('steak')) return '🥩';
    if (n.contains('fish') || n.contains('salmon')) return '🐟';
    if (n.contains('egg'))      return '🥚';
    if (n.contains('rice'))     return '🍚';
    if (n.contains('pasta'))    return '🍝';
    if (n.contains('salad'))    return '🥗';
    if (n.contains('oat'))      return '🥣';
    if (n.contains('yogurt'))   return '🥛';
    if (n.contains('pizza'))    return '🍕';
    if (n.contains('burger'))   return '🍔';
    if (n.contains('avocado'))  return '🥑';
    if (n.contains('nut'))      return '🥜';
    return '🍽️';
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// AdminMealsScreen
// ══════════════════════════════════════════════════════════════════════════════
class AdminMealsScreen extends StatefulWidget {
  const AdminMealsScreen({super.key});
  @override State<AdminMealsScreen> createState() => _AdminMealsScreenState();
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
  void initState() { super.initState(); _load(); }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  Future<Map<String, String>> get _headers async {
    final token = await _tokenStorage.getToken();
    return ApiConfig.headers(token: token);
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final headers = await _headers;
      final raw     = await _api.getAsList(ApiConfig.getMeals, headers: headers);
      final meals   = raw
          .map((e) => _Meal.fromJson(e as Map<String, dynamic>))
          .toList();
      setState(() { _meals = meals; _filtered = meals; _loading = false; });
    } on ApiException catch (e) {
      setState(() { _error = e.message; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _onSearch(String q) {
    setState(() {
      _filtered = _meals.where((m) =>
        m.name.toLowerCase().contains(q.toLowerCase()) ||
        m.id.toString().contains(q)
      ).toList();
    });
  }

  Future<void> _deleteMeal(_Meal meal) async {
    final ok = await showCupertinoDialog<bool>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Delete Meal'),
        content: Text('Delete "${meal.name}"?\nThis cannot be undone.'),
        actions: [
          CupertinoDialogAction(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    try {
      final headers = await _headers;
      await _api.delete(ApiConfig.deleteMeal(meal.id), headers: headers);
      setState(() {
        _meals.removeWhere((m) => m.id == meal.id);
        _filtered.removeWhere((m) => m.id == meal.id);
      });
      _snack('"${meal.name}" deleted', error: false);
    } catch (e) {
      _snack(e.toString(), error: true);
    }
  }

  void _showForm({_Meal? meal}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MealForm(
        meal: meal,
        onSave: (data) async {
          final headers = await _headers;
          if (meal == null) {
            final res = await _api.post(
                ApiConfig.createMeal, headers: headers, body: data);
            final created = _Meal.fromJson(res);
            setState(() {
              _meals.add(created);
              _filtered = _meals;
            });
            _snack('Meal added!', error: false);
          } else {
            final res = await _api.put(
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

  void _snack(String msg, {required bool error}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error
          ? const Color(0xFFFF4757) : const Color(0xFF63E6BE),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            // ── Header ────────────────────────────────────────────────────
            FadeInDown(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
                child: Row(children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Meals',
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                          fontWeight: FontWeight.bold, fontSize: 24)),
                    Text('${_filtered.length} meals in catalog',
                        style: TextStyle(
                          color: isDark ? Colors.white38 : const Color(0xFF9B9B9B),
                          fontSize: 12)),
                  ]),
                  const Spacer(),
                  IconButton(
                    onPressed: _load,
                    icon: const Icon(Icons.refresh,
                        color: Color(0xFF4361EE), size: 22)),
                  // Add button
                  GestureDetector(
                    onTap: () => _showForm(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4361EE), Color(0xFF4CC9F0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(
                          color: const Color(0xFF4361EE).withOpacity(0.35),
                          blurRadius: 10, offset: const Offset(0, 4),
                        )],
                      ),
                      child: const Row(children: [
                        Icon(Icons.add, color: Colors.white, size: 16),
                        SizedBox(width: 5),
                        Text('Add Meal',
                            style: TextStyle(color: Colors.white,
                                fontWeight: FontWeight.bold, fontSize: 12)),
                      ]),
                    ),
                  ),
                ]),
              ),
            ),

            // ── Search ────────────────────────────────────────────────────
            FadeInDown(
              delay: const Duration(milliseconds: 60),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                      blurRadius: 10,
                    )],
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: _onSearch,
                    style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E)),
                    decoration: InputDecoration(
                      hintText: 'Search meals...',
                      hintStyle: TextStyle(
                          color: isDark ? Colors.white30 : Colors.grey),
                      prefixIcon: const Icon(CupertinoIcons.search,
                          color: Color(0xFF4361EE), size: 20),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              ),
            ),

            // ── List ──────────────────────────────────────────────────────
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(
                      color: Color(0xFF4361EE), strokeWidth: 2.5))
                  : _error != null
                      ? Center(child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline,
                                color: Color(0xFFFF4757), size: 48),
                            const SizedBox(height: 12),
                            Text(_error!,
                                style: TextStyle(
                                    color: isDark ? Colors.white70
                                        : const Color(0xFF2D3142)),
                                textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _load,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4361EE)),
                              child: const Text('Retry',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ))
                      : _filtered.isEmpty
                          ? Center(child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🍽️',
                                    style: TextStyle(fontSize: 48)),
                                const SizedBox(height: 12),
                                Text('No meals yet',
                                    style: TextStyle(
                                        color: isDark ? Colors.white38
                                            : Colors.grey, fontSize: 16)),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () => _showForm(),
                                  icon: const Icon(Icons.add, size: 16),
                                  label: const Text('Add First Meal'),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4361EE),
                                      foregroundColor: Colors.white),
                                ),
                              ],
                            ))
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
                              itemCount: _filtered.length,
                              itemBuilder: (_, i) {
                                final m = _filtered[i];
                                return FadeInLeft(
                                  delay: Duration(milliseconds: 40 * i),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: card,
                                      borderRadius: BorderRadius.circular(16),
                                      border: isDark ? Border.all(
                                          color: Colors.white.withOpacity(0.05))
                                          : null,
                                      boxShadow: [BoxShadow(
                                        color: Colors.black.withOpacity(
                                            isDark ? 0.3 : 0.06),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      )],
                                    ),
                                    child: Row(children: [
                                      // Emoji
                                      Text(m.emoji,
                                          style: const TextStyle(fontSize: 30)),
                                      const SizedBox(width: 12),

                                      // Info
                                      Expanded(child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(m.name,
                                              style: TextStyle(
                                                color: isDark ? Colors.white
                                                    : const Color(0xFF1A1A2E),
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              )),
                                          if (m.description.isNotEmpty)
                                            Text(m.description,
                                                style: TextStyle(
                                                  color: isDark ? Colors.white38
                                                      : const Color(0xFF9B9B9B),
                                                  fontSize: 11,
                                                ),
                                                overflow: TextOverflow.ellipsis),
                                          const SizedBox(height: 6),
                                          // Macros row
                                          Row(children: [
                                            _MacroBadge('${m.calories} kcal',
                                                const Color(0xFFFF9A3C)),
                                            const SizedBox(width: 4),
                                            _MacroBadge('P ${m.protein.toStringAsFixed(0)}g',
                                                const Color(0xFFFFA94D)),
                                            const SizedBox(width: 4),
                                            _MacroBadge('C ${m.carbs.toStringAsFixed(0)}g',
                                                const Color(0xFF63E6BE)),
                                            const SizedBox(width: 4),
                                            _MacroBadge('F ${m.fat.toStringAsFixed(0)}g',
                                                const Color(0xFFFF8787)),
                                          ]),
                                        ],
                                      )),

                                      // Actions
                                      Column(children: [
                                        GestureDetector(
                                          onTap: () => _showForm(meal: m),
                                          child: Container(
                                            padding: const EdgeInsets.all(7),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF4361EE)
                                                  .withOpacity(0.12),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                                Icons.edit_outlined,
                                                color: Color(0xFF4361EE),
                                                size: 16),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        GestureDetector(
                                          onTap: () => _deleteMeal(m),
                                          child: Container(
                                            padding: const EdgeInsets.all(7),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFF4757)
                                                  .withOpacity(0.12),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                                CupertinoIcons.trash,
                                                color: Color(0xFFFF4757),
                                                size: 16),
                                          ),
                                        ),
                                      ]),
                                    ]),
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

class _MacroBadge extends StatelessWidget {
  final String label;
  final Color  color;
  const _MacroBadge(this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(label,
        style: TextStyle(color: color,
            fontSize: 10, fontWeight: FontWeight.bold)),
  );
}

// ── Meal Form ─────────────────────────────────────────────────────────────────
class _MealForm extends StatefulWidget {
  final _Meal?  meal;
  final Future<void> Function(Map<String, dynamic>) onSave;
  const _MealForm({this.meal, required this.onSave});
  @override State<_MealForm> createState() => _MealFormState();
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
    _prot  = TextEditingController(text: m != null ? '${m.protein}' : '');
    _carbs = TextEditingController(text: m != null ? '${m.carbs}' : '');
    _fat   = TextEditingController(text: m != null ? '${m.fat}' : '');
  }

  @override
  void dispose() {
    for (final c in [_name, _desc, _cal, _prot, _carbs, _fat]) c.dispose();
    super.dispose();
  }

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
        content: Text(e.toString()),
        backgroundColor: const Color(0xFFFF4757),
        behavior: SnackBarBehavior.floating,
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
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 18),
              Text(widget.meal == null ? 'Add New Meal' : 'Edit Meal',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 20),

              _field(_name,  'Meal Name *',     isDark, required: true),
              const SizedBox(height: 10),
              _field(_desc,  'Description',     isDark),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _field(_cal,   'Calories *', isDark,
                    num: true, required: true)),
                const SizedBox(width: 10),
                Expanded(child: _field(_prot,  'Protein (g) *', isDark,
                    num: true, required: true)),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _field(_carbs, 'Carbs (g) *', isDark,
                    num: true, required: true)),
                const SizedBox(width: 10),
                Expanded(child: _field(_fat,   'Fat (g) *', isDark,
                    num: true, required: true)),
              ]),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4361EE),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: _saving
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(
                          widget.meal == null ? 'Add Meal' : 'Save Changes',
                          style: const TextStyle(color: Colors.white,
                              fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, bool isDark,
      {bool num = false, bool required = false}) =>
      TextFormField(
        controller: ctrl,
        keyboardType: num ? TextInputType.number : TextInputType.text,
        style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1A1A2E)),
        validator: (v) {
          if (required && (v == null || v.trim().isEmpty)) return 'Required';
          if (num && v != null && v.isNotEmpty &&
              double.tryParse(v) == null) return 'Must be a number';
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
              color: isDark ? Colors.white38 : Colors.grey, fontSize: 13),
          filled: true,
          fillColor: isDark
              ? Colors.white.withOpacity(0.06)
              : const Color(0xFFF5F7FF),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: isDark ? Colors.white12 : Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: isDark ? Colors.white12 : Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4361EE)),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFFF4757)),
          ),
          isDense: true,
        ),
      );
}