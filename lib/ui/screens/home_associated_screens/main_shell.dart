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

  final List<Widget> _screens = const [
    HomeScreen(),
    ActivityScreen(),
    RecipesScreen(),
    ProgressScreen(),
  ];

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

  void _onFabTap() {
    HapticFeedback.lightImpact();

    showCenterFabSheet(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final navBg = isDark
        ? const Color(0xFF171B2E)
        : Colors.white;

    return Scaffold(
      extendBody: true,
      backgroundColor: context.colors.bg,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _AnimatedFab(
        onTap: _onFabTap,
      ),
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        itemCount: 4,
        activeIndex: _currentIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.verySmoothEdge,
        leftCornerRadius: 28.r,
        rightCornerRadius: 28.r,
        backgroundColor: navBg,
        height: 72.h,
        splashColor: Colors.transparent,
        shadow: BoxShadow(
          color: Colors.black.withOpacity(
            isDark ? 0.35 : 0.08,
          ),
          blurRadius: 22,
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

class _NavTabState extends State<_NavTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1,
          end: 1.16,
        ).chain(
          CurveTween(
            curve: Curves.easeOut,
          ),
        ),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.16,
          end: 1,
        ).chain(
          CurveTween(
            curve: Curves.elasticOut,
          ),
        ),
        weight: 60,
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
    const activeColor = Color(0xFF5B6CFF);

    final inactiveColor = widget.isDark
        ? Colors.white.withOpacity(0.38)
        : Colors.black.withOpacity(0.38);

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = _ctrl.value;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: Offset(0, -2 * t),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOut,
                padding: EdgeInsets.symmetric(
                  horizontal: 13.w,
                  vertical: 7.h,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18.r),
                  gradient: t > 0
                      ? LinearGradient(
                          colors: [
                            activeColor.withOpacity(0.26),
                            activeColor.withOpacity(0.10),
                          ],
                        )
                      : null,
                  border: Border.all(
                    color: Color.lerp(
                      Colors.transparent,
                      activeColor.withOpacity(0.35),
                      t,
                    )!,
                    width: 1,
                  ),
                ),
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Opacity(
                        opacity: 1 - t,
                        child: Icon(
                          widget.icon,
                          size: 22.sp,
                          color: inactiveColor,
                        ),
                      ),
                      Opacity(
                        opacity: t,
                        child: ShaderMask(
                          shaderCallback: (bounds) {
                            return const LinearGradient(
                              colors: [
                                Color(0xFF7B8CFF),
                                Color(0xFF4CC9F0),
                              ],
                            ).createShader(bounds);
                          },
                          child: Icon(
                            widget.activeIcon,
                            size: 22.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 4.h),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight:
                    t > 0.5 ? FontWeight.w700 : FontWeight.w400,
                color: Color.lerp(
                  inactiveColor,
                  activeColor,
                  t,
                ),
              ),
              child: Text(widget.label),
            ),
          ],
        );
      },
    );
  }
}

class _AnimatedFab extends StatefulWidget {
  final VoidCallback onTap;

  const _AnimatedFab({
    required this.onTap,
  });

  @override
  State<_AnimatedFab> createState() => _AnimatedFabState();
}

class _AnimatedFabState extends State<_AnimatedFab>
    with TickerProviderStateMixin {
  late AnimationController _switchCtrl;

  late AnimationController _pulseCtrl;

  late AnimationController _tapCtrl;

  late Animation<double> _rotationAnim;

  late Animation<double> _scaleAnim;

  late Animation<double> _pulseAnim;

  late Animation<double> _tapAnim;

  Timer? _cycleTimer;

  int _currentIndex = 0;

  static const List<String> _labels = [
    'AI',
    'SWAP',
  ];

  static const List<List<Color>> _gradients = [
    [
      Color(0xFF6D5BFF),
      Color(0xFF46C2FF),
    ],
    [
      Color(0xFF00C896),
      Color(0xFF00E676),
    ],
  ];

  @override
  void initState() {
    super.initState();

    _switchCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _tapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );

    _rotationAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _switchCtrl,
        curve: Curves.easeInOutCubic,
      ),
    );

    _scaleAnim = Tween<double>(
      begin: 0.85,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _switchCtrl,
        curve: Curves.elasticOut,
      ),
    );

    _pulseAnim = Tween<double>(
      begin: 1,
      end: 1.08,
    ).animate(
      CurvedAnimation(
        parent: _pulseCtrl,
        curve: Curves.easeInOut,
      ),
    );

    _tapAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1,
          end: 0.92,
        ).chain(
          CurveTween(
            curve: Curves.easeOut,
          ),
        ),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.92,
          end: 1,
        ).chain(
          CurveTween(
            curve: Curves.elasticOut,
          ),
        ),
        weight: 70,
      ),
    ]).animate(_tapCtrl);

    _startCycle();
  }

  void _startCycle() {
    _cycleTimer?.cancel();

    _cycleTimer = Timer.periodic(
      const Duration(seconds: 4),
      (_) => _changeFab(),
    );
  }

  Future<void> _changeFab() async {
    if (!mounted) {
      return;
    }

    await _switchCtrl.forward();

    setState(() {
      _currentIndex = (_currentIndex + 1) % 2;
    });

    _switchCtrl.reset();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();

    _tapCtrl.forward(from: 0);

    widget.onTap();
  }

  @override
  void dispose() {
    _cycleTimer?.cancel();

    _switchCtrl.dispose();

    _pulseCtrl.dispose();

    _tapCtrl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _switchCtrl,
          _pulseCtrl,
          _tapCtrl,
        ]),
        builder: (_, __) {
          return Transform.scale(
            scale: _pulseAnim.value * _tapAnim.value,
            child: Container(
              width: 78.w,
              height: 78.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: _gradients[_currentIndex],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _gradients[_currentIndex][0]
                        .withOpacity(0.55),
                    blurRadius: 30,
                    spreadRadius: 2,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 64.w,
                    height: 64.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.10),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.16),
                        width: 1.2,
                      ),
                    ),
                  ),
                  Transform.rotate(
                    angle: _rotationAnim.value * 6.2,
                    child: Transform.scale(
                      scale: _scaleAnim.value,
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          _currentIndex == 0
                              ? Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 34.w,
                                      height: 34.h,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white
                                              .withOpacity(0.20),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons
                                          .psychology_alt_rounded,
                                      color: Colors.white,
                                      size: 22.sp,
                                    ),
                                  ],
                                )
                              : Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Transform.rotate(
                                      angle: 0.7,
                                      child: Icon(
                                        Icons.sync_alt_rounded,
                                        color: Colors.white
                                            .withOpacity(0.18),
                                        size: 38.sp,
                                      ),
                                    ),
                                    Icon(
                                      Icons
                                          .restaurant_menu_rounded,
                                      color: Colors.white,
                                      size: 18.sp,
                                    ),
                                  ],
                                ),
                          SizedBox(height: 4.h),
                          Text(
                            _labels[_currentIndex],
                            style: TextStyle(
                              color:
                                  Colors.white.withOpacity(0.92),
                              fontSize: 8.5.sp,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}