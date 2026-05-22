
import 'package:equatable/equatable.dart';

abstract class BadgeState extends Equatable {
  const BadgeState();
  @override
  List<Object?> get props => [];
}

class BadgeLoading extends BadgeState {
  const BadgeLoading();
}

class BadgeReady extends BadgeState {
  final int unread;
  const BadgeReady(this.unread);
  @override
  List<Object?> get props => [unread];
}