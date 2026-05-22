import 'package:passflow_app/core/dio/dio_client.dart';

class Lu72Repository {
  static const String _searchPath = '/api/v1/wagonLU72s/search';
  static const List<String> defaultIncludes = <String>[
    'costs',
    'costs.station',
  ];
  Future<dynamic> search(Map<String, dynamic> body) async {
    try {
      final response = await DioClient.dio.post(_searchPath, data: body);
      return response.data;
    } catch (_) {
      return null;
    }
  }

  Future<dynamic> searchByConductor({
    required int conductorId,
    int? routeSheetId,
    int? wagonId,
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
        'conductorId': {
          'operand1': conductorId,
          'operator': 'Equals',
        },
        if (routeSheetId != null)
          'routeSheetId': {
            'operand1': routeSheetId,
            'operator': 'Equals',
          },
        if (wagonId != null)
          'wagonId': {
            'operand1': wagonId,
            'operator': 'Equals',
          },
      },
      'filterOperator': 'And',
      'sort': {
        'createdTime': {
          'operator': 'Desc',
          'ordinal': 0,
        }
      },
      'includes': includes,
    };

    return await search(body);
  }
}
