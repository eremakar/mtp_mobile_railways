import 'package:passflow_app/data/models/class_station_model.dart';

abstract class BoardingEvent {}

class LoadInitialData extends BoardingEvent {
  final num routeSheetId;
  LoadInitialData({required this.routeSheetId});
}

class TrainChanged extends BoardingEvent {
  final String train;
  TrainChanged(this.train);
}

class DateChanged extends BoardingEvent {
  final String date;
  DateChanged(this.date);
}

class CarChanged extends BoardingEvent {
  final String car;
  CarChanged(this.car);
}

class StationChanged extends BoardingEvent {
  final ClassStationModel station;
  StationChanged(this.station);
}
