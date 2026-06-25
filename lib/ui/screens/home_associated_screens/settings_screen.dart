// lib/ui/screens/home_associated_screens/settings_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:vital_metrics/logic/home/theme_cubit.dart';
import 'package:vital_metrics/logic/home/water_cubit.dart';
import 'package:vital_metrics/logic/home/locale_cubit.dart';
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
  // Single source of truth for notification preferences
  NotificationPreferencesModel _currentPrefs =
      const NotificationPreferencesModel();
  bool _notifLoading = false;

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

  // Load

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAvatarPath = prefs.getString('avatar_path');

    // The cached/saved file may no longer exist (Android can wipe cache at
    // any time, the app may have been reinstalled, etc). Verify it before
    // ever handing it to FileImage, otherwise we crash with
    // PathNotFoundException on first frame.
    final avatarStillExists =
        savedAvatarPath != null && File(savedAvatarPath).existsSync();

    setState(() {
      _username = prefs.getString('username') ?? 'Abdelrhman';
      _email = prefs.getString('email') ?? 'Abdelrhman@gmail.com';
      _avatarPath = avatarStillExists ? savedAvatarPath : null;
    });

    // clean up the stale reference so we don't keep re-checking it
    if (!avatarStillExists && savedAvatarPath != null) {
      await prefs.remove('avatar_path');
    }
  }

  // GET /notifications/preferences — fetches the full object and keeps it
  Future<void> _loadNotifPreference() async {
    try {
      final pref = await _notifService.getPreferences();
      if (mounted) setState(() => _currentPrefs = pref);
    } catch (_) {
      // keep default on error
    }
  }

  // Save

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', _username);
    await prefs.setString('email', _email);
    if (_avatarPath != null) await prefs.setString('avatar_path', _avatarPath!);
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (picked == null) return;

      // image_picker hands back a file inside the app's OS cache dir
      // (and for PNGs it doesn't even resize/compress it, just returns the
      // original — see the "compressing is not supported for type PNG" log).
      // The cache dir can be cleared by the system at any time, so we copy
      // the picked image into permanent app storage before saving its path.
      final docsDir = await getApplicationDocumentsDirectory();
      final ext = picked.path.contains('.')
          ? picked.path.split('.').last
          : 'jpg';
      final savedPath = '${docsDir.path}/avatar.$ext';

      // remove any previous avatar file(s), they might have a different
      // extension than the new one (e.g. old .jpg, new .png)
      for (final entity in docsDir.listSync()) {
        if (entity is File && entity.path.contains('${docsDir.path}/avatar.')) {
          await entity.delete();
        }
      }

      final savedFile = await File(picked.path).copy(savedPath);

      if (!mounted) return;
      setState(() => _avatarPath = savedFile.path);
      await _saveProfile();
    } catch (e) {
      debugPrint('[Settings] pickImage error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not update profile photo. Please try again.'),
          ),
        );
      }
    }
  }

  // Toggle master push switch
  Future<void> _toggleNotifications(bool value) async {
    // prevent double-tap while loading
    if (_notifLoading) return;

    final previous = _currentPrefs;

    // optimistic update — UI changes immediately
    setState(() {
      _currentPrefs = _currentPrefs.copyWith(pushEnabled: value);
      _notifLoading = true;
    });

    try {
      // send the full object — we don't setState from the response
      // because the server might return pushEnabled: true even if we sent false
      await _notifService.updatePreferences(_currentPrefs);
    } catch (e) {
      debugPrint('[Settings] toggleNotifications error: $e');
      // revert only if there was an actual server error
      if (mounted) setState(() => _currentPrefs = previous);
    } finally {
      if (mounted) setState(() => _notifLoading = false);
    }
  }

  // Update a single preference field
  // Used by the NotificationTypesDialog whenever any type changes
  Future<void> _updatePrefs(NotificationPreferencesModel updated) async {
    final previous = _currentPrefs;
    setState(() => _currentPrefs = updated);
    try {
      final fromServer = await _notifService.updatePreferences(updated);
      if (mounted) setState(() => _currentPrefs = fromServer);
    } catch (e) {
      debugPrint('[Settings] updatePrefs error: $e');
      if (mounted) setState(() => _currentPrefs = previous);
    }
  }

  // Logout

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

    await DeviceTokenManager.instance.unregisterOnLogout();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('accessToken');
    await prefs.remove('token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_id');

    if (mounted) context.go('/signin');
  }

  // TextField builder

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

  // Edit Profile Dialog

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

  // Personal Information Dialog

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

  // Notification Types Dialog
  // Full bottom sheet with a switch for each notification type
  void _showNotificationTypesDialog(bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _NotificationTypesSheet(
        isDark: isDark,
        currentPrefs: _currentPrefs,
        onSave: (updated) {
          Navigator.pop(ctx);
          _updatePrefs(updated);
        },
      ),
    );
  }

  // Reset Water Dialog

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

  // Build

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF6F8FF);
    final cardBg = isDark ? const Color(0xFF16213E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF2D3142);
    final subColor = isDark ? Colors.white54 : Colors.grey;
    final divColor = isDark ? Colors.white12 : Colors.grey.shade200;

    // Verify the file is actually there right before we hand it to
    // FileImage — this is what prevents the PathNotFoundException crash.
    final avatarExists = _avatarPath != null && File(_avatarPath!).existsSync();

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
            // Profile Card
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
                              backgroundImage: avatarExists
                                  ? FileImage(File(_avatarPath!))
                                  : null,
                              // extra safety net: if the file vanishes
                              // between the existsSync check above and the
                              // actual decode (rare race), fall back to the
                              // initials instead of crashing.
                              onBackgroundImageError: avatarExists
                                  ? (_, __) {
                                      if (mounted) {
                                        setState(() => _avatarPath = null);
                                      }
                                    }
                                  : null,
                              child: !avatarExists
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

            // Account
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
                ],
              ),
            ),

            const SizedBox(height: 20),

            // General
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
                        // master push toggle — keeps all the prefs
                        _GradSwitch(
                          icon: Icons.notifications_outlined,
                          label: 'Notifications',
                          value: _currentPrefs.pushEnabled,
                          loading: _notifLoading,
                          onChanged: _toggleNotifications,
                        ),

                        // Notification Types — opens the sheet
                        if (_currentPrefs.pushEnabled) ...[
                          const _GradDivider(),
                          _GradTileRow(
                            icon: Icons.tune_outlined,
                            label: 'Notification Types',
                            subtitle: _activeTypesLabel,
                            onTap: () => _showNotificationTypesDialog(isDark),
                          ),
                        ],

                        const _GradDivider(),
                        // Language toggle — Arabic / English only, drives LocaleCubit
                        const _GradLanguage(),

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

            // Water
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

            // More
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

            // Log Out Button
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

  // short label that shows the active types in the tile
  String get _activeTypesLabel {
    final p = _currentPrefs;
    final active = <String>[];
    if (p.waterReminders) active.add('💧');
    if (p.sleepReminders) active.add('🌙');
    if (p.activityReminders) active.add('🏃');
    if (p.mealReminders) active.add('🥗');
    if (p.goalAlerts) active.add('🎉');
    if (p.dailyReminder) active.add('🔔');
    if (active.isEmpty) return 'All off';
    if (active.length == 6) return 'All on';
    return active.join(' ');
  }
}

// _NotificationTypesSheet — bottom sheet that controls notification types

class _NotificationTypesSheet extends StatefulWidget {
  final bool isDark;
  final NotificationPreferencesModel currentPrefs;
  final ValueChanged<NotificationPreferencesModel> onSave;

  const _NotificationTypesSheet({
    required this.isDark,
    required this.currentPrefs,
    required this.onSave,
  });

  @override
  State<_NotificationTypesSheet> createState() =>
      _NotificationTypesSheetState();
}

class _NotificationTypesSheetState extends State<_NotificationTypesSheet> {
  late NotificationPreferencesModel _prefs;

  @override
  void initState() {
    super.initState();
    _prefs = widget.currentPrefs;
  }

  // UI

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final bg = isDark ? const Color(0xFF16213E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF2D3142);
    final subColor = isDark ? Colors.white54 : Colors.grey.shade600;
    final divColor = isDark ? Colors.white12 : Colors.grey.shade200;

    final screenHeight = MediaQuery.of(context).size.height;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      // maxHeight prevents the sheet from exceeding 90% of the screen
      constraints: BoxConstraints(maxHeight: screenHeight * 0.90),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle (fixed, outside the scroll)
          const SizedBox(height: 12),
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Header (fixed)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4361EE), Color(0xFF7B5EA7)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notification Types',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Choose which alerts you want to receive',
                        style: TextStyle(color: subColor, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Divider(height: 1, color: divColor),

          // scrollable part (list + Quiet Hours)
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: bottomInset + 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Toggle List
                  _TypeTile(
                    emoji: '🔔',
                    label: 'Daily Reminder',
                    description: 'Morning summary & daily goals',
                    value: _prefs.dailyReminder,
                    color: const Color(0xFF9B9B9B),
                    isDark: isDark,
                    onChanged: (v) => setState(
                      () => _prefs = _prefs.copyWith(dailyReminder: v),
                    ),
                  ),
                  Divider(height: 1, indent: 68, color: divColor),

                  _TypeTile(
                    emoji: '🎉',
                    label: 'Goal Alerts',
                    description: 'Get notified when you hit your goals',
                    value: _prefs.goalAlerts,
                    color: const Color(0xFF4361EE),
                    isDark: isDark,
                    onChanged: (v) =>
                        setState(() => _prefs = _prefs.copyWith(goalAlerts: v)),
                  ),
                  Divider(height: 1, indent: 68, color: divColor),

                  _TypeTile(
                    emoji: '💧',
                    label: 'Water Reminders',
                    description: 'Stay hydrated throughout the day',
                    value: _prefs.waterReminders,
                    color: const Color(0xFF4CC9F0),
                    isDark: isDark,
                    onChanged: (v) => setState(
                      () => _prefs = _prefs.copyWith(waterReminders: v),
                    ),
                  ),
                  Divider(height: 1, indent: 68, color: divColor),

                  _TypeTile(
                    emoji: '🥗',
                    label: 'Meal Reminders',
                    description: 'Log your meals on time',
                    value: _prefs.mealReminders,
                    color: const Color(0xFF51CF66),
                    isDark: isDark,
                    onChanged: (v) => setState(
                      () => _prefs = _prefs.copyWith(mealReminders: v),
                    ),
                  ),
                  Divider(height: 1, indent: 68, color: divColor),

                  _TypeTile(
                    emoji: '🏃',
                    label: 'Activity Reminders',
                    description: 'Move your body & hit step goals',
                    value: _prefs.activityReminders,
                    color: const Color(0xFF63E6BE),
                    isDark: isDark,
                    onChanged: (v) => setState(
                      () => _prefs = _prefs.copyWith(activityReminders: v),
                    ),
                  ),
                  Divider(height: 1, indent: 68, color: divColor),

                  _TypeTile(
                    emoji: '🌙',
                    label: 'Sleep Reminders',
                    description: 'Wind down & improve sleep quality',
                    value: _prefs.sleepReminders,
                    color: const Color(0xFF7B5EA7),
                    isDark: isDark,
                    onChanged: (v) => setState(
                      () => _prefs = _prefs.copyWith(sleepReminders: v),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Quiet Hours
                  _QuietHoursRow(
                    isDark: isDark,
                    start: _prefs.quietHoursStart,
                    end: _prefs.quietHoursEnd,
                    textColor: textColor,
                    subColor: subColor,
                    onStartChanged: (v) => setState(
                      () => _prefs = _prefs.copyWith(quietHoursStart: v),
                    ),
                    onEndChanged: (v) => setState(
                      () => _prefs = _prefs.copyWith(quietHoursEnd: v),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Save Button (fixed at the bottom)
          Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, bottomInset + 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: const Color(0xFF4361EE),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                onPressed: () => widget.onSave(_prefs),
                child: const Text(
                  'Save Preferences',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Single type toggle tile

class _TypeTile extends StatelessWidget {
  final String emoji;
  final String label;
  final String description;
  final bool value;
  final Color color;
  final bool isDark;
  final ValueChanged<bool> onChanged;

  const _TypeTile({
    required this.emoji,
    required this.label,
    required this.description,
    required this.value,
    required this.color,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : const Color(0xFF2D3142);
    final subColor = isDark ? Colors.white54 : Colors.grey.shade600;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        description,
        style: TextStyle(color: subColor, fontSize: 11),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: color,
        activeTrackColor: color.withOpacity(0.25),
        inactiveThumbColor: isDark ? Colors.white38 : Colors.grey.shade400,
        inactiveTrackColor: isDark ? Colors.white12 : Colors.grey.shade200,
      ),
    );
  }
}

// Quiet Hours Row

class _QuietHoursRow extends StatelessWidget {
  final bool isDark;
  final String start;
  final String end;
  final Color textColor;
  final Color subColor;
  final ValueChanged<String> onStartChanged;
  final ValueChanged<String> onEndChanged;

  const _QuietHoursRow({
    required this.isDark,
    required this.start,
    required this.end,
    required this.textColor,
    required this.subColor,
    required this.onStartChanged,
    required this.onEndChanged,
  });

  Future<void> _pick(
    BuildContext context,
    String current,
    ValueChanged<String> onChanged,
  ) async {
    final parts = current.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 22,
      minute: int.tryParse(parts[1]) ?? 0,
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4361EE),
            brightness: isDark ? Brightness.dark : Brightness.light,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      final formatted =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      onChanged(formatted);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF6F8FF);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.bedtime_outlined,
                  color: Color(0xFF7B5EA7),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Quiet Hours',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'No notifications during this period',
              style: TextStyle(color: subColor, fontSize: 11),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _TimeChip(
                    label: 'From',
                    time: start,
                    isDark: isDark,
                    onTap: () => _pick(context, start, onStartChanged),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TimeChip(
                    label: 'To',
                    time: end,
                    isDark: isDark,
                    onTap: () => _pick(context, end, onEndChanged),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String label;
  final String time;
  final bool isDark;
  final VoidCallback onTap;

  const _TimeChip({
    required this.label,
    required this.time,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF4361EE).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF4361EE).withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF4361EE),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  color: Color(0xFF4361EE),
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  time,
                  style: const TextStyle(
                    color: Color(0xFF4361EE),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Helper Widgets

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

// Tile inside the gradient card that navigates to another screen
class _GradTileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _GradTileRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.65),
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white70, size: 20),
          ],
        ),
      ),
    );
  }
}

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
              // null = disabled while loading, prevents double-tap
              onChanged: loading ? null : onChanged,
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

// Language row — Arabic / English toggle wired to LocaleCubit.
// This is the single switch that controls which language is used
// everywhere FoodItem.displayName / Recipe.displayName are read.
class _GradLanguage extends StatelessWidget {
  const _GradLanguage();

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LocaleCubit>().state;

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
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _LangChip(
                  label: 'EN',
                  selected: !isArabic,
                  onTap: () => context.read<LocaleCubit>().setArabic(false),
                ),
                _LangChip(
                  label: 'عربي',
                  selected: isArabic,
                  onTap: () => context.read<LocaleCubit>().setArabic(true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LangChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF4361EE) : Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
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
