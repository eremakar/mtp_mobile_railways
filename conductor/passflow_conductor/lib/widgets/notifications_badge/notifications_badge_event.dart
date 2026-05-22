
import 'package:equatable/equatable.dart';

abstract class BadgeEvent extends Equatable {
  const BadgeEvent();
  @override
  List<Object?> get props => [];
}

class BadgeWatch extends BadgeEvent {
  const BadgeWatch();
}

class BadgeChanged extends BadgeEvent {
  final int unread;
  const BadgeChanged(this.unread);
  @override
  List<Object?> get props => [unread];
}

class ResetBadge extends BadgeEvent {
  const ResetBadge();
}