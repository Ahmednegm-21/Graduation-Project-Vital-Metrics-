import 'package:equatable/equatable.dart';
import 'package:vital_metrics/data/models/notification_model.dart';

abstract class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

// جاري التحميل
class NotificationsLoading extends NotificationsState {}

// تحميل ناجح
class NotificationsLoaded extends NotificationsState {
  final List<NotificationItem> items;

  const NotificationsLoaded(this.items);

  int get unreadCount => items.where((n) => !n.isRead).length;

  @override
  List<Object?> get props => [items];
}

// خطأ
class NotificationsError extends NotificationsState {
  final String message;

  const NotificationsError(this.message);

  @override
  List<Object?> get props => [message];
}

// حالة أولية
class NotificationsInitial extends NotificationsState {}