import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:passflow_app/data/models/wagon_lu72_costs_models.dart';

enum Lu72Status { initial, loading, loaded, empty, failure }

@immutable
class Lu72StationItem {
  const Lu72StationItem({
    required this.id,
    required this.name,
    this.stationId,
  });

  final int id;
  final int? stationId;
  final String name;

  @override
  String toString() => name;
}

@immutable
class Lu72State extends Equatable {
  const Lu72State({
    required this.status,
    required this.routeTitle,
    required this.routeSubtitle,
    required this.stations,
    required this.costItems,
    required this.wagons,
    required this.selectedWagon,
    required this.wagonRouteClassIds,
    required this.wagonRouteSheetItemIds,
    required this.wagonPlaceCounts,
    required this.wagonLu72AttendantsCounts,
    required this.wagonLu72StaffCounts,
    required this.wagonLu72TotalCounts,
    required this.wagonLu72States,
    required this.selectedRouteClassId,
    this.selectedPlaceCount,
    this.routeSheetId,
    this.routeSheetLu72AttendantsCount,
    this.routeSheetLu72StaffCount,
    this.routeSheetLu72TotalCount,
    this.routeSheetItemId,
    this.lu72Id,
    this.selectedLu72AttendantsCount,
    this.selectedLu72StaffCount,
    this.selectedLu72TotalCount,
    this.selectedLu72State,
    this.isUpdatingLu72State = false,
    this.selectedStationId,
    this.selectedCostItem,
    this.startStationName,
    this.errorMessage,
    this.isLead = false,
  });

  final Lu72Status status;
  final String routeTitle;
  final String routeSubtitle;
  final List<Lu72StationItem> stations;
  final List<WagonLu72CostModel> costItems;

  final List<String> wagons;
  final String? selectedWagon;
  final Map<String, int?> wagonRouteClassIds;
  final Map<String, int?> wagonRouteSheetItemIds;
  final Map<String, int?> wagonPlaceCounts;
  final Map<String, int?> wagonLu72AttendantsCounts;
  final Map<String, int?> wagonLu72StaffCounts;
  final Map<String, int?> wagonLu72TotalCounts;
  final Map<String, int?> wagonLu72States;
  final int? selectedRouteClassId;
  final int? selectedPlaceCount;
  final int? routeSheetId;
  final int? routeSheetLu72AttendantsCount;
  final int? routeSheetLu72StaffCount;
  final int? routeSheetLu72TotalCount;
  final int? routeSheetItemId;
  final int? lu72Id;
  final int? selectedLu72AttendantsCount;
  final int? selectedLu72StaffCount;
  final int? selectedLu72TotalCount;
  final int? selectedLu72State;
  final bool isUpdatingLu72State;
  final int? selectedStationId;
  final WagonLu72CostModel? selectedCostItem;

  final String? startStationName;
  final String? errorMessage;
  int? get routeClassId => selectedRouteClassId;
  final bool isLead;

  factory Lu72State.initial() => const Lu72State(
        status: Lu72Status.initial,
        routeTitle: 'Активный маршрут',
        routeSubtitle: '—',
        stations: <Lu72StationItem>[],
        costItems: <WagonLu72CostModel>[],
        wagons: <String>[],
        selectedWagon: null,
        wagonRouteClassIds: <String, int?>{},
        wagonRouteSheetItemIds: <String, int?>{},
        wagonPlaceCounts: <String, int?>{},
        wagonLu72AttendantsCounts: <String, int?>{},
        wagonLu72StaffCounts: <String, int?>{},
        wagonLu72TotalCounts: <String, int?>{},
        wagonLu72States: <String, int?>{},
        selectedRouteClassId: null,
        selectedPlaceCount: null,
        routeSheetId: null,
        routeSheetLu72AttendantsCount: null,
        routeSheetLu72StaffCount: null,
        routeSheetLu72TotalCount: null,
        routeSheetItemId: null,
        lu72Id: null,
        selectedLu72AttendantsCount: null,
        selectedLu72StaffCount: null,
        selectedLu72TotalCount: null,
        selectedLu72State: null,
        isUpdatingLu72State: false,
        selectedStationId: null,
        selectedCostItem: null,
        startStationName: null,
        errorMessage: null,
        isLead: false,
      );

  Lu72State copyWith({
    Lu72Status? status,
    String? routeTitle,
    String? routeSubtitle,
    List<Lu72StationItem>? stations,
    List<WagonLu72CostModel>? costItems,
    List<String>? wagons,
    String? selectedWagon,
    bool clearSelectedWagon = false,
    Map<String, int?>? wagonRouteClassIds,
    Map<String, int?>? wagonRouteSheetItemIds,
    Map<String, int?>? wagonPlaceCounts,
    Map<String, int?>? wagonLu72AttendantsCounts,
    Map<String, int?>? wagonLu72StaffCounts,
    Map<String, int?>? wagonLu72TotalCounts,
    Map<String, int?>? wagonLu72States,
    int? selectedRouteClassId,
    bool clearSelectedRouteClassId = false,
    int? selectedPlaceCount,
    bool clearSelectedPlaceCount = false,
    int? routeSheetId,
    bool clearRouteSheetId = false,
    int? routeSheetLu72AttendantsCount,
    bool clearRouteSheetLu72AttendantsCount = false,
    int? routeSheetLu72StaffCount,
    bool clearRouteSheetLu72StaffCount = false,
    int? routeSheetLu72TotalCount,
    bool clearRouteSheetLu72TotalCount = false,
    String? startStationName,
    int? routeSheetItemId,
    int? lu72Id,
    int? selectedLu72AttendantsCount,
    bool clearSelectedLu72AttendantsCount = false,
    int? selectedLu72StaffCount,
    bool clearSelectedLu72StaffCount = false,
    int? selectedLu72TotalCount,
    bool clearSelectedLu72TotalCount = false,
    int? selectedLu72State,
    bool clearSelectedLu72State = false,
    bool? isUpdatingLu72State,
    int? selectedStationId,
    WagonLu72CostModel? selectedCostItem,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool? isLead,
  }) {
    return Lu72State(
      status: status ?? this.status,
      routeTitle: routeTitle ?? this.routeTitle,
      routeSubtitle: routeSubtitle ?? this.routeSubtitle,
      stations: stations ?? this.stations,
      costItems: costItems ?? this.costItems,
      wagons: wagons ?? this.wagons,
      selectedWagon:
          clearSelectedWagon ? null : (selectedWagon ?? this.selectedWagon),
      wagonRouteClassIds: wagonRouteClassIds ?? this.wagonRouteClassIds,
      wagonRouteSheetItemIds:
          wagonRouteSheetItemIds ?? this.wagonRouteSheetItemIds,
      wagonPlaceCounts: wagonPlaceCounts ?? this.wagonPlaceCounts,
      wagonLu72AttendantsCounts:
          wagonLu72AttendantsCounts ?? this.wagonLu72AttendantsCounts,
      wagonLu72StaffCounts: wagonLu72StaffCounts ?? this.wagonLu72StaffCounts,
      wagonLu72TotalCounts: wagonLu72TotalCounts ?? this.wagonLu72TotalCounts,
      wagonLu72States: wagonLu72States ?? this.wagonLu72States,
      selectedRouteClassId: clearSelectedRouteClassId
          ? null
          : (selectedRouteClassId ?? this.selectedRouteClassId),
      selectedPlaceCount: clearSelectedPlaceCount
          ? null
          : (selectedPlaceCount ?? this.selectedPlaceCount),
      routeSheetId:
          clearRouteSheetId ? null : (routeSheetId ?? this.routeSheetId),
      routeSheetLu72AttendantsCount: clearRouteSheetLu72AttendantsCount
          ? null
          : (routeSheetLu72AttendantsCount ??
              this.routeSheetLu72AttendantsCount),
      routeSheetLu72StaffCount: clearRouteSheetLu72StaffCount
          ? null
          : (routeSheetLu72StaffCount ?? this.routeSheetLu72StaffCount),
      routeSheetLu72TotalCount: clearRouteSheetLu72TotalCount
          ? null
          : (routeSheetLu72TotalCount ?? this.routeSheetLu72TotalCount),
      routeSheetItemId: routeSheetItemId ?? this.routeSheetItemId,
      lu72Id: lu72Id ?? this.lu72Id,
      selectedLu72AttendantsCount: clearSelectedLu72AttendantsCount
          ? null
          : (selectedLu72AttendantsCount ?? this.selectedLu72AttendantsCount),
      selectedLu72StaffCount: clearSelectedLu72StaffCount
          ? null
          : (selectedLu72StaffCount ?? this.selectedLu72StaffCount),
      selectedLu72TotalCount: clearSelectedLu72TotalCount
          ? null
          : (selectedLu72TotalCount ?? this.selectedLu72TotalCount),
      selectedLu72State: clearSelectedLu72State
          ? null
          : (selectedLu72State ?? this.selectedLu72State),
      isUpdatingLu72State: isUpdatingLu72State ?? this.isUpdatingLu72State,
      selectedStationId: selectedStationId ?? this.selectedStationId,
      selectedCostItem: selectedCostItem ?? this.selectedCostItem,
      startStationName: startStationName ?? this.startStationName,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      isLead: isLead ?? this.isLead,
    );
  }

  @override
  List<Object?> get props => [
        status,
        routeTitle,
        routeSubtitle,
        stations,
        costItems,
        wagons,
        selectedWagon,
        wagonRouteClassIds,
        wagonRouteSheetItemIds,
        wagonPlaceCounts,
        wagonLu72AttendantsCounts,
        wagonLu72StaffCounts,
        wagonLu72TotalCounts,
        wagonLu72States,
        selectedRouteClassId,
        selectedPlaceCount,
        routeSheetId,
        routeSheetLu72AttendantsCount,
        routeSheetLu72StaffCount,
        routeSheetLu72TotalCount,
        routeSheetItemId,
        lu72Id,
        selectedLu72AttendantsCount,
        selectedLu72StaffCount,
        selectedLu72TotalCount,
        selectedLu72State,
        isUpdatingLu72State,
        selectedStationId,
        selectedCostItem,
        startStationName,
        errorMessage,
        isLead,
      ];
}
