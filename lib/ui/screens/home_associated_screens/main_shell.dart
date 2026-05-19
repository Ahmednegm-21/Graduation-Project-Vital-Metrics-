import 'dart:async';

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vital_metrics/core/themes/theme_context_extension.dart';

import 'package:vital_metrics/ui/screens/home_associated_screens/activity_screen.dart';
import 'package:vital_metrics/ui/widgets/home_widgets/center_fab_sheet.dart';

import 'home_screen.dart';
import 'progress_screen.dart';
import 'recipes_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // =====================================================
  // SCREENS
  // =====================================================

  final List<Widget> _screens = const [
    HomeScreen(),
    ActivityScreen(),
    RecipesScreen(),
    ProgressScreen(),
  ];

  // =====================================================
  // NAV ICONS
  // =====================================================

  static const List<IconData> _icons = [
    Icons.home_outlined,
    Icons.directions_walk_outlined,
    Icons.restaurant_menu_outlined,
    Icons.bar_chart_outlined,
  ];

  static const List<IconData> _activeIcons = [
    Icons.home_rounded,
    Icons.directions_walk_rounded,
    Icons.restaurant_menu_rounded,
    Icons.bar_chart_rounded,
  ];

  static const List<String> _labels = [
    'Today',
    'Activities',
    'Recipes',
    'Progress',
  ];

  // =====================================================
  // FAB ACTION
  // =====================================================

  void _onFabTap() {
    HapticFeedback.lightImpact();

    showCenterFabSheet(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final navBg = isDark ? const Color(0xFF1E2235) : Colors.white;

    return Scaffold(
      extendBody: true,

      backgroundColor: context.colors.bg,

      body: IndexedStack(index: _currentIndex, children: _screens),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      floatingActionButton: _AnimatedFab(onTap: _onFabTap),

      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        itemCount: 4,

        activeIndex: _currentIndex,

        gapLocation: GapLocation.center,

        notchSmoothness: NotchSmoothness.verySmoothEdge,

        leftCornerRadius: 24,

        rightCornerRadius: 24,

        backgroundColor: navBg,

        height: 66.h,

        shadow: BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.35 : 0.10),

          blurRadius: 24,

          offset: const Offset(0, -4),
        ),

        onTap: (index) {
          HapticFeedback.selectionClick();

          setState(() {
            _currentIndex = index;
          });
        },

        tabBuilder: (int index, bool isActive) {
          return _NavTab(
            icon: _icons[index],

            activeIcon: _activeIcons[index],

            label: _labels[index],

            isActive: isActive,

            isDark: isDark,
          );
        },
      ),
    );
  }
}

// =====================================================
// NAVIGATION TAB
// =====================================================

class _NavTab extends StatefulWidget {
  final IconData icon;

  final IconData activeIcon;

  final String label;

  final bool isActive;

  final bool isDark;

  const _NavTab({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.isDark,
  });

  @override
  State<_NavTab> createState() => _NavTabState();
}

class _NavTabState extends State<_NavTab> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  late Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,

      duration: const Duration(milliseconds: 380),
    );

    // Bounce animation
    _bounceAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.18,
        ).chain(CurveTween(curve: Curves.easeOut)),

        weight: 35,
      ),

      TweenSequenceItem(
        tween: Tween(
          begin: 1.18,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),

        weight: 65,
      ),
    ]).animate(_ctrl);

    if (widget.isActive) {
      _ctrl.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant _NavTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive && !oldWidget.isActive) {
      _ctrl.forward(from: 0);
    }

    if (!widget.isActive && oldWidget.isActive) {
      _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF4361EE);

    final inactiveColor = widget.isDark
        ? Colors.white.withOpacity(0.38)
        : Colors.black.withOpacity(0.35);

    return AnimatedBuilder(
      animation: _ctrl,

      builder: (_, __) {
        final t = _ctrl.value;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,

          mainAxisSize: MainAxisSize.min,

          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),

              curve: Curves.easeOut,

              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),

              decoration: BoxDecoration(
                color: Color.lerp(
                  Colors.transparent,

                  activeColor.withOpacity(widget.isDark ? 0.18 : 0.10),

                  t,
                ),

                borderRadius: BorderRadius.circular(14.r),
              ),

              child: ScaleTransition(
                scale: _bounceAnim,

                child: Stack(
                  alignment: Alignment.center,

                  children: [
                    Opacity(
                      opacity: (1 - t).clamp(0.0, 1.0),

                      child: Icon(
                        widget.icon,

                        size: 22.sp,

                        color: inactiveColor,
                      ),
                    ),

                    Opacity(
                      opacity: t.clamp(0.0, 1.0),

                      child: Icon(
                        widget.activeIcon,

                        size: 22.sp,

                        color: activeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 4.h),

            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),

              style: TextStyle(
                fontSize: 10.sp,

                fontWeight: t > 0.5 ? FontWeight.w700 : FontWeight.w400,

                color: Color.lerp(inactiveColor, activeColor, t),
              ),

              child: Text(widget.label),
            ),
          ],
        );
      },
    );
  }
}

// =====================================================
// ANIMATED CENTER FAB
// =====================================================

class _AnimatedFab extends StatefulWidget {
  final VoidCallback onTap;

  const _AnimatedFab({required this.onTap});

  @override
  State<_AnimatedFab> createState() => _AnimatedFabState();
}

class _AnimatedFabState extends State<_AnimatedFab>
    with TickerProviderStateMixin {
  late AnimationController _outCtrl;

  late AnimationController _inCtrl;

  late AnimationController _tapCtrl;

  late Animation<Offset> _outSlide;

  late Animation<double> _outFade;

  late Animation<Offset> _inSlide;

  late Animation<double> _inFade;

  late Animation<double> _inScale;

  late Animation<double> _tapScale;

  Timer? _cycleTimer;

  int _currentIndex = 0;

  bool _animating = false;

  static const List<IconData> _icons = [
    Icons.smart_toy_rounded,
    Icons.swap_horiz_rounded,
  ];

  static const List<Color> _colors = [Color(0xFF4361EE), Color(0xFF34C759)];

  static const List<Color> _colors2 = [Color(0xFF4CC9F0), Color(0xFF30D158)];

  @override
  void initState() {
    super.initState();

    _initializeAnimations();

    _startCycle();
  }

  // =====================================================
  // INITIALIZE ANIMATIONS
  // =====================================================

  void _initializeAnimations() {
    _outCtrl = AnimationController(
      vsync: this,

      duration: const Duration(milliseconds: 250),
    );

    _inCtrl = AnimationController(
      vsync: this,

      duration: const Duration(milliseconds: 320),
    );

    _tapCtrl = AnimationController(
      vsync: this,

      duration: const Duration(milliseconds: 380),
    );

    // Exit animation
    _outSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1.2, 0),
    ).animate(CurvedAnimation(parent: _outCtrl, curve: Curves.easeIn));

    _outFade = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(CurvedAnimation(parent: _outCtrl, curve: Curves.easeIn));

    // Enter animation
    _inSlide = Tween<Offset>(
      begin: const Offset(1.2, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _inCtrl, curve: Curves.easeOutCubic));

    _inFade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _inCtrl, curve: Curves.easeOut));

    _inScale = Tween<double>(
      begin: 0.6,
      end: 1,
    ).animate(CurvedAnimation(parent: _inCtrl, curve: Curves.easeOutBack));

    // Tap bounce
    _tapScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.18,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),

      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.18,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 65,
      ),
    ]).animate(_tapCtrl);
  }

  // =====================================================
  // START AUTO CYCLE
  // =====================================================

  void _startCycle() {
    _cycleTimer?.cancel();

    _cycleTimer = Timer.periodic(const Duration(seconds: 3), (_) => _cycle());
  }

  // =====================================================
  // ICON CYCLE
  // =====================================================

  Future<void> _cycle() async {
    if (!mounted || _animating) {
      return;
    }

    _animating = true;

    // Exit old icon
    _outCtrl.reset();

    await _outCtrl.forward();

    if (!mounted) {
      return;
    }

    // Change icon
    setState(() {
      _currentIndex = (_currentIndex + 1) % _icons.length;
    });

    // Enter new icon
    _inCtrl.reset();

    await _inCtrl.forward();

    _animating = false;
  }

  // =====================================================
  // FAB TAP
  // =====================================================

  void _handleTap() {
    HapticFeedback.lightImpact();

    _tapCtrl.forward(from: 0);

    widget.onTap();
  }

  @override
  void dispose() {
    _cycleTimer?.cancel();

    _outCtrl.dispose();

    _inCtrl.dispose();

    _tapCtrl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,

      child: AnimatedBuilder(
        animation: Listenable.merge([_outCtrl, _inCtrl, _tapCtrl]),

        builder: (_, __) {
          Widget iconWidget;

          if (_outCtrl.isAnimating) {
            iconWidget = SlideTransition(
              position: _outSlide,

              child: FadeTransition(
                opacity: _outFade,

                child: Icon(
                  _icons[_currentIndex],

                  size: 26,

                  color: Colors.white,
                ),
              ),
            );
          } else if (_inCtrl.isAnimating) {
            iconWidget = SlideTransition(
              position: _inSlide,

              child: FadeTransition(
                opacity: _inFade,

                child: ScaleTransition(
                  scale: _inScale,

                  child: Icon(
                    _icons[_currentIndex],

                    size: 26,

                    color: Colors.white,
                  ),
                ),
              ),
            );
          } else {
            iconWidget = Icon(
              _icons[_currentIndex],

              size: 26,

              color: Colors.white,
            );
          }

          return Transform.scale(
            scale: _tapScale.value,

            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),

              curve: Curves.easeInOut,

              width: 58.w,

              height: 58.h,

              decoration: BoxDecoration(
                shape: BoxShape.circle,

                gradient: LinearGradient(
                  colors: [_colors[_currentIndex], _colors2[_currentIndex]],

                  begin: Alignment.topLeft,

                  end: Alignment.bottomRight,
                ),

                boxShadow: [
                  BoxShadow(
                    color: _colors[_currentIndex].withOpacity(0.45),

                    blurRadius: 22,

                    spreadRadius: 1,

                    offset: const Offset(0, 6),
                  ),
                ],
              ),

              child: ClipOval(child: Center(child: iconWidget)),
            ),
          );
        },
      ),
    );
  }
}
