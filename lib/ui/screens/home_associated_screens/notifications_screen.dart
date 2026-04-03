import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:vital_metrics/core/themes/theme_context_extension.dart';
import 'package:vital_metrics/data/models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _State();
}

class _State extends State<NotificationsScreen>
    with TickerProviderStateMixin {

  late final AnimationController _bellCtrl;
  late final Animation<double>   _bellShake, _bellScale, _bellGlow;

  bool _selectMode = false;

  final List<NotificationItem> _items = defaultNotifications();

  int get _unread    => _items.where((n) => !n.isRead).length;
  int get _selected  => _items.where((n) => n.isSelected).length;
  bool get _allSel   => _items.isNotEmpty && _selected == _items.length;

  @override
  void initState() {
    super.initState();

    _bellCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 800));

    // shake (rotation swing)
    _bellShake = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0,   end:  0.18), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.18,  end: -0.14), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.14, end:  0.10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.10,  end: -0.06), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.06, end:  0.0),  weight: 1),
    ]).animate(CurvedAnimation(parent: _bellCtrl, curve: Curves.easeInOut));

    // scale pulse
    _bellScale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _bellCtrl, curve: Curves.easeInOut));

    // glow opacity
    _bellGlow = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.7), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.7, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _bellCtrl, curve: Curves.easeInOut));

    _runBellLoop();
  }

  void _runBellLoop() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 3));
      if (mounted && _unread > 0) {
        await _bellCtrl.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _bellCtrl.dispose();
    super.dispose();
  }

  // ── actions ───────────────────────────────────────────────────────────────
  void _markAllRead()   => setState(() { for (var n in _items) n.isRead = true; });
  void _deleteAll()     => setState(() => _items.clear());
  void _markSelRead()   => setState(() {
    for (var n in _items) { if (n.isSelected) { n.isRead = true; n.isSelected = false; } }
    _selectMode = false;
  });
  void _deleteSel()     => setState(() {
    _items.removeWhere((n) => n.isSelected);
    _selectMode = false;
  });
  void _toggleSel(String id) => setState(() {
    final n = _items.firstWhere((n) => n.id == id);
    n.isSelected = !n.isSelected;
    if (_selected == 0) _selectMode = false;
  });
  void _toggleAllSel() => setState(() {
    final v = !_allSel;
    for (var n in _items) n.isSelected = v;
  });

  // ── build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bg     = isDark ? const Color(0xFF0F1221) : const Color(0xFFF0F3FF);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _header(context, isDark),
            _actionBar(context, isDark),
            if (_selectMode) _selectBar(context, isDark),
            Expanded(child: _items.isEmpty
                ? _empty(isDark)
                : _list(context, isDark)),
          ],
        ),
      ),
    );
  }

  // ── header ────────────────────────────────────────────────────────────────
  Widget _header(BuildContext context, bool isDark) {
    final cardBg = isDark ? const Color(0xFF1A2340) : Colors.white;
    final shadow = isDark ? Colors.black38 : Colors.black.withOpacity(0.07);

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 10),
      child: Row(
        children: [
          // back
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

          // ── Animated Bell ─────────────────────────────────────────────────
          AnimatedBuilder(
            animation: _bellCtrl,
            builder: (_, __) => Stack(
              clipBehavior: Clip.none,
              children: [
                // glow ring
                if (_unread > 0)
                  Positioned.fill(
                    child: Opacity(
                      opacity: _bellGlow.value,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
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

                // bell icon
                Transform.scale(
                  scale: _bellScale.value,
                  child: Transform.rotate(
                    angle: _bellShake.value,
                    alignment: Alignment.topCenter,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: _unread > 0
                            ? const LinearGradient(
                                colors: [Color(0xFF4361EE), Color(0xFF4CC9F0)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: _unread == 0 ? cardBg : null,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: _unread > 0
                                ? const Color(0xFF4361EE).withOpacity(0.40)
                                : shadow,
                            blurRadius: _unread > 0 ? 14 : 10,
                          ),
                        ],
                      ),
                      child: Icon(CupertinoIcons.bell_fill,
                          color: _unread > 0
                              ? Colors.white
                              : (isDark ? Colors.white54 : const Color(0xFF4361EE)),
                          size: 20),
                    ),
                  ),
                ),

                // unread count badge
                if (_unread > 0)
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
                      child: Text('$_unread',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Notifications',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    )),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _unread > 0
                        ? '$_unread unread message${_unread > 1 ? 's' : ''}'
                        : 'All caught up ✓',
                    key: ValueKey(_unread),
                    style: TextStyle(
                      color: _unread > 0
                          ? const Color(0xFF4361EE)
                          : (isDark ? Colors.white30 : const Color(0xFF9B9B9B)),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // select toggle
          GestureDetector(
            onTap: () => setState(() {
              _selectMode = !_selectMode;
              if (!_selectMode) for (var n in _items) n.isSelected = false;
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _selectMode
                    ? const Color(0xFF4361EE)
                    : const Color(0xFF4361EE).withOpacity(isDark ? 0.18 : 0.09),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: const Color(0xFF4361EE).withOpacity(0.35)),
              ),
              child: Text(
                _selectMode ? 'Cancel' : 'Select',
                style: TextStyle(
                  color: _selectMode ? Colors.white : const Color(0xFF4361EE),
                  fontSize: 12, fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── action bar ────────────────────────────────────────────────────────────
  Widget _actionBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(
        children: [
          _ActionBtn(
            label: 'Read All',
            icon: CupertinoIcons.checkmark_circle_fill,
            color: const Color(0xFF4361EE),
            enabled: _unread > 0,
            isDark: isDark,
            onTap: _markAllRead,
          ),
          const SizedBox(width: 10),
          _ActionBtn(
            label: 'Delete All',
            icon: CupertinoIcons.trash_fill,
            color: const Color(0xFFFF4757),
            enabled: _items.isNotEmpty,
            isDark: isDark,
            onTap: () => _confirmDeleteAll(context, isDark),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAll(BuildContext ctx, bool isDark) async {
    final ok = await showCupertinoDialog<bool>(
      context: ctx,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Delete All?'),
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
    if (ok == true) _deleteAll();
  }

  // ── select bar ────────────────────────────────────────────────────────────
  Widget _selectBar(BuildContext context, bool isDark) {
    final hasSel = _selected > 0;
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
          // select all toggle
          GestureDetector(
            onTap: _toggleAllSel,
            child: Row(children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  _allSel
                      ? CupertinoIcons.checkmark_square_fill
                      : CupertinoIcons.square,
                  key: ValueKey(_allSel),
                  color: _allSel
                      ? const Color(0xFF4361EE)
                      : (isDark ? Colors.white30 : Colors.grey),
                  size: 20,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                _allSel ? 'Deselect All' : 'Select All',
                style: TextStyle(
                  color: isDark ? Colors.white70 : const Color(0xFF2D3142),
                  fontSize: 12, fontWeight: FontWeight.w600,
                ),
              ),
            ]),
          ),

          const Spacer(),

          if (hasSel) ...[
            // count
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF4361EE).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('$_selected selected',
                  style: const TextStyle(
                    color: Color(0xFF4361EE),
                    fontSize: 11, fontWeight: FontWeight.bold,
                  )),
            ),
            const SizedBox(width: 8),

            // mark read
            GestureDetector(
              onTap: _markSelRead,
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

            // delete
            GestureDetector(
              onTap: _deleteSel,
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

  // ── list ──────────────────────────────────────────────────────────────────
  Widget _list(BuildContext context, bool isDark) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
      itemCount: _items.length,
      itemBuilder: (_, i) {
        final item = _items[i];
        return _NotifCard(
          key: ValueKey(item.id),
          item: item,
          index: i,
          isDark: isDark,
          selectMode: _selectMode,
          onTap: () {
            if (_selectMode) {
              _toggleSel(item.id);
            } else {
              setState(() => item.isRead = true);
            }
          },
          onLongPress: () => setState(() {
            _selectMode = true;
            item.isSelected = true;
          }),
          onDismiss: () => setState(
              () => _items.removeWhere((n) => n.id == item.id)),
        );
      },
    );
  }

  // ── empty ─────────────────────────────────────────────────────────────────
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
            fontWeight: FontWeight.bold, fontSize: 20,
          )),
      const SizedBox(height: 6),
      Text('No notifications right now',
          style: TextStyle(
            color: isDark ? Colors.white30 : const Color(0xFF9B9B9B),
            fontSize: 14,
          )),
    ]),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// _ActionBtn
// ══════════════════════════════════════════════════════════════════════════════
class _ActionBtn extends StatelessWidget {
  final String  label;
  final IconData icon;
  final Color   color;
  final bool    enabled, isDark;
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
                    fontSize: 12, fontWeight: FontWeight.w600,
                  )),
            ],
          ),
        ),
      ),
    ),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// _NotifCard — entrance animation + swipe to delete
// ══════════════════════════════════════════════════════════════════════════════
class _NotifCard extends StatefulWidget {
  final NotificationItem       item;
  final int          index;
  final bool         isDark, selectMode;
  final VoidCallback onTap, onLongPress, onDismiss;

  const _NotifCard({
    super.key,
    required this.item, required this.index,
    required this.isDark, required this.selectMode,
    required this.onTap, required this.onLongPress,
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
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 480));

    _fade  = CurvedAnimation(parent: _ctrl,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOut));
    _slide = Tween(begin: 36.0, end: 0.0).animate(
      CurvedAnimation(parent: _ctrl,
          curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic)));
    _scale = Tween(begin: 0.90, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl,
          curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack)));

    Future.delayed(Duration(milliseconds: 55 * widget.index), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final item   = widget.item;
    final isDark = widget.isDark;
    final color  = item.type.color;

    final cardBg = isDark
        ? (item.isRead ? const Color(0xFF1A2340) : const Color(0xFF1E2D4A))
        : (item.isRead ? Colors.white            : const Color(0xFFEEF2FF));

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Opacity(
        opacity: _fade.value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, _slide.value),
          child: Transform.scale(
            scale: _scale.value,
            child: Dismissible(
              key: ValueKey('d_${item.id}'),
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(CupertinoIcons.trash_fill,
                        color: Colors.white, size: 22),
                    SizedBox(height: 4),
                    Text('Delete',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11, fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
              ),
              onDismissed: (_) => widget.onDismiss(),
              child: GestureDetector(
                onTap: widget.onTap,
                onLongPress: widget.onLongPress,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(18),
                    border: item.isSelected
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
                      if (item.isSelected)
                        BoxShadow(
                          color: const Color(0xFF4361EE).withOpacity(0.22),
                          blurRadius: 16,
                        ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // select checkbox
                      if (widget.selectMode) ...[
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            item.isSelected
                                ? CupertinoIcons.checkmark_circle_fill
                                : CupertinoIcons.circle,
                            key: ValueKey(item.isSelected),
                            color: item.isSelected
                                ? const Color(0xFF4361EE)
                                : (isDark ? Colors.white30 : Colors.grey.shade400),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],

                      // icon
                      Container(
                        width: 46, height: 46,
                        decoration: BoxDecoration(
                          color: color.withOpacity(isDark ? 0.18 : 0.11),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: color.withOpacity(isDark ? 0.38 : 0.22),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(item.type.emoji,
                              style: const TextStyle(fontSize: 22)),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // title row
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
                                      fontSize: 13,
                                    )),
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
                                        blurRadius: 6, spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                            ]),
                            const SizedBox(height: 5),

                            // body
                            Text(item.body,
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.58)
                                      : const Color(0xFF6B7280),
                                  fontSize: 12, height: 1.45,
                                )),
                            const SizedBox(height: 8),

                            // footer
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
                                    fontSize: 11,
                                  )),
                              const Spacer(),
                              // type badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(
                                      isDark ? 0.18 : 0.11),
                                  borderRadius: BorderRadius.circular(7),
                                  border: Border.all(
                                    color: color.withOpacity(0.28),
                                    width: 1,
                                  ),
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
                                          fontWeight: FontWeight.w600,
                                        )),
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