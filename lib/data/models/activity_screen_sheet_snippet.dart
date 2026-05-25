import 'package:vital_metrics/core/imports.dart';
import 'package:vital_metrics/data/models/activity_level.dart';
import 'package:vital_metrics/data/models/activity_level_card.dart';
import 'package:vital_metrics/logic/activity/activity_cubit.dart';

void _showActivityLevelSheet(
  BuildContext context,
  ActivityLevel currentLevel,
  ActivityCubit cubit,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => ActivityLevelDetailSheet(
      currentLevel: currentLevel,
      onLevelSelected: (level) {
        cubit.changeActivityLevel(level);
        Navigator.pop(context);
      },
    ),
  );
}