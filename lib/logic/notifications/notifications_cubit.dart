import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vital_metrics/data/exceptions/api_exception.dart';
import 'package:vital_metrics/data/models/notification_model.dart';
import 'package:vital_metrics/data/repositories/notifications_repository.dart';
import 'package:vital_metrics/logic/notifications/notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationsRepository _repo;

  NotificationsCubit({NotificationsRepository? repo})
      : _repo = repo ?? NotificationsRepository(),
        super(NotificationsInitial());

  // ── Load all notifications ─────────────────────────────────────────────────
  Future<void> loadNotifications() async {
    try {
      emit(NotificationsLoading());
      final items = await _repo.getNotifications();
      emit(NotificationsLoaded(items));
    } on ApiException catch (e) {
      // لو فشل الـ API نحمّل الـ default notifications
      emit(NotificationsLoaded(defaultNotifications()));
      // ممكن تعمل emit للـ error بدل كده لو عايز تعرض رسالة
      // emit(NotificationsError(e.message));
    } catch (e) {
      emit(NotificationsLoaded(defaultNotifications()));
    }
  }

  // ── Mark single as read ────────────────────────────────────────────────────
  Future<void> markAsRead(String id) async {
    final current = state;
    if (current is! NotificationsLoaded) return;

    // Optimistic update — نحدّث الـ UI فوراً
    final updated = current.items.map((n) {
      return n.id == id ? n.copyWith(isRead: true) : n;
    }).toList();
    emit(NotificationsLoaded(updated));

    // ثم نبعت للـ API في الخلفية
    try {
      await _repo.markAsRead(id);
    } on ApiException {
      // لو فشل نرجع للـ state القديم
      emit(current);
    }
  }

  // ── Mark all as read ───────────────────────────────────────────────────────
  Future<void> markAllAsRead() async {
    final current = state;
    if (current is! NotificationsLoaded) return;

    // Optimistic update
    final updated = current.items
        .map((n) => n.copyWith(isRead: true))
        .toList();
    emit(NotificationsLoaded(updated));

    try {
      await _repo.markAllAsRead();
    } on ApiException {
      emit(current);
    }
  }

  // ── Delete single ──────────────────────────────────────────────────────────
  Future<void> deleteNotification(String id) async {
    final current = state;
    if (current is! NotificationsLoaded) return;

    // Optimistic update
    final updated = current.items.where((n) => n.id != id).toList();
    emit(NotificationsLoaded(updated));

    try {
      await _repo.deleteNotification(id);
    } on ApiException {
      emit(current);
    }
  }

  // ── Delete all ─────────────────────────────────────────────────────────────
  Future<void> deleteAll() async {
    final current = state;
    if (current is! NotificationsLoaded) return;

    // Optimistic update
    emit(const NotificationsLoaded([]));

    try {
      await _repo.deleteAll();
    } on ApiException {
      emit(current);
    }
  }

  // ── Mark selected as read ──────────────────────────────────────────────────
  Future<void> markSelectedAsRead(List<String> ids) async {
    final current = state;
    if (current is! NotificationsLoaded) return;

    final updated = current.items.map((n) {
      return ids.contains(n.id) ? n.copyWith(isRead: true) : n;
    }).toList();
    emit(NotificationsLoaded(updated));

    try {
      for (final id in ids) {
        await _repo.markAsRead(id);
      }
    } on ApiException {
      emit(current);
    }
  }

  // ── Delete selected ────────────────────────────────────────────────────────
  Future<void> deleteSelected(List<String> ids) async {
    final current = state;
    if (current is! NotificationsLoaded) return;

    final updated = current.items.where((n) => !ids.contains(n.id)).toList();
    emit(NotificationsLoaded(updated));

    try {
      for (final id in ids) {
        await _repo.deleteNotification(id);
      }
    } on ApiException {
      emit(current);
    }
  }

  // ── Unread count ───────────────────────────────────────────────────────────
  int get unreadCount {
    final current = state;
    if (current is NotificationsLoaded) return current.unreadCount;
    return 0;
  }
}