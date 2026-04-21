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

  static const _icons = [
    Icons.home_outlined,
    Icons.directions_walk_outlined,
    Icons.restaurant_menu_outlined,
    Icons.bar_chart_outlined,
  ];

  // Filled icons for active state — morphing effect
  static const _activeIcons = [
    Icons.home_rounded,
    Icons.directions_walk_rounded,
    Icons.restaurant_menu_rounded,
    Icons.bar_chart_rounded,
  ];

  static const _labels = ['Today', 'Activities', 'Recipes', 'Progress'];

  void _onFabTap() {
    HapticFeedback.lightImpact();
    showCenterFabSheet(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg  = isDark ? const Color(0xFF1E2235) : Colors.white;

    return Scaffold(
      extendBody: true,
      backgroundColor: context.colors.bg,
      body: IndexedStack(index: _currentIndex, children: _screens),

      // Center FAB — always rotating, morphs on tap
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
        height: 64.h,
        shadow: BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.35 : 0.10),
          blurRadius: 24,
          offset: const Offset(0, -4),
        ),
        onTap: (i) => setState(() => _currentIndex = i),
        tabBuilder: (int index, bool isActive) => _NavTab(
          icon: _icons[index],
          activeIcon: _activeIcons[index],
          label: _labels[index],
          isActive: isActive,
          isDark: isDark,
        ),
      ),
    );
  }
}

// ─── Animated nav tab ─────────────────────────────────────────────────────────
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
  late Animation<double> _bounceAnim;   // scale bounce on tap
  late Animation<double> _morphAnim;    // icon swap crossfade
  late Animation<double> _bgAnim;       // background color fade

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Bounce: goes up to 1.3 then settles at 1.18
    _bounceAnim = TweenSequence([
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 1.30)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 35),
      TweenSequenceItem(
          tween: Tween(begin: 1.30, end: 1.0)
              .chain(CurveTween(curve: Curves.elasticOut)),
          weight: 65),
    ]).animate(_ctrl);

    // Morph crossfade between outline ↔ filled icon
    _morphAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);

    // Background pill fade
    _bgAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);

    if (widget.isActive) _ctrl.forward(from: 0.4);
  }

  @override
  void didUpdateWidget(_NavTab old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !old.isActive) {
      // Became active → play full bounce + morph
      _ctrl.forward(from: 0.0);
    } else if (!widget.isActive && old.isActive) {
      // Became inactive → reverse smoothly
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
    const activeColor   = Color(0xFF4361EE);
    final inactiveColor = widget.isDark
        ? Colors.white.withOpacity(0.38)
        : Colors.black.withOpacity(0.35);

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = _ctrl.value; // 0.0 → 1.0

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Background pill — fades in when active
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
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
                    // Outline icon — fades out when active
                    Opacity(
                      opacity: (1 - t).clamp(0.0, 1.0),
                      child: Icon(widget.icon,
                          color: inactiveColor, size: 22.sp),
                    ),
                    // Filled icon — fades in when active
                    Opacity(
                      opacity: t.clamp(0.0, 1.0),
                      child: Icon(widget.activeIcon,
                          color: activeColor, size: 22.sp),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 3.h),

            // Label — color animates with background
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight:
                    t > 0.5 ? FontWeight.w700 : FontWeight.w400,
                color: Color.lerp(inactiveColor, activeColor, t),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Animated center FAB ─────────────────────────────────────────────────────
// Old icon slides left out, new icon slides in from right + scales up
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
  late Animation<double>  _outFade;
  late Animation<Offset> _inSlide;
  late Animation<double>  _inFade;
  late Animation<double>  _inScale;
  late Animation<double>  _tapScale;

  int _currentIndex = 0;
  bool _animating = false;

  static const _icons   = [Icons.smart_toy_rounded, Icons.swap_horiz_rounded];
  static const _colors  = [Color(0xFF4361EE),        Color(0xFF34C759)];
  static const _colors2 = [Color(0xFF4CC9F0),        Color(0xFF30D158)];

  @override
  void initState() {
    super.initState();

    _outCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 250));
    _inCtrl  = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 320));
    _tapCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 380));

    // Old icon slides LEFT and fades
    _outSlide = Tween<Offset>(
            begin: Offset.zero, end: const Offset(-1.2, 0))
        .animate(CurvedAnimation(parent: _outCtrl, curve: Curves.easeIn));
    _outFade  = Tween<double>(begin: 1.0, end: 0.0)
        .animate(CurvedAnimation(parent: _outCtrl, curve: Curves.easeIn));

    // New icon slides in from RIGHT + scales from 0.6→1.0
    _inSlide  = Tween<Offset>(
            begin: const Offset(1.2, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _inCtrl, curve: Curves.easeOutCubic));
    _inFade   = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _inCtrl, curve: Curves.easeOut));
    _inScale  = Tween<double>(begin: 0.6, end: 1.0)
        .animate(CurvedAnimation(parent: _inCtrl, curve: Curves.easeOutBack));

    // Tap bounce
    _tapScale = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.28)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.28, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 65,
      ),
    ]).animate(_tapCtrl);

    Future.delayed(const Duration(milliseconds: 2500), _cycle);
  }

  void _cycle() async {
    if (!mounted || _animating) return;
    _animating = true;

    // Phase 1: current icon exits to the left
    _outCtrl.reset();
    await _outCtrl.forward();
    if (!mounted) return;

    // Swap index
    setState(() => _currentIndex = (_currentIndex + 1) % 2);

    // Phase 2: new icon enters from the right
    _inCtrl.reset();
    await _inCtrl.forward();
    if (!mounted) return;

    _animating = false;
    Future.delayed(const Duration(milliseconds: 2500), _cycle);
  }

  @override
  void dispose() {
    _outCtrl.dispose();
    _inCtrl.dispose();
    _tapCtrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    _tapCtrl.forward(from: 0);
    widget.onTap();
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
                child: Icon(_icons[_currentIndex],
                    color: Colors.white, size: 26),
              ),
            );
          } else if (_inCtrl.isAnimating) {
            iconWidget = SlideTransition(
              position: _inSlide,
              child: FadeTransition(
                opacity: _inFade,
                child: ScaleTransition(
                  scale: _inScale,
                  child: Icon(_icons[_currentIndex],
                      color: Colors.white, size: 26),
                ),
              ),
            );
          } else {
            iconWidget = Icon(_icons[_currentIndex],
                color: Colors.white, size: 26);
          }

          return Transform.scale(
            scale: _tapScale.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              width: 56.w,
              height: 56.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [_colors[_currentIndex], _colors2[_currentIndex]],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _colors[_currentIndex].withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 1,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipOval(child: iconWidget),
            ),
          );
        },
      ),
    );
  }
}