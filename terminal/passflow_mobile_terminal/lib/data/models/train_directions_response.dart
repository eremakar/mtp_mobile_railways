import 'package:hive/hive.dart';
import 'train_direction_model.dart';

part 'train_directions_response.g.dart';

@HiveType(typeId: 21) // замените, если конфликтуют
class TrainDirectionsResponse {
  @HiveField(0)
  final List<TrainDirectionModel> result;

  @HiveField(1)
  final int? total;

  @HiveField(2)
  final int? pageCount;

  TrainDirectionsResponse({
    required this.result,
    this.total,
    this.pageCount,
  });

  factory TrainDirectionsResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['result'] as List? ?? const [])
        .map((e) => TrainDirectionModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return TrainDirectionsResponse(
      result: list,
      total: json['total'] as int?,
      pageCount: json['pageCount'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'result': result.map((e) => e.toJson()).toList(),
        'total': total,
        'pageCount': pageCount,
      };
}
