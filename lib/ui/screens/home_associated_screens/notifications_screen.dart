// lib/presentation/screens/notifications_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vital_metrics/core/themes/theme_context_extension.dart';
import 'package:vital_metrics/data/models/notification_model.dart';
import 'package:vital_metrics/logic/notifications/notifications_cubit.dart';
import 'package:vital_metrics/logic/notifications/notifications_state.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _State();
}

class _State extends State<NotificationsScreen> with TickerProviderStateMixin {

  late final AnimationController _bellCtrl;
  late final Animation<double>   _bellShake, _bellScale, _bellGlow;

  bool _selectMode = false;
  final Set<int> _selectedIds = {};

  @override
  void initState() {
    super.initState();

    _bellCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));

    _bellShake = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0,   end:  0.18), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.18,  end: -0.14), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.14, end:  0.10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.10,  end: -0.06), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.06, end:  0.0),  weight: 1),
    ]).animate(CurvedAnimation(parent: _bellCtrl, curve: Curves.easeInOut));

    _bellScale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0,  end: 1.15), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0),  weight: 1),
    ]).animate(CurvedAnimation(parent: _bellCtrl, curve: Curves.easeInOut));

    _bellGlow = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.7), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.7, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _bellCtrl, curve: Curves.easeInOut));

    context.read<NotificationsCubit>().loadNotifications();
    _runBellLoop();
  }

  void _runBellLoop() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 3));
      if (mounted && context.read<NotificationsCubit>().unreadCount > 0) {
        await _bellCtrl.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _bellCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _toggleSelect(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
      if (_selectedIds.isEmpty) _selectMode = false;
    });
  }

  void _toggleSelectAll(List<NotificationItem> items) {
    setState(() {
      if (_selectedIds.length == items.length) {
        _selectedIds.clear();
      } else {
        _selectedIds
          ..clear()
          ..addAll(items.map((n) => n.notificationId));
      }
    });
  }

  void _exitSelectMode() {
    setState(() {
      _selectMode = false;
      _selectedIds.clear();
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F1221)
          : const Color(0xFFF0F3FF),
      body: SafeArea(
        child: BlocBuilder<NotificationsCubit, NotificationsState>(
          builder: (context, state) {
            final items  = state is NotificationsLoaded ? state.items : <NotificationItem>[];
            final unread = state is NotificationsLoaded ? state.unreadCount : 0;
            final allSel = _selectedIds.length == items.length && items.isNotEmpty;

            return Column(
              children: [
                _header(context, isDark, unread),
                _actionBar(context, isDark, items, unread),
                if (_selectMode) _selectBar(context, isDark, items, allSel),
                Expanded(
                  child: state is NotificationsLoading
                      ? const Center(child: CircularProgressIndicator())
                      : state is NotificationsError
                          ? _buildError(isDark, state.message)
                          : items.isEmpty
                              ? _empty(isDark)
                              : _list(context, isDark, items),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── Error ─────────────────────────────────────────────────────────────────

  Widget _buildError(bool isDark, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFFF6B6B), size: 48),
          const SizedBox(height: 12),
          Text(message,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey)),
          const SizedBox(height: 16),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF4361EE),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () =>
                context.read<NotificationsCubit>().loadNotifications(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _header(BuildContext context, bool isDark, int unread) {
    final cardBg = isDark ? const Color(0xFF1A2340) : Colors.white;
    final shadow = isDark ? Colors.black38 : Colors.black.withOpacity(0.07);

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: shadow, blurRadius: 12)],
              ),
              child: const Icon(CupertinoIcons.chevron_left,
                  color: Color(0xFF4361EE), size: 20),
            ),
          ),
          const SizedBox(width: 12),

          // Animated bell
          AnimatedBuilder(
            animation: _bellCtrl,
            builder: (_, __) => Stack(
              clipBehavior: Clip.none,
              children: [
                if (unread > 0)
                  Positioned.fill(
                    child: Opacity(
                      opacity: _bellGlow.value,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4361EE).withOpacity(0.6),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Transform.scale(
                  scale: _bellScale.value,
                  child: Transform.rotate(
                    angle: _bellShake.value,
                    alignment: Alignment.topCenter,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: unread > 0
                            ? const LinearGradient(
                                colors: [Color(0xFF4361EE), Color(0xFF4CC9F0)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: unread == 0 ? cardBg : null,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: unread > 0
                                ? const Color(0xFF4361EE).withOpacity(0.40)
                                : shadow,
                            blurRadius: unread > 0 ? 14 : 10,
                          ),
                        ],
                      ),
                      child: Icon(CupertinoIcons.bell_fill,
                          color: unread > 0
                              ? Colors.white
                              : (isDark
                                  ? Colors.white54
                                  : const Color(0xFF4361EE)),
                          size: 20),
                    ),
                  ),
                ),
                if (unread > 0)
                  Positioned(
                    top: -5, right: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF4757),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF0F1221)
                              : const Color(0xFFF0F3FF),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF4757).withOpacity(0.4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Text('$unread',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Notifications',
                    style: TextStyle(
                        color: isDark
                            ? Colors.white
                            : const Color(0xFF1A1A2E),
                        fontWeight: FontWeight.bold,
                        fontSize: 20)),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    unread > 0
                        ? '$unread unread message${unread > 1 ? 's' : ''}'
                        : 'All caught up ✓',
                    key: ValueKey(unread),
                    style: TextStyle(
                        color: unread > 0
                            ? const Color(0xFF4361EE)
                            : (isDark
                                ? Colors.white30
                                : const Color(0xFF9B9B9B)),
                        fontSize: 11,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),

          // Select toggle
          GestureDetector(
            onTap: () {
              if (_selectMode) {
                _exitSelectMode();
              } else {
                setState(() => _selectMode = true);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _selectMode
                    ? const Color(0xFF4361EE)
                    : const Color(0xFF4361EE)
                        .withOpacity(isDark ? 0.18 : 0.09),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: const Color(0xFF4361EE).withOpacity(0.35)),
              ),
              child: Text(
                _selectMode ? 'Cancel' : 'Select',
                style: TextStyle(
                    color: _selectMode
                        ? Colors.white
                        : const Color(0xFF4361EE),
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Action Bar ────────────────────────────────────────────────────────────

  Widget _actionBar(BuildContext context, bool isDark,
      List<NotificationItem> items, int unread) {
    final cubit = context.read<NotificationsCubit>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(
        children: [
          _ActionBtn(
            label:   'Read All',
            icon:    CupertinoIcons.checkmark_circle_fill,
            color:   const Color(0xFF4361EE),
            enabled: unread > 0,
            isDark:  isDark,
            onTap:   cubit.markAllAsRead,
          ),
          const SizedBox(width: 10),
          _ActionBtn(
            label:   'Delete All',
            icon:    CupertinoIcons.trash_fill,
            color:   const Color(0xFFFF4757),
            enabled: items.isNotEmpty,
            isDark:  isDark,
            onTap:   () => _confirmDeleteAll(context, isDark),
          ),
          const SizedBox(width: 10),
          _ActionBtn(
            label:   'Refresh',
            icon:    CupertinoIcons.refresh,
            color:   const Color(0xFF2ECC9A),
            enabled: true,
            isDark:  isDark,
            onTap:   cubit.loadNotifications,
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAll(BuildContext ctx, bool isDark) async {
    final ok = await showCupertinoDialog<bool>(
      context: ctx,
      builder: (_) => CupertinoAlertDialog(
        title:   const Text('Delete All?'),
        content: const Text('This will remove all notifications permanently.'),
        actions: [
          CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete')),
          CupertinoDialogAction(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
        ],
      ),
    );
    if (ok == true && mounted) {
      context.read<NotificationsCubit>().deleteAll();
      _exitSelectMode();
    }
  }

  // ── Select Bar ────────────────────────────────────────────────────────────

  Widget _selectBar(BuildContext context, bool isDark,
      List<NotificationItem> items, bool allSel) {
    final hasSel = _selectedIds.isNotEmpty;
    final cubit  = context.read<NotificationsCubit>();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2340) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: hasSel
                ? const Color(0xFF4361EE).withOpacity(0.45)
                : Colors.transparent),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black38 : Colors.black.withOpacity(0.06),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _toggleSelectAll(items),
            child: Row(children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  allSel
                      ? CupertinoIcons.checkmark_square_fill
                      : CupertinoIcons.square,
                  key: ValueKey(allSel),
                  color: allSel
                      ? const Color(0xFF4361EE)
                      : (isDark ? Colors.white30 : Colors.grey),
                  size: 20,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                allSel ? 'Deselect All' : 'Select All',
                style: TextStyle(
                    color: isDark
                        ? Colors.white70
                        : const Color(0xFF2D3142),
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
            ]),
          ),
          const Spacer(),
          if (hasSel) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF4361EE).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('${_selectedIds.length} selected',
                  style: const TextStyle(
                      color: Color(0xFF4361EE),
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                cubit.markSelectedAsRead(_selectedIds.toList());
                _exitSelectMode();
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4361EE).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(CupertinoIcons.checkmark_circle_fill,
                    color: Color(0xFF4361EE), size: 18),
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () {
                cubit.deleteSelected(_selectedIds.toList());
                _exitSelectMode();
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4757).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(CupertinoIcons.trash_fill,
                    color: Color(0xFFFF4757), size: 18),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── List ──────────────────────────────────────────────────────────────────

  Widget _list(BuildContext context, bool isDark, List<NotificationItem> items) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        final isSelected = _selectedIds.contains(item.notificationId);
        return _NotifCard(
          key:        ValueKey(item.notificationId),
          item:       item,
          index:      i,
          isDark:     isDark,
          selectMode: _selectMode,
          isSelected: isSelected,
          onTap: () {
            if (_selectMode) {
              _toggleSelect(item.notificationId);
            } else {
              context
                  .read<NotificationsCubit>()
                  .markAsRead(item.notificationId);
            }
          },
          onLongPress: () => setState(() {
            _selectMode = true;
            _selectedIds.add(item.notificationId);
          }),
          onDismiss: () => context
              .read<NotificationsCubit>()
              .deleteNotification(item.notificationId),
        );
      },
    );
  }

  // ── Empty ─────────────────────────────────────────────────────────────────

  Widget _empty(bool isDark) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 88, height: 88,
        decoration: BoxDecoration(
          color: const Color(0xFF4361EE).withOpacity(isDark ? 0.15 : 0.08),
          shape: BoxShape.circle,
        ),
        child: const Center(
            child: Text('🔔', style: TextStyle(fontSize: 38))),
      ),
      const SizedBox(height: 16),
      Text('All caught up!',
          style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              fontWeight: FontWeight.bold,
              fontSize: 20)),
      const SizedBox(height: 6),
      Text('No notifications right now',
          style: TextStyle(
              color: isDark ? Colors.white30 : const Color(0xFF9B9B9B),
              fontSize: 14)),
    ]),
  );
}

// ═════════════════════════════════════════════════════════════════════════════
// _ActionBtn
// ═════════════════════════════════════════════════════════════════════════════
class _ActionBtn extends StatelessWidget {
  final String     label;
  final IconData   icon;
  final Color      color;
  final bool       enabled, isDark;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label, required this.icon,
    required this.color, required this.enabled,
    required this.isDark, required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.38,
        duration: const Duration(milliseconds: 250),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: color.withOpacity(isDark ? 0.16 : 0.09),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.30)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 15),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    ),
  );
}

// ═════════════════════════════════════════════════════════════════════════════
// _NotifCard
// ═════════════════════════════════════════════════════════════════════════════
class _NotifCard extends StatefulWidget {
  final NotificationItem item;
  final int              index;
  final bool             isDark, selectMode, isSelected;
  final VoidCallback     onTap, onLongPress, onDismiss;

  const _NotifCard({
    super.key,
    required this.item,
    required this.index,
    required this.isDark,
    required this.selectMode,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    required this.onDismiss,
  });

  @override
  State<_NotifCard> createState() => _NotifCardState();
}

class _NotifCardState extends State<_NotifCard>
    with SingleTickerProviderStateMixin {

  late final AnimationController _ctrl;
  late final Animation<double>   _fade, _slide, _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 480));

    _fade  = CurvedAnimation(parent: _ctrl,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOut));
    _slide = Tween(begin: 36.0, end: 0.0).animate(
        CurvedAnimation(parent: _ctrl,
            curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic)));
    _scale = Tween(begin: 0.90, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl,
            curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack)));

    Future.delayed(
        Duration(milliseconds: 55 * widget.index),
        () { if (mounted) _ctrl.forward(); });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final item       = widget.item;
    final isDark     = widget.isDark;
    final isSelected = widget.isSelected;
    final color      = item.type.color;

    final cardBg = isDark
        ? (item.isRead ? const Color(0xFF1A2340) : const Color(0xFF1E2D4A))
        : (item.isRead ? Colors.white : const Color(0xFFEEF2FF));

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Opacity(
        opacity: _fade.value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, _slide.value),
          child: Transform.scale(
            scale: _scale.value,
            child: Dismissible(
              key: ValueKey('d_${item.notificationId}'),
              direction: widget.selectMode
                  ? DismissDirection.none
                  : DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 22),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4757),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.trash_fill,
                        color: Colors.white, size: 22),
                    SizedBox(height: 4),
                    Text('Delete',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              onDismissed: (_) => widget.onDismiss(),
              child: GestureDetector(
                onTap:       widget.onTap,
                onLongPress: widget.onLongPress,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(18),
                    border: isSelected
                        ? Border.all(color: const Color(0xFF4361EE), width: 2)
                        : (!item.isRead
                            ? Border.all(
                                color: color.withOpacity(isDark ? 0.38 : 0.25),
                                width: 1)
                            : (isDark
                                ? Border.all(
                                    color: Colors.white.withOpacity(0.05),
                                    width: 1)
                                : null)),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black45
                            : Colors.black.withOpacity(0.06),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                      if (isSelected)
                        BoxShadow(
                          color: const Color(0xFF4361EE).withOpacity(0.22),
                          blurRadius: 16,
                        ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.selectMode) ...[
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            isSelected
                                ? CupertinoIcons.checkmark_circle_fill
                                : CupertinoIcons.circle,
                            key: ValueKey(isSelected),
                            color: isSelected
                                ? const Color(0xFF4361EE)
                                : (isDark
                                    ? Colors.white30
                                    : Colors.grey.shade400),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      // Icon
                      Container(
                        width: 46, height: 46,
                        decoration: BoxDecoration(
                          color: color.withOpacity(isDark ? 0.18 : 0.11),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: color.withOpacity(isDark ? 0.38 : 0.22),
                              width: 1),
                        ),
                        child: Center(
                          child: Text(item.type.emoji,
                              style: const TextStyle(fontSize: 22)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Expanded(
                                child: Text(item.title,
                                    style: TextStyle(
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF1A1A2E),
                                        fontWeight: item.isRead
                                            ? FontWeight.w600
                                            : FontWeight.bold,
                                        fontSize: 13)),
                              ),
                              if (!item.isRead)
                                Container(
                                  width: 8, height: 8,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: color.withOpacity(0.6),
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                            ]),
                            const SizedBox(height: 5),
                            Text(item.message,   // ← message بدل body
                                style: TextStyle(
                                    color: isDark
                                        ? Colors.white.withOpacity(0.58)
                                        : const Color(0xFF6B7280),
                                    fontSize: 12,
                                    height: 1.45)),
                            const SizedBox(height: 8),
                            Row(children: [
                              Icon(CupertinoIcons.clock,
                                  size: 11,
                                  color: isDark
                                      ? Colors.white24
                                      : const Color(0xFFB0B8CC)),
                              const SizedBox(width: 4),
                              Text(item.time,
                                  style: TextStyle(
                                      color: isDark
                                          ? Colors.white24
                                          : const Color(0xFFB0B8CC),
                                      fontSize: 11)),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(
                                      isDark ? 0.18 : 0.11),
                                  borderRadius: BorderRadius.circular(7),
                                  border: Border.all(
                                      color: color.withOpacity(0.28),
                                      width: 1),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(item.type.emoji,
                                        style: const TextStyle(fontSize: 10)),
                                    const SizedBox(width: 3),
                                    Text(item.type.label,
                                        style: TextStyle(
                                            color: color,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}