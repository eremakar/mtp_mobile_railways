import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:passflow_app/core/dio/dio_client.dart';
import 'package:passflow_app/data/models/wagon_lu72_costs_models.dart';
import 'package:passflow_app/data/repositories/route_sheet_employees_repository.dart';
import 'package:passflow_app/data/repositories/route_sheet_items_repository.dart';
import 'package:passflow_app/data/repositories/route_sheets_repository.dart';
import 'package:passflow_app/data/repositories/wagon_lu72_costs_repository.dart';
import 'lu72_event.dart';
import 'lu72_state.dart';

typedef Lu72EmployeeIdProvider = Future<int?> Function();

class Lu72Bloc extends Bloc<Lu72Event, Lu72State> {
  Lu72Bloc({
    Lu72EmployeeIdProvider? employeeIdProvider,
  })  : _routeSheetEmployeesRepository =
            GetIt.I<RouteSheetEmployeesRepository>(),
        _routeSheetItemsRepository = GetIt.I<RouteSheetItemsRepository>(),
        _wagonLu72CostsRepository = GetIt.I<WagonLu72CostsRepository>(),
        _routeSheetsRepository = GetIt.I<RouteSheetsRepository>(),
        _employeeIdProvider = employeeIdProvider ?? _defaultEmployeeIdProvider,
        super(Lu72State.initial()) {
    on<Lu72LoadRequested>(_onLoad);
    on<Lu72WagonSelected>(_onWagonSelected);
    on<Lu72SaveRequested>(_onSaveRequested);
    on<Lu72SummaryMetaSaveRequested>(_onSummaryMetaSaveRequested);
    on<Lu72ApprovalToggled>(_onApprovalToggled);
  }

  final RouteSheetEmployeesRepository _routeSheetEmployeesRepository;
  final RouteSheetItemsRepository _routeSheetItemsRepository;
  final WagonLu72CostsRepository _wagonLu72CostsRepository;
  final Lu72EmployeeIdProvider _employeeIdProvider;
  final RouteSheetsRepository _routeSheetsRepository;
  final Dio _dio = DioClient.dio;

  static Future<int?> _defaultEmployeeIdProvider() async {
    return null;
  }

  Future<void> _onLoad(Lu72LoadRequested event, Emitter<Lu72State> emit) async {
    emit(state.copyWith(
      status: Lu72Status.loading,
      errorMessage: null,
      clearRouteSheetId: true,
    ));

    try {
      final employeeId = await _employeeIdProvider();
      if (employeeId == null) {
        emit(state.copyWith(
          status: Lu72Status.failure,
          errorMessage: 'Не найден employeeId (пользователь не загружен)',
          clearRouteSheetId: true,
          wagons: const <String>[],
          wagonRouteClassIds: const <String, int?>{},
          wagonRouteSheetItemIds: const <String, int?>{},
          wagonPlaceCounts: const <String, int?>{},
          wagonLu72AttendantsCounts: const <String, int?>{},
          wagonLu72StaffCounts: const <String, int?>{},
          wagonLu72TotalCounts: const <String, int?>{},
          wagonLu72States: const <String, int?>{},
          selectedPlaceCount: null,
          clearSelectedLu72AttendantsCount: true,
          clearSelectedLu72StaffCount: true,
          clearSelectedLu72TotalCount: true,
          clearSelectedLu72State: true,
          clearSelectedWagon: true,
          clearSelectedRouteClassId: true,
          stations: const <Lu72StationItem>[],
        ));
        return;
      }

      final banner = await _routeSheetsRepository.getNextOrCurrentRouteBanner(
        employeeId: employeeId,
      );
      final list = await _routeSheetEmployeesRepository
          .lu72SearchActiveRouteSheetEmployees(
        employeeId: employeeId,
        state2Id: 3,
      );

      final rsId = banner?.routeSheetId ??
          (list.isNotEmpty ? list.first.routeSheetId : null);

      final active = list.where((e) => e.routeSheetId == rsId).isNotEmpty
          ? list.firstWhere((e) => e.routeSheetId == rsId)
          : (list.isNotEmpty ? list.first : null);

      final bannerRouteName = (banner?.routeName ?? '').trim();
      final fallbackName = (active?.routeSheet.name ?? '').trim();
      final routeTitle = bannerRouteName.isNotEmpty
          ? bannerRouteName
          : (fallbackName.isNotEmpty ? fallbackName : 'Маршрут');

      if (rsId == null) {
        emit(state.copyWith(
          status: Lu72Status.empty,
          clearRouteSheetId: true,
          clearRouteSheetLu72AttendantsCount: true,
          clearRouteSheetLu72StaffCount: true,
          clearRouteSheetLu72TotalCount: true,
          wagons: const <String>[],
          wagonRouteClassIds: const <String, int?>{},
          wagonRouteSheetItemIds: const <String, int?>{},
          wagonPlaceCounts: const <String, int?>{},
          wagonLu72AttendantsCounts: const <String, int?>{},
          wagonLu72StaffCounts: const <String, int?>{},
          wagonLu72TotalCounts: const <String, int?>{},
          wagonLu72States: const <String, int?>{},
          selectedPlaceCount: null,
          clearSelectedLu72AttendantsCount: true,
          clearSelectedLu72StaffCount: true,
          clearSelectedLu72TotalCount: true,
          clearSelectedLu72State: true,
          clearSelectedWagon: true,
          clearSelectedRouteClassId: true,
          routeTitle: routeTitle,
          routeSubtitle: 'Не найден routeSheetId',
          stations: const <Lu72StationItem>[],
          isLead: active?.isLead == true,
        ));
        return;
      }

      final groupNumber =
          banner?.groupNumber ?? active?.routeSheetItem.groupNumber;
      final st = active?.routeSheet.state2Id;
      // ignore: avoid_print
      // print(
      //   '[LU72][DEBUG] RouteSheetItems search params: routeSheetId=$rsId, groupNumber=${groupNumber ?? 'null'}',
      // );

      if (groupNumber == null) {
        emit(state.copyWith(
          status: Lu72Status.empty,
          routeSheetId: rsId,
          clearRouteSheetLu72AttendantsCount: true,
          clearRouteSheetLu72StaffCount: true,
          clearRouteSheetLu72TotalCount: true,
          wagons: const <String>[],
          wagonRouteClassIds: const <String, int?>{},
          wagonRouteSheetItemIds: const <String, int?>{},
          wagonPlaceCounts: const <String, int?>{},
          wagonLu72AttendantsCounts: const <String, int?>{},
          wagonLu72StaffCounts: const <String, int?>{},
          wagonLu72TotalCounts: const <String, int?>{},
          wagonLu72States: const <String, int?>{},
          selectedPlaceCount: null,
          clearSelectedLu72AttendantsCount: true,
          clearSelectedLu72StaffCount: true,
          clearSelectedLu72TotalCount: true,
          clearSelectedLu72State: true,
          clearSelectedWagon: true,
          clearSelectedRouteClassId: true,
          routeTitle: routeTitle,
          routeSubtitle: 'Не найден groupNumber для RouteSheetId: $rsId',
          stations: const <Lu72StationItem>[],
        ));
        return;
      }
      final itemsResponse = await _routeSheetItemsRepository.search(
        routeSheetId: rsId,
        groupNumber: groupNumber,
      );

      final items = itemsResponse.result;
      final grouped = items
          .map((e) => e.groupNumber)
          .whereType<int>()
          .toSet()
          .toList()
        ..sort();
      // ignore: avoid_print
      print(
        '[LU72][DEBUG] RouteSheetItems result: count=${items.length}, groupNumbers=$grouped',
      );

      final wagonRouteClassIds = <String, int?>{};
      final wagonRouteSheetItemIds = <String, int?>{};
      final wagonPlaceCounts = <String, int?>{};
      final wagonLu72AttendantsCounts = <String, int?>{};
      final wagonLu72StaffCounts = <String, int?>{};
      final wagonLu72TotalCounts = <String, int?>{};
      final wagonLu72States = <String, int?>{};
      final wagonLabels = <String>[];

      for (final e in items) {
        final n = (e.number ?? '').trim();
        if (n.isEmpty) continue;
        final wId = e.wagonId;
        final typeName = (e.wagonType?.name ?? '').trim();
        final baseLabel = typeName.isNotEmpty ? '$n • $typeName' : n;
        final label = (wId != null) ? '$baseLabel №$wId' : baseLabel;
        wagonLabels.add(label);
        wagonRouteClassIds[label] = e.wagon?.routeClassId;
        wagonRouteSheetItemIds[label] = e.id;
        wagonPlaceCounts[label] =
            e.wagonType?.placeCount ?? e.wagon?.wagonType?.placeCount;
        wagonLu72AttendantsCounts[label] = e.lu72AttendantsCount;
        wagonLu72StaffCounts[label] = e.lu72StaffiCount;
        wagonLu72TotalCounts[label] = e.lu72TotalCount;
        wagonLu72States[label] = e.lu72State;
      }

      final subtitle =
          'RouteSheetId: $rsId • groupNumber: $groupNumber • state2Id: ${st ?? "—"}';

      emit(state.copyWith(
        status: Lu72Status.loaded,
        routeSheetId: rsId,
        wagons: wagonLabels,
        stations: const <Lu72StationItem>[],
        wagonRouteClassIds: wagonRouteClassIds,
        wagonRouteSheetItemIds: wagonRouteSheetItemIds,
        wagonPlaceCounts: wagonPlaceCounts,
        wagonLu72AttendantsCounts: wagonLu72AttendantsCounts,
        wagonLu72StaffCounts: wagonLu72StaffCounts,
        wagonLu72TotalCounts: wagonLu72TotalCounts,
        wagonLu72States: wagonLu72States,
        selectedPlaceCount: null,
        clearSelectedLu72AttendantsCount: true,
        clearSelectedLu72StaffCount: true,
        clearSelectedLu72TotalCount: true,
        clearSelectedLu72State: true,
        routeSheetItemId: null,
        clearSelectedWagon: true,
        clearSelectedRouteClassId: true,
        routeTitle: routeTitle,
        routeSubtitle: subtitle,
      ));

      try {
        final summary =
            await _routeSheetsRepository.getLu72Summary(routeSheetId: rsId);
        // ignore: avoid_print
        print(
          '[LU72][DEBUG] RouteSheet summary: routeSheetId=$rsId, '
          'attendants=${summary?.lu72AttendantsCount}, '
          'staff=${summary?.lu72StaffCount}, '
          'total=${summary?.lu72TotalCount}',
        );
        emit(state.copyWith(
          routeSheetLu72AttendantsCount: summary?.lu72AttendantsCount,
          routeSheetLu72StaffCount: summary?.lu72StaffCount,
          routeSheetLu72TotalCount: summary?.lu72TotalCount,
        ));
      } catch (_) {
        emit(state.copyWith(
          clearRouteSheetLu72AttendantsCount: true,
          clearRouteSheetLu72StaffCount: true,
          clearRouteSheetLu72TotalCount: true,
        ));
      }

      try {
        final costsRes = await _wagonLu72CostsRepository.search(
          routeSheetId: rsId,
          take: 200,
          skip: 0,
          returnCount: true,
        );

        final costs = costsRes.result;

        emit(state.copyWith(
          costItems: costs,
          lu72Id: costs.isNotEmpty ? costs.first.lu72Id : null,
        ));
      } catch (e) {
        emit(state.copyWith(
          costItems: const <WagonLu72CostModel>[],
          lu72Id: null,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: Lu72Status.failure,
        errorMessage: e.toString(),
        clearRouteSheetId: true,
        clearRouteSheetLu72AttendantsCount: true,
        clearRouteSheetLu72StaffCount: true,
        clearRouteSheetLu72TotalCount: true,
        wagons: const <String>[],
        wagonRouteClassIds: const <String, int?>{},
        wagonRouteSheetItemIds: const <String, int?>{},
        wagonPlaceCounts: const <String, int?>{},
        wagonLu72AttendantsCounts: const <String, int?>{},
        wagonLu72StaffCounts: const <String, int?>{},
        wagonLu72TotalCounts: const <String, int?>{},
        wagonLu72States: const <String, int?>{},
        selectedPlaceCount: null,
        clearSelectedLu72AttendantsCount: true,
        clearSelectedLu72StaffCount: true,
        clearSelectedLu72TotalCount: true,
        clearSelectedLu72State: true,
        clearSelectedWagon: true,
        clearSelectedRouteClassId: true,
        stations: const <Lu72StationItem>[],
      ));
    }
  }

  Future<void> _onWagonSelected(
    Lu72WagonSelected event,
    Emitter<Lu72State> emit,
  ) async {
    final routeClassIdForFetch = state.wagonRouteClassIds[event.wagon];
    final routeSheetItemId = state.wagonRouteSheetItemIds[event.wagon];
    final selectedPlaceCount = state.wagonPlaceCounts[event.wagon];
    final selectedLu72AttendantsCount =
        state.wagonLu72AttendantsCounts[event.wagon];
    final selectedLu72StaffCount = state.wagonLu72StaffCounts[event.wagon];
    final selectedLu72TotalCount = state.wagonLu72TotalCounts[event.wagon];
    final selectedLu72State = state.wagonLu72States[event.wagon];

    emit(state.copyWith(
      selectedWagon: event.wagon,
      selectedRouteClassId: routeClassIdForFetch,
      selectedPlaceCount: selectedPlaceCount,
      selectedLu72AttendantsCount: selectedLu72AttendantsCount,
      selectedLu72StaffCount: selectedLu72StaffCount,
      selectedLu72TotalCount: selectedLu72TotalCount,
      selectedLu72State: selectedLu72State,
      routeSheetItemId: routeSheetItemId,
    ));

    try {
      if (routeSheetItemId == null) {
        emit(state.copyWith(costItems: const <WagonLu72CostModel>[]));
      } else {
        final costsRes = await _wagonLu72CostsRepository.search(
          routeSheetItemId: routeSheetItemId,
          take: 200,
          skip: 0,
          returnCount: true,
        );
        emit(state.copyWith(costItems: costsRes.result));
      }
    } catch (_) {
      emit(state.copyWith(costItems: const <WagonLu72CostModel>[]));
    }

    if (routeClassIdForFetch == null || routeClassIdForFetch <= 0) return;

    try {
      final body = <String, dynamic>{
        'paging': {
          'take': 200,
          'skip': 0,
          'returnCount': true,
        },
        'filter': {
          'routeClassId': {
            'operand1': routeClassIdForFetch,
            'operator': '1',
          },
        },
      };

      final res = await _dio.post(
        '/routes/api/v1/routeClassStations/search',
        data: body,
      );

      final data = Map<String, dynamic>.from(res.data as Map);
      final list = (data['result'] as List? ?? const [])
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList()
        ..sort((a, b) {
          final ao = (a['order'] as num?)?.toInt() ?? 999999;
          final bo = (b['order'] as num?)?.toInt() ?? 999999;
          return ao.compareTo(bo);
        });

      final stationItems = <Lu72StationItem>[];
      for (final e in list) {
        final stMap = e['station'];
        if (stMap is! Map) continue;

        final st = Map<String, dynamic>.from(stMap);
        final stationId = (st['id'] as num?)?.toInt();
        if (stationId == null || stationId <= 0) continue;

        final stationName = (st['name'] as String?)?.trim() ?? '';
        stationItems.add(
          Lu72StationItem(
            id: stationId,
            stationId: stationId,
            name: stationName.isNotEmpty ? stationName : 'Станция $stationId',
          ),
        );
      }

      final selectedStationId =
          stationItems.isNotEmpty ? stationItems.first.id : null;
      final startStationName =
          stationItems.isNotEmpty ? stationItems.first.name.trim() : null;

      emit(state.copyWith(
        stations: stationItems,
        startStationName: startStationName,
        selectedStationId: selectedStationId,
      ));
    } catch (e) {
      emit(state.copyWith(stations: const <Lu72StationItem>[]));
    }
  }

  Future<void> _onSaveRequested(
    Lu72SaveRequested event,
    Emitter<Lu72State> emit,
  ) async {
    final routeSheetItemId = state.routeSheetItemId;
    if (routeSheetItemId == null) {
      emit(state.copyWith(
        status: Lu72Status.failure,
        errorMessage: 'Не удалось сохранить: routeSheetItemId не определён',
      ));
      return;
    }

    final stationId = event.stationId;
    final Set<int> selectedSeats = event.seats;

    try {
      emit(state.copyWith(status: Lu72Status.loading, errorMessage: null));

      await _wagonLu72CostsRepository.upsert(
        routeSheetItemId: routeSheetItemId,
        stationId: stationId,
        seats: selectedSeats,
        mergeWithExisting: true,
        placeCount: null,
      );

      final refreshed =
          await _wagonLu72CostsRepository.searchByRouteSheetItemAndStation(
        routeSheetItemId: routeSheetItemId,
        stationId: stationId,
        take: 1,
        skip: 0,
        returnCount: false,
      );

      emit(state.copyWith(
        status: Lu72Status.loaded,
        costItems: _mergeCosts(state.costItems, refreshed.result),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Lu72Status.failure,
        errorMessage: 'Ошибка сохранения: $e',
      ));
    }
  }

  Future<void> _onSummaryMetaSaveRequested(
    Lu72SummaryMetaSaveRequested event,
    Emitter<Lu72State> emit,
  ) async {
    final nextAttendants =
        event.lu72AttendantsCount ?? state.routeSheetLu72AttendantsCount;
    final nextStaff = event.lu72StaffiCount ?? state.routeSheetLu72StaffCount;
    final nextTotal = (nextAttendants ?? 0) + (nextStaff ?? 0);

    emit(state.copyWith(
      errorMessage: null,
      routeSheetLu72AttendantsCount: nextAttendants,
      routeSheetLu72StaffCount: nextStaff,
      routeSheetLu72TotalCount: nextTotal,
    ));
  }

  Future<void> _onApprovalToggled(
    Lu72ApprovalToggled event,
    Emitter<Lu72State> emit,
  ) async {
    final selectedWagon = state.selectedWagon;
    if (selectedWagon == null) {
      emit(state.copyWith(
        errorMessage: 'Не удалось определить выбранный вагон',
      ));
      return;
    }

    final nextStateValue = event.approved ? 1 : 0;
    if (event.approved) {
      final routeSheetId = state.routeSheetId;
      final routeSheetItemId = state.routeSheetItemId;
      if (routeSheetId == null) {
        emit(state.copyWith(
          errorMessage: 'Не удалось определить routeSheetId',
        ));
        return;
      }
      if (routeSheetItemId == null) {
        emit(state.copyWith(
          errorMessage: 'Не удалось определить routeSheetItemId',
        ));
        return;
      }

      final nextAttendants = state.routeSheetLu72AttendantsCount ?? 0;
      final nextStaff = state.routeSheetLu72StaffCount ?? 0;
      final nextTotal = nextAttendants + nextStaff;

      emit(state.copyWith(
        isUpdatingLu72State: true,
        clearErrorMessage: true,
      ));

      try {
        final updated = await _routeSheetsRepository.patchLu72Summary(
          routeSheetId: routeSheetId,
          lu72AttendantsCount: nextAttendants,
          lu72StaffCount: nextStaff,
          lu72TotalCount: nextTotal,
        );
        final updatedItem = await _routeSheetItemsRepository.patchLu72Meta(
          id: routeSheetItemId,
          lu72State: nextStateValue,
        );

        final nextMap = Map<String, int?>.from(state.wagonLu72States);
        nextMap[selectedWagon] = updatedItem?.lu72State ?? nextStateValue;

        emit(state.copyWith(
          isUpdatingLu72State: false,
          wagonLu72States: nextMap,
          selectedLu72State: updatedItem?.lu72State ?? nextStateValue,
          routeSheetLu72AttendantsCount:
              updated?.lu72AttendantsCount ?? nextAttendants,
          routeSheetLu72StaffCount: updated?.lu72StaffCount ?? nextStaff,
          routeSheetLu72TotalCount: updated?.lu72TotalCount ?? nextTotal,
          clearErrorMessage: true,
        ));
      } catch (e) {
        emit(state.copyWith(
          isUpdatingLu72State: false,
          errorMessage: 'Ошибка сохранения: $e',
        ));
      }
      return;
    }

    final nextMap = Map<String, int?>.from(state.wagonLu72States);
    nextMap[selectedWagon] = nextStateValue;

    emit(state.copyWith(
      isUpdatingLu72State: false,
      wagonLu72States: nextMap,
      selectedLu72State: nextStateValue,
      clearErrorMessage: true,
    ));
  }

  List<WagonLu72CostModel> _mergeCosts(
    List<WagonLu72CostModel> oldList,
    List<WagonLu72CostModel> newOnes,
  ) {
    String keyOf(WagonLu72CostModel c) =>
        '${c.routeSheetItemId ?? c.lu72Id}_${c.stationId}';

    final map = <String, WagonLu72CostModel>{};
    for (final c in oldList) {
      map[keyOf(c)] = c;
    }
    for (final c in newOnes) {
      map[keyOf(c)] = c;
    }
    return map.values.toList(growable: false);
  }
}
