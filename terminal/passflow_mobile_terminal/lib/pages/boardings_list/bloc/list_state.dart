import 'package:equatable/equatable.dart';
import 'package:passflow_app/data/models/name_id.pair_model.dart';
import 'package:passflow_app/data/models/route_sheet_direction.dart';
import 'package:passflow_app/data/models/ticket_model.dart';
import 'package:passflow_app/data/models/tickets_search_entry_model.dart';
import 'package:passflow_app/data/models/train_direction_model.dart';

abstract class BoardingsState extends Equatable {
  const BoardingsState();

  @override
  List<Object?> get props => [];
}

class BoardingsListState extends BoardingsState {
  final bool isLoading;
  final String? error;
  final List<TicketModel> tickets;
  final int offset;
  final bool hasMore;

  /// null — ничего, true — успех, false — ошибка (последняя операция)
  final bool? boardingSuccess;

  /// Локальные статусы (UI-метки)
  final Set<String> refusedTicketIds;
  final Set<String> disembarkedTicketIds;
  // final List<NameIdPairModel>? stations;
  final List<TrainDirectionModel>? trainDirections;
  final String? startTime; // Uncomment if needed
  final List<TicketSearchEntryModel> history;

  const BoardingsListState({
    this.isLoading = false,
    this.error,
    this.tickets = const [],
    this.offset = 0,
    this.hasMore = true,
    this.boardingSuccess,
    this.refusedTicketIds = const {},
    this.disembarkedTicketIds = const {},
    // this.stations,
    this.trainDirections,
    this.startTime,
    this.history = const [],
  });

  BoardingsListState copyWith(
      {bool? isLoading,
      String? error,
      List<TicketModel>? tickets,
      List<NameIdPairModel>? stations,
      List<TrainDirectionModel>? trainDirections,
      int? offset,
      bool? hasMore,
      bool clearError = false,
      bool? boardingSuccess,
      Set<String>? refusedTicketIds,
      Set<String>? disembarkedTicketIds,
      String? startTime,
      List<TicketSearchEntryModel>? history}) {
    return BoardingsListState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      tickets: tickets ?? this.tickets,
      offset: offset ?? this.offset,
      hasMore: hasMore ?? this.hasMore,
      boardingSuccess: boardingSuccess,
      refusedTicketIds: refusedTicketIds ?? this.refusedTicketIds,
      disembarkedTicketIds: disembarkedTicketIds ?? this.disembarkedTicketIds,
      // stations: stations ?? this.stations,
      trainDirections: trainDirections ?? this.trainDirections,
      startTime: startTime ?? this.startTime, // Uncomment if needed
      history: history ?? this.history,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        tickets,
        error,
        offset,
        hasMore,
        boardingSuccess,
        refusedTicketIds,
        disembarkedTicketIds,
        // stations,
        trainDirections,
        startTime, // Uncomment if needed
        history,
      ];
}
