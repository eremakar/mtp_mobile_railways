
abstract class NextRouteEvent {
  const NextRouteEvent();

  List<Object?> get props => [];
}

class LoadNextRoute extends NextRouteEvent {
  final int employeeId;
  final DateTime selectedMonth;

  const LoadNextRoute({required this.employeeId, required this.selectedMonth});

  @override
  List<Object?> get props => [employeeId, selectedMonth];
}
