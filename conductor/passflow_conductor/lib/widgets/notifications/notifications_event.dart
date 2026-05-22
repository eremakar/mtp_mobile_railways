import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();
  @override
  List<Object?> get props => [];
}

class RestoreNotifications extends NotificationsEvent {
  const RestoreNotifications();
}

class PushArrived extends NotificationsEvent {
  final RemoteMessage message;
  const PushArrived(this.message);
  @override
  List<Object?> get props => [message];
}

class ClearAll extends NotificationsEvent {
  const ClearAll();
}
