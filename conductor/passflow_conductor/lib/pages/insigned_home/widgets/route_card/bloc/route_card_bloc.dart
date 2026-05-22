import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passflow_app/data/models/route_sheets_models.dart';
import 'package:passflow_app/data/repositories/route_sheets_repository.dart';
import 'package:passflow_app/pages/insigned_home/widgets/route_card/bloc/route_card_event.dart';
import 'package:passflow_app/pages/insigned_home/widgets/route_card/bloc/route_card_state.dart';

class NextRouteBloc extends Bloc<NextRouteEvent, NextRouteState> {
  final RouteSheetsRepository routeRepo;

  NextRouteBloc(this.routeRepo) : super(NextRouteInitial()) {
    on<LoadNextRoute>(_onLoadNextRoute);
  }

  Future<void> _onLoadNextRoute(
    LoadNextRoute event,
    Emitter<NextRouteState> emit,
  ) async {
    emit(NextRouteLoading());

    try {
      final routes = await routeRepo.search(
        employeeId: event.employeeId,
        month: event.selectedMonth,
      );
      
      final now = DateTime.now().toUtc();
      RouteSheetSearchDto? picked;

      for (final r in routes) {
        final lt = r.leaveTime;
        if (lt == null) continue;
        if (!lt.isAfter(now)) continue;

        if (picked == null || lt.isBefore(picked.leaveTime!)) {
          picked = r;
        }
      }

      emit(NextRouteLoaded(picked));
    } catch (e) {
      emit(NextRouteError(e.toString()));
    }
  }
}