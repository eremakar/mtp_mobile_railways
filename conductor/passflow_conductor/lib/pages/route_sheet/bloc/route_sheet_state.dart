part of 'route_sheet_bloc.dart';

@immutable
abstract class RouteSheetState {}

class RouteSheetLoading extends RouteSheetState {}

class RouteSheetLoaded extends RouteSheetState {
  final List<RouteSheetModel> routeSheets;

  RouteSheetLoaded(this.routeSheets);
}

class RouteSheetError extends RouteSheetState {
  final String message;

  RouteSheetError(this.message);
}
