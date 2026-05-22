import 'package:hive/hive.dart';

part 'class_station_model.g.dart';

@HiveType(typeId: 22)
class ClassStationModel {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? code;

  ClassStationModel({required this.id, required this.name, this.code});

  factory ClassStationModel.fromJson(Map<String, dynamic> json) =>
      ClassStationModel(
        id: json['id'],
        name: json['name'],
        code: json['code'],
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'code': code};
}
