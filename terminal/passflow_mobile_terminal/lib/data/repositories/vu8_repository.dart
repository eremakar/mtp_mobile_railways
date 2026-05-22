import 'package:dio/dio.dart';
import 'package:passflow_app/core/dio/dio_client.dart';
import 'package:passflow_app/data/models/services_model/vu8_remark_models.dart';

class Vu8Repository {
  static const String _searchPath = '/api/v1/wagonVU8s/search';
  static const String _createPath = '/api/v1/wagonVU8s';
  static const String _typesSearchPath = '/api/v1/vU8Types/search';

  static const List<String> defaultIncludes = <String>[
    'type',
    'employee',
  ];

  final Dio _dio;

  Vu8Repository({Dio? dio}) : _dio = dio ?? DioClient.dio;

  Future<dynamic> searchRaw(Map<String, dynamic> body) async {
    try {
      final res = await _dio.post(_searchPath, data: body);
      return res.data;
    } catch (_) {
      return null;
    }
  }

  Future<Vu8RemarkSearchResponse?> search(Map<String, dynamic> body) async {
    final data = await searchRaw(body);
    if (data is Map<String, dynamic>) {
      return Vu8RemarkSearchResponse.fromJson(data);
    }
    return null;
  }

  Future<dynamic> searchTypesRaw(Map<String, dynamic> body) async {
    try {
      final res = await _dio.post(_typesSearchPath, data: body);
      return res.data;
    } catch (_) {
      return null;
    }
  }

  Future<Vu8TypeSearchResponse?> searchTypes({
    int take = 50,
    int skip = 0,
    String sortField = 'id',
    String sortDirection = 'Asc',
  }) async {
    final body = <String, dynamic>{
      'paging': {
        'skip': skip,
        'take': take,
        'returnCount': true,
      },
      'filter': <String, dynamic>{},
      'filterOperator': 'And',
      'sort': {
        sortField: {
          'operator': sortDirection,
          'ordinal': 0,
        }
      },
    };

    final data = await searchTypesRaw(body);
    if (data is Map<String, dynamic>) {
      return Vu8TypeSearchResponse.fromJson(data);
    }
    return null;
  }

  Future<List<Vu8Type>> getTypes({
    int take = 50,
    int skip = 0,
    String sortField = 'id',
    String sortDirection = 'Asc',
  }) async {
    final res = await searchTypes(
      take: take,
      skip: skip,
      sortField: sortField,
      sortDirection: sortDirection,
    );
    return res?.result ?? <Vu8Type>[];
  }

  Future<Vu8RemarkSearchResponse?> searchByWagon({
    required int wagonId,
    int? routeId,
    int? routeSheetId,
    int take = 20,
    int skip = 0,
    List<String> includes = defaultIncludes,
  }) async {
    final body = <String, dynamic>{
      'paging': {
        'skip': skip,
        'take': take,
        'returnCount': true,
      },
      'filter': {
        'wagonId': {'operand1': wagonId, 'operator': 'Equals'},
        if (routeId != null) 'routeId': {'operand1': routeId, 'operator': 'Equals'},
        if (routeSheetId != null)
          'routeSheetId': {'operand1': routeSheetId, 'operator': 'Equals'},
      },
      'filterOperator': 'And',
      'sort': {
        'createdTime': {'operator': 'Desc', 'ordinal': 0},
      },
      'includes': includes,
    };

    return await search(body);
  }

  Future<bool> createRemark({
    required String text,
    required int wagonId,
    required int typeId,
    int? employeeId,
    int? routeId,
    int? routeSheetId,
    String? imageUrl, 
    String? completedText,
  }) async {
    final body = <String, dynamic>{
      'text': text,
      if (imageUrl != null && imageUrl.trim().isNotEmpty) 'imageUrl': imageUrl,
      if (completedText != null && completedText.trim().isNotEmpty)
        'completedText': completedText,
      'wagonId': wagonId,
      if (employeeId != null) 'employeeId': employeeId,
      if (routeId != null) 'routeId': routeId,
      if (routeSheetId != null) 'routeSheetId': routeSheetId,
      'typeId': typeId,
    };

    try {
      await _dio.post(_createPath, data: body);
      return true;
    } catch (_) {
      return false;
    }
  }
}