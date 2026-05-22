import 'package:equatable/equatable.dart';
import 'package:passflow_app/data/models/notifications_model.dart';

abstract class NotificationsState extends Equatable {
  const NotificationsState();
  @override
  List<Object?> get props => [];
}

class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

class NotificationsLoaded extends NotificationsState {
  final List<NotificationItem> list;
  const NotificationsLoaded(this.list);

  int get unread => list.where((e) => e.isNew).length;

  @override
  List<Object?> get props => [list];
}
