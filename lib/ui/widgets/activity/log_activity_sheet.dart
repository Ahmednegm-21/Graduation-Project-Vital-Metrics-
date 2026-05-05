import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vital_metrics/core/themes/theme_context_extension.dart';
import 'package:vital_metrics/data/models/activity_model.dart';
import 'package:vital_metrics/logic/activity/activity_cubit.dart';
import 'package:vital_metrics/logic/onboarding_data/onboarding_data_cubit.dart';

// Activity type model
// name is the display name shown to the user
// backendType is the value sent to the backend API
class _ActivityType {
  final String name;
  final String backendType;
  final IconData icon;
  final Color color;
  final int metValue;
  const _ActivityType(
    this.name,
    this.backendType,
    this.icon,
    this.color,
    this.metValue,
  );
}

// Popular activities with their backend type mappings and MET values
// backendType must match the backend enum: walk or run
const _kActivities = [
  _ActivityType('Walking',    'walk', Icons.directions_walk_rounded,   Color(0xFF34C759), 4),
  _ActivityType('Running',    'run',  Icons.directions_run_rounded,    Color(0xFFFF3B30), 8),
  _ActivityType('Cycling',    'run',  Icons.directions_bike_rounded,   Color(0xFF32ADE6), 7),
  _ActivityType('Swimming',   'run',  Icons.pool_rounded,              Color(0xFF5AC8FA), 8),
  _ActivityType('Football',   'run',  Icons.sports_soccer_rounded,     Color(0xFF4361EE), 8),
  _ActivityType('Basketball', 'run',  Icons.sports_basketball_rounded, Color(0xFFFF6B00), 8),
  _ActivityType('Yoga',       'walk', Icons.self_improvement_rounded,  Color(0xFFAF52DE), 3),
  _ActivityType('Other',      'walk', Icons.more_horiz_rounded,        Color(0xFF00B894), 5),
];

// Show the log activity bottom sheet
void showLogActivitySheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => BlocProvider.value(
      value: context.read<ActivityCubit>(),
      child: Builder(
        builder: (innerCtx) => _LogActivitySheet(
          userWeight: context.read<OnboardingCubitAllData>().currentData.weight,
        ),
      ),
    ),
  );
}

class _LogActivitySheet extends StatefulWidget {
  final double? userWeight;
  const _LogActivitySheet({this.userWeight});

  @override
  State<_LogActivitySheet> createState() => _LogActivitySheetState();
}

class _LogActivitySheetState extends State<_LogActivitySheet>
    with SingleTickerProviderStateMixin {
  // Step 0 = pick type, Step 1 = fill details
  int _step = 0;
  _ActivityType? _selected;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  final _durationCtrl   = TextEditingController();
  final _weightCtrl     = TextEditingController();
  final _customNameCtrl = TextEditingController();
  final _formKey        = GlobalKey<FormState>();

  bool get _isOther => _selected?.name == 'Other';

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();

    // Pre-fill weight from user profile
    final w = widget.userWeight;
    _weightCtrl.text = w != null
        ? w.toStringAsFixed(w == w.roundToDouble() ? 0 : 1)
        : '70';
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _durationCtrl.dispose();
    _weightCtrl.dispose();
    _customNameCtrl.dispose();
    super.dispose();
  }

  void _selectActivity(_ActivityType type) {
    setState(() {
      _selected = type;
      _step     = 1;
    });
    _animCtrl
      ..reset()
      ..forward();
  }

  void _goBack() {
    setState(() {
      _step = 0;
      _customNameCtrl.clear();
    });
    _animCtrl
      ..reset()
      ..forward();
  }

  int _estimateCalories() {
    final mins   = int.tryParse(_durationCtrl.text) ?? 0;
    final weight = double.tryParse(_weightCtrl.text) ?? 70;
    return ((_selected?.metValue ?? 5) * weight * mins / 60).round();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    // Store display name for UI (Running, Football, etc.)
    // Repository will map it to backend type (run, walk) before sending to API
    final activityName = _isOther
        ? _customNameCtrl.text.trim()
        : _selected!.name;

    final activity = ActivityModel(
      // Add local_ prefix to distinguish manually logged activities from Health Connect activities
      // Cubit uses this prefix to decide whether to send to backend or not
      id:              'local_${DateTime.now().millisecondsSinceEpoch}',
      type:            activityName,
      durationMinutes: int.parse(_durationCtrl.text),
      caloriesBurned:  _estimateCalories(),
      timestamp:       DateTime.now(),
    );

    context.read<ActivityCubit>().addActivity(activity);
    HapticFeedback.lightImpact();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Container(
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      child: FadeTransition(
        opacity: _fadeAnim,
        child: _step == 0 ? _buildPicker(isDark) : _buildForm(isDark),
      ),
    );
  }

  // Step 0: activity type grid
  Widget _buildPicker(bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SheetHandle(),
        SizedBox(height: 8.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'What did you do?',
              style: TextStyle(
                fontSize:      22.sp,
                fontWeight:    FontWeight.w800,
                color:         context.colors.text,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),
        SizedBox(height: 4.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Choose your activity to log',
              style: TextStyle(
                fontSize: 13.sp,
                color:    context.colors.subText,
              ),
            ),
          ),
        ),
        SizedBox(height: 20.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:   4,
              mainAxisSpacing:  12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.82,
            ),
            itemCount: _kActivities.length,
            itemBuilder: (_, i) => _ActivityTile(
              activity: _kActivities[i],
              isDark:   isDark,
              onTap:    () => _selectActivity(_kActivities[i]),
            ),
          ),
        ),
        SizedBox(height: 12.h),
      ],
    );
  }

  // Step 1: details form
  Widget _buildForm(bool isDark) {
    final act = _selected!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SheetHandle(),
            SizedBox(height: 8.h),

            // Back button and selected activity pill
            Row(
              children: [
                GestureDetector(
                  onTap: _goBack,
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color:        act.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size:  16.sp,
                      color: act.color,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical:   8.h,
                  ),
                  decoration: BoxDecoration(
                    color:        act.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(50.r),
                    border:       Border.all(color: act.color.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(act.icon, color: act.color, size: 18.sp),
                      SizedBox(width: 6.w),
                      // Show display name to user
                      Text(
                        act.name,
                        style: TextStyle(
                          fontSize:   14.sp,
                          fontWeight: FontWeight.w700,
                          color:      act.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 22.h),

            // Custom name field shown only when Other is selected
            if (_isOther) ...[
              _FieldLabel('Activity name', context),
              SizedBox(height: 8.h),
              _InputField(
                controller:      _customNameCtrl,
                hint:            'e.g. Martial arts, Boxing...',
                keyboardType:    TextInputType.text,
                inputFormatters: [],
                prefixIcon:      Icons.edit_rounded,
                accentColor:     act.color,
                isDark:          isDark,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter activity name';
                  return null;
                },
              ),
              SizedBox(height: 16.h),
            ],

            // Duration field
            _FieldLabel('Duration (minutes)', context),
            SizedBox(height: 8.h),
            _InputField(
              controller:      _durationCtrl,
              hint:            'e.g. 30',
              keyboardType:    TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              prefixIcon:      Icons.timer_rounded,
              accentColor:     act.color,
              isDark:          isDark,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter duration';
                final n = int.tryParse(v);
                if (n == null || n <= 0) return 'Must be greater than 0';
                return null;
              },
            ),

            SizedBox(height: 16.h),

            // Weight field
            _FieldLabel('Your weight (kg)', context),
            SizedBox(height: 8.h),
            _InputField(
              controller:   _weightCtrl,
              hint:         '70',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
              prefixIcon:  Icons.monitor_weight_outlined,
              accentColor: act.color,
              isDark:      isDark,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter your weight';
                final n = double.tryParse(v);
                if (n == null || n <= 0) return 'Must be greater than 0';
                return null;
              },
            ),

            SizedBox(height: 12.h),

            // Live calorie estimate preview
            _CaloriePreview(
              durationCtrl: _durationCtrl,
              weightCtrl:   _weightCtrl,
              met:          act.metValue,
              color:        act.color,
              isDark:       isDark,
            ),

            SizedBox(height: 22.h),

            // Save button
            SizedBox(
              width:  double.infinity,
              height: 52.h,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: act.color,
                  foregroundColor: Colors.white,
                  elevation:       0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_rounded, size: 20),
                    SizedBox(width: 8.w),
                    Text(
                      'Log Activity',
                      style: TextStyle(
                        fontSize:   16.sp,
                        fontWeight: FontWeight.w700,
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
  }
}

// Drag handle at top of sheet
class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 12.h, bottom: 4.h),
      child: Center(
        child: Container(
          width:  40.w,
          height: 4.h,
          decoration: BoxDecoration(
            color:        context.colors.subText.withOpacity(0.25),
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      ),
    );
  }
}

// Tappable activity card in the grid
class _ActivityTile extends StatefulWidget {
  final _ActivityType activity;
  final bool isDark;
  final VoidCallback onTap;
  const _ActivityTile({
    required this.activity,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_ActivityTile> createState() => _ActivityTileState();
}

class _ActivityTileState extends State<_ActivityTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.06,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.94).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final act = widget.activity;
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            color: widget.isDark
                ? act.color.withOpacity(0.12)
                : act.color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: act.color.withOpacity(0.2), width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color:  act.color.withOpacity(0.15),
                  shape:  BoxShape.circle,
                ),
                child: Icon(act.icon, color: act.color, size: 22.sp),
              ),
              SizedBox(height: 6.h),
              Text(
                act.name,
                style: TextStyle(
                  fontSize:   10.sp,
                  fontWeight: FontWeight.w600,
                  color:      context.colors.text,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Form field label
class _FieldLabel extends StatelessWidget {
  final String text;
  final BuildContext ctx;
  const _FieldLabel(this.text, this.ctx);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize:      12.sp,
        fontWeight:    FontWeight.w600,
        color:         context.colors.subText,
        letterSpacing: 0.2,
      ),
    );
  }
}

// Reusable styled text input
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final IconData prefixIcon;
  final Color accentColor;
  final bool isDark;
  final String? Function(String?) validator;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.keyboardType,
    required this.inputFormatters,
    required this.prefixIcon,
    required this.accentColor,
    required this.isDark,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller:      controller,
      keyboardType:    keyboardType,
      inputFormatters: inputFormatters,
      validator:       validator,
      style: TextStyle(
        fontSize:   15.sp,
        fontWeight: FontWeight.w600,
        color:      context.colors.text,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color:    context.colors.subText.withOpacity(0.5),
          fontSize: 14.sp,
        ),
        prefixIcon: Icon(prefixIcon, color: accentColor, size: 20.sp),
        filled:     true,
        fillColor: isDark
            ? accentColor.withOpacity(0.07)
            : accentColor.withOpacity(0.05),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical:   14.h,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide:   BorderSide(color: accentColor.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide:   BorderSide(color: accentColor.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide:   BorderSide(color: accentColor, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide:   const BorderSide(color: Color(0xFFFF3B30)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide:   const BorderSide(color: Color(0xFFFF3B30), width: 1.8),
        ),
      ),
    );
  }
}

// Live calorie estimate card that updates on every keystroke
class _CaloriePreview extends StatefulWidget {
  final TextEditingController durationCtrl;
  final TextEditingController weightCtrl;
  final int met;
  final Color color;
  final bool isDark;

  const _CaloriePreview({
    required this.durationCtrl,
    required this.weightCtrl,
    required this.met,
    required this.color,
    required this.isDark,
  });

  @override
  State<_CaloriePreview> createState() => _CaloriePreviewState();
}

class _CaloriePreviewState extends State<_CaloriePreview> {
  @override
  void initState() {
    super.initState();
    widget.durationCtrl.addListener(_rebuild);
    widget.weightCtrl.addListener(_rebuild);
  }

  @override
  void dispose() {
    widget.durationCtrl.removeListener(_rebuild);
    widget.weightCtrl.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  int get _calories {
    final mins   = int.tryParse(widget.durationCtrl.text) ?? 0;
    final weight = double.tryParse(widget.weightCtrl.text) ?? 70;
    return (widget.met * weight * mins / 60).round();
  }

  @override
  Widget build(BuildContext context) {
    if (_calories <= 0) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve:    Curves.easeOut,
      padding:  EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color:        widget.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14.r),
        border:       Border.all(color: widget.color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            color: widget.color,
            size:  20.sp,
          ),
          SizedBox(width: 10.w),
          Text(
            'Estimated calories burned',
            style: TextStyle(
              fontSize: 12.sp,
              color:    context.colors.subText,
            ),
          ),
          const Spacer(),
          Text(
            '$_calories kcal',
            style: TextStyle(
              fontSize:   16.sp,
              fontWeight: FontWeight.w800,
              color:      widget.color,
            ),
          ),
        ],
      ),
    );
  }
}