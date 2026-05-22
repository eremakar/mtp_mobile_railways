import 'package:hive/hive.dart';

part 'train_direction_model.g.dart';

@HiveType(typeId: 19) // уникальный typeId
class TrainDirectionModel extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String asuName;

  @HiveField(2)
  String fullName;

  @HiveField(3)
  String code;

  @HiveField(4)
  int routeClassId;

  TrainDirectionModel({
    required this.id,
    required this.asuName,
    required this.fullName,
    required this.code,
    required this.routeClassId,
  });

  factory TrainDirectionModel.fromJson(Map<String, dynamic> json) {
    return TrainDirectionModel(
      id: json['id'] ?? 0,
      asuName: json['asuName'] ?? '',
      fullName: json['fullName'] ?? '',
      code: json['code'] ?? '',
      routeClassId: json['routeClassId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'asuName': asuName,
        'fullName': fullName,
        'code': code,
        'routeClassId': routeClassId,
      };
}
