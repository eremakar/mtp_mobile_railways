import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:passflow_app/data/models/notifications_model.dart';
import 'package:passflow_app/widgets/notifications_badge/notifications_badge_event.dart';
import 'package:passflow_app/widgets/notifications_badge/notifications_badge_state.dart';

class NotificationBadgeBloc extends Bloc<BadgeEvent, BadgeState> {
  static const _iosChannel = MethodChannel('app_badge');

  final Box<NotificationItem> _box = Hive.box<NotificationItem>('notificationsBox');
  late final StreamSubscription _watchSub;

  NotificationBadgeBloc() : super(const BadgeLoading()) {
    on<BadgeWatch>(_onWatch);
    on<BadgeChanged>(_onChanged);
    on<ResetBadge>(_onReset);

    add(const BadgeWatch());
  }

  void _onWatch(BadgeWatch _, Emitter<BadgeState> __) {
    _dispatchCurrent();
    _watchSub = _box.watch().listen((_) => _dispatchCurrent());
  }

  void _onChanged(BadgeChanged e, Emitter<BadgeState> emit) async {
    if (Platform.isIOS) {
      try {
        await _iosChannel.invokeMethod('setBadge', e.unread);
      } catch (_) {
      }
    }

    emit(BadgeReady(e.unread));
  }

  Future<void> _onReset(ResetBadge _, Emitter<BadgeState> __) async {
    for (final key in _box.keys) {
      final n = _box.get(key);
      if (n != null && n.isNew) {
        await _box.put(key, n.copyWith(isNew: false));
      }
    }
    _dispatchCurrent();
  }

  void _dispatchCurrent() {
    final unread = _box.values.where((e) => e.isNew).length;
    add(BadgeChanged(unread));
  }

  @override
  Future<void> close() async {
    await _watchSub.cancel();
    return super.close();
  }
}