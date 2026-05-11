part of 'recipes_cubit.dart';

abstract class RecipesState extends Equatable {
  const RecipesState();
  @override
  List<Object?> get props => [];
}

class RecipesInitial extends RecipesState {
  const RecipesInitial();
}

class RecipesLoading extends RecipesState {
  const RecipesLoading();
}

class RecipesLoaded extends RecipesState {
  final List<MealModel> meals;
  final Set<int>        selectedIds;    // meal_id of selected meals
  final String          query;
  final String          categoryFilter;
  final bool            isAdding;       // true while POST /consumed-meals in flight
  final bool            isLocalData;    // true = showing local fallback

  const RecipesLoaded({
    required this.meals,
    this.selectedIds    = const {},
    this.query          = '',
    this.categoryFilter = 'ALL',
    this.isAdding       = false,
    this.isLocalData    = false,
  });

  // ── Filter helpers ─────────────────────────────────────────────────────────
  List<MealModel> get filtered {
    return meals.where((m) {
      final matchCat = categoryFilter == 'ALL' ||
          _guessCategory(m.name) == categoryFilter;
      final matchQ = query.isEmpty ||
          m.name.toLowerCase().contains(query.toLowerCase());
      return matchCat && matchQ;
    }).toList();
  }

  // Guess category from meal name — same logic as before
  static String _guessCategory(String name) {
    final n = name.toLowerCase();
    if (n.contains('oat') || n.contains('egg') || n.contains('toast') ||
        n.contains('yogurt') || n.contains('smoothie') ||
        n.contains('pancake') || n.contains('cereal'))   return 'breakfast';
    if (n.contains('steak') || n.contains('chicken') ||
        n.contains('salmon') || n.contains('pasta') ||
        n.contains('pizza') || n.contains('burger') ||
        n.contains('ravioli'))                           return 'dinner';
    if (n.contains('bar') || n.contains('nut') ||
        n.contains('chocolate') || n.contains('cookie') ||
        n.contains('moo') || n.contains('snack'))        return 'snacks';
    return 'lunch';
  }

  RecipesLoaded copyWith({
    List<MealModel>? meals,
    Set<int>?        selectedIds,
    String?          query,
    String?          categoryFilter,
    bool?            isAdding,
    bool?            isLocalData,
  }) =>
      RecipesLoaded(
        meals:          meals          ?? this.meals,
        selectedIds:    selectedIds    ?? this.selectedIds,
        query:          query          ?? this.query,
        categoryFilter: categoryFilter ?? this.categoryFilter,
        isAdding:       isAdding       ?? this.isAdding,
        isLocalData:    isLocalData    ?? this.isLocalData,
      );

  @override
  List<Object?> get props =>
      [meals, selectedIds, query, categoryFilter, isAdding, isLocalData];
}

class RecipesError extends RecipesState {
  final String message;
  const RecipesError(this.message);
  @override
  List<Object?> get props => [message];
}