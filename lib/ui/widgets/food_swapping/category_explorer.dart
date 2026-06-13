import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vital_metrics/core/themes/app_colors.dart';
import 'package:vital_metrics/data/models/food_item.dart';
import 'package:vital_metrics/services/food_swap_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Category definitions
// ─────────────────────────────────────────────────────────────────────────────
class _CatDef {
  final String id;
  final String label;
  final String emoji;
  final Color accent;
  final Color bg;
  final bool Function(FoodItem) matches;
  final int Function(FoodItem, FoodItem) sort;

  const _CatDef({
    required this.id,
    required this.label,
    required this.emoji,
    required this.accent,
    required this.bg,
    required this.matches,
    required this.sort,
  });
}

const _kPageSize = 30; // items shown per "load more" page

final _cats = <_CatDef>[
  // ── Protein pair
  _CatDef(
    id: 'high_protein',
    label: 'High Protein',
    emoji: '🍗',
    accent: Color(0xFF4361EE),
    bg: Color(0xFF1A2340),
    matches: (f) => f.protein >= 15,
    sort: (a, b) => b.protein.compareTo(a.protein),
  ),
  _CatDef(
    id: 'low_protein',
    label: 'Low Protein',
    emoji: '🥗',
    accent: Color(0xFF7986CB),
    bg: Color(0xFF151C35),
    matches: (f) => f.protein <= 5,
    sort: (a, b) => a.protein.compareTo(b.protein),
  ),
  // ── Calorie pair
  _CatDef(
    id: 'high_calorie',
    label: 'High Calorie',
    emoji: '🔥',
    accent: Color(0xFFFF6D00),
    bg: Color(0xFF2A1500),
    matches: (f) => f.calories >= 400,
    sort: (a, b) => b.calories.compareTo(a.calories),
  ),
  _CatDef(
    id: 'low_calorie',
    label: 'Low Calorie',
    emoji: '🥬',
    accent: Color(0xFF2E7D4F),
    bg: Color(0xFF0E2A1A),
    matches: (f) => f.calories <= 200,
    sort: (a, b) => a.calories.compareTo(b.calories),
  ),
  // ── Carb pair
  _CatDef(
    id: 'high_carb',
    label: 'High Carb',
    emoji: '🍚',
    accent: Color(0xFFB07D2E),
    bg: Color(0xFF2A1F0E),
    matches: (f) => f.carbs >= 40,
    sort: (a, b) => b.carbs.compareTo(a.carbs),
  ),
  _CatDef(
    id: 'low_carb',
    label: 'Low Carb',
    emoji: '🥩',
    accent: Color(0xFF8B2E2E),
    bg: Color(0xFF250E0E),
    matches: (f) => f.carbs <= 10,
    sort: (a, b) => a.carbs.compareTo(b.carbs),
  ),
  // ── Fat pair
  _CatDef(
    id: 'high_fat',
    label: 'High Fat',
    emoji: '🧀',
    accent: Color(0xFF00BFA5),
    bg: Color(0xFF0A2420),
    matches: (f) => f.fats >= 15,
    sort: (a, b) => b.fats.compareTo(a.fats),
  ),
  _CatDef(
    id: 'low_fat',
    label: 'Low Fat',
    emoji: '🍎',
    accent: Color(0xFFE57373),
    bg: Color(0xFF2A1010),
    matches: (f) => f.fats <= 5,
    sort: (a, b) => a.fats.compareTo(b.fats),
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// CategoryExplorer — الشاشة الرئيسية
// ─────────────────────────────────────────────────────────────────────────────
class CategoryExplorer extends StatefulWidget {
  final ValueChanged<FoodItem> onSelect;
  const CategoryExplorer({super.key, required this.onSelect});

  @override
  State<CategoryExplorer> createState() => _CategoryExplorerState();
}

class _CategoryExplorerState extends State<CategoryExplorer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  List<FoodItem> _backendMeals = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final meals = await FoodSwapService().getMealsFromBackend();
      if (mounted) setState(() => _backendMeals = meals);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<FoodItem> get _allFoods {
    final local = FoodSwapService().allFoods;
    final ids = _backendMeals.map((f) => f.id).toSet();
    return [..._backendMeals, ...local.where((f) => !ids.contains(f.id))];
  }

  List<FoodItem> _foodsFor(_CatDef def) =>
      (_allFoods.where(def.matches).toList()..sort(def.sort));

  int _countFor(_CatDef def) => _allFoods.where(def.matches).length;

  void _open(_CatDef def) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (_) => _CategorySheet(
        def: def,
        allFoods: _foodsFor(def),
        onSelect: widget.onSelect,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // CustomScrollView بدل SingleChildScrollView + GridView عشان ما فيش overflow
    return CustomScrollView(
      slivers: [
        // ── padding top
        SliverToBoxAdapter(child: SizedBox(height: 8.h)),

        // ── Hero
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          sliver: SliverToBoxAdapter(
            child: FadeTransition(
              opacity: CurvedAnimation(
                  parent: _entrance,
                  curve: const Interval(0, .5, curve: Curves.easeOut)),
              child: const _HeroSection(),
            ),
          ),
        ),

        SliverToBoxAdapter(child: SizedBox(height: 24.h)),

        // ── Title row
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          sliver: SliverToBoxAdapter(
            child: FadeTransition(
              opacity: CurvedAnimation(
                  parent: _entrance,
                  curve: const Interval(.1, .5, curve: Curves.easeOut)),
              child: Row(
                children: [
                  Text(
                    'Explore by Category',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  if (_loading)
                    SizedBox(
                      width: 14.w,
                      height: 14.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.swapGreen,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        SliverToBoxAdapter(child: SizedBox(height: 14.h)),

        // ── 2-column grid — SliverGrid لا overflow أبداً
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              // glass card height
              mainAxisExtent: 185.h,
            ),
            delegate: SliverChildBuilderDelegate(
              (_, i) {
                final def = _cats[i];
                final delay = (i * 0.08).clamp(0.0, 0.5);
                return AnimatedBuilder(
                  animation: _entrance,
                  builder: (_, child) {
                    final t = CurvedAnimation(
                      parent: _entrance,
                      curve: Interval(
                        .15 + delay,
                        (.55 + delay).clamp(0.0, 1.0),
                        curve: Curves.easeOutBack,
                      ),
                    ).value.clamp(0.0, 1.0);
                    return Opacity(
                      opacity: t,
                      child: Transform.scale(scale: .7 + .3 * t, child: child),
                    );
                  },
                  child: _CategoryCard(
                    def: def,
                    count: _countFor(def),
                    onTap: () => _open(def),
                  ),
                );
              },
              childCount: _cats.length,
            ),
          ),
        ),

        SliverToBoxAdapter(child: SizedBox(height: 32.h)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category card — Glassmorphism + shimmer + arc + tilt + particles
// ─────────────────────────────────────────────────────────────────────────────
class _CategoryCard extends StatefulWidget {
  final _CatDef def;
  final int count;
  final VoidCallback onTap;
  const _CategoryCard(
      {required this.def, required this.count, required this.onTap});

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

// ── tiny particle data
class _Particle {
  double x, y, size, speed, opacity, phase;
  _Particle(this.x, this.y, this.size, this.speed, this.opacity, this.phase);
}

class _CategoryCardState extends State<_CategoryCard>
    with TickerProviderStateMixin {
  // press scale
  late final AnimationController _press = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 120));

  // shimmer sweep
  late final AnimationController _shimmer = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 2200))..repeat();

  // arc fill on entrance
  late final AnimationController _arc = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 1400));
  late final Animation<double> _arcVal = CurvedAnimation(
    parent: _arc, curve: Curves.easeOutCubic);

  // particle drift
  late final AnimationController _particles = AnimationController(
    vsync: this, duration: const Duration(seconds: 4))..repeat();

  // tilt from gesture
  double _tiltX = 0, _tiltY = 0;

  late final List<_Particle> _pts;

  @override
  void initState() {
    super.initState();
    final rng = math.Random(widget.def.id.hashCode);
    _pts = List.generate(7, (_) => _Particle(
      rng.nextDouble(),
      rng.nextDouble(),
      rng.nextDouble() * 3 + 1.5,
      rng.nextDouble() * .4 + .2,
      rng.nextDouble() * .5 + .2,
      rng.nextDouble() * math.pi * 2,
    ));
    Future.delayed(
      Duration(milliseconds: 300 + widget.def.id.hashCode.abs() % 200),
      () { if (mounted) _arc.forward(); },
    );
  }

  @override
  void dispose() {
    _press.dispose();
    _shimmer.dispose();
    _arc.dispose();
    _particles.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails d) {
    final size = context.size ?? const Size(160, 185);
    setState(() {
      _tiltY = ((d.localPosition.dx / size.width) - .5) * .25;
      _tiltX = ((.5 - d.localPosition.dy / size.height)) * .18;
    });
  }

  void _resetTilt() => setState(() { _tiltX = 0; _tiltY = 0; });

  @override
  Widget build(BuildContext context) {
    final d = widget.def;
    final ratio = (widget.count / 230).clamp(0.0, 1.0);
    final accent = d.accent;

    return GestureDetector(
      onTapDown: (_) => _press.forward(),
      onTapUp: (_) { _press.reverse(); widget.onTap(); },
      onTapCancel: () => _press.reverse(),
      onPanUpdate: _onPanUpdate,
      onPanEnd: (_) => _resetTilt(),
      onPanCancel: _resetTilt,
      child: AnimatedBuilder(
        animation: Listenable.merge([_press, _shimmer, _arcVal, _particles]),
        builder: (_, __) {
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(_tiltX - _press.value * .02)
              ..rotateY(_tiltY)
              ..scale(1 - _press.value * 0.045),
            child: _buildCard(d, ratio, accent),
          );
        },
      ),
    );
  }

  Widget _buildCard(_CatDef d, double ratio, Color accent) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onCard = isDark ? Colors.white : Colors.black87;
    final onCardSub = isDark ? Colors.white38 : Colors.black38;
    final glassBase = isDark
        ? Colors.white.withOpacity(.13)
        : Colors.white.withOpacity(.55);
    final glassBorder = isDark
        ? Colors.white.withOpacity(.18)
        : Colors.white.withOpacity(.6);
    final trackColor = isDark
        ? Colors.white.withOpacity(.08)
        : Colors.black.withOpacity(.06);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22.r),
        // outer glow
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(.28 + _press.value * .12),
            blurRadius: 22 + _press.value * 8,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? .45 : .12),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22.r),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  glassBase,
                  accent.withOpacity(.07),
                  isDark ? d.bg.withOpacity(.55) : d.bg.withOpacity(.18),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
              border: Border.all(color: glassBorder, width: 1.1),
            ),
            child: Stack(
              children: [
                // ── background accent blob
                Positioned(
                  bottom: -20.h,
                  right: -20.w,
                  child: Container(
                    width: 90.w,
                    height: 90.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        accent.withOpacity(isDark ? .35 : .18),
                        accent.withOpacity(.0),
                      ]),
                    ),
                  ),
                ),

                // ── particles
                ..._pts.map((p) {
                  final t = (_particles.value + p.phase / (math.pi * 2)) % 1.0;
                  final py = (p.y - t * p.speed) % 1.0;
                  return Positioned(
                    left: p.x * 130.w,
                    top: py * 160.h,
                    child: Container(
                      width: p.size.w,
                      height: p.size.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent.withOpacity(
                            p.opacity * (0.4 + 0.6 * math.sin(t * math.pi))),
                      ),
                    ),
                  );
                }),

                // ── shimmer sweep
                Positioned.fill(
                  child: ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (bounds) => LinearGradient(
                      begin: Alignment(-1.5 + _shimmer.value * 3.5, -0.5),
                      end: Alignment(-1.0 + _shimmer.value * 3.5, 0.5),
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(isDark ? .12 : .35),
                        Colors.transparent,
                      ],
                    ).createShader(bounds),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22.r),
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // ── main content
                Padding(
                  padding: EdgeInsets.fromLTRB(13.w, 13.h, 13.w, 11.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // top row: arc + emoji
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Animated circular arc
                          SizedBox(
                            width: 46.w,
                            height: 46.w,
                            child: CustomPaint(
                              painter: _ArcPainter(
                                progress: _arcVal.value * ratio,
                                accent: accent,
                                emoji: d.emoji,
                              ),
                            ),
                          ),
                          const Spacer(),
                          // glass chip — count
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10.r),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: accent.withOpacity(.18),
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                      color: accent.withOpacity(.4), width: .8),
                                ),
                                child: Text(
                                  '${widget.count}',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w900,
                                    color: isDark ? accent : accent.withOpacity(.9),
                                    height: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 10.h),

                      // label
                      Text(
                        d.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w800,
                          color: onCard,
                          letterSpacing: -.2,
                          shadows: isDark
                              ? [Shadow(color: accent.withOpacity(.6), blurRadius: 8)]
                              : null,
                        ),
                      ),

                      SizedBox(height: 3.h),

                      Text(
                        'items to explore',
                        style: TextStyle(
                          fontSize: 8.5.sp,
                          color: onCardSub,
                          fontWeight: FontWeight.w500,
                          letterSpacing: .3,
                        ),
                      ),

                      SizedBox(height: 9.h),

                      // thin glass progress track
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6.r),
                        child: SizedBox(
                          height: 3.5.h,
                          child: Stack(children: [
                            // track
                            Container(color: trackColor),
                            // fill
                            FractionallySizedBox(
                              widthFactor: _arcVal.value * ratio,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [
                                    accent.withOpacity(.7),
                                    accent,
                                  ]),
                                  borderRadius: BorderRadius.circular(6.r),
                                  boxShadow: isDark
                                      ? [BoxShadow(
                                          color: accent.withOpacity(.6),
                                          blurRadius: 6,
                                        )]
                                      : null,
                                ),
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Arc painter — رسم الدايري + emoji في النص
// ─────────────────────────────────────────────────────────────────────────────
class _ArcPainter extends CustomPainter {
  final double progress;
  final Color accent;
  final String emoji;

  const _ArcPainter({
    required this.progress,
    required this.accent,
    required this.emoji,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2 - 3;
    const startAngle = -math.pi / 2;
    const fullSweep = math.pi * 2;

    // track
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = Colors.white.withOpacity(.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round,
    );

    // arc fill with gradient
    if (progress > 0.01) {
      final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
      final gradPaint = Paint()
        ..shader = SweepGradient(
          startAngle: startAngle,
          endAngle: startAngle + fullSweep * progress,
          colors: [accent.withOpacity(.5), accent],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, startAngle, fullSweep * progress, false, gradPaint);

      // glow dot at tip
      final tipAngle = startAngle + fullSweep * progress;
      final tx = cx + r * math.cos(tipAngle);
      final ty = cy + r * math.sin(tipAngle);
      canvas.drawCircle(
        Offset(tx, ty),
        4,
        Paint()
          ..color = accent
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      canvas.drawCircle(Offset(tx, ty), 2.5, Paint()..color = Colors.white);
    }

    // emoji in center
    final tp = TextPainter(
      text: TextSpan(
        text: emoji,
        style: TextStyle(fontSize: size.width * .42),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(cx - tp.width / 2, cy - tp.height / 2),
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.progress != progress || old.accent != accent;
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom sheet — كل الداتا + load more
// ─────────────────────────────────────────────────────────────────────────────
class _CategorySheet extends StatefulWidget {
  final _CatDef def;
  final List<FoodItem> allFoods; // كل الداتا بدون حد
  final ValueChanged<FoodItem> onSelect;

  const _CategorySheet({
    required this.def,
    required this.allFoods,
    required this.onSelect,
  });

  @override
  State<_CategorySheet> createState() => _CategorySheetState();
}

class _CategorySheetState extends State<_CategorySheet>
    with TickerProviderStateMixin {
  // ── animations
  late final AnimationController _sheetCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 420))
    ..forward();
  late final AnimationController _headerCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 550));
  late final AnimationController _gridCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 650));

  // ── pagination
  int _shownCount = _kPageSize;
  late final ScrollController _scrollCtrl;
  bool _loadingMore = false;

  List<FoodItem> get _visibleFoods =>
      widget.allFoods.take(_shownCount).toList();
  bool get _hasMore => _shownCount < widget.allFoods.length;

  @override
  void initState() {
    super.initState();
    _scrollCtrl = ScrollController()..addListener(_onScroll);
    _sheetCtrl.forward().then((_) {
      _headerCtrl.forward().then((_) => _gridCtrl.forward());
    });
  }

  @override
  void dispose() {
    _sheetCtrl.dispose();
    _headerCtrl.dispose();
    _gridCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    // لما يوصل لـ 80% من الـ scroll يحمل المزيد
    if (_loadingMore || !_hasMore) return;
    final pos = _scrollCtrl.position;
    if (pos.pixels >= pos.maxScrollExtent * 0.8) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    // Simulate tiny delay for smooth UX
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() {
        _shownCount =
            (_shownCount + _kPageSize).clamp(0, widget.allFoods.length);
        _loadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.def.accent;
    final bg = widget.def.bg;
    final visible = _visibleFoods;

    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
          .animate(CurvedAnimation(
              parent: _sheetCtrl, curve: Curves.easeOutCubic)),
      child: DraggableScrollableSheet(
        initialChildSize: 0.88,
        maxChildSize: 0.95,
        minChildSize: 0.45,
        expand: false,
        builder: (_, __) => Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0D1117),
            borderRadius: BorderRadius.vertical(top: Radius.circular(26.r)),
            border: Border.all(color: accent.withOpacity(.22), width: 1),
          ),
          child: Column(
            children: [
              // ── drag handle
              Container(
                margin: EdgeInsets.only(top: 10.h),
                width: 38.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: accent.withOpacity(.4),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),

              // ── header
              AnimatedBuilder(
                animation: _headerCtrl,
                builder: (_, child) {
                  final t = CurvedAnimation(
                          parent: _headerCtrl, curve: Curves.easeOutBack)
                      .value
                      .clamp(0.0, 1.0);
                  return Opacity(
                    opacity: CurvedAnimation(
                            parent: _headerCtrl, curve: Curves.easeOut)
                        .value
                        .clamp(0.0, 1.0),
                    child: Transform.scale(
                        scale: .65 + .35 * t, child: child),
                  );
                },
                child: Container(
                  margin: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 6.h),
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [bg, Color.lerp(bg, accent, .18)!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(color: accent.withOpacity(.38)),
                    boxShadow: [
                      BoxShadow(
                          color: accent.withOpacity(.28),
                          blurRadius: 22,
                          spreadRadius: 1),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Emoji glow
                      Container(
                        width: 60.w,
                        height: 60.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accent.withOpacity(.14),
                          boxShadow: [
                            BoxShadow(
                                color: accent.withOpacity(.45),
                                blurRadius: 20,
                                spreadRadius: 2),
                          ],
                        ),
                        child: Center(
                          child: Text(widget.def.emoji,
                              style: TextStyle(fontSize: 30.sp)),
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.def.label,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: accent.withOpacity(.18),
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                    color: accent.withOpacity(.4)),
                              ),
                              child: Text(
                                '${widget.allFoods.length} foods',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: accent,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Close
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 30.w,
                          height: 30.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(.08),
                          ),
                          child: Icon(Icons.close_rounded,
                              color: Colors.white54, size: 15.sp),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── grid — CustomScrollView داخل الـ sheet
              Expanded(
                child: widget.allFoods.isEmpty
                    ? Center(
                        child: Text(
                          '🔍  No foods in this category yet',
                          style: TextStyle(
                              fontSize: 13.sp, color: Colors.white38),
                        ),
                      )
                    : CustomScrollView(
                        controller: _scrollCtrl,
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(
                                14.w, 8.h, 14.w, 0),
                            sliver: SliverGrid(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 10.w,
                                mainAxisSpacing: 10.h,
                                childAspectRatio: .82,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (_, i) {
                                  // انيميشن بس على أول batch
                                  final animated = i < _kPageSize;
                                  final delay =
                                      (i * .035).clamp(0.0, .55);
                                  return animated
                                      ? AnimatedBuilder(
                                          animation: _gridCtrl,
                                          builder: (_, child) {
                                            final t = CurvedAnimation(
                                              parent: _gridCtrl,
                                              curve: Interval(
                                                delay,
                                                (delay + .35)
                                                    .clamp(0.0, 1.0),
                                                curve:
                                                    Curves.easeOutBack,
                                              ),
                                            ).value.clamp(0.0, 1.0);
                                            return Opacity(
                                              opacity: t,
                                              child: Transform.scale(
                                                scale: .5 + .5 * t,
                                                child: child,
                                              ),
                                            );
                                          },
                                          child: _FoodTile(
                                            food: visible[i],
                                            accent: accent,
                                            onTap: () {
                                              HapticFeedback
                                                  .selectionClick();
                                              Navigator.pop(context);
                                              widget.onSelect(visible[i]);
                                            },
                                          ),
                                        )
                                      : _FoodTile(
                                          food: visible[i],
                                          accent: accent,
                                          onTap: () {
                                            HapticFeedback.selectionClick();
                                            Navigator.pop(context);
                                            widget.onSelect(visible[i]);
                                          },
                                        );
                                },
                                childCount: visible.length,
                              ),
                            ),
                          ),

                          // ── Load more indicator
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 16.h),
                              child: _loadingMore
                                  ? Center(
                                      child: SizedBox(
                                        width: 22.w,
                                        height: 22.w,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: accent,
                                        ),
                                      ),
                                    )
                                  : _hasMore
                                      ? Center(
                                          child: GestureDetector(
                                            onTap: _loadMore,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 20.w,
                                                  vertical: 8.h),
                                              decoration: BoxDecoration(
                                                color: accent.withOpacity(.12),
                                                borderRadius:
                                                    BorderRadius.circular(20.r),
                                                border: Border.all(
                                                    color: accent.withOpacity(.3)),
                                              ),
                                              child: Text(
                                                'Load more  ↓',
                                                style: TextStyle(
                                                  fontSize: 11.sp,
                                                  color: accent,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      : Padding(
                                          padding:
                                              EdgeInsets.only(bottom: 8.h),
                                          child: Text(
                                            '✅  All ${widget.allFoods.length} foods loaded',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 11.sp,
                                              color: Colors.white30,
                                            ),
                                          ),
                                        ),
                            ),
                          ),

                          SliverToBoxAdapter(child: SizedBox(height: 24.h)),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero section
// ─────────────────────────────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.swapGreen.withOpacity(.14),
            AppColors.swapBlue.withOpacity(.07),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.swapGreen.withOpacity(.18)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 52.w,
            height: 52.w,
            child: Stack(
              children: [
                Positioned(
                    top: 0,
                    left: 0,
                    child: Text('🍗', style: TextStyle(fontSize: 22.sp))),
                Positioned(
                    bottom: 0,
                    right: 0,
                    child: Text('🥦', style: TextStyle(fontSize: 22.sp))),
                Positioned(
                    top: 10.h,
                    left: 12.w,
                    child: Text('🔄',
                        style: TextStyle(fontSize: 16.sp, shadows: [
                          Shadow(
                              color: AppColors.swapGreen.withOpacity(.5),
                              blurRadius: 8),
                        ]))),
              ],
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Smart Food Swaps',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: -.3,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Search any food or pick a category below to find healthier alternatives',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(.55),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Food tile
// ─────────────────────────────────────────────────────────────────────────────
class _FoodTile extends StatefulWidget {
  final FoodItem food;
  final Color accent;
  final VoidCallback onTap;

  const _FoodTile({
    required this.food,
    required this.accent,
    required this.onTap,
  });

  @override
  State<_FoodTile> createState() => _FoodTileState();
}

class _FoodTileState extends State<_FoodTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 90));

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.accent;
    return GestureDetector(
      onTapDown: (_) => _press.forward(),
      onTapUp: (_) {
        _press.reverse();
        widget.onTap();
      },
      onTapCancel: () => _press.reverse(),
      child: AnimatedBuilder(
        animation: _press,
        builder: (_, child) =>
            Transform.scale(scale: 1 - _press.value * .07, child: child),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF161B27),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: c.withOpacity(.24)),
            boxShadow: [
              BoxShadow(
                  color: c.withOpacity(.09),
                  blurRadius: 10,
                  offset: const Offset(0, 3)),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    c.withOpacity(.22),
                    c.withOpacity(.05),
                  ]),
                ),
                child: Center(
                    child: Text(widget.food.emoji,
                        style: TextStyle(fontSize: 21.sp))),
              ),
              SizedBox(height: 6.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                child: Text(
                  widget.food.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 9.5.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
              ),
              SizedBox(height: 5.h),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: c.withOpacity(.14),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  '${widget.food.calories.round()} kcal',
                  style: TextStyle(
                      fontSize: 8.5.sp,
                      color: c,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}