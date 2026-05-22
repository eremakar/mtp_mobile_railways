import 'package:passflow_app/data/models/class_station_model.dart';
import 'package:passflow_app/data/models/ticket_model.dart';

class BoardingState {
  final bool isLoading;

  final List<String> trains;
  final String? train;

  final List<String> dates;
  final String? date;

  final List<String> cars;
  final String? car;

  final List<ClassStationModel> stations;
  final ClassStationModel? station;

  final Map<String, int> trainToClassId;

  final Map<String, List<String>> trainToDates;

  BoardingState({
    this.isLoading = false,
    this.trains = const [],
    this.train,
    this.dates = const [],
    this.date,
    this.cars = const [],
    this.car,
    this.stations = const [],
    this.station,
    this.trainToClassId = const {},
    this.trainToDates = const {},
  });

  BoardingState copyWith({
    bool? isLoading,
    List<String>? trains,
    String? train,
    List<String>? dates,
    String? date,
    List<String>? cars,
    String? car,
    List<ClassStationModel>? stations,
    ClassStationModel? station,
    Map<String, int>? trainToClassId,
    Map<String, List<String>>? trainToDates,
  }) {
    return BoardingState(
      isLoading: isLoading ?? this.isLoading,
      trains: trains ?? this.trains,
      train: train ?? this.train,
      dates: dates ?? this.dates,
      date: date ?? this.date,
      cars: cars ?? this.cars,
      car: car ?? this.car,
      stations: stations ?? this.stations,
      station: station,
      trainToClassId: trainToClassId ?? this.trainToClassId,
      trainToDates: trainToDates ?? this.trainToDates,
    );
  }
}
