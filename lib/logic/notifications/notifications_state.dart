import 'package:equatable/equatable.dart';
import 'package:vital_metrics/data/models/notification_model.dart';

abstract class NotificationsState extends Equatable {
  const NotificationsState();
  @override List<Object?> get props => [];
}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoading extends NotificationsState {}

class NotificationsLoaded extends NotificationsState {
  final List<NotificationItem> items;
  const NotificationsLoaded(this.items);
  int get unreadCount => items.where((n) => !n.isRead).length;
  @override List<Object?> get props => [items];
}

class NotificationsError extends NotificationsState {
  final String message;
  const NotificationsError(this.message);
  @override List<Object?> get props => [message];
}