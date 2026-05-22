import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:passflow_app/data/models/route_sheet_model.dart';
import 'package:passflow_app/data/models/taskListType/task_model.dart';
import 'package:passflow_app/data/models/user_model.dart';
import 'package:passflow_app/data/repositories/route_sheet_employees_repository.dart';
import 'package:passflow_app/data/repositories/task_list_type_repository.dart';

part 'route_sheet_event.dart';
part 'route_sheet_state.dart';

class RouteSheetBloc extends Bloc<RouteSheetEvent, RouteSheetState> {
  final RouteSheetEmployeesRepository repository;
  final Box<RouteSheetModel> hiveBox;
  final TaskListTypeRepository taskRepo;
  final Box<TaskListTypeModel> taskBox;

  RouteSheetBloc({
    required this.repository,
    required this.hiveBox,
    required this.taskRepo,
    required this.taskBox,
  }) : super(RouteSheetLoading()) {
    on<LoadRouteSheets>((event, emit) async {
      emit(RouteSheetLoading());

      try {
        final user = Hive.box<UserModel>('userBox');

        final result = await repository
            .searchByEmployeeId(user.get('currentUser')?.id ?? 0);

        if (result != null && result.isNotEmpty) {
          // Очистим и сохраним маршруты
          await hiveBox.clear();
          for (var sheet in result) {
            await hiveBox.put(sheet.id, sheet);
          }

          // Загрузим связанные TaskListTypeModel по taskListTypeId
          for (final sheet in result) {
            final taskListTypeId = sheet.taskListTypeId;
            if (taskListTypeId > 0 && !taskBox.containsKey(taskListTypeId)) {
              final form = await taskRepo.getById(taskListTypeId);
              if (form != null) {
                await taskBox.put(taskListTypeId, form);
              }
            }
          }

          emit(RouteSheetLoaded(result));
          return;
        }

        // офлайн — берём маршруты из кэша
        final cached = hiveBox.values.toList();
        if (cached.isNotEmpty) {
          emit(RouteSheetLoaded(cached));
        } else {
          emit(RouteSheetError("Нет данных ни в сети, ни в кэше"));
        }
      } catch (e) {
        final cached = hiveBox.values.toList();
        if (cached.isNotEmpty) {
          emit(RouteSheetLoaded(cached));
        } else {
          emit(RouteSheetError("Ошибка: ${e.toString()}"));
        }
      }
    });
  }
}
