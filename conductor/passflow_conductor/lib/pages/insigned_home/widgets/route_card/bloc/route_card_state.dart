import 'package:passflow_app/data/models/route_sheets_models.dart';

abstract class NextRouteState {
  const NextRouteState();

  List<Object?> get props => [];
}

class NextRouteInitial extends NextRouteState {}

class NextRouteLoading extends NextRouteState {}

class NextRouteLoaded extends NextRouteState {
  final RouteSheetSearchDto? nextRoute;

  const NextRouteLoaded(this.nextRoute);

  @override
  List<Object?> get props => [nextRoute];
}

class NextRouteError extends NextRouteState {
  final String message;

  const NextRouteError(this.message);

  @override
  List<Object?> get props => [message];
}
