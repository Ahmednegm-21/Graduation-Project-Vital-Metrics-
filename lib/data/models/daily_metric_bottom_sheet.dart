import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:vital_metrics/data/models/daily_metric_model.dart';
import 'package:vital_metrics/core/themes/theme_context_extension.dart';

class DailyMetricBottomSheet extends StatelessWidget {
  final DateTime date;
  final DailyMetricModel? metric;

  const DailyMetricBottomSheet({
    super.key,
    required this.date,
    required this.metric,
  });

  // Static helper to show the sheet from anywhere
  static Future<void> show(
    BuildContext context, {
    required DateTime date,
    required DailyMetricModel? metric,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DailyMetricBottomSheet(date: date, metric: metric),
    );
  }

  // Format DateTime to readable string like "Sat, May 30, 2026"
  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  // Convert total minutes to readable format like "7h 30m"
  String _formatSleep(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bg = isDark ? const Color(0xFF1A2340) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subColor = isDark ? Colors.white54 : const Color(0xFF7B8299);
    const primary = Color(0xFF4361EE);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.10),
            blurRadius: 30,
          ),
        ],
      ),
      // Add bottom padding to avoid system nav bar overlap
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle bar at top of sheet
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header row showing selected date and summary label
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calendar_today_rounded,
                    color: primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(date),
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Daily Summary',
                      style: TextStyle(color: subColor, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Show empty state if no data exists for the selected date
          if (metric == null)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 20,
              ),
              child: Column(
                children: [
                  Icon(
                    CupertinoIcons.calendar_badge_minus,
                    size: 52,
                    color: subColor,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'No data for this day',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Start logging to see your daily summary here.',
                    style: TextStyle(color: subColor, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            // Metric cards grid when data is available
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // First row: Calories consumed and Water intake
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          icon: Icons.local_fire_department_rounded,
                          iconColor: const Color(0xFFFF9500),
                          label: 'Calories',
                          value: '${metric!.caloriesConsumed}',
                          unit: 'kcal',
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricCard(
                          icon: Icons.water_drop_rounded,
                          iconColor: const Color(0xFF4FC3FF),
                          label: 'Water',
                          value: '${metric!.totalWaterMl}',
                          unit: 'ml',
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Second row: Steps count and Sleep duration
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          icon: Icons.directions_walk_rounded,
                          iconColor: const Color(0xFF34C759),
                          label: 'Steps',
                          value: '${metric!.totalSteps}',
                          unit: 'steps',
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricCard(
                          icon: Icons.bedtime_rounded,
                          iconColor: const Color(0xFF9B59B6),
                          label: 'Sleep',
                          value: _formatSleep(metric!.totalSleepMinutes),
                          unit: '',
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Third row: Calories burned shown full width
                  _MetricCard(
                    icon: Icons.bolt_rounded,
                    iconColor: const Color(0xFFFF6B6B),
                    label: 'Calories Burned',
                    value: '${metric!.burnedTotal}',
                    unit: 'kcal',
                    isDark: isDark,
                    fullWidth: true,
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// Single metric display card used inside the bottom sheet
class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String unit;
  final bool isDark;

  // When true the card spans full width with horizontal layout
  final bool fullWidth;

  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.unit,
    required this.isDark,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark
        ? const Color(0xFF0F1629)
        : const Color(0xFFF5F7FF);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subColor = isDark ? Colors.white38 : const Color(0xFF9B9B9B);

    // Icon container shared by both layouts
    final iconBox = Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: iconColor, size: fullWidth ? 20 : 18),
    );

    // Value with optional unit label
    Widget valueRow = Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          value,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        if (unit.isNotEmpty) ...[
          const SizedBox(width: 3),
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              unit,
              style: TextStyle(
                color: iconColor,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withOpacity(0.15)),
      ),
      child: fullWidth
          // Horizontal layout for full-width card
          ? Row(
              children: [
                iconBox,
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(color: subColor, fontSize: 11),
                    ),
                    const SizedBox(height: 2),
                    valueRow,
                  ],
                ),
              ],
            )
          // Vertical layout for half-width card
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                iconBox,
                const SizedBox(height: 10),
                Text(
                  label,
                  style: TextStyle(color: subColor, fontSize: 11),
                ),
                const SizedBox(height: 2),
                valueRow,
              ],
            ),
    );
  }
}