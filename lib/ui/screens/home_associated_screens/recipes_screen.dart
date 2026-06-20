// lib/ui/screens/.../recipes_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vital_metrics/core/themes/theme_context_extension.dart';
import 'package:vital_metrics/data/models/recipe.dart';
import 'package:vital_metrics/data/repositories/meal_repository.dart';
import 'package:vital_metrics/data/repositories/consumed_meal_repository.dart';
import 'package:vital_metrics/logic/home/calorie_cubit.dart';
import 'package:vital_metrics/logic/home/locale_cubit.dart';
import 'package:vital_metrics/ui/widgets/home_widgets/voice_search_button.dart';
import 'meal_detail_screen.dart';

class RecipesScreen extends StatefulWidget {
  final String? mealType;
  const RecipesScreen({super.key, this.mealType});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  String _selectedFilter = 'ALL';
  String? _mealType;

  final Map<String, double> _servings = {};
  final Set<String> _chosen = {};

  List<Recipe> _recipes = [];
  bool _loading = true;
  bool _isRealData = false;

  late final AnimationController _fabCtrl;
  late final Animation<double> _fabAnim;

  final MealRepository _mealRepo = MealRepository();
  final ConsumedMealRepository _consumedRepo = ConsumedMealRepository();

  static const _filters = ['ALL', 'breakfast', 'lunch', 'dinner', 'snacks'];

  @override
  void initState() {
    super.initState();
    _mealType = widget.mealType;
    if (_mealType != null) _selectedFilter = _mealType!;

    _fabCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _fabAnim = CurvedAnimation(parent: _fabCtrl, curve: Curves.easeOutBack);

    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    setState(() => _loading = true);
    try {
      const pageSize = 100;
      final allMeals = [];
      int page = 1;

      while (true) {
        final batch = await _mealRepo.getMeals(page: page, limit: pageSize);
        if (batch.isEmpty) break;
        allMeals.addAll(batch);
        if (batch.length < pageSize) break;
        page++;
      }

      if (allMeals.isNotEmpty) {
        setState(() {
          _recipes = allMeals.map((m) => Recipe.fromMealModel(m)).toList();
          _isRealData = true;
          _loading = false;
        });
      } else {
        setState(() {
          _recipes = Recipe.sampleRecipes;
          _isRealData = false;
          _loading = false;
        });
      }
    } catch (_) {
      setState(() {
        _recipes = Recipe.sampleRecipes;
        _isRealData = false;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _fabCtrl.dispose();
    super.dispose();
  }

  // normalize — strip diacritics, unify alef/taa marbuta/yaa
  static String _norm(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '')
      .replaceAll(RegExp(r'[أإآٱ]'), 'ا')
      .replaceAll(RegExp(r'ة'), 'ه')
      .replaceAll(RegExp(r'ى'), 'ي')
      .replaceAll(RegExp(r'[،,.\-_]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  static bool _fuzzy(String name, String q) {
    if (name.contains(q)) return true;
    final words = q.split(' ').where((w) => w.length >= 2).toList();
    if (words.isEmpty) return false;
    return words.every((w) => name.contains(w));
  }

  // Search matches against both Arabic and English names
  List<Recipe> get _filtered => _recipes.where((r) {
        final matchCat =
            _selectedFilter == 'ALL' || r.category == _selectedFilter;
        if (!matchCat) return false;
        if (_query.isEmpty) return true;
        final q = _norm(_query);
        final matchesArabic = _fuzzy(_norm(r.name), q);
        final matchesEnglish =
            r.nameEn.isNotEmpty && _fuzzy(_norm(r.nameEn), q);
        return matchesArabic || matchesEnglish;
      }).toList();

  double _mult(String id) => _servings[id] ?? 1.0;
  int _kcal(Recipe r) => (r.calories * _mult(r.id)).round();
  int _protein(Recipe r) => (r.protein * _mult(r.id)).round();
  int _carbs(Recipe r) => (r.carbs * _mult(r.id)).round();
  int _fat(Recipe r) => (r.fat * _mult(r.id)).round();

  void _setMult(String id, double v) =>
      setState(() => _servings[id] = v.clamp(0.25, 5.0));

  void _toggle(String id) {
    setState(() {
      _chosen.contains(id) ? _chosen.remove(id) : _chosen.add(id);
    });
    _chosen.isNotEmpty ? _fabCtrl.forward() : _fabCtrl.reverse();
  }

  Future<void> _addSelected() async {
    final isArabic = context.read<LocaleCubit>().state;
    final chosen = Set<String>.from(_chosen);

    for (final id in chosen) {
      final r = _recipes.firstWhere((r) => r.id == id);
      final mealId = int.tryParse(id);

      if (_isRealData && mealId != null && mealId > 0) {
        try {
          await _consumedRepo.addMeal(mealId: mealId);
        } catch (e) {
          debugPrint('[RecipesScreen] consumed-meals POST failed for $id: $e');
        }
      }

      context.read<CalorieCubit>().addMeal(
            MealEntry(
              name: r.displayName(isArabic: isArabic),
              calories: _kcal(r),
              protein: _protein(r),
              carbs: _carbs(r),
              fat: _fat(r),
              mealType: _mealType ?? r.category,
            ),
          );
    }

    final total = chosen.fold(0, (s, id) {
      final r = _recipes.firstWhere((r) => r.id == id);
      return s + _kcal(r);
    });
    final count = chosen.length;

    setState(() => _chosen.clear());
    _fabCtrl.reverse();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$count meal${count > 1 ? 's' : ''} added · +$total kcal'),
        backgroundColor: const Color(0xFF4361EE),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _openDetail(Recipe recipe) async {
    final isArabic = context.read<LocaleCubit>().state;
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 430),
        reverseTransitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (_, __, ___) => MealDetailScreen(
          recipe: recipe,
          isArabic: isArabic,
          mealType: _mealType,
          initiallySelected: _chosen.contains(recipe.id),
        ),
        transitionsBuilder: (_, anim, __, child) {
          final c = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(c),
            child: FadeTransition(opacity: c, child: child),
          );
        },
      ),
    );
    if (result != null && mounted) {
      final action = result['action'] as String?;
      final id = result['id'] as String?;
      if (id != null) {
        setState(() {
          if (action == 'select') _chosen.add(id);
          if (action == 'deselect') _chosen.remove(id);
        });
        _chosen.isNotEmpty ? _fabCtrl.forward() : _fabCtrl.reverse();
      }
    }
  }

  // voice callback
  void _onVoiceResult(String text) {
    final cleaned = text.trim().replaceAll(RegExp(r'[،,.]'), '');
    // notifyListeners manually since onChanged doesn't fire on programmatic text changes
    _searchCtrl.value = _searchCtrl.value.copyWith(
      text: cleaned,
      selection: TextSelection.collapsed(offset: cleaned.length),
    );
    setState(() => _query = cleaned);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final isArabic = context.watch<LocaleCubit>().state;
    final hasSel = _chosen.isNotEmpty;
    const primary = Color(0xFF4361EE);
    const fabBottomPadding = 80.0 + 48.0;

    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _mealType != null
            ? GestureDetector(
                onTap: () => context.pop(),
                child: const Icon(
                  CupertinoIcons.chevron_left,
                  color: primary,
                  size: 22,
                ),
              )
            : null,
        centerTitle: true,
        title: Text(
          'Healthy Recipes',
          style: TextStyle(
            color: context.colors.text,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          _BellAction(isDark: isDark),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => context.push('/settings'),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.colors.card,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: context.colors.shadow, blurRadius: 8),
                  ],
                ),
                child: const Icon(Icons.settings, color: primary, size: 20),
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF4361EE),
                strokeWidth: 2,
              ),
            )
          : Stack(
              children: [
                Column(
                  children: [
                    // Search bar + mic
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: context.colors.card,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: context.colors.shadow,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: (v) => setState(() => _query = v),
                          style: TextStyle(color: context.colors.text),
                          decoration: InputDecoration(
                            hintText: 'Search recipes',
                            hintStyle:
                                TextStyle(color: context.colors.subText),
                            prefixIcon: const Icon(
                              CupertinoIcons.search,
                              color: primary,
                            ),
                            suffixIcon: _query.isNotEmpty
                                ? GestureDetector(
                                    onTap: () {
                                      _searchCtrl.clear();
                                      setState(() => _query = '');
                                    },
                                    child: Icon(
                                      CupertinoIcons.xmark_circle_fill,
                                      color: context.colors.subText,
                                      size: 18,
                                    ),
                                  )
                                : VoiceSearchButton(
                                    onResult: _onVoiceResult,
                                    idleColor: context.colors.subText,
                                  ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Filter chips
                    SizedBox(
                      height: 42,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: _filters.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final f = _filters[i];
                          final sel = _selectedFilter == f;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedFilter = f),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOutCubic,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: sel ? primary : context.colors.card,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: sel
                                    ? [
                                        BoxShadow(
                                          color:
                                              primary.withOpacity(0.35),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Text(
                                f.toUpperCase(),
                                style: TextStyle(
                                  color: sel
                                      ? Colors.white
                                      : context.colors.subText,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Header row
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Suggestions',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: context.colors.text,
                            ),
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: hasSel
                                ? Text(
                                    '${_chosen.length} selected',
                                    key: const ValueKey('c'),
                                    style: const TextStyle(
                                      color: primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  )
                                : const SizedBox.shrink(
                                    key: ValueKey('e')),
                          ),
                        ],
                      ),
                    ),

                    // Recipe list
                    Expanded(
                      child: RefreshIndicator(
                        color: primary,
                        onRefresh: _loadRecipes,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: fabBottomPadding + 64,
                          ),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) {
                            final recipe = _filtered[i];
                            final isChosen = _chosen.contains(recipe.id);
                            return _RecipeTile(
                              key: ValueKey(recipe.id),
                              recipe: recipe,
                              isArabic: isArabic,
                              isChosen: isChosen,
                              isDark: isDark,
                              mult: _mult(recipe.id),
                              kcal: _kcal(recipe),
                              protein: _protein(recipe),
                              carbs: _carbs(recipe),
                              fat: _fat(recipe),
                              index: i,
                              onToggle: () => _toggle(recipe.id),
                              onDetails: () => _openDetail(recipe),
                              onMultChange: (v) =>
                                  _setMult(recipe.id, v),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                // FAB
                Positioned(
                  bottom: fabBottomPadding,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ScaleTransition(
                      scale: _fabAnim,
                      child: GestureDetector(
                        onTap: hasSel ? _addSelected : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 28, vertical: 16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF4361EE),
                                Color(0xFF4CC9F0)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4361EE)
                                    .withOpacity(0.45),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                CupertinoIcons.add_circled_solid,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Add ${_chosen.length} Meal${_chosen.length > 1 ? 's' : ''}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// remaining widgets

class _RecipeTile extends StatefulWidget {
  final Recipe recipe;
  final bool isChosen, isDark, isArabic;
  final double mult;
  final int kcal, protein, carbs, fat, index;
  final VoidCallback onToggle, onDetails;
  final ValueChanged<double> onMultChange;

  const _RecipeTile({
    super.key,
    required this.recipe,
    required this.isChosen,
    required this.isDark,
    required this.isArabic,
    required this.mult,
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.index,
    required this.onToggle,
    required this.onDetails,
    required this.onMultChange,
  });

  @override
  State<_RecipeTile> createState() => _RecipeTileState();
}

class _RecipeTileState extends State<_RecipeTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeAnim, _slideAnim, _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _slideAnim = Tween(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    _scaleAnim = Tween(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );
    final delay = (50 * widget.index).clamp(0, 800);
    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _showServingSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ServingSheet(
        recipe: widget.recipe,
        isDark: widget.isDark,
        isArabic: widget.isArabic,
        initMult: widget.mult,
        onConfirm: (v) {
          widget.onMultChange(v);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF4361EE);
    final isDark = widget.isDark;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Opacity(
        opacity: _fadeAnim.value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, _slideAnim.value),
          child: Transform.scale(
            scale: _scaleAnim.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOut,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: widget.isChosen
                    ? primary.withOpacity(isDark ? 0.20 : 0.07)
                    : context.colors.card,
                borderRadius: BorderRadius.circular(16),
                border: widget.isChosen
                    ? Border.all(
                        color: primary.withOpacity(0.38), width: 1.5)
                    : (isDark
                        ? Border.all(
                            color: Colors.white.withOpacity(0.05),
                            width: 1)
                        : null),
                boxShadow: [
                  BoxShadow(
                    color: widget.isChosen
                        ? primary.withOpacity(isDark ? 0.25 : 0.12)
                        : context.colors.shadow,
                    blurRadius: widget.isChosen ? 14 : 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: widget.onToggle,
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(12, 12, 0, 12),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              AnimatedOpacity(
                                opacity: widget.isChosen ? 1.0 : 0.0,
                                duration:
                                    const Duration(milliseconds: 280),
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            primary.withOpacity(0.38),
                                        blurRadius: 14,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              AnimatedContainer(
                                duration:
                                    const Duration(milliseconds: 280),
                                curve: Curves.easeOutBack,
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: widget.isChosen
                                      ? primary
                                      : context.colors.iconBtnBg,
                                  shape: BoxShape.circle,
                                ),
                                child: AnimatedSwitcher(
                                  duration:
                                      const Duration(milliseconds: 230),
                                  transitionBuilder: (child, anim) =>
                                      ScaleTransition(
                                          scale: anim, child: child),
                                  child: Icon(
                                    widget.isChosen
                                        ? CupertinoIcons.checkmark_alt
                                        : CupertinoIcons.add,
                                    key: ValueKey(widget.isChosen),
                                    color: widget.isChosen
                                        ? Colors.white
                                        : primary,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(widget.recipe.emoji,
                          style: const TextStyle(fontSize: 26)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.recipe.displayName(
                                    isArabic: widget.isArabic),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: context.colors.text,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  AnimatedSwitcher(
                                    duration: const Duration(
                                        milliseconds: 250),
                                    transitionBuilder: (child, anim) =>
                                        FadeTransition(
                                            opacity: anim, child: child),
                                    child: Container(
                                      key: ValueKey(widget.kcal),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color:
                                            primary.withOpacity(0.10),
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '${widget.kcal} kcal',
                                        style: const TextStyle(
                                          color: primary,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: AnimatedSwitcher(
                                      duration: const Duration(
                                          milliseconds: 200),
                                      child: Text(
                                        _servingLabel(),
                                        key: ValueKey(widget.mult),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: context.colors.subText,
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
                      IntrinsicWidth(
                        child: _ServingStepper(
                          mult: widget.mult,
                          isDark: isDark,
                          onTap: () => _showServingSheet(context),
                          onMinus: () =>
                              widget.onMultChange(widget.mult - 0.25),
                          onPlus: () =>
                              widget.onMultChange(widget.mult + 0.25),
                        ),
                      ),
                      Container(
                          width: 1,
                          height: 40,
                          color: context.colors.divider),
                      GestureDetector(
                        onTap: widget.onDetails,
                        behavior: HitTestBehavior.opaque,
                        child: const SizedBox(
                          width: 44,
                          height: 60,
                          child: Center(
                            child: Icon(CupertinoIcons.chevron_right,
                                color: primary, size: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    child: widget.mult != 1.0
                        ? _MacrosStrip(
                            protein: widget.protein,
                            carbs: widget.carbs,
                            fat: widget.fat,
                            isDark: isDark,
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _servingLabel() {
    if (widget.mult == 1.0) return widget.recipe.servingSize;
    final orig = widget.recipe.servingSize;
    final numMatch = RegExp(r'(\d+\.?\d*)').firstMatch(orig);
    if (numMatch != null) {
      final base =
          double.tryParse(numMatch.group(1) ?? '') ?? 100.0;
      final unit = orig.replaceAll(numMatch.group(0)!, '').trim();
      final newVal = (base * widget.mult).round();
      return '$newVal $unit';
    }
    return '×${widget.mult.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '')}';
  }
}

class _ServingStepper extends StatelessWidget {
  final double mult;
  final bool isDark;
  final VoidCallback onTap, onMinus, onPlus;

  const _ServingStepper({
    required this.mult,
    required this.isDark,
    required this.onTap,
    required this.onMinus,
    required this.onPlus,
  });

  static String _multLabel(double m) {
    if (m == 1.0) return '1×';
    if (m == 0.25) return '¼×';
    if (m == 0.5) return '½×';
    return m % 1 == 0
        ? '${m.toInt()}×'
        : '${m.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '')}×';
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF4361EE);
    final bg =
        isDark ? const Color(0xFF1E2D4A) : const Color(0xFFF0F3FF);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: primary.withOpacity(0.20), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StepBtn(
                icon: CupertinoIcons.minus,
                onTap: mult > 0.25 ? onMinus : null,
                primary: primary),
            GestureDetector(
              onTap: onTap,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Text(_multLabel(mult),
                    key: ValueKey(mult),
                    style: const TextStyle(
                        color: primary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ),
            ),
            _StepBtn(
                icon: CupertinoIcons.plus,
                onTap: mult < 5.0 ? onPlus : null,
                primary: primary),
          ],
        ),
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color primary;

  const _StepBtn(
      {required this.icon, required this.onTap, required this.primary});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedOpacity(
          opacity: onTap != null ? 1.0 : 0.30,
          duration: const Duration(milliseconds: 200),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Icon(icon, color: primary, size: 13),
          ),
        ),
      );
}

class _MacrosStrip extends StatelessWidget {
  final int protein, carbs, fat;
  final bool isDark;

  const _MacrosStrip(
      {required this.protein,
      required this.carbs,
      required this.fat,
      required this.isDark});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _MacroChip(
                label: 'P',
                value: protein,
                color: const Color(0xFFFF9A3C),
                isDark: isDark),
            _MacroChip(
                label: 'C',
                value: carbs,
                color: const Color(0xFF2ECC9A),
                isDark: isDark),
            _MacroChip(
                label: 'F',
                value: fat,
                color: const Color(0xFFFF6B6B),
                isDark: isDark),
          ],
        ),
      );
}

class _MacroChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final bool isDark;

  const _MacroChip(
      {required this.label,
      required this.value,
      required this.color,
      required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(isDark ? 0.18 : 0.11),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.28), width: 1),
        ),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                  text: '$label  ',
                  style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.w800)),
              TextSpan(
                  text: '${value}g',
                  style: TextStyle(
                      color: isDark
                          ? Colors.white70
                          : const Color(0xFF2D3142),
                      fontSize: 10,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
}

class _ServingSheet extends StatefulWidget {
  final Recipe recipe;
  final bool isDark;
  final bool isArabic;
  final double initMult;
  final ValueChanged<double> onConfirm;

  const _ServingSheet(
      {required this.recipe,
      required this.isDark,
      required this.isArabic,
      required this.initMult,
      required this.onConfirm});

  @override
  State<_ServingSheet> createState() => _ServingSheetState();
}

class _ServingSheetState extends State<_ServingSheet> {
  late double _mult;

  @override
  void initState() {
    super.initState();
    _mult = widget.initMult;
  }

  int get _kcal => (widget.recipe.calories * _mult).round();
  int get _protein => (widget.recipe.protein * _mult).round();
  int get _carbs => (widget.recipe.carbs * _mult).round();
  int get _fat => (widget.recipe.fat * _mult).round();

  static const _presets = [0.25, 0.5, 1.0, 1.5, 2.0, 3.0];

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF4361EE);
    final isDark = widget.isDark;
    final bg = isDark ? const Color(0xFF1A2340) : Colors.white;
    final textCol =
        isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subCol =
        isDark ? Colors.white54 : const Color(0xFF7B8299);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.5 : 0.12),
              blurRadius: 30),
        ],
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Text(widget.recipe.emoji,
                  style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.recipe.displayName(isArabic: widget.isArabic),
                        style: TextStyle(
                            color: textCol,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    Text('Adjust serving size',
                        style:
                            TextStyle(color: subCol, fontSize: 11)),
                  ],
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: Container(
                  key: ValueKey(_kcal),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color:
                        primary.withOpacity(isDark ? 0.22 : 0.10),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: primary.withOpacity(0.35), width: 1),
                  ),
                  child: Text('$_kcal kcal',
                      style: const TextStyle(
                          color: primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 5,
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 11),
              overlayShape:
                  const RoundSliderOverlayShape(overlayRadius: 20),
              activeTrackColor: primary,
              inactiveTrackColor: isDark
                  ? Colors.white12
                  : primary.withOpacity(0.15),
              thumbColor: primary,
              overlayColor: primary.withOpacity(0.18),
              valueIndicatorColor: primary,
              valueIndicatorTextStyle: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
              showValueIndicator: ShowValueIndicator.always,
            ),
            child: Slider(
              value: _mult,
              min: 0.25,
              max: 5.0,
              divisions: 19,
              label:
                  '${_mult.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '')}×',
              onChanged: (v) => setState(() => _mult = v),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _presets.map((p) {
              final sel = (_mult - p).abs() < 0.01;
              return GestureDetector(
                onTap: () => setState(() => _mult = p),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: sel
                        ? primary
                        : primary
                            .withOpacity(isDark ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: sel
                            ? primary
                            : primary.withOpacity(0.25)),
                  ),
                  child: Text(
                    p == 0.25
                        ? '¼×'
                        : p == 0.5
                            ? '½×'
                            : '${p.toInt()}×',
                    style: TextStyle(
                        color: sel ? Colors.white : primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _SheetMacro(
                  label: 'Protein',
                  value: _protein,
                  color: const Color(0xFFFF9A3C),
                  isDark: isDark),
              _SheetMacro(
                  label: 'Carbs',
                  value: _carbs,
                  color: const Color(0xFF2ECC9A),
                  isDark: isDark),
              _SheetMacro(
                  label: 'Fat',
                  value: _fat,
                  color: const Color(0xFFFF6B6B),
                  isDark: isDark),
            ],
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => widget.onConfirm(_mult),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4361EE), Color(0xFF4CC9F0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: primary.withOpacity(0.38),
                      blurRadius: 16,
                      offset: const Offset(0, 6)),
                ],
              ),
              child: const Center(
                child: Text('Confirm Serving',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetMacro extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final bool isDark;

  const _SheetMacro(
      {required this.label,
      required this.value,
      required this.color,
      required this.isDark});

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: Column(
          key: ValueKey(value),
          children: [
            Text('${value}g',
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                    color: isDark
                        ? Colors.white38
                        : const Color(0xFF9B9B9B),
                    fontSize: 11)),
          ],
        ),
      );
}

class _BellAction extends StatelessWidget {
  final bool isDark;
  const _BellAction({required this.isDark});
  static const int _unread = 3;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => context.push('/notifications'),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.colors.card,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: context.colors.shadow, blurRadius: 8)
                ],
              ),
              child: Icon(CupertinoIcons.bell_fill,
                  color: isDark
                      ? const Color(0xFFFFA94D)
                      : const Color(0xFF4361EE),
                  size: 20),
            ),
            if (_unread > 0)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4757),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: isDark
                            ? const Color(0xFF0F1221)
                            : const Color(0xFFF0F3FF),
                        width: 1.5),
                  ),
                  child: const Text('$_unread',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      );
}