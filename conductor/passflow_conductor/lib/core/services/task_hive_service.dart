import 'package:hive_flutter/hive_flutter.dart';
import 'package:passflow_app/data/models/taskForm/put_task_form_model.dart';
import 'package:passflow_app/data/models/taskListType/task_model.dart';
import 'package:passflow_app/data/models/user_model.dart';
import 'package:passflow_app/data/models/route_sheet_model.dart';
import 'package:passflow_app/data/models/taskForm/task_form_model.dart';

class HiveService {
  static Future<void> initAllHive() async {
    await Hive.initFlutter();

    await Future.wait([
      Hive.openBox<TaskListTypeModel>('taskLists'),
      Hive.openBox<RouteSheetModel>('routeSheets'),
      Hive.openBox<TaskFormModel>('taskFormTypes'),
      Hive.openBox<Map>('formAnswers'),
      Hive.openBox<UserModel>('userBox'),
      Hive.openBox<bool>('needSync'),
      Hive.openBox<PutTaskFormModel>('formId'),
    ]);

    // await _loadFromApiIfOnline();
  }

  static Future<void> clear() async {
    Hive.box<RouteSheetModel>('routeSheets').clear();
    Hive.box<TaskListTypeModel>('taskLists').clear();
    Hive.box<TaskFormModel>('taskFormTypes').clear();
    Hive.box<Map>('formAnswers').clear();
    Hive.box<bool>('needSync').clear();
    Hive.box<PutTaskFormModel>('formId').clear();
  }

  // static Future<void> _loadFromApiIfOnline() async {
  //   final userBox = Hive.box<UserModel>('userBox');
  //   final user = userBox.get('currentUser');
  //   if (user?.id == null) {
  //     logger.i('❌ Не найден пользователь в userBox');
  //     return;
  //   }

  //   final online = await NetworkUtils.hasConnection();
  //   if (!online) {
  //     logger.i("📴 Нет интернета — пропускаем загрузку с API");
  //     return;
  //   }

  //   final routeSheetRepo = sl<RouteSheetEmployeesRepository>();
  //   final taskListRepo = sl<TaskListTypeRepository>();
  //   final taskFormRepo = sl<TaskFormRepository>();

  //   final routeSheetBox = Hive.box<RouteSheetModel>('routeSheets');
  //   final taskListBox = Hive.box<TaskListTypeModel>('taskLists');
  //   final taskFormBox = Hive.box<TaskFormModel>('taskFormTypes');
  //   // final formAnswersBox = Hive.box<Map>('formAnswers');
  //   final formIdBox = Hive.box<PutTaskFormModel>('formId');

  //   final userId = user!.id;
  //   final sheets = await routeSheetRepo.searchByEmployeeId(userId);

  //   if (sheets == null || sheets.isEmpty) {
  //     logger.i('❌ Не удалось получить маршруты');
  //     return;
  //   }

  //   for (final sheet in sheets) {
  //     await routeSheetBox.put(sheet.id, sheet);

  //     final taskListId = sheet.taskListTypeId;
  //     final taskList = await taskListRepo.getById(taskListId);
  //     if (taskList != null) {
  //       await taskListBox.put(taskListId, taskList);
  //       for (final block in taskList.configuration.data) {
  //         for (final task in block.tasks) {
  //           final typeId = int.tryParse(task.typeId);
  //           if (typeId != null) {
  //             final formType = await taskFormRepo.getFromTaskByTypeId(typeId);
  //             if (formType != null) {
  //               await taskFormBox.put(typeId, formType);
  //               final formIdState = await taskFormRepo.getFormByTypeId(
  //                   typeId, sheet.id, userId);
  //               if (formIdState != null) {
  //                 await formIdBox.put(
  //                     typeId,
  //                     PutTaskFormModel(
  //                         id: formIdState.id,
  //                         coordinatorEmployeeId: userId,
  //                         routeSheetId: sheet.id,
  //                         state: formIdState.state,
  //                         type2Id: typeId,
  //                         type: task.tasktype));
  //                 task.currentStatus = formIdState.state;
  //               } else {
  //                 var formId = await taskFormRepo.addTaskForm(AddFormModel(
  //                     id: 0,
  //                     state: 2,
  //                     routeSheetId: sheet.id,
  //                     coordinatorEmployeeId: userId,
  //                     type2Id: typeId));
  //                 if (formId != null) {
  //                   await formIdBox.put(
  //                       typeId,
  //                       PutTaskFormModel(
  //                           id: formId,
  //                           coordinatorEmployeeId: userId,
  //                           routeSheetId: sheet.id,
  //                           state: 2,
  //                           type2Id: typeId,
  //                           type: task.tasktype));
  //                 }
  //               }
  //             }
  //           }
  //         }
  //       }
  //     }
  //   }

  //   logger.i("✅ Данные загружены в Hive: routeSheets, taskLists, taskForms");
  // }
}
