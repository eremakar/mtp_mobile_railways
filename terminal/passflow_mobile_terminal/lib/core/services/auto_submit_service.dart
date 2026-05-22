import 'dart:async';

import 'package:hive/hive.dart';
import 'package:passflow_app/core/di/service_locator.dart';
import 'package:passflow_app/data/models/task/answer_model.dart';
import 'package:passflow_app/data/models/task/task_model.dart';
import 'package:passflow_app/data/models/taskForm/put_task_form_model.dart';
import 'package:passflow_app/data/models/taskForm/task_form_model.dart';
import 'package:passflow_app/data/models/taskListType/task_model.dart';
import 'package:passflow_app/data/models/user_model.dart';
import 'package:passflow_app/data/repositories/task_form_repository.dart';
import 'package:passflow_app/data/repositories/task_repository.dart';
import 'package:passflow_app/utils/network_utils.dart';

class AutoSubmitService {
  static final taskRepository = sl<TaskRepository>();
  static final taskFormRepo = sl<TaskFormRepository>();

  static Future<void> trySubmitCachedAnswers() async {
    final taskListTypeModel = Hive.box<TaskListTypeModel>('taskLists').values;

    if (taskListTypeModel.isNotEmpty) {
      for (final taskList in taskListTypeModel) {
        for (final block in taskList.configuration.data) {
          for (final task in block.tasks) {
            final typeId = int.tryParse(task.typeId);
            task.currentStatus = await _fillAnswers(typeId);
          }
        }
        await taskList.save();
      }
    }
  }

  static Future _updateTaskStatus(int status, int typeId) async {
    final taskLists = Hive.box<TaskListTypeModel>('taskLists').values;

    if (taskLists.isNotEmpty) {
      for (final taskList in taskLists) {
        for (final block in taskList.configuration.data) {
          for (final task in block.tasks) {
            if (task.typeId.toString() == typeId.toString()) {
              task.currentStatus = status;
            }
          }
        }
        await taskList.save();
      }

      print('📦 Статус задачи обновлён до currentStatus = 3');
    }
  }

  static FutureOr<int> _fillAnswers(int? typeId) async {
    int status = 2;

    if (typeId == null) {
      print("❌ typeId для typeId=${typeId} не найден в Hive");
      return Future.value(status);
    }

    final formTypeBox = Hive.box<TaskFormModel>('taskFormTypes');
    final form = Hive.box<PutTaskFormModel>('formId').get(typeId);
    final answerBox = Hive.box<Map>('formAnswers');

    if (form == null) {
      print("❌ form для typeId=${typeId} не найден в Hive");
      return Future.value(status);
    }

    final answers = answerBox.get(form.id);
    if (answers == null) {
      print("❌ answerBox для formId=${form.id} не найден в Hive");
      return Future.value(status);
    }

    final formConfig = formTypeBox.get(typeId)?.configuration;
    if (formConfig == null) {
      print("❌ Конфигурация формы не найдена");
      return Future.value(status);
    }

    final userId = Hive.box<UserModel>('userBox').get('currentUser')?.id;
    if (userId == null) {
      return Future.value(status);
    }

    final List<TaskModel> taskModelsToSend = [];

    for (final field in formConfig.tasks) {
      final name = field.name;
      final value = answers[name];

      if (value == null) continue;

      // multiple-select = список значений -> один TaskModel с answers[]
      if (field.type == 'select-multiple' && value is List) {
        final answers = value.map<AnswerModel>((val) {
          return AnswerModel(
            id: 0,
            optionName: name,
            value: val.toString(),
            status: null,
            taskId: null,
            formId: form.id,
          );
        }).toList();

        taskModelsToSend.add(TaskModel(
          id: 0,
          type: field.type,
          state: 1,
          index: 0,
          formId: form.id,
          employeeId: userId,
          answers: answers,
        ));
      } else {
        // все остальные типы — по одному TaskModel на поле
        taskModelsToSend.add(TaskModel(
          id: 0,
          type: field.type,
          state: 1,
          index: 0,
          formId: form.id,
          employeeId: userId,
          answers: [
            AnswerModel(
              id: 0,
              optionName: name,
              value: value.toString(),
              status: null,
              taskId: null,
              formId: form.id,
            )
          ],
        ));
      }
    }

    try {
      final online = await NetworkUtils.hasConnection();

      if (online) {
        form.tasks = taskModelsToSend;
        form.state = 1;
        final result = await taskFormRepo.putTaskForm(form);

        if (result != null) {
          await answerBox.delete(form.id);
          status = 1;
          form.save();
          print('✅ Все ответы успешно отправлены');
        }
      }
    } catch (e) {
      print('❌ Ошибка при отправке: $e');
    }
    await _updateTaskStatus(status, typeId);
    return Future.value(status);
  }
}
