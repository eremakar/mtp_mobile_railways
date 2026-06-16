import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:passflow_app/core/cache/route_sheet_search_cache.dart';
import 'package:passflow_app/core/di/service_locator.dart';
import 'package:passflow_app/data/models/boarding_model.dart';
import 'package:passflow_app/data/models/class_station_model.dart';
import 'package:passflow_app/data/models/name_id.pair_model.dart';
import 'package:passflow_app/data/models/taskForm/add_form_model.dart';
import 'package:passflow_app/data/models/taskForm/put_task_form_model.dart';
import 'package:passflow_app/data/models/taskListType/task_model.dart';
import 'package:passflow_app/data/models/ticket_model.dart';
import 'package:passflow_app/data/models/tickets_search_entry_model.dart';
import 'package:passflow_app/data/models/train_direction_model.dart';
import 'package:passflow_app/data/models/train_directions_response.dart';
import 'package:passflow_app/data/models/user_model.dart';
import 'package:passflow_app/data/models/route_sheet_model.dart';
import 'package:passflow_app/data/models/taskForm/task_form_model.dart';
import 'package:passflow_app/data/repositories/class_stations_repo.dart';
import 'package:passflow_app/data/repositories/route_sheet_employees_repository.dart';
import 'package:passflow_app/data/repositories/task_form_repository.dart';
import 'package:passflow_app/data/repositories/task_list_type_repository.dart';
import 'package:passflow_app/data/repositories/tickets_repository.dart';
import 'package:passflow_app/data/repositories/train_direction_repository.dart';
import 'package:passflow_app/utils/network_utils.dart';

class HiveService {
  static const _apiLoadMinInterval = Duration(minutes: 5);

  static DateTime? _lastApiLoadAt;
  static bool _loadInProgress = false;

  static Future<void> initAllHive({bool force = false}) async {
    await Hive.initFlutter();

    await Future.wait([
      Hive.openBox<TaskListTypeModel>('taskLists'),
      Hive.openBox<RouteSheetModel>('routeSheets'),
      Hive.openBox<TaskFormModel>('taskFormTypes'),
      Hive.openBox<Map>('formAnswers'),
      Hive.openBox<UserModel>('userBox'),
      Hive.openBox<bool>('needSync'),
      Hive.openBox<PutTaskFormModel>('formId'),
      Hive.openBox<String>('pending_boarding'),
      Hive.openBox<TicketModel>('tickets'),
      Hive.openBox<TicketSearchEntryModel>('search_history'),
      Hive.openBox('tickets_cache'),
      Hive.openBox<TrainDirectionsResponse>('train_directions'),
      Hive.openBox<List<ClassStationModel>>('loaded_stations'),
      Hive.openBox<String>('station_codes'),
      Hive.openBox('deviceBox'),
    ]);
    await _loadFromApiIfOnline(force: force);
  }

  /// Повторная загрузка маршрутов с API (без переоткрытия Hive).
  static Future<void> syncRouteSheetsFromApi({bool force = false}) async {
    await _loadFromApiIfOnline(force: force);
  }

  static Future<void> clear() async {
    _lastApiLoadAt = null;
    RouteSheetSearchCache.invalidate();
    await Hive.box<RouteSheetModel>('routeSheets').clear();
    await Hive.box<TaskListTypeModel>('taskLists').clear();
    await Hive.box<TaskFormModel>('taskFormTypes').clear();
    await Hive.box<Map>('formAnswers').clear();
    await Hive.box<bool>('needSync').clear();
    await Hive.box<PutTaskFormModel>('formId').clear();
    await Hive.box<String>('pending_boarding').clear();
    await Hive.box<TicketModel>('tickets').clear();
    await Hive.box<TicketSearchEntryModel>('search_history').clear();
    await Hive.box('tickets_cache').clear();
    await Hive.box<TrainDirectionsResponse>('train_directions').clear();
    await Hive.box<List<ClassStationModel>>('loaded_stations').clear();
    await Hive.box<String>('station_codes').clear();
    await Hive.box('deviceBox').clear();
  }

  static Future<void> _loadFromApiIfOnline({bool force = false}) async {
    if (!force &&
        _lastApiLoadAt != null &&
        DateTime.now().difference(_lastApiLoadAt!) < _apiLoadMinInterval) {
      return;
    }
    if (_loadInProgress) return;
    _loadInProgress = true;

    final userBox = Hive.box<UserModel>('userBox');
    final user = userBox.get('currentUser');
    if (user?.id == null) {
      print('❌ Не найден пользователь в userBox');
      _loadInProgress = false;
      return;
    }

    final online = await NetworkUtils.isNetworkAvailable();
    if (!online) {
      print("📴 Нет интернета — пропускаем загрузку с API");
      _loadInProgress = false;
      return;
    }

    try {
      // Попробуем повторно отправить все локально сохранённые посадки
      try {
        final ticketsRepo = sl<TicketsRepository>();
        await ticketsRepo.resendAllPendingBoardings();
      } catch (e) {
        print('⚠️ Ошибка повторной отправки посадок: $e');
      }

      final routeSheetRepo = sl<RouteSheetEmployeesRepository>();

      final userId = user!.employeeId;
      final filialId = user.filialId;
      var sheets = await routeSheetRepo.searchByEmployeeId(userId);

      if ((sheets == null || sheets.isEmpty) && filialId != null) {
        sheets = await routeSheetRepo.searchByFilialId(filialId);
      }

      if (sheets == null) {
        print('❌ Не удалось получить маршруты');
        return;
      }

      final routeSheetBox = Hive.box<RouteSheetModel>('routeSheets');
      await routeSheetBox.clear();

      if (sheets.isEmpty) {
        print('ℹ️ Маршрутов нет — кэш очищен');
        _lastApiLoadAt = DateTime.now();
        return;
      }

    // final taskListRepo = sl<TaskListTypeRepository>();
    // final taskFormRepo = sl<TaskFormRepository>();
    // final stationsRepo = sl<StationsRepo>();

    // final taskListBox = Hive.box<TaskListTypeModel>('taskLists');
    // final taskFormBox = Hive.box<TaskFormModel>('taskFormTypes');
    // final formIdBox = Hive.box<PutTaskFormModel>('formId');

      for (final sheet in sheets) {
      // if (sheet.startStationName != null) {
      //   var stationCode =
      //       await stationsRepo.searchSspdStationCode(sheet.startStationName!);
      //   sheet.startStationCode = stationCode;
      // }

        await routeSheetBox.put(sheet.id, sheet);

      // final taskListId = sheet.taskListTypeId;
      // final taskList = await taskListRepo.getById(taskListId);
      // if (taskList != null) {
      //   await taskListBox.put(taskListId, taskList);
      //   for (final block in taskList.configuration.data) {
      //     for (final task in block.tasks) {
      //       final typeId = int.tryParse(task.typeId);
      //       if (typeId != null) {
      //         final formType = await taskFormRepo.getFromTaskByTypeId(typeId);
      //         if (formType != null) {
      //           await taskFormBox.put(typeId, formType);
      //           final formIdState = await taskFormRepo.getFormByTypeId(
      //               typeId, sheet.id, userId);
      //           if (formIdState != null) {
      //             await formIdBox.put(
      //                 typeId,
      //                 PutTaskFormModel(
      //                     id: formIdState.id,
      //                     coordinatorEmployeeId: userId,
      //                     routeSheetId: sheet.id,
      //                     state: formIdState.state,
      //                     type2Id: typeId,
      //                     type: task.tasktype));
      //             task.currentStatus = formIdState.state;
      //           } else {
      //             var formId = await taskFormRepo.addTaskForm(AddFormModel(
      //                 id: 0,
      //                 state: 2,
      //                 routeSheetId: sheet.id,
      //                 coordinatorEmployeeId: userId,
      //                 type2Id: typeId));
      //             if (formId != null) {
      //               await formIdBox.put(
      //                   typeId,
      //                   PutTaskFormModel(
      //                       id: formId,
      //                       coordinatorEmployeeId: userId,
      //                       routeSheetId: sheet.id,
      //                       state: 2,
      //                       type2Id: typeId,
      //                       type: task.tasktype));
      //             }
      //           }
      //         }
      //       }
      //     }
      //   }
      // }
      }

      _lastApiLoadAt = DateTime.now();
      print("✅ Данные загружены в Hive: routeSheets, taskLists, taskForms");
    } finally {
      _loadInProgress = false;
    }
  }
}
