import 'package:hive/hive.dart';

part 'tickets_search_entry_model.g.dart';

@HiveType(typeId: 18)
class TicketSearchEntryModel extends HiveObject {
  @HiveField(0)
  final String train;
  @HiveField(1)
  final String station;
  @HiveField(2)
  final String departure;
  @HiveField(3)
  final String startStationCode;
  @HiveField(4)
  final DateTime createdAt;
  @HiveField(5)
  final String key;

  TicketSearchEntryModel({
    required this.train,
    required this.station,
    required this.departure,
    required this.startStationCode,
    required this.createdAt,
    required this.key,
  });

  static String buildKey({
    required String train,
    required String station,
    required String departure,
    required String startStationCode,
  }) =>
      '${train.trim()}|${station.trim()}|$departure|$startStationCode';
}
