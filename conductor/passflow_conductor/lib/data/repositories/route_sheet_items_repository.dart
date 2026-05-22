import 'package:dio/dio.dart';
import 'package:passflow_app/core/dio/dio_client.dart';
import 'package:passflow_app/data/models/route_sheet_item.dart';
import 'package:passflow_app/data/models/wagon_lu72_costs_models.dart';

class RouteSheetItemsRepository {
  final Dio _dio;

  RouteSheetItemsRepository({Dio? dio}) : _dio = dio ?? DioClient.dio;

  static const String _searchPath =
      '/routeSheets/api/v1/RouteSheetItems/search';
  static const String _basePath = '/routeSheets/api/v1/RouteSheetItems';

  Future<RouteSheetItemsSearchResponse> search({
    required int routeSheetId,
    required int groupNumber,
    int take = 200,
    int skip = 0,
    bool returnCount = true,
  }) async {
    final body = <String, dynamic>{
      'paging': {
        'take': take,
        'skip': skip,
        'returnCount': returnCount,
      },
      'filter': {
        'routeSheetId': {
          'operand1': routeSheetId,
          'operator': '1',
        },
        'groupNumber': {
          'operand1': groupNumber,
          'operator': '1',
        },
      },
    };

    final res = await _dio.post<Map<String, dynamic>>(
      _searchPath,
      data: body,
    );

    final data = res.data ?? const <String, dynamic>{};
    return RouteSheetItemsSearchResponse.fromJson(data);
  }

  Future<RouteSheetItemModel?> patchLu72Meta({
    required int id,
    int? lu72AttendantsCount,
    int? lu72StaffiCount,
    int? lu72TotalCount,
    int? lu72State,
  }) async {
    if (lu72AttendantsCount == null &&
        lu72StaffiCount == null &&
        lu72TotalCount == null &&
        lu72State == null) {
      return null;
    }
    final operations = <Map<String, dynamic>>[
      if (lu72AttendantsCount != null)
        <String, dynamic>{
          'operationType': 'Replace',
          'path': '/lu72AttendantsCount',
          'op': 'replace',
          'from': '',
          'value': '$lu72AttendantsCount',
        },
      if (lu72StaffiCount != null)
        <String, dynamic>{
          'operationType': 'Replace',
          'path': '/lu72StaffiCount',
          'op': 'replace',
          'from': '',
          'value': '$lu72StaffiCount',
        },
      if (lu72TotalCount != null)
        <String, dynamic>{
          'operationType': 'Replace',
          'path': '/lu72TotalCount',
          'op': 'replace',
          'from': '',
          'value': '$lu72TotalCount',
        },
      if (lu72State != null)
        <String, dynamic>{
          'operationType': 'Replace',
          'path': '/lu72State',
          'op': 'replace',
          'from': '',
          'value': '$lu72State',
        },
    ];
    try {
      final response = await _dio.patch<dynamic>(
        '$_basePath/$id',
        data: operations,
        options: Options(contentType: 'application/json-patch+json'),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return RouteSheetItemModel.fromJson(data);
      }
      return null;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final message =
          e.response?.data?.toString() ?? e.message ?? 'unknown_error';
      throw HttpException(
        'RouteSheetItems update failed: ${status ?? 'no_status'}: $message',
      );
    }
  }
}

/// Search response wrapper.
class RouteSheetItemsSearchResponse {
  RouteSheetItemsSearchResponse({
    required this.result,
    this.total,
    this.pageCount,
  });

  final List<RouteSheetItemModel> result;
  final int? total;
  final int? pageCount;

  factory RouteSheetItemsSearchResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['result'];
    final list = (raw is List)
        ? raw
            .whereType<Map<String, dynamic>>()
            .map(RouteSheetItemModel.fromJson)
            .toList()
        : <RouteSheetItemModel>[];

    int? toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    return RouteSheetItemsSearchResponse(
      result: list,
      total: toInt(json['total']),
      pageCount: toInt(json['pageCount']),
    );
  }
}
