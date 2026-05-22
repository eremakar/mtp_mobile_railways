import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passflow_app/core/di/service_locator.dart';
import 'package:passflow_app/data/repositories/boardings_repo.dart';
import 'package:passflow_app/data/repositories/class_stations_repo.dart';

import 'boardings_event.dart';
import 'boardings_state.dart';

class BoardingBloc extends Bloc<BoardingEvent, BoardingState> {
  final BoardingsRepo repository = sl<BoardingsRepo>();
  final StationsRepo stationsRepository = sl<StationsRepo>();

  BoardingBloc() : super(BoardingState()) {
    on<LoadInitialData>(_onLoadInitialData);
    on<TrainChanged>(_onTrainChanged);
    on<DateChanged>(_onDateChanged);
    on<CarChanged>(_onCarChanged);
    on<StationChanged>(_onStationChanged);
  }

  Future<void> _onLoadInitialData(
      LoadInitialData event, Emitter<BoardingState> emit) async {
    emit(state.copyWith(isLoading: true));

    final data = await repository.getBoardingDropdownValues(event.routeSheetId);

    final trains = (data['trains'] as List<dynamic>? ?? []).cast<String>();
    final cars = (data['carOrders'] as List<dynamic>? ?? []).cast<String>();
    final trainToClassId =
        (data['trainToClassId'] as Map<String, dynamic>? ?? {})
            .map((key, value) => MapEntry(key, value as int));
    final trainToDatesRaw =
        (data['trainToDates'] as Map<String, dynamic>? ?? {});

    final trainToDates = trainToDatesRaw.map((key, value) {
      final listDynamic = value as List<dynamic>;
      return MapEntry(key, listDynamic.cast<String>());
    });

    final firstTrain = trains.isNotEmpty ? trains.first : null;
    final datesForFirstTrain =
        firstTrain != null ? trainToDates[firstTrain] ?? [] : [];

    if (firstTrain == null || trainToClassId[firstTrain] == null) return;
    var stations = await stationsRepository
        .getStationNamesByClassId(trainToClassId[firstTrain]!);

    emit(state.copyWith(
      isLoading: false,
      trains: trains,
      cars: cars,
      trainToClassId: trainToClassId,
      trainToDates: trainToDates,
      train: firstTrain,
      dates: datesForFirstTrain.cast<String>(),
      date: datesForFirstTrain.isNotEmpty ? datesForFirstTrain.first : null,
      stations: stations,
      station: null,
    ));
  }

  Future<void> _onTrainChanged(
      TrainChanged event, Emitter<BoardingState> emit) async {
    emit(state.copyWith(
        train: event.train, station: null, stations: [], isLoading: true));

    final classId = state.trainToClassId[event.train];
    final datesForTrain = state.trainToDates[event.train] ?? [];

    if (classId == null) return;
    var stations = await stationsRepository.getStationNamesByClassId(classId);

    emit(state.copyWith(
      stations: stations,
      station: null,
      dates: datesForTrain,
      date: datesForTrain.isNotEmpty ? datesForTrain.first : null,
      isLoading: false,
      train: event.train,
    ));
  }

  void _onDateChanged(DateChanged event, Emitter<BoardingState> emit) {
    emit(state.copyWith(date: event.date));
  }

  void _onCarChanged(CarChanged event, Emitter<BoardingState> emit) {
    emit(state.copyWith(car: event.car));
  }

  void _onStationChanged(StationChanged event, Emitter<BoardingState> emit) {
    emit(state.copyWith(station: event.station));
  }
}
