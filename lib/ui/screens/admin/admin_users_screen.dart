import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:animate_do/animate_do.dart';
import 'package:vital_metrics/core/themes/theme_context_extension.dart';
import 'package:vital_metrics/data/config/api_config.dart';
import 'package:vital_metrics/data/exceptions/api_exception.dart';
import 'package:vital_metrics/services/api_service.dart';
import 'package:vital_metrics/services/token_storage_service.dart';

// AdminUsersScreen

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});
  @override State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _api          = ApiService();
  final _tokenStorage = TokenStorageService();
  final _searchCtrl   = TextEditingController();

  List<Map<String, dynamic>> _users    = [];
  List<Map<String, dynamic>> _filtered = [];
  bool    _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final token   = await _tokenStorage.getToken();
      final headers = ApiConfig.headers(token: token);
      final raw     = await _api.getAsList(ApiConfig.adminUsers, headers: headers);
      final users   = raw.cast<Map<String, dynamic>>();
      setState(() { _users = users; _filtered = users; _loading = false; });
    } on ApiException catch (e) {
      setState(() { _error = e.message; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _onSearch(String q) {
    setState(() {
      _filtered = _users.where((u) {
        final name  = (u['name']  as String? ?? '').toLowerCase();
        final email = (u['email'] as String? ?? '').toLowerCase();
        final id    = (u['user_id'] ?? '').toString();
        final query = q.toLowerCase();
        return name.contains(query) || email.contains(query) || id.contains(query);
      }).toList();
    });
  }

  Future<void> _deleteUser(Map<String, dynamic> user) async {
    final id   = (user['user_id'] as num?)?.toInt() ?? 0;
    final name = user['name'] as String? ?? 'User';

    final ok = await showCupertinoDialog<bool>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Delete User'),
        content: Text('Delete "$name" (ID: $id)?\nThis cannot be undone.'),
        actions: [
          CupertinoDialogAction(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    try {
      final token   = await _tokenStorage.getToken();
      final headers = ApiConfig.headers(token: token);
      await _api.delete(ApiConfig.adminDeleteUser(id), headers: headers);
      setState(() {
        _users.removeWhere((u) => (u['user_id'] as num?)?.toInt() == id);
        _filtered.removeWhere((u) => (u['user_id'] as num?)?.toInt() == id);
      });
      _snack('"$name" deleted', error: false);
    } catch (e) {
      _snack(e.toString(), error: true);
    }
  }

  void _snack(String msg, {required bool error}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? const Color(0xFFFF4757) : const Color(0xFF63E6BE),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  void _showDetail(Map<String, dynamic> user) {
    final isDark = context.isDark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2340) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(width: 40, height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),

            // Avatar + name
            CircleAvatar(
              radius: 30,
              backgroundColor: const Color(0xFF4361EE).withOpacity(0.15),
              child: Text(
                (user['name'] as String? ?? '?')[0].toUpperCase(),
                style: const TextStyle(
                    color: Color(0xFF4361EE),
                    fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Text(user['name'] as String? ?? '',
                style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    fontWeight: FontWeight.bold, fontSize: 18)),
            if (user['is_admin'] == true)
              Container(
                margin: const EdgeInsets.only(top: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFA94D).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFA94D).withOpacity(0.4)),
                ),
                child: const Text('Admin',
                    style: TextStyle(
                        color: Color(0xFFFFA94D),
                        fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            const SizedBox(height: 20),

            // Details
            _DetailItem('ID',      '${user['user_id']}', isDark),
            _DetailItem('Email',   user['email']        ?? '-', isDark),
            _DetailItem('Gender',  user['gender']       ?? '-', isDark),
            _DetailItem('DOB',     user['date_of_birth'] ?? '-', isDark),
            _DetailItem('Height',  '${user['height']} cm', isDark),
            _DetailItem('Weight',  '${user['weight']} kg', isDark),
            const SizedBox(height: 20),

            // Delete button
            if (user['is_admin'] != true)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _deleteUser(user);
                  },
                  icon: const Icon(CupertinoIcons.trash, size: 16),
                  label: const Text('Delete User'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4757).withOpacity(0.12),
                    foregroundColor: const Color(0xFFFF4757),
                    elevation: 0,
                    side: const BorderSide(color: Color(0xFFFF4757)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bg     = isDark ? const Color(0xFF0F1221) : const Color(0xFFF0F3FF);
    final card   = isDark ? const Color(0xFF1A2340) : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            FadeInDown(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Users',
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                          fontWeight: FontWeight.bold, fontSize: 24,
                        )),
                    Text('${_filtered.length} users',
                        style: TextStyle(
                          color: isDark ? Colors.white38 : const Color(0xFF9B9B9B),
                          fontSize: 12,
                        )),
                  ]),
                  const Spacer(),
                  IconButton(
                    onPressed: _load,
                    icon: const Icon(Icons.refresh,
                        color: Color(0xFF4361EE), size: 22),
                  ),
                ]),
              ),
            ),

            // Search
            FadeInDown(
              delay: const Duration(milliseconds: 60),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                      blurRadius: 10,
                    )],
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: _onSearch,
                    style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E)),
                    decoration: InputDecoration(
                      hintText: 'Search by name, email, or ID',
                      hintStyle: TextStyle(
                          color: isDark ? Colors.white30 : Colors.grey),
                      prefixIcon: const Icon(CupertinoIcons.search,
                          color: Color(0xFF4361EE), size: 20),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              ),
            ),

            // List
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(
                      color: Color(0xFF4361EE), strokeWidth: 2.5))
                  : _error != null
                      ? Center(child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline,
                                color: Color(0xFFFF4757), size: 48),
                            const SizedBox(height: 12),
                            Text(_error!,
                                style: TextStyle(
                                    color: isDark ? Colors.white70
                                        : const Color(0xFF2D3142))),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _load,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4361EE)),
                              child: const Text('Retry',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ))
                      : _filtered.isEmpty
                          ? Center(child: Text('No users found',
                              style: TextStyle(
                                  color: isDark ? Colors.white38 : Colors.grey)))
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
                              itemCount: _filtered.length,
                              itemBuilder: (_, i) {
                                final u    = _filtered[i];
                                final name = u['name']  as String? ?? '';
                                final mail = u['email'] as String? ?? '';
                                final id   = u['user_id'];
                                final isAdm = u['is_admin'] as bool? ?? false;

                                return FadeInLeft(
                                  delay: Duration(milliseconds: 40 * i),
                                  child: GestureDetector(
                                    onTap: () => _showDetail(u),
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: card,
                                        borderRadius: BorderRadius.circular(16),
                                        border: isAdm
                                            ? Border.all(
                                                color: const Color(0xFFFFA94D)
                                                    .withOpacity(0.35))
                                            : (isDark ? Border.all(
                                                color: Colors.white.withOpacity(0.05))
                                                : null),
                                        boxShadow: [BoxShadow(
                                          color: Colors.black.withOpacity(
                                              isDark ? 0.3 : 0.06),
                                          blurRadius: 10,
                                          offset: const Offset(0, 3),
                                        )],
                                      ),
                                      child: Row(children: [
                                        // Avatar
                                        CircleAvatar(
                                          radius: 22,
                                          backgroundColor: const Color(0xFF4361EE)
                                              .withOpacity(0.14),
                                          child: Text(
                                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                                            style: const TextStyle(
                                                color: Color(0xFF4361EE),
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        const SizedBox(width: 12),

                                        // Info
                                        Expanded(child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(children: [
                                              Expanded(child: Text(name,
                                                  style: TextStyle(
                                                    color: isDark ? Colors.white
                                                        : const Color(0xFF1A1A2E),
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                  ),
                                                  overflow: TextOverflow.ellipsis)),
                                              if (isAdm)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 7, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFFFA94D)
                                                        .withOpacity(0.14),
                                                    borderRadius:
                                                        BorderRadius.circular(6),
                                                  ),
                                                  child: const Text('Admin',
                                                      style: TextStyle(
                                                        color: Color(0xFFFFA94D),
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.bold,
                                                      )),
                                                ),
                                            ]),
                                            const SizedBox(height: 3),
                                            Text(mail,
                                                style: TextStyle(
                                                  color: isDark ? Colors.white38
                                                      : const Color(0xFF9B9B9B),
                                                  fontSize: 12,
                                                ),
                                                overflow: TextOverflow.ellipsis),
                                          ],
                                        )),

                                        // ID + delete
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text('ID: $id',
                                                style: TextStyle(
                                                  color: isDark ? Colors.white24
                                                      : Colors.grey,
                                                  fontSize: 11,
                                                )),
                                            const SizedBox(height: 6),
                                            if (!isAdm)
                                              GestureDetector(
                                                onTap: () => _deleteUser(u),
                                                child: Container(
                                                  padding: const EdgeInsets.all(6),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFFF4757)
                                                        .withOpacity(0.12),
                                                    borderRadius:
                                                        BorderRadius.circular(8),
                                                  ),
                                                  child: const Icon(
                                                      CupertinoIcons.trash,
                                                      color: Color(0xFFFF4757),
                                                      size: 14),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ]),
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label, value;
  final bool   isDark;
  const _DetailItem(this.label, this.value, this.isDark);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      SizedBox(width: 80,
          child: Text(label,
              style: TextStyle(
                  color: isDark ? Colors.white38 : const Color(0xFF9B9B9B),
                  fontSize: 12))),
      Expanded(child: Text(value,
          style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              fontWeight: FontWeight.w500, fontSize: 13))),
    ]),
  );
}