import 'package:hive/hive.dart';
import 'package:passflow_app/helpers/parse_helper.dart';

part 'wagon_model.g.dart';

/// Если приходит массив объектов, где каждый имеет ключ 'wagon',
/// используйте этот хелпер: List<WagonModel> wagons = wagonModelsFromJson(response);
List<WagonModel> wagonModelsFromJson(dynamic str) =>
    List<WagonModel>.from(str.map((x) => WagonModel.fromJson(x['wagon'])));

@HiveType(typeId: 14)
class WagonModel extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String number;

  @HiveField(2)
  String? type;

  @HiveField(3)
  String? order;

  @HiveField(4)
  int? itemId;

  @HiveField(5)
  String? typeName;

  WagonModel({
    required this.id,
    required this.number,
    this.type,
    this.order,
    this.itemId,
    String? typeName,
  });

  factory WagonModel.fromJson(Map<String, dynamic> json) {
    final wagon = (json['wagon'] is Map)
        ? (json['wagon'] as Map).cast<String, dynamic>()
        : <String, dynamic>{};

    return WagonModel(
      id: ParseHelper.asInt(wagon['id']),
      number: (json['number'] ?? '').toString().padLeft(2, '0'),
      type: json['type']?.toString(),
      typeName: json['wagonType'] != null
          ? json['wagonType']['name']?.toString()
          : '',
      order: json['order']?.toString().padLeft(2, '0'),
      itemId: ParseHelper.asIntOrNull(json['id']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'number': number,
        'type': type,
        'order': order,
        'itemId': itemId,
      };
}
