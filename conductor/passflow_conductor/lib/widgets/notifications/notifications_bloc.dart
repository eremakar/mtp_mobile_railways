import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive/hive.dart';
import 'package:passflow_app/data/models/notifications_model.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final Box<NotificationItem> _box = Hive.box<NotificationItem>('notificationsBox');

  StreamSubscription<RemoteMessage>? _msgSub;
  StreamSubscription<String>? _tokenSub;

  NotificationsBloc() : super(const NotificationsLoading()) {
    on<RestoreNotifications>(_onRestore);
    on<PushArrived>(_onPushArrived);
    on<ClearAll>(_onClearAll);

    // _initLocalNotif();
    add(const RestoreNotifications());
    // _listenFcm();
  }
  Future<void> _onPushArrived(PushArrived event, Emitter<NotificationsState> emit) async {
    final n = event.message.notification;
    if (n == null) return;

    final id = event.message.messageId ?? DateTime.now().toIso8601String();

    if (!_box.values.any((e) => e.id == id)) {
      final item = NotificationItem(
        id: id,
        title: n.title ?? '',
        message: n.body ?? '',
        dateTime: DateTime.now(),
        avatarUrl: event.message.data['avatarUrl'] ?? '',
        isNew: true,
      );

      await _box.add(item);
    }

    emit(NotificationsLoaded(_box.values.toList().reversed.toList()));
  }

  Future<void> _onRestore(RestoreNotifications _, Emitter<NotificationsState> emit) async {
    emit(NotificationsLoaded(_box.values.toList().reversed.toList()));
  }

  Future<void> _onClearAll(ClearAll _, Emitter<NotificationsState> emit) async {
    await _box.clear();
    emit(const NotificationsLoaded([]));
  }

  @override
  Future<void> close() async {
    await _msgSub?.cancel();
    await _tokenSub?.cancel();
    return super.close();
  }
}