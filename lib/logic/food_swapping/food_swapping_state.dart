import 'package:equatable/equatable.dart';
import 'package:vital_metrics/data/models/food_item.dart';

// ── Goal filter ───────────────────────────────────────────────────────────────
enum SwapGoalFilter { all, muscle, cut, vegan, energy }

extension SwapGoalFilterExt on SwapGoalFilter {
  String get label {
    switch (this) {
      case SwapGoalFilter.all:    return 'All';
      case SwapGoalFilter.muscle: return '🏋️ Muscle';
      case SwapGoalFilter.cut:    return '🔥 Cut';
      case SwapGoalFilter.vegan:  return '🌱 Vegan';
      case SwapGoalFilter.energy: return '⚡ Energy';
    }
  }
  List<String> get requiredTags {
    switch (this) {
      case SwapGoalFilter.all:    return [];
      case SwapGoalFilter.muscle: return ['high-protein'];
      case SwapGoalFilter.cut:    return ['low-calorie'];
      case SwapGoalFilter.vegan:  return ['vegan'];
      case SwapGoalFilter.energy: return ['quick-energy'];
    }
  }
}

// ── States ────────────────────────────────────────────────────────────────────
abstract class FoodSwapState extends Equatable {
  const FoodSwapState();
  @override List<Object?> get props => [];
}

class FoodSwapInitial extends FoodSwapState {
  final String? searchCategory;
  const FoodSwapInitial({this.searchCategory});
  @override List<Object?> get props => [searchCategory];
}

class FoodSwapSearching extends FoodSwapState {
  final String query;
  final List<FoodItem> results;
  final String? searchCategory;
  const FoodSwapSearching({
    required this.query,
    required this.results,
    this.searchCategory,
  });
  @override List<Object?> get props => [query, results, searchCategory];
}

class FoodSwapLoaded extends FoodSwapState {
  final FoodSwapResult result;
  final double portionGrams;
  final SwapGoalFilter activeFilter;
  final Set<String> favoriteIds;

  const FoodSwapLoaded({
    required this.result,
    this.portionGrams = 100,
    this.activeFilter = SwapGoalFilter.all,
    this.favoriteIds  = const {},
  });

  FoodSwapLoaded copyWith({
    FoodSwapResult? result,
    double? portionGrams,
    SwapGoalFilter? activeFilter,
    Set<String>? favoriteIds,
  }) => FoodSwapLoaded(
    result:       result       ?? this.result,
    portionGrams: portionGrams ?? this.portionGrams,
    activeFilter: activeFilter ?? this.activeFilter,
    favoriteIds:  favoriteIds  ?? this.favoriteIds,
  );

  List<SwapAlternative> get filteredAlternatives {
    final required = activeFilter.requiredTags;
    if (required.isEmpty) return result.alternatives;
    return result.alternatives
        .where((a) => required.every((t) => a.food.tags.contains(t)))
        .toList();
  }

  @override
  List<Object?> get props => [result, portionGrams, activeFilter, favoriteIds];
}

class FoodSwapError extends FoodSwapState {
  final String message;
  const FoodSwapError(this.message);
  @override List<Object?> get props => [message];
}