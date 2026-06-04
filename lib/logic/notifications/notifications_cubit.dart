import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vital_metrics/data/exceptions/api_exception.dart';
import 'package:vital_metrics/data/models/notification_model.dart';
import 'package:vital_metrics/data/repositories/notifications_repository.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationsRepository _repo;

  NotificationsCubit({NotificationsRepository? repo})
      : _repo = repo ?? NotificationsRepository(),
        super(NotificationsInitial());

  // ── Load ───────────────────────────────────────────────────────────────────
  Future<void> loadNotifications() async {
    try {
      emit(NotificationsLoading());
      final items = await _repo.getNotifications();
      emit(NotificationsLoaded(items));
    } on ApiException {
      emit(NotificationsLoaded(defaultNotifications())); // fallback
    } catch (_) {
      emit(NotificationsLoaded(defaultNotifications()));
    }
  }

  // ── Mark single read ───────────────────────────────────────────────────────
  Future<void> markAsRead(int id) async {
    final current = state;
    if (current is! NotificationsLoaded) return;

    // optimistic update
    final updated = current.items
        .map((n) => n.notificationId == id ? n.copyWith(isRead: true) : n)
        .toList();
    emit(NotificationsLoaded(updated));

    try {
      await _repo.markAsRead(id);
    } on ApiException {
      emit(current); // revert on error
    }
  }

  // ── Mark all read ──────────────────────────────────────────────────────────
  Future<void> markAllAsRead() async {
    final current = state;
    if (current is! NotificationsLoaded) return;

    final updated = current.items.map((n) => n.copyWith(isRead: true)).toList();
    emit(NotificationsLoaded(updated));

    try {
      await _repo.markAllAsRead();
    } on ApiException {
      emit(current);
    }
  }

  // ── Delete single ──────────────────────────────────────────────────────────
  Future<void> deleteNotification(int id) async {
    final current = state;
    if (current is! NotificationsLoaded) return;

    final updated = current.items.where((n) => n.notificationId != id).toList();
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

    emit(const NotificationsLoaded([]));

    try {
      await _repo.deleteAll();
    } on ApiException {
      emit(current);
    }
  }

  // ── Mark selected read ─────────────────────────────────────────────────────
  Future<void> markSelectedAsRead(List<int> ids) async {
    final current = state;
    if (current is! NotificationsLoaded) return;

    final updated = current.items
        .map((n) => ids.contains(n.notificationId) ? n.copyWith(isRead: true) : n)
        .toList();
    emit(NotificationsLoaded(updated));

    try {
      for (final id in ids) await _repo.markAsRead(id);
    } on ApiException {
      emit(current);
    }
  }

  // ── Delete selected ────────────────────────────────────────────────────────
  Future<void> deleteSelected(List<int> ids) async {
    final current = state;
    if (current is! NotificationsLoaded) return;

    final updated = current.items
        .where((n) => !ids.contains(n.notificationId))
        .toList();
    emit(NotificationsLoaded(updated));

    try {
      for (final id in ids) await _repo.deleteNotification(id);
    } on ApiException {
      emit(current);
    }
  }

  int get unreadCount {
    final s = state;
    return s is NotificationsLoaded ? s.unreadCount : 0;
  }
}