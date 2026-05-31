import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:vital_metrics/core/themes/theme_context_extension.dart';
import 'admin_dashboard_screen.dart';
import 'admin_users_screen.dart';
import 'admin_meals_screen.dart';
import 'admin_settings_screen.dart';

// ══════════════════════════════════════════════════════════════════════════════
// AdminShell
// ══════════════════════════════════════════════════════════════════════════════
class AdminShell extends StatefulWidget {
  const AdminShell({super.key});
  @override State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  static const _screens = [
    AdminDashboardScreen(),
    AdminUsersScreen(),
    AdminMealsScreen(),
    AdminSettingsScreen(),
  ];

  static const _items = [
    _Item(Icons.dashboard_outlined,      Icons.dashboard,         'Dashboard'),
    _Item(Icons.people_outline,          Icons.people,            'Users'),
    _Item(Icons.restaurant_menu_outlined,Icons.restaurant_menu,   'Meals'),
    _Item(CupertinoIcons.settings,       CupertinoIcons.settings_solid, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final cardBg = isDark ? const Color(0xFF1A2340) : Colors.white;

    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: cardBg,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
              blurRadius: 20, offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_items.length, (i) {
                final item = _items[i];
                final sel  = _index == i;
                return GestureDetector(
                  onTap: () => setState(() => _index = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel
                          ? const Color(0xFF4361EE).withOpacity(0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          sel ? item.activeIcon : item.icon,
                          color: sel
                              ? const Color(0xFF4361EE)
                              : (isDark ? Colors.white38 : Colors.black38),
                          size: 22,
                        ),
                        const SizedBox(height: 4),
                        Text(item.label,
                            style: TextStyle(
                              color: sel
                                  ? const Color(0xFF4361EE)
                                  : (isDark ? Colors.white38 : Colors.black38),
                              fontSize: 10,
                              fontWeight: sel
                                  ? FontWeight.bold : FontWeight.normal,
                            )),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _Item {
  final IconData icon, activeIcon;
  final String   label;
  const _Item(this.icon, this.activeIcon, this.label);
}