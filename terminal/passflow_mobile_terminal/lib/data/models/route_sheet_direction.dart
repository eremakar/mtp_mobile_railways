import 'package:hive/hive.dart';
import 'train_direction_model.dart';

part 'route_sheet_direction.g.dart';

@HiveType(typeId: 20) // другой уникальный typeId
class RouteSheetDirectionModel extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  DateTime startDate;

  @HiveField(2)
  int routeSheetId;

  @HiveField(3)
  int trainDirectionId;

  @HiveField(4)
  int? routeId;

  @HiveField(5)
  TrainDirectionModel? trainDirection;

  RouteSheetDirectionModel({
    required this.id,
    required this.startDate,
    required this.routeSheetId,
    required this.trainDirectionId,
    this.routeId,
    this.trainDirection,
  });

  factory RouteSheetDirectionModel.fromJson(Map<String, dynamic> json) {
    return RouteSheetDirectionModel(
      id: json['id'] ?? 0,
      startDate: DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
      routeSheetId: json['routeSheetId'] ?? 0,
      trainDirectionId: json['trainDirectionId'] ?? 0,
      routeId: json['routeId'],
      trainDirection: json['trainDirection'] != null
          ? TrainDirectionModel.fromJson(json['trainDirection'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'startDate': startDate.toIso8601String(),
        'routeSheetId': routeSheetId,
        'trainDirectionId': trainDirectionId,
        'routeId': routeId,
        'trainDirection': trainDirection?.toJson(),
      };
}
