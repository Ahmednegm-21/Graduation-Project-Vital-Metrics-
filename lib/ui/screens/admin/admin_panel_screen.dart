import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;

import 'package:vital_metrics/data/models/admin_meal_model.dart';
import 'package:vital_metrics/data/models/admin_user_model.dart';
import 'package:vital_metrics/logic/admin/admin_cubit.dart';
import 'package:vital_metrics/logic/admin/admin_state.dart';
import 'package:vital_metrics/logic/home/theme_cubit.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;

  final TextEditingController _userSearchController = TextEditingController();
  final TextEditingController _mealSearchController = TextEditingController();

  String _selectedGender      = 'all';
  String _selectedAdminFilter = 'all';

  late final AnimationController _particleCtrl;
  late final AnimationController _pulseCtrl;
  late final Animation<double>   _pulseAnim;

  static const _primaryColor = Color(0xFF4361EE);

  Color get _bgColor   => Theme.of(context).scaffoldBackgroundColor;
  Color get _cardColor => Theme.of(context).colorScheme.surface;
  Color get _textPrimary   => Theme.of(context).colorScheme.onSurface;
  Color get _textSecondary => Theme.of(context).colorScheme.onSurface.withOpacity(0.55);
  Color get _borderColor   => Theme.of(context).colorScheme.onSurface.withOpacity(0.08);
  Color get _borderMedium  => Theme.of(context).colorScheme.onSurface.withOpacity(0.14);

  @override
  void initState() {
    super.initState();
    context.read<AdminCubit>().loadAll();

    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _pulseAnim = Tween(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _userSearchController.dispose();
    _mealSearchController.dispose();
    _particleCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Filtered lists ────────────────────────────────────────────────────────
  List<AdminUserModel> _filteredUsers(List<AdminUserModel> users) {
    final query = _userSearchController.text.trim().toLowerCase();
    return users.where((user) {
      final matchesSearch  = user.name.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query);
      final matchesGender  = _selectedGender == 'all' ||
          user.gender.toLowerCase() == _selectedGender;
      final matchesAdmin   = _selectedAdminFilter == 'all' ||
          (_selectedAdminFilter == 'admin' && user.isAdmin) ||
          (_selectedAdminFilter == 'user'  && !user.isAdmin);
      return matchesSearch && matchesGender && matchesAdmin;
    }).toList();
  }

  List<AdminMealModel> _filteredMeals(List<AdminMealModel> meals) {
    final query = _mealSearchController.text.trim().toLowerCase();
    return meals.where((m) =>
        m.name.toLowerCase().contains(query) ||
        m.description.toLowerCase().contains(query)).toList();
  }

  // ── Actions ───────────────────────────────────────────────────────────────
  Future<void> _deleteUser(AdminUserModel user) async {
    final confirm = await _confirmDialog(
      title:   'Delete User',
      content: 'Are you sure you want to delete ${user.name}?',
    );
    if (!confirm) return;
    try {
      await context.read<AdminCubit>().deleteUser(user);
      _showSnack('User deleted successfully');
    } catch (e) {
      _showSnack('Failed to delete user: $e', isError: true);
    }
  }

  Future<void> _deleteMeal(AdminMealModel meal) async {
    final confirm = await _confirmDialog(
      title:   'Delete Meal',
      content: 'Are you sure you want to delete ${meal.name}?',
    );
    if (!confirm) return;
    try {
      await context.read<AdminCubit>().deleteMeal(meal);
      _showSnack('Meal deleted successfully');
    } catch (e) {
      _showSnack('Failed to delete meal: $e', isError: true);
    }
  }

  Future<bool> _confirmDialog({required String title, required String content}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title:   Text(title,   style: TextStyle(color: _textPrimary,   fontWeight: FontWeight.bold)),
        content: Text(content, style: TextStyle(color: _textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: _textSecondary)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:         Text(message),
      backgroundColor: isError ? const Color(0xFFFF6B6B) : const Color(0xFF2ECC9A),
      behavior:        SnackBarBehavior.floating,
      shape:           RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin:          const EdgeInsets.all(16),
    ));
  }

  Future<void> _openMealDialog({AdminMealModel? meal}) async {
    final isEdit              = meal != null;
    final nameCtrl            = TextEditingController(text: meal?.name ?? '');
    final descCtrl            = TextEditingController(text: meal?.description ?? '');
    final caloriesCtrl        = TextEditingController(text: meal?.calories.toString() ?? '');
    final proteinCtrl         = TextEditingController(text: meal?.protein.toString() ?? '');
    final carbsCtrl           = TextEditingController(text: meal?.carbs.toString() ?? '');
    final fatCtrl             = TextEditingController(text: meal?.fat.toString() ?? '');
    final formKey             = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isEdit ? 'Edit Meal' : 'Add Meal',
          style: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: 400,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                _styledInput(controller: nameCtrl,     label: 'Name',        icon: Icons.restaurant_menu),
                const SizedBox(height: 12),
                _styledInput(controller: descCtrl,     label: 'Description', icon: Icons.description, maxLines: 3),
                const SizedBox(height: 12),
                _styledInput(controller: caloriesCtrl, label: 'Calories',    icon: Icons.local_fire_department, keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                _styledInput(controller: proteinCtrl,  label: 'Protein (g)', icon: Icons.fitness_center,        keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                _styledInput(controller: carbsCtrl,    label: 'Carbs (g)',   icon: Icons.grain,                 keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                _styledInput(controller: fatCtrl,      label: 'Fat (g)',     icon: Icons.opacity,               keyboardType: TextInputType.number),
              ]),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: _textSecondary)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(context, true);
            },
            child: Text(isEdit ? 'Update' : 'Create'),
          ),
        ],
      ),
    );

    if (result != true) return;

    try {
      final name     = nameCtrl.text.trim();
      final desc     = descCtrl.text.trim();
      final calories = int.tryParse(caloriesCtrl.text.trim()) ?? 0;
      final protein  = double.tryParse(proteinCtrl.text.trim()) ?? 0;
      final carbs    = double.tryParse(carbsCtrl.text.trim()) ?? 0;
      final fat      = double.tryParse(fatCtrl.text.trim()) ?? 0;

      if (isEdit) {
        await context.read<AdminCubit>().updateMeal(
          id: meal.mealId, name: name, description: desc,
          calories: calories, protein: protein, carbs: carbs, fat: fat,
        );
        _showSnack('Meal updated successfully');
      } else {
        await context.read<AdminCubit>().createMeal(
          name: name, description: desc,
          calories: calories, protein: protein, carbs: carbs, fat: fat,
        );
        _showSnack('Meal created successfully');
      }
    } catch (e) {
      _showSnack('Meal operation failed: $e', isError: true);
    }
  }

  Widget _styledInput({
    required TextEditingController controller,
    required String  label,
    required IconData icon,
    TextInputType?   keyboardType,
    int              maxLines = 1,
  }) {
    return TextFormField(
      controller:   controller,
      keyboardType: keyboardType,
      maxLines:     maxLines,
      style:        TextStyle(color: _textPrimary),
      validator:    (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null,
      decoration: InputDecoration(
        labelText:  label,
        labelStyle: TextStyle(color: _textSecondary),
        prefixIcon: Icon(icon, color: _primaryColor, size: 20),
        filled:     true,
        fillColor:  _textPrimary.withOpacity(0.04),
        border:         OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _borderColor)),
        enabledBorder:  OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _borderColor)),
        focusedBorder:  OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _primaryColor)),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: _bgColor,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildNavBar(),
                Expanded(
                  child: state.loading
                      ? _buildLoading()
                      : state.error != null
                          ? _buildError(state.error!)
                          : _buildPage(state),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return BlocBuilder<ThemeCubit, bool>(
      builder: (context, isDark) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: _primaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _primaryColor.withOpacity(0.3)),
                    ),
                    child: const Icon(Icons.shield_rounded, color: _primaryColor, size: 22),
                  ),
                  ..._miniParticles(),
                ],
              ),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Admin Panel',
                    style: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold, fontSize: 20)),
                Text('Vital Metrics Control',
                    style: TextStyle(color: _textSecondary, fontSize: 12)),
              ]),
              const Spacer(),

              // Dark-mode toggle
              GestureDetector(
                onTap: () => context.read<ThemeCubit>().toggle(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  width: 56, height: 30,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: isDark ? _primaryColor.withOpacity(0.3) : _textPrimary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? _primaryColor.withOpacity(0.6) : _borderMedium,
                      width: 1,
                    ),
                    boxShadow: isDark ? [BoxShadow(color: _primaryColor.withOpacity(0.25), blurRadius: 8)] : [],
                  ),
                  child: Stack(children: [
                    AnimatedAlign(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        width: 22, height: 22,
                        decoration: BoxDecoration(
                          color: isDark ? _primaryColor : _textPrimary.withOpacity(0.35),
                          shape: BoxShape.circle,
                          boxShadow: isDark ? [BoxShadow(color: _primaryColor.withOpacity(0.5), blurRadius: 6)] : [],
                        ),
                        child: Icon(
                          isDark ? CupertinoIcons.moon_fill : CupertinoIcons.sun_max_fill,
                          size: 12,
                          color: isDark ? Colors.white : _bgColor,
                        ),
                      ),
                    ),
                  ]),
                ),
              ),

              const SizedBox(width: 8),

              GestureDetector(
                onTap: () => context.read<AdminCubit>().loadAll(),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _borderColor),
                  ),
                  child: AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (_, child) => Transform.scale(scale: _pulseAnim.value, child: child),
                    child: const Icon(CupertinoIcons.refresh, color: _primaryColor, size: 20),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _miniParticles() {
    final particles = [
      (top: -6.0, right: -4.0, size: 5.0, color: 0xFF4361EE),
      (top:  8.0, right: -8.0, size: 4.0, color: 0xFF4CC9F0),
    ];
    return particles.map((p) {
      return AnimatedBuilder(
        animation: _particleCtrl,
        builder: (_, __) {
          final t  = _particleCtrl.value;
          final dy = math.sin(t * 2 * math.pi) * 3.0;
          final op = (0.3 + math.sin(t * 2 * math.pi) * 0.3).clamp(0.0, 1.0);
          return Positioned(
            top: p.top + dy, right: p.right,
            child: Opacity(
              opacity: op,
              child: Container(
                width: p.size, height: p.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(p.color),
                  boxShadow: [BoxShadow(color: Color(p.color).withOpacity(0.6), blurRadius: p.size * 2)],
                ),
              ),
            ),
          );
        },
      );
    }).toList();
  }

  Widget _buildNavBar() {
    final tabs = [
      (icon: CupertinoIcons.chart_bar_fill, label: 'Dashboard'),
      (icon: CupertinoIcons.person_2_fill,  label: 'Users'),
      (icon: CupertinoIcons.flame_fill,     label: 'Meals'),
    ];
    return Container(
      margin:  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: tabs.asMap().entries.map((e) {
          final selected = _selectedIndex == e.key;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedIndex = e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? _primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: selected
                      ? [BoxShadow(color: _primaryColor.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))]
                      : [],
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(e.value.icon,
                      color: selected ? Colors.white : _textSecondary, size: 18),
                  const SizedBox(height: 4),
                  Text(e.value.label,
                      style: TextStyle(
                        color: selected ? Colors.white : _textSecondary,
                        fontSize: 11,
                        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                      )),
                ]),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPage(AdminState state) {
    switch (_selectedIndex) {
      case 0:  return _buildDashboard(state);
      case 1:  return _buildUsers(state);
      case 2:  return _buildMeals(state);
      default: return const SizedBox();
    }
  }

  Widget _buildLoading() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        AnimatedBuilder(
          animation: _pulseAnim,
          builder: (_, child) => Transform.scale(scale: _pulseAnim.value, child: child),
          child: Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: _primaryColor.withOpacity(0.3)),
            ),
            child: const Icon(Icons.shield_rounded, color: _primaryColor, size: 28),
          ),
        ),
        const SizedBox(height: 16),
        Text('Loading...', style: TextStyle(color: _textSecondary, fontSize: 14)),
      ]),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFFF6B6B).withOpacity(0.3)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B6B).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline, color: Color(0xFFFF6B6B), size: 28),
            ),
            const SizedBox(height: 16),
            Text(error, textAlign: TextAlign.center,
                style: TextStyle(color: _textSecondary, fontSize: 14)),
            const SizedBox(height: 20),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              ),
              onPressed: () => context.read<AdminCubit>().loadAll(),
              child: const Text('Retry'),
            ),
          ]),
        ),
      ),
    );
  }

  // ── Dashboard ─────────────────────────────────────────────────────────────
  Widget _buildDashboard(AdminState state) {
    final overview = state.overview;
    if (overview == null) {
      return Center(child: Text('No data', style: TextStyle(color: _textSecondary)));
    }

    final stats = [
      (title: 'Total Users',   value: overview.totalUsers.toString(),        icon: CupertinoIcons.person_2_fill,  color: _primaryColor),
      (title: 'Total Goals',   value: overview.totalGoals.toString(),        icon: CupertinoIcons.flag_fill,      color: const Color(0xFF7B5EA7)),
      (title: 'Total Meals',   value: overview.totalMeals.toString(),        icon: CupertinoIcons.flame_fill,     color: const Color(0xFFFF9A3C)),
      (title: 'Daily Metrics', value: overview.totalDailyMetrics.toString(), icon: CupertinoIcons.chart_bar_fill, color: const Color(0xFF2ECC9A)),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      physics: const BouncingScrollPhysics(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Overview',
            style: TextStyle(color: _textSecondary, fontSize: 12,
                fontWeight: FontWeight.w600, letterSpacing: 1.2)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12, mainAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: stats.map((s) => _statCard(s)).toList(),
        ),
        const SizedBox(height: 20),
        _buildQuickActions(),
      ]),
    );
  }

  Widget _statCard(dynamic s) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: (s.color as Color).withOpacity(0.2)),
        boxShadow: [BoxShadow(color: (s.color as Color).withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: (s.color as Color).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: (s.color as Color).withOpacity(0.3)),
            ),
            child: Icon(s.icon as IconData, color: s.color as Color, size: 18),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: (s.color as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('↑', style: TextStyle(color: s.color as Color, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ]),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.value as String,
              style: TextStyle(color: _textPrimary, fontSize: 28, fontWeight: FontWeight.bold, height: 1)),
          const SizedBox(height: 2),
          Text(s.title as String,
              style: TextStyle(color: _textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
        ]),
      ]),
    );
  }

  Widget _buildQuickActions() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Quick Actions',
          style: TextStyle(color: _textSecondary, fontSize: 12,
              fontWeight: FontWeight.w600, letterSpacing: 1.2)),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _actionBtn(
          label: 'Manage Users', icon: CupertinoIcons.person_2_fill,
          color: _primaryColor,
          onTap: () => setState(() => _selectedIndex = 1),
        )),
        const SizedBox(width: 12),
        Expanded(child: _actionBtn(
          label: 'Add Meal', icon: CupertinoIcons.add_circled_solid,
          color: const Color(0xFFFF9A3C),
          onTap: () {
            setState(() => _selectedIndex = 2);
            Future.delayed(const Duration(milliseconds: 100), _openMealDialog);
          },
        )),
      ]),
    ]);
  }

  Widget _actionBtn({required String label, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Flexible(child: Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600))),
        ]),
      ),
    );
  }

  // ── Users ─────────────────────────────────────────────────────────────────
  Widget _buildUsers(AdminState state) {
    final users = _filteredUsers(state.users);
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: Column(children: [
          Container(
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _borderColor),
            ),
            child: TextField(
              controller: _userSearchController,
              onChanged: (_) => setState(() {}),
              style: TextStyle(color: _textPrimary),
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
                hintStyle: TextStyle(color: _textSecondary),
                prefixIcon: Icon(CupertinoIcons.search, color: _textSecondary, size: 18),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _filterDropdown(
              value: _selectedGender,
              items: const {'all': 'All Gender', 'male': 'Male', 'female': 'Female'},
              onChanged: (v) => setState(() => _selectedGender = v ?? 'all'),
            )),
            const SizedBox(width: 10),
            Expanded(child: _filterDropdown(
              value: _selectedAdminFilter,
              items: const {'all': 'All Roles', 'admin': 'Admins', 'user': 'Users'},
              onChanged: (v) => setState(() => _selectedAdminFilter = v ?? 'all'),
            )),
          ]),
        ]),
      ),
      Expanded(
        child: users.isEmpty
            ? _buildEmpty('No users found', CupertinoIcons.person_2)
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                physics: const BouncingScrollPhysics(),
                itemCount: users.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _userCard(users[i]),
              ),
      ),
    ]);
  }

  Widget _filterDropdown({required String value, required Map<String, String> items, required ValueChanged<String?> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: _cardColor,
          style: TextStyle(color: _textPrimary, fontSize: 13),
          icon: Icon(CupertinoIcons.chevron_down, color: _textSecondary, size: 14),
          isExpanded: true,
          items: items.entries
              .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _userCard(AdminUserModel user) {
    final isAdmin = user.isAdmin;
    const roleActiveColor = Color(0xFF2ECC9A);
    final roleColor = isAdmin ? roleActiveColor : _textSecondary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isAdmin ? roleActiveColor.withOpacity(0.2) : _borderColor),
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: _primaryColor.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: _primaryColor.withOpacity(0.3)),
          ),
          child: Center(child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
            style: const TextStyle(color: _primaryColor, fontWeight: FontWeight.bold, fontSize: 18),
          )),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Flexible(child: Text(user.name,
                style: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: roleColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: roleColor.withOpacity(0.3)),
              ),
              child: Text(isAdmin ? 'Admin' : 'User',
                  style: TextStyle(color: roleColor, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ]),
          const SizedBox(height: 3),
          Text(user.email, style: TextStyle(color: _textSecondary, fontSize: 12), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Row(children: [
            _miniChip('${user.gender[0].toUpperCase()}${user.gender.substring(1)}', CupertinoIcons.person),
            const SizedBox(width: 6),
            _miniChip('${user.height}cm', CupertinoIcons.arrow_up),
            const SizedBox(width: 6),
            _miniChip('${user.weight}kg', CupertinoIcons.circle),
          ]),
        ])),
        GestureDetector(
          onTap: () => _deleteUser(user),
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B6B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFF6B6B).withOpacity(0.2)),
            ),
            child: const Icon(CupertinoIcons.trash, color: Color(0xFFFF6B6B), size: 16),
          ),
        ),
      ]),
    );
  }

  Widget _miniChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: _textPrimary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 10, color: _textSecondary),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(color: _textSecondary, fontSize: 10)),
      ]),
    );
  }

  // ── Meals ─────────────────────────────────────────────────────────────────
  Widget _buildMeals(AdminState state) {
    final meals = _filteredMeals(state.meals);
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: Row(children: [
          Expanded(child: Container(
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _borderColor),
            ),
            child: TextField(
              controller: _mealSearchController,
              onChanged: (_) => setState(() {}),
              style: TextStyle(color: _textPrimary),
              decoration: InputDecoration(
                hintText: 'Search meals...',
                hintStyle: TextStyle(color: _textSecondary),
                prefixIcon: Icon(CupertinoIcons.search, color: _textSecondary, size: 18),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          )),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _openMealDialog(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: _primaryColor,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: _primaryColor.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: const Row(children: [
                Icon(CupertinoIcons.add, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text('Add', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              ]),
            ),
          ),
        ]),
      ),
      Expanded(
        child: meals.isEmpty
            ? _buildEmpty('No meals found', CupertinoIcons.flame)
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                physics: const BouncingScrollPhysics(),
                itemCount: meals.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _mealCard(meals[i]),
              ),
      ),
    ]);
  }

  Widget _mealCard(AdminMealModel meal) {
    final macros = [
      (label: 'Cal',  value: meal.calories.toString(),               color: const Color(0xFFFF6B6B)),
      (label: 'Pro',  value: '${meal.protein.toStringAsFixed(0)}g',  color: const Color(0xFFFF9A3C)),
      (label: 'Carb', value: '${meal.carbs.toStringAsFixed(0)}g',    color: const Color(0xFF2ECC9A)),
      (label: 'Fat',  value: '${meal.fat.toStringAsFixed(0)}g',      color: const Color(0xFF4CC9F0)),
    ];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderColor),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFF9A3C).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFF9A3C).withOpacity(0.25)),
            ),
            child: const Center(child: Text('🍽️', style: TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(meal.name,
                style: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                overflow: TextOverflow.ellipsis),
            if (meal.description.isNotEmpty)
              Text(meal.description,
                  style: TextStyle(color: _textSecondary, fontSize: 11),
                  overflow: TextOverflow.ellipsis, maxLines: 1),
          ])),
          Row(children: [
            GestureDetector(
              onTap: () => _openMealDialog(meal: meal),
              child: Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _primaryColor.withOpacity(0.2)),
                ),
                child: const Icon(CupertinoIcons.pencil, color: _primaryColor, size: 15),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _deleteMeal(meal),
              child: Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFF6B6B).withOpacity(0.2)),
                ),
                child: const Icon(CupertinoIcons.trash, color: Color(0xFFFF6B6B), size: 15),
              ),
            ),
          ]),
        ]),
        const SizedBox(height: 12),
        Row(
          children: macros.map((m) => Expanded(
            child: Container(
              margin: EdgeInsets.only(right: macros.last == m ? 0 : 6),
              padding: const EdgeInsets.symmetric(vertical: 7),
              decoration: BoxDecoration(
                color: m.color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: m.color.withOpacity(0.2)),
              ),
              child: Column(children: [
                Text(m.value, style: TextStyle(color: m.color, fontWeight: FontWeight.bold, fontSize: 13)),
                Text(m.label, style: TextStyle(color: m.color.withOpacity(0.6), fontSize: 10)),
              ]),
            ),
          )).toList(),
        ),
      ]),
    );
  }

  Widget _buildEmpty(String message, IconData icon) {
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 64, height: 64,
        decoration: BoxDecoration(color: _textPrimary.withOpacity(0.05), shape: BoxShape.circle),
        child: Icon(icon, color: _textSecondary, size: 28),
      ),
      const SizedBox(height: 12),
      Text(message, style: TextStyle(color: _textSecondary, fontSize: 14)),
    ]));
  }
}