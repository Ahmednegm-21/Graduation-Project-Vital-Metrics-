import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vital_metrics/core/themes/theme_context_extension.dart';
import 'home_screen.dart';
import 'recipes_screen.dart';
import 'progress_screen.dart';
import 'package:vital_metrics/ui/widgets/home_widgets/ai_meal_sheet.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    _Placeholder(label: 'Activities'),
    _Placeholder(label: 'AI Assistant'),
    RecipesScreen(),
    ProgressScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: context.colors.navBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(icon: Icons.home_rounded,            label: 'Today',      index: 0, current: _currentIndex, onTap: () => setState(() => _currentIndex = 0)),
                _NavItem(icon: Icons.directions_walk_rounded, label: 'Activities', index: 1, current: _currentIndex, onTap: () => setState(() => _currentIndex = 1)),
                _CenterButton(onTap: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const AiMealSheet(),
                )),
                _NavItem(icon: Icons.restaurant_menu_rounded, label: 'Recipes',   index: 3, current: _currentIndex, onTap: () => setState(() => _currentIndex = 3)),
                _NavItem(icon: Icons.bar_chart_rounded,       label: 'Progress',  index: 4, current: _currentIndex, onTap: () => setState(() => _currentIndex = 4)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int current;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == current;
    const active     = Color(0xFF4361EE);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              height: 3,
              width: isSelected ? 28 : 0,
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: active,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            AnimatedScale(
              scale: isSelected ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(icon, size: 22,
                  color: isSelected ? active : context.colors.navInactive),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? active : context.colors.navInactive,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CenterButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 54, height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4361EE), Color(0xFF4CC9F0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4361EE).withOpacity(0.5),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final String label;
  const _Placeholder({required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(label,
            style: TextStyle(
                color: context.colors.text, fontWeight: FontWeight.bold)),
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
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.construction_rounded, size: 64, color: context.colors.subText),
            const SizedBox(height: 12),
            Text(label,
                style: TextStyle(
                    fontSize: 18,
                    color: context.colors.subText,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text('Coming Soon',
                style: TextStyle(
                    fontSize: 13,
                    color: context.colors.subText.withOpacity(0.6))),
          ],
        ),
      ),
    );
  }
}