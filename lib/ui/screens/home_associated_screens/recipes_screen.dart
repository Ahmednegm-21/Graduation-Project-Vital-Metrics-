import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:vital_metrics/core/themes/theme_context_extension.dart';
import 'package:vital_metrics/data/models/recipe.dart';
import 'package:vital_metrics/logic/home/calorie_cubit.dart';

class RecipesScreen extends StatefulWidget {
  final String? mealType;
  const RecipesScreen({super.key, this.mealType});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery    = '';
  String _selectedFilter = 'ALL';
  String? _mealType;

  final List<String> _filters = ['ALL', 'breakfast', 'lunch', 'dinner', 'snacks'];

  @override
  void initState() {
    super.initState();
    _mealType = widget.mealType;
    if (_mealType != null) _selectedFilter = _mealType!;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Recipe> get _filtered => Recipe.sampleRecipes.where((r) {
    final matchFilter = _selectedFilter == 'ALL' || r.category == _selectedFilter;
    final matchSearch = _searchQuery.isEmpty ||
        r.name.toLowerCase().contains(_searchQuery.toLowerCase());
    return matchFilter && matchSearch;
  }).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _mealType != null
            ? GestureDetector(
                onTap: () => context.pop(),
                child: const Icon(Icons.chevron_left, color: Color(0xFF4361EE), size: 28),
              )
            : null,
        centerTitle: true,
        title: Text('Healthy Recipes',
            style: TextStyle(
                color: context.colors.text, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => context.push('/settings'),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.colors.card,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: context.colors.shadow, blurRadius: 8)],
                ),
                child: const Icon(Icons.settings, color: Color(0xFF4361EE), size: 20),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search ────────────────────────────────────────────────────────
          FadeInDown(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: context.colors.card,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: context.colors.shadow, blurRadius: 10)],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: TextStyle(color: context.colors.text),
                  decoration: InputDecoration(
                    hintText: 'Search recipes',
                    hintStyle: TextStyle(color: context.colors.subText),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF4361EE)),
                    suffixIcon: Icon(Icons.mic, color: context.colors.subText, size: 20),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),
          ),

          // ── Filters ───────────────────────────────────────────────────────
          FadeInDown(
            delay: const Duration(milliseconds: 100),
            child: SizedBox(
              height: 42,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final f          = _filters[i];
                  final isSelected = _selectedFilter == f;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF4361EE) : context.colors.card,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isSelected
                            ? [BoxShadow(
                                color: const Color(0xFF4361EE).withOpacity(0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 3))]
                            : [],
                      ),
                      child: Text(
                        f.toUpperCase(),
                        style: TextStyle(
                          color: isSelected ? Colors.white : context.colors.subText,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ── Label ─────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Suggestions',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: context.colors.text)),
            ),
          ),

          // ── List ──────────────────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              itemCount: _filtered.length,
              itemBuilder: (_, i) => FadeInLeft(
                delay: Duration(milliseconds: 50 * i),
                duration: const Duration(milliseconds: 400),
                child: _RecipeTile(recipe: _filtered[i], mealType: _mealType),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeTile extends StatefulWidget {
  final Recipe recipe;
  final String? mealType;
  const _RecipeTile({required this.recipe, this.mealType});

  @override
  State<_RecipeTile> createState() => _RecipeTileState();
}

class _RecipeTileState extends State<_RecipeTile> {
  bool _added = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _onAdd(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: _added
              ? const Color(0xFF4361EE).withOpacity(context.isDark ? 0.25 : 0.08)
              : context.colors.card,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: context.colors.shadow,
                blurRadius: 8,
                offset: const Offset(0, 3))
          ],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: _added ? const Color(0xFF4361EE) : context.colors.iconBtnBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _added ? Icons.check : Icons.add,
                color: _added ? Colors.white : const Color(0xFF4361EE),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text(widget.recipe.emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.recipe.name,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: context.colors.text)),
                  const SizedBox(height: 2),
                  Text('${widget.recipe.calories} kcal · ${widget.recipe.servingSize}',
                      style: TextStyle(fontSize: 11, color: context.colors.subText)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: context.colors.subText, size: 20),
          ],
        ),
      ),
    );
  }

  void _onAdd(BuildContext context) {
    final mealType = widget.mealType ?? widget.recipe.category;
    context.read<CalorieCubit>().addMeal(MealEntry(
      name:     widget.recipe.name,
      calories: widget.recipe.calories,
      protein:  widget.recipe.protein,
      carbs:    widget.recipe.carbs,
      fat:      widget.recipe.fat,
      mealType: mealType,
    ));
    setState(() => _added = true);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${widget.recipe.name} added! +${widget.recipe.calories} kcal'),
      backgroundColor: const Color(0xFF4361EE),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    ));
  }
}