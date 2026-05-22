import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:passflow_app/core/dio/dio_client.dart';
import 'package:passflow_app/data/models/wagon_lu72_costs_models.dart';

class WagonLu72CostsRepository {
  final Dio _dio;

  WagonLu72CostsRepository({Dio? dio}) : _dio = dio ?? DioClient.dio;

  static const String _searchPath = '/wagons/api/v1/wagonLU72Costs/search';
  static const String _basePath = '/wagons/api/v1/wagonLU72Costs';

  // SEARCH

  Future<PagedResponse<WagonLu72CostModel>> search({
    int? routeSheetId,
    int? routeSheetItemId,
    int? lu72Id,
    int? stationId,
    int take = 50,
    int skip = 0,
    bool returnCount = true,
  }) async {
    if (routeSheetId != null) {
      return searchByRouteSheetId(
        routeSheetId: routeSheetId,
        stationId: stationId,
        take: take,
        skip: skip,
        returnCount: returnCount,
      );
    }
    if (routeSheetItemId != null) {
      return searchByRouteSheetItemId(
        routeSheetItemId: routeSheetItemId,
        stationId: stationId,
        take: take,
        skip: skip,
        returnCount: returnCount,
      );
    }
    if (lu72Id != null) {
      return searchByLu72Id(
        lu72Id: lu72Id,
        stationId: stationId,
        take: take,
        skip: skip,
        returnCount: returnCount,
      );
    }

    return _searchRaw(
      allowEmptyFilter: true,
      stationId: stationId,
      take: take,
      skip: skip,
      returnCount: returnCount,
    );
  }

  Future<PagedResponse<WagonLu72CostModel>> searchByRouteSheetItemId({
    required int routeSheetItemId,
    int? stationId,
    int take = 50,
    int skip = 0,
    bool returnCount = true,
  }) async {
    return _searchRaw(
      allowEmptyFilter: false,
      routeSheetItemId: routeSheetItemId,
      stationId: stationId,
      sortByIdDesc: true,
      take: take,
      skip: skip,
      returnCount: returnCount,
    );
  }

  Future<PagedResponse<WagonLu72CostModel>> searchByLu72Id({
    required int lu72Id,
    int? stationId,
    int take = 50,
    int skip = 0,
    bool returnCount = true,
  }) async {
    return _searchRaw(
      allowEmptyFilter: false,
      lu72Id: lu72Id,
      stationId: stationId,
      take: take,
      skip: skip,
      returnCount: returnCount,
    );
  }

  Future<PagedResponse<WagonLu72CostModel>> searchByRouteSheetId({
    required int routeSheetId,
    int? stationId,
    int take = 50,
    int skip = 0,
    bool returnCount = true,
  }) async {
    final lu72Id = await resolveLu72IdByRouteSheetId(
      routeSheetId: routeSheetId,
      take: 200,
      skip: 0,
    );

    if (lu72Id == null) {
      return const PagedResponse<WagonLu72CostModel>(
        result: <WagonLu72CostModel>[],
        total: 0,
        pageCount: null,
      );
    }

    return searchByLu72Id(
      lu72Id: lu72Id,
      stationId: stationId,
      take: take,
      skip: skip,
      returnCount: returnCount,
    );
  }

  Future<PagedResponse<WagonLu72CostModel>> searchByLu72AndStation({
    required int lu72Id,
    required int stationId,
    int take = 50,
    int skip = 0,
    bool returnCount = true,
  }) {
    return _searchRaw(
      allowEmptyFilter: false,
      lu72Id: lu72Id,
      stationId: stationId,
      take: take,
      skip: skip,
      returnCount: returnCount,
    );
  }

  Future<PagedResponse<WagonLu72CostModel>> searchByRouteSheetItemAndStation({
    required int routeSheetItemId,
    required int stationId,
    int take = 50,
    int skip = 0,
    bool returnCount = true,
  }) {
    return _searchRaw(
      allowEmptyFilter: false,
      routeSheetItemId: routeSheetItemId,
      stationId: stationId,
      take: take,
      skip: skip,
      returnCount: returnCount,
    );
  }

  Future<WagonLu72CostModel?> getOneByLu72AndStation({
    required int lu72Id,
    required int stationId,
  }) async {
    final res = await searchByLu72AndStation(
      lu72Id: lu72Id,
      stationId: stationId,
      take: 1,
      skip: 0,
      returnCount: false,
    );
    return res.result.isEmpty ? null : res.result.first;
  }

  Future<int?> findExistingCostId({
    required int lu72Id,
    required int stationId,
  }) async {
    final existing = await getOneByLu72AndStation(
      lu72Id: lu72Id,
      stationId: stationId,
    );
    return existing?.id;
  }

  // UPSERT
  Future<WagonLu72CostModel> upsertSelectedSeats({
    required int lu72Id,
    required int stationId,
    required Iterable<int> selectedSeats,
    bool mergeWithExisting = true,
    String description = 'Места (список)',
    bool recalcPlaceCount = true,
  }) async {
    final existing = await getOneByLu72AndStation(
      lu72Id: lu72Id,
      stationId: stationId,
    );
    final incoming = selectedSeats.whereType<int>().toSet();
    final Set<int> finalOccupied = <int>{};
    if (mergeWithExisting && existing != null) {
      finalOccupied.addAll(existing.occupiedSeats);
    }
    finalOccupied.addAll(incoming);
    final seatsSorted = finalOccupied.toList()..sort();

    final seatsStr = jsonEncode([
      <String, dynamic>{
        'description': description,
        'занятые_места': seatsSorted,
      },
    ]);

    int? placeCount;
    if (recalcPlaceCount) {
      placeCount = finalOccupied.length;
    }

    return _upsertRaw(
      existingId: existing?.id,
      lu72Id: lu72Id,
      stationId: stationId,
      seatsStr: seatsStr,
      placeCount: placeCount,
      totalConsumed: finalOccupied.length,
    );
  }

  Future<WagonLu72CostModel> upsertOccupiedSeats({
    required int lu72Id,
    required int stationId,
    required Iterable<int> occupiedSeats,
    String description = 'Места (список)',
    bool recalcPlaceCount = true,
  }) {
    return upsertSelectedSeats(
      lu72Id: lu72Id,
      stationId: stationId,
      selectedSeats: occupiedSeats,
      mergeWithExisting: false,
      description: description,
      recalcPlaceCount: recalcPlaceCount,
    );
  }

  Future<WagonLu72CostModel> _upsertRaw({
    int? existingId,
    int? lu72Id,
    int? routeSheetItemId,
    required int stationId,
    required String seatsStr,
    int? placeCount,
    int? totalConsumed,
  }) async {
    if (lu72Id == null && routeSheetItemId == null) {
      throw const HttpException(
        'WagonLU72Costs upsert: provide routeSheetItemId or lu72Id',
      );
    }

    final body = <String, dynamic>{
      if (existingId != null) 'id': existingId,
      if (lu72Id != null) 'lU72Id': lu72Id,
      if (routeSheetItemId != null) 'routeSheetItemId': routeSheetItemId,
      'stationId': stationId,
      'seats': seatsStr,
      if (placeCount != null) 'placeCount': placeCount,
      if (totalConsumed != null) 'totalConsumed': totalConsumed,
    };

    // ignore: avoid_print
    print('[LU72][DEBUG] UPSERT payload (full): ${jsonEncode(body)}');

    try {
      final bool isUpdate = existingId != null;
      final resp = isUpdate
          ? await _dio.put(_basePath, data: body)
          : await _dio.post(_basePath, data: body);

      // ignore: avoid_print
      print(
          '[LU72][DEBUG] UPSERT method: ${isUpdate ? 'PUT' : 'POST'} $_basePath');
      // ignore: avoid_print
      print(
          '[LU72][DEBUG] UPSERT response: status=${resp.statusCode} data=${resp.data}');
      final data = resp.data;
      final bool shouldRefetch = (resp.statusCode == 204) ||
          data == null ||
          data is String ||
          data is bool;

      if (!shouldRefetch && data is Map<String, dynamic>) {
        if (data.containsKey('id')) {
          final got = WagonLu72CostModel.fromJson(data);
          // ignore: avoid_print
          print(
              '[LU72][DEBUG] UPSERT map response: id=${got.id} placeCount=${got.placeCount} occupied=${(got.occupiedSeats.toList()..sort())}');
          return got;
        }
        final r = data['result'];
        if (r is Map<String, dynamic>) {
          final got = WagonLu72CostModel.fromJson(r);
          // ignore: avoid_print
          print(
              '[LU72][DEBUG] UPSERT result response: id=${got.id} placeCount=${got.placeCount} occupied=${(got.occupiedSeats.toList()..sort())}');
          return got;
        }
      }

      // 2) Fallback: refetch.
      // ignore: avoid_print
      print(
        '[LU72][DEBUG] UPSERT non-entity response (${data.runtimeType}) -> refetching by routeSheetItemId=${routeSheetItemId ?? '-'}, lu72Id=${lu72Id ?? '-'}, stationId=$stationId',
      );
      final PagedResponse<WagonLu72CostModel> refetch;
      if (routeSheetItemId != null) {
        // ignore: avoid_print
        print(
            '[LU72][DEBUG] UPSERT refetch: POST $_searchPath filter={routeSheetItemId:$routeSheetItemId, stationId:$stationId}');
        refetch = await searchByRouteSheetItemAndStation(
          routeSheetItemId: routeSheetItemId,
          stationId: stationId,
          take: 1,
          skip: 0,
          returnCount: false,
        );
      } else {
        // ignore: avoid_print
        print(
            '[LU72][DEBUG] UPSERT refetch: POST $_searchPath filter={lU72Id:$lu72Id, stationId:$stationId}');
        refetch = await searchByLu72AndStation(
          lu72Id: lu72Id!,
          stationId: stationId,
          take: 1,
          skip: 0,
          returnCount: false,
        );
      }

      if (refetch.result.isNotEmpty) {
        final got = refetch.result.first;
        // ignore: avoid_print
        print(
            '[LU72][DEBUG] REFRESH after upsert: id=${got.id} placeCount=${got.placeCount} seatsLen=${got.seatsRaw?.length}');
        // ignore: avoid_print
        print('[LU72][DEBUG] REFRESH seatsRaw=${got.seatsRaw}');
        // ignore: avoid_print
        print(
            '[LU72][DEBUG] REFRESH occupied=${(got.occupiedSeats.toList()..sort())}');
        return got;
      }

      throw HttpException(
        'Upsert did not return entity and refetch is empty (routeSheetItemId=${routeSheetItemId ?? '-'}, lu72Id=${lu72Id ?? '-'}, stationId=$stationId). ResponseType=${data.runtimeType} status=${resp.statusCode}',
      );
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final bodyStr = e.response?.data?.toString();
      throw HttpException(
        'WagonLU72Costs upsert failed: ${status ?? 'no_status'}: ${bodyStr ?? e.message}',
      );
    }
  }

  Future<WagonLu72CostModel> upsert({
    int? lu72Id,
    int? routeSheetItemId,
    required int stationId,
    required Iterable<int> seats,
    bool mergeWithExisting = true,
    int? placeCount,
    String description = 'Места (список)',
  }) async {
    if (lu72Id == null && routeSheetItemId == null) {
      throw const HttpException(
        'WagonLU72Costs upsert: provide routeSheetItemId or lu72Id',
      );
    }
    if (placeCount == null) {
      if (routeSheetItemId != null) {
        final existing = mergeWithExisting
            ? (await searchByRouteSheetItemAndStation(
                routeSheetItemId: routeSheetItemId,
                stationId: stationId,
                take: 1,
                skip: 0,
                returnCount: false,
              ))
            : const PagedResponse<WagonLu72CostModel>(
                result: <WagonLu72CostModel>[]);
        final existed =
            existing.result.isNotEmpty ? existing.result.first : null;
        final incoming = seats.whereType<int>().toSet();
        final Set<int> finalOccupied = <int>{};
        if (mergeWithExisting && existed != null) {
          finalOccupied.addAll(existed.occupiedSeats);
        }
        finalOccupied.addAll(incoming);
        final seatsSorted = finalOccupied.toList()..sort();
        final seatsStr = jsonEncode([
          <String, dynamic>{
            'description': description,
            'занятые_места': seatsSorted,
          },
        ]);
        return _upsertRaw(
          existingId: existed?.id,
          routeSheetItemId: routeSheetItemId,
          stationId: stationId,
          seatsStr: seatsStr,
          totalConsumed: finalOccupied.length,
        );
      }
      return upsertSelectedSeats(
        lu72Id: lu72Id!,
        stationId: stationId,
        selectedSeats: seats,
        mergeWithExisting: mergeWithExisting,
        description: description,
        recalcPlaceCount: true,
      );
    } else {
      final existing = mergeWithExisting
          ? (routeSheetItemId != null
              ? (() async {
                  final res = await searchByRouteSheetItemAndStation(
                    routeSheetItemId: routeSheetItemId,
                    stationId: stationId,
                    take: 1,
                    skip: 0,
                    returnCount: false,
                  );
                  return res.result.isEmpty ? null : res.result.first;
                })()
              : getOneByLu72AndStation(
                  lu72Id: lu72Id!,
                  stationId: stationId,
                ))
          : Future.value(null);
      final existed = await existing;

      final incoming = seats.whereType<int>().toSet();
      final Set<int> finalOccupied = <int>{};
      if (mergeWithExisting && existed != null) {
        finalOccupied.addAll(existed.occupiedSeats);
      }
      finalOccupied.addAll(incoming);
      final seatsSorted = finalOccupied.toList()..sort();

      final seatsStr = jsonEncode([
        <String, dynamic>{
          'description': description,
          'занятые_места': seatsSorted,
        },
      ]);

      return _upsertRaw(
        existingId: existed?.id,
        lu72Id: lu72Id,
        routeSheetItemId: routeSheetItemId,
        stationId: stationId,
        seatsStr: seatsStr,
        placeCount: placeCount,
        totalConsumed: finalOccupied.length,
      );
    }
  }

  // RESOLVE lu72Id
  Future<int?> resolveLu72IdByRouteSheetId({
    required int routeSheetId,
    int take = 200,
    int skip = 0,
  }) async {
    final res = await _searchRaw(
      allowEmptyFilter: true,
      take: take,
      skip: skip,
      returnCount: true,
    );

    for (final c in res.result) {
      final rsId = c.lU72?.routeSheetId;
      if (rsId == routeSheetId) {
        return c.lU72Id;
      }
    }
    return null;
  }

  // RAW SEARCH
  Future<PagedResponse<WagonLu72CostModel>> _searchRaw({
    int? routeSheetItemId,
    int? lu72Id,
    int? stationId,
    bool sortByIdDesc = false,
    bool allowEmptyFilter = false,
    int take = 50,
    int skip = 0,
    bool returnCount = true,
  }) async {
    final filter = <String, dynamic>{};

    if (routeSheetItemId != null) {
      filter['routeSheetItemId'] = {
        'operand1': routeSheetItemId,
        'operator': '1'
      };
    }
    if (lu72Id != null) {
      filter['lU72Id'] = {'operand1': lu72Id, 'operator': '1'};
    }
    if (stationId != null) {
      filter['stationId'] = {'operand1': stationId, 'operator': '1'};
    }

    if (filter.isEmpty && !allowEmptyFilter) {
      throw const HttpException(
        'WagonLU72Costs search: provide routeSheetId, routeSheetItemId, or lu72Id',
      );
    }

    final body = <String, dynamic>{
      'paging': {
        'take': take,
        'skip': skip,
        'returnCount': returnCount,
      },
      if (filter.isNotEmpty) 'filter': filter,
      if (sortByIdDesc)
        'sort': {
          'id': {'operator': 'Desc', 'ordinal': 0}
        },
    };

    try {
      final resp = await _dio.post(_searchPath, data: body);
      final data = resp.data;

      if (data is! Map<String, dynamic>) {
        throw HttpException('Unexpected response type: ${data.runtimeType}');
      }

      return PagedResponse<WagonLu72CostModel>.fromJson(
        data,
        (j) => WagonLu72CostModel.fromJson(j as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final bodyStr = e.response?.data?.toString();
      throw HttpException(
        'WagonLU72Costs search failed: ${status ?? 'no_status'}: ${bodyStr ?? e.message}',
      );
    }
  }
}
