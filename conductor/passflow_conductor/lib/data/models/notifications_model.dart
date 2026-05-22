// lib/widgets/notifications/models/notification_item.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';


/* ───────── М О Д Е Л Ь ───────────────────────────────────── */

class NotificationItem with EquatableMixin {
  final String id;
  final String title;
  final String message;
  final DateTime dateTime;
  final String avatarUrl;
  final bool isNew;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.dateTime,
    required this.avatarUrl,
    this.isNew = true,
  });

  /* ─── Factory из Firestore ─── */
  factory NotificationItem.fromDoc(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return NotificationItem(
      id: doc.id,
      title: d['title'] ?? '',
      message: d['message'] ?? '',
      dateTime: (d['dateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      avatarUrl: d['avatarUrl'] ?? '',
      isNew: d['isNew'] ?? true,
    );
  }

  /* ─── Для Firestore/REST ─── */
  Map<String, dynamic> toFirestore() => {
        'title'    : title,
        'message'  : message,
        'dateTime' : Timestamp.fromDate(dateTime),
        'avatarUrl': avatarUrl,
        'isNew'    : isNew,
      };

  /* ─── copyWith (immutability) ─── */
  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? dateTime,
    String? avatarUrl,
    bool? isNew,
  }) =>
      NotificationItem(
        id       : id       ?? this.id,
        title    : title    ?? this.title,
        message  : message  ?? this.message,
        dateTime : dateTime ?? this.dateTime,
        avatarUrl: avatarUrl?? this.avatarUrl,
        isNew    : isNew    ?? this.isNew,
      );

  @override
  List<Object?> get props => [id, title, message, dateTime, avatarUrl, isNew];
}

/* ───────── А Д А П Т Е Р  H I V E ────────────────────────── */

class NotificationItemAdapter extends TypeAdapter<NotificationItem> {
  @override
  final int typeId = 60;

  @override
  NotificationItem read(BinaryReader reader) {
    return NotificationItem(
      id       : reader.readString(),
      title    : reader.readString(),
      message  : reader.readString(),
      dateTime : DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      avatarUrl: reader.readString(),
      isNew    : reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, NotificationItem obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.title)
      ..writeString(obj.message)
      ..writeInt(obj.dateTime.millisecondsSinceEpoch)
      ..writeString(obj.avatarUrl)
      ..writeBool(obj.isNew);
  }
}
