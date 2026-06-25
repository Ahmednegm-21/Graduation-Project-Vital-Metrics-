import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vital_metrics/data/models/food_item.dart';
import 'package:vital_metrics/logic/food_swapping/food_swapping_state.dart';
import 'package:vital_metrics/services/food_swap_service.dart';

class FoodSwapCubit extends Cubit<FoodSwapState> {
  final FoodSwapService _service;
  final String userGoal;

  Set<String> _favoriteIds   = {};
  String?     _searchCategory;
  String      _lastQuery     = '';

  FoodSwapCubit({
    FoodSwapService? service,
    this.userGoal = 'maintain',
  })  : _service = service ?? FoodSwapService(),
        super(const FoodSwapInitial()) {
    _loadFavorites();
  }

  // ── Category filter ───────────────────────────────────────────────────────

  void setSearchCategory(String? category) {
    _searchCategory = category;

    if (category == null) {
      if (_lastQuery.isEmpty) {
        emit(const FoodSwapInitial());
      } else {
        search(_lastQuery);
      }
      return;
    }

    _searchWithCategory(_lastQuery);
  }

  // ── Search ────────────────────────────────────────────────────────────────

  void search(String query) {
    _lastQuery = query;

    if (query.trim().isEmpty && _searchCategory == null) {
      emit(FoodSwapInitial(searchCategory: _searchCategory));
      return;
    }

    _searchWithCategory(query);
  }

  Future<void> _searchWithCategory(String query) async {
    await _service.ensureLoaded();

    final localResults = _service.search(
      query,
      categoryId: _searchCategory,  
    );

    emit(FoodSwapSearching(
      query:          query,
      results:        localResults,
      searchCategory: _searchCategory,
    ));

    if (query.trim().isNotEmpty) {
      _service.searchFromBackend(query).then((backendResults) {
        if (backendResults.isNotEmpty && !isClosed) {
          final filtered = _searchCategory != null
              ? backendResults
                  .where((f) => _service.matchesCategoryId(f, _searchCategory!))
                  .toList()
              : backendResults;

          emit(FoodSwapSearching(
            query:          query,
            results:        filtered,
            searchCategory: _searchCategory,
          ));
        }
      }).catchError((_) {});
    }
  }

  // ── Select food ───────────────────────────────────────────────────────────

  void selectFood(FoodItem food) {
    final localResult = _service.getSwaps(food, userGoal);
    emit(FoodSwapLoaded(
      result:      localResult,
      favoriteIds: _favoriteIds,
    ));

    _service.getSwapsFromBackend(food, userGoal).then((backendResult) {
      if (!isClosed && backendResult.alternatives.isNotEmpty) {
        final current = state;
        if (current is FoodSwapLoaded) {
          emit(current.copyWith(result: backendResult));
        }
      }
    }).catchError((_) {});
  }

  void reset() {
    _lastQuery      = '';
    _searchCategory = null;
    emit(const FoodSwapInitial());
  }

  void clearCategory() {
    _searchCategory = null;
    if (_lastQuery.isEmpty) {
      emit(const FoodSwapInitial());
    } else {
      search(_lastQuery);
    }
  }

  // ── Portion ───────────────────────────────────────────────────────────────

  void updatePortion(double grams) {
    final s = state;
    if (s is! FoodSwapLoaded) return;
    emit(s.copyWith(portionGrams: grams));
  }

  // ── Goal filter ───────────────────────────────────────────────────────────

  void setFilter(SwapGoalFilter filter) {
    final s = state;
    if (s is! FoodSwapLoaded) return;
    emit(s.copyWith(activeFilter: filter));
  }

  // ── Favorites ─────────────────────────────────────────────────────────────

  Future<void> toggleFavorite(String foodId) async {
    final updated = Set<String>.from(_favoriteIds);
    updated.contains(foodId) ? updated.remove(foodId) : updated.add(foodId);
    _favoriteIds = updated;
    await _persistFavorites();

    final s = state;
    if (s is FoodSwapLoaded) emit(s.copyWith(favoriteIds: updated));
  }

  bool isFavorite(String foodId) => _favoriteIds.contains(foodId);

  List<FoodItem> getFavoriteItems() => _favoriteIds
      .map((id) => _service.findById(id))
      .whereType<FoodItem>()
      .toList();

  Future<void> loadFavorites() => _loadFavorites();

  Future<void> _loadFavorites() async {
    final prefs  = await SharedPreferences.getInstance();
    final raw    = prefs.getStringList('swap_favorites') ?? [];
    _favoriteIds = raw.toSet();
    final s = state;
    if (s is FoodSwapLoaded) emit(s.copyWith(favoriteIds: _favoriteIds));
  }

  Future<void> _persistFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('swap_favorites', _favoriteIds.toList());
  }

  String? get searchCategory => _searchCategory;
}