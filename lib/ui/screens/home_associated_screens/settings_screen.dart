// lib/ui/screens/home_associated_screens/settings_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:vital_metrics/logic/home/theme_cubit.dart';
import 'package:vital_metrics/logic/home/water_cubit.dart';
import 'package:vital_metrics/logic/home/settings/personal_info_cubit.dart';
import 'package:vital_metrics/services/notification_api_service.dart';
import 'package:vital_metrics/data/models/notification_preferences_model.dart';
import 'package:vital_metrics/services/device_token_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _notifLoading = false;
  String _language = 'English';
  String _username = 'Abdelrhman';
  String _email = 'Abdelrhman@gmail.com';
  String? _avatarPath;

  final NotificationApiService _notifService = NotificationApiService();

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadNotifPreference();
  }

  // ── Load ───────────────────────────────────────────────────────────────────

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'Abdelrhman';
      _email = prefs.getString('email') ?? 'Abdelrhman@gmail.com';
      _avatarPath = prefs.getString('avatar_path');
    });
  }

  Future<void> _loadNotifPreference() async {
    try {
      final pref = await _notifService.getPreferences();
      if (mounted) setState(() => _notifications = pref.pushEnabled);
    } catch (_) {
      // keep default true on error
    }
  }

  // ── Save ───────────────────────────────────────────────────────────────────

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', _username);
    await prefs.setString('email', _email);
    if (_avatarPath != null) await prefs.setString('avatar_path', _avatarPath!);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _avatarPath = picked.path);
      _saveProfile();
    }
  }

  // ── Toggle Notifications ───────────────────────────────────────────────────

  Future<void> _toggleNotifications(bool value) async {
    // optimistic update — بيتغير على الفور
    setState(() {
      _notifications = value;
      _notifLoading = true;
    });
    try {
      // بنبعت الـ value مباشرةً من غير ما نعمل GET الأول
      await _notifService.updatePreferences(
        NotificationPreferencesModel(pushEnabled: value),
      );
    } catch (e) {
      debugPrint('[Settings] toggleNotifications error: $e');
      // revert لو السيرفر رد بـ error
      if (mounted) setState(() => _notifications = !value);
    } finally {
      if (mounted) setState(() => _notifLoading = false);
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────────────

  Future<void> _logout() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF16213E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Log Out',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF2D3142),
          ),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: isDark ? Colors.white70 : Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4757),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Log Out',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // 1. Unregister FCM device token
    await DeviceTokenManager.instance.unregisterOnLogout();

    // 2. Clear stored tokens
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('accessToken');
    await prefs.remove('token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_id');

    // 3. Navigate to sign-in
    if (mounted) context.go('/signin');
  }

  // ── TextField builder ──────────────────────────────────────────────────────

  Widget _buildTextField(
    TextEditingController ctrl,
    String label,
    IconData icon,
    bool isDark, {
    TextInputType keyboard = TextInputType.text,
  }) {
    final fillColor = isDark
        ? const Color(0xFF1A1A2E)
        : const Color(0xFFF6F8FF);
    final txtColor = isDark ? Colors.white : const Color(0xFF2D3142);
    final lblColor = isDark ? Colors.white54 : Colors.grey;

    return TextField(
      controller: ctrl,
      keyboardType: keyboard,
      style: TextStyle(color: txtColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: lblColor),
        prefixIcon: Icon(icon, color: const Color(0xFF4361EE)),
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4361EE), width: 2),
        ),
      ),
    );
  }

  // ── Edit Profile Dialog ────────────────────────────────────────────────────

  void _showEditProfileDialog(bool isDark) {
    final nameCtrl = TextEditingController(text: _username);
    final emailCtrl = TextEditingController(text: _email);
    final dlgBg = isDark ? const Color(0xFF16213E) : Colors.white;
    final txtColor = isDark ? Colors.white : const Color(0xFF2D3142);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: dlgBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold, color: txtColor),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(nameCtrl, 'Username', Icons.person_outline, isDark),
            const SizedBox(height: 12),
            _buildTextField(
              emailCtrl,
              'Email',
              Icons.email_outlined,
              isDark,
              keyboard: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4361EE),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              setState(() {
                if (nameCtrl.text.trim().isNotEmpty)
                  _username = nameCtrl.text.trim();
                if (emailCtrl.text.trim().isNotEmpty)
                  _email = emailCtrl.text.trim();
              });
              _saveProfile();
              Navigator.pop(ctx);
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Personal Information Dialog ────────────────────────────────────────────

  void _showPersonalInfoDialog(bool isDark) {
    final info = context.read<PersonalInfoCubit>().state;
    final weightCtrl = TextEditingController(
      text: info.weight.toStringAsFixed(1),
    );
    final heightCtrl = TextEditingController(
      text: info.height.toStringAsFixed(0),
    );
    final yearCtrl = TextEditingController(text: info.yearOfBirth.toString());
    String selectedGender = info.gender;

    final dlgBg = isDark ? const Color(0xFF16213E) : Colors.white;
    final txtColor = isDark ? Colors.white : const Color(0xFF2D3142);
    final fillBg = isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF6F8FF);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          backgroundColor: dlgBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            'Personal Information',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: txtColor,
              fontSize: 16,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gender',
                  style: TextStyle(
                    color: txtColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setDlgState(() => selectedGender = 'male'),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            gradient: selectedGender == 'male'
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFF4361EE),
                                      Color(0xFF4CC9F0),
                                    ],
                                  )
                                : null,
                            color: selectedGender == 'male' ? null : fillBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '♂',
                                style: TextStyle(
                                  fontSize: 22,
                                  color: selectedGender == 'male'
                                      ? Colors.white
                                      : const Color(0xFF4361EE),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Male',
                                style: TextStyle(
                                  color: selectedGender == 'male'
                                      ? Colors.white
                                      : txtColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setDlgState(() => selectedGender = 'female'),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            gradient: selectedGender == 'female'
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFF7B5EA7),
                                      Color(0xFFF72585),
                                    ],
                                  )
                                : null,
                            color: selectedGender == 'female' ? null : fillBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '♀',
                                style: TextStyle(
                                  fontSize: 22,
                                  color: selectedGender == 'female'
                                      ? Colors.white
                                      : const Color(0xFF7B5EA7),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Female',
                                style: TextStyle(
                                  color: selectedGender == 'female'
                                      ? Colors.white
                                      : txtColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  weightCtrl,
                  'Weight (kg)',
                  Icons.monitor_weight_outlined,
                  isDark,
                  keyboard: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  heightCtrl,
                  'Height (cm)',
                  Icons.height,
                  isDark,
                  keyboard: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  yearCtrl,
                  'Year of Birth',
                  Icons.cake_outlined,
                  isDark,
                  keyboard: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4361EE),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              onPressed: () {
                final w = double.tryParse(weightCtrl.text) ?? info.weight;
                final h = double.tryParse(heightCtrl.text) ?? info.height;
                final y = int.tryParse(yearCtrl.text) ?? info.yearOfBirth;
                context.read<PersonalInfoCubit>().save(
                  gender: selectedGender,
                  weight: w,
                  height: h,
                  yearOfBirth: y.clamp(1920, DateTime.now().year - 5),
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Personal info saved ✓'),
                    backgroundColor: const Color(0xFF4361EE),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Reset Water Dialog ─────────────────────────────────────────────────────

  void _showResetWaterDialog(bool isDark) {
    final dlgBg = isDark ? const Color(0xFF16213E) : Colors.white;
    final txtColor = isDark ? Colors.white : const Color(0xFF2D3142);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: dlgBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Reset Water',
          style: TextStyle(fontWeight: FontWeight.bold, color: txtColor),
        ),
        content: Text(
          "Reset today's water intake to 0?",
          style: TextStyle(color: txtColor.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              context.read<WaterCubit>().reset();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Water intake reset ✓'),
                  backgroundColor: const Color(0xFF4361EE),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF6F8FF);
    final cardBg = isDark ? const Color(0xFF16213E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF2D3142);
    final subColor = isDark ? Colors.white54 : Colors.grey;
    final divColor = isDark ? Colors.white12 : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Settings',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.chevron_left,
            color: Color(0xFF4361EE),
            size: 28,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Profile Card ───────────────────────────────────────────────
            FadeInDown(
              child: GestureDetector(
                onTap: () => _showEditProfileDialog(isDark),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4361EE), Color(0xFF7B5EA7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4361EE).withOpacity(0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: Colors.white.withOpacity(0.25),
                              backgroundImage: _avatarPath != null
                                  ? FileImage(File(_avatarPath!))
                                  : null,
                              child: _avatarPath == null
                                  ? Text(
                                      _username.isNotEmpty
                                          ? _username[0].toUpperCase()
                                          : 'A',
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    )
                                  : null,
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 12,
                                  color: Color(0xFF4361EE),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _username,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _email,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.edit_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Account ────────────────────────────────────────────────────
            FadeInDown(
              delay: const Duration(milliseconds: 100),
              child: _SectionCard(
                title: 'Account',
                cardBg: cardBg,
                textColor: textColor,
                divColor: divColor,
                children: [
                  _TileRow(
                    icon: Icons.person_outline,
                    label: 'Edit Profile',
                    textColor: textColor,
                    subColor: subColor,
                    onTap: () => _showEditProfileDialog(isDark),
                  ),
                  _TileRow(
                    icon: Icons.accessibility_new_outlined,
                    label: 'Personal Information',
                    textColor: textColor,
                    subColor: subColor,
                    trailing: BlocBuilder<PersonalInfoCubit, PersonalInfoState>(
                      builder: (_, info) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4361EE).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'BMI: ${info.bmi.toStringAsFixed(1)}',
                          style: const TextStyle(
                            color: Color(0xFF4361EE),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                    onTap: () => _showPersonalInfoDialog(isDark),
                  ),
                  // ✅ Change Password شيل — مش موجود
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── General ────────────────────────────────────────────────────
            FadeInDown(
              delay: const Duration(milliseconds: 200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      'General',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4361EE), Color(0xFF7B5EA7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4361EE).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // ✅ Notification toggle مربوط بالـ API
                        _GradSwitch(
                          icon: Icons.notifications_outlined,
                          label: 'Notifications',
                          value: _notifications,
                          loading: _notifLoading,
                          onChanged: _toggleNotifications,
                        ),
                        const _GradDivider(),
                        _GradLanguage(
                          value: _language,
                          onChanged: (v) => setState(() => _language = v),
                        ),
                        const _GradDivider(),
                        BlocBuilder<ThemeCubit, bool>(
                          builder: (ctx, dark) => _GradSwitch(
                            icon: Icons.dark_mode_outlined,
                            label: 'Dark Mode',
                            value: dark,
                            onChanged: (_) => ctx.read<ThemeCubit>().toggle(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Water ──────────────────────────────────────────────────────
            FadeInDown(
              delay: const Duration(milliseconds: 300),
              child: _SectionCard(
                title: 'Water',
                cardBg: cardBg,
                textColor: textColor,
                divColor: divColor,
                children: [
                  _TileRow(
                    icon: Icons.water_drop_outlined,
                    label: "Reset Today's Water",
                    textColor: textColor,
                    subColor: subColor,
                    iconColor: Colors.blue,
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(isDark ? 0.25 : 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Reset',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    onTap: () => _showResetWaterDialog(isDark),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── More ───────────────────────────────────────────────────────
            FadeInDown(
              delay: const Duration(milliseconds: 400),
              child: _SectionCard(
                title: 'More',
                cardBg: cardBg,
                textColor: textColor,
                divColor: divColor,
                children: [
                  _TileRow(
                    icon: Icons.shield_outlined,
                    label: 'Legal and Policies',
                    textColor: textColor,
                    subColor: subColor,
                    onTap: () {},
                  ),
                  _TileRow(
                    icon: Icons.help_outline,
                    label: 'Help & Feedback',
                    textColor: textColor,
                    subColor: subColor,
                    onTap: () {},
                  ),
                  _TileRow(
                    icon: Icons.info_outline,
                    label: 'About Us',
                    textColor: textColor,
                    subColor: subColor,
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Log Out Button ─────────────────────────────────────────────
            FadeInDown(
              delay: const Duration(milliseconds: 500),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4757).withOpacity(0.12),
                    foregroundColor: const Color(0xFFFF4757),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: const Color(0xFFFF4757).withOpacity(0.35),
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.logout_rounded, size: 20),
                  label: const Text(
                    'Log Out',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  onPressed: _logout,
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Helper Widgets
// ═════════════════════════════════════════════════════════════════════════════

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Color cardBg, textColor, divColor;

  const _SectionCard({
    required this.title,
    required this.children,
    required this.cardBg,
    required this.textColor,
    required this.divColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: textColor,
              fontSize: 15,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  Divider(
                    height: 1,
                    indent: 52,
                    endIndent: 16,
                    color: divColor,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _TileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color textColor, subColor;
  final Color? iconColor;
  final Widget? trailing;
  final VoidCallback onTap;

  const _TileRow({
    required this.icon,
    required this.label,
    required this.textColor,
    required this.subColor,
    this.iconColor,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? const Color(0xFF4361EE)).withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: iconColor ?? const Color(0xFF4361EE),
          size: 18,
        ),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing:
          trailing ?? Icon(Icons.chevron_right, color: subColor, size: 20),
      onTap: onTap,
    );
  }
}

// ✅ _GradSwitch — أضاف loading indicator
class _GradSwitch extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final bool loading;
  final ValueChanged<bool> onChanged;

  const _GradSwitch({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (loading)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          else
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: Colors.white.withOpacity(0.4),
              inactiveThumbColor: Colors.white.withOpacity(0.7),
              inactiveTrackColor: Colors.white.withOpacity(0.2),
            ),
        ],
      ),
    );
  }
}

class _GradLanguage extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _GradLanguage({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.language, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Language',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          DropdownButton<String>(
            value: value,
            dropdownColor: const Color(0xFF4361EE),
            style: const TextStyle(color: Colors.white, fontSize: 14),
            iconEnabledColor: Colors.white,
            underline: const SizedBox(),
            items: [
              'English',
              'Arabic',
              'French',
            ].map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ],
      ),
    );
  }
}

class _GradDivider extends StatelessWidget {
  const _GradDivider();

  @override
  Widget build(BuildContext context) => Container(
    height: 1,
    margin: const EdgeInsets.symmetric(horizontal: 16),
    color: Colors.white.withOpacity(0.2),
  );
}
