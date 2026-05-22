import 'dart:convert';
import 'package:passflow_app/core/dio/dio_client.dart';
import 'package:passflow_app/core/services/logger.dart';
import 'package:passflow_app/data/models/taskForm/add_form_model.dart';
import 'package:passflow_app/data/models/taskForm/put_task_form_model.dart';
import 'package:passflow_app/data/models/taskForm/taks_form_id_state_model.dart';
import 'package:passflow_app/data/models/taskForm/task_form_model.dart';

class TaskFormRepository {
  Future<TaskFormModel?> getFromTaskByTypeId(int typeId) async {
    try {
      final response =
          await DioClient.dio.get('/tasks/api/v1/TaskFormTypes/$typeId');
      if (response.statusCode == 200) {
        return TaskFormModel.fromJson(response.data);
      } else {
        logger.i('⚠️ Unexpected status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      logger.i('Profile fetch error: $e');
      return null;
    }
  }

  Future<int?> addTaskForm(AddFormModel model) async {
    try {
      final response = await DioClient.dio
          .post('/tasks/api/v1/TaskForms', data: model.toJson());
      if (response.statusCode == 200) {
        return response.data;
      } else {
        logger.i('⚠️ Unexpected status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      logger.i('Profile fetch error: $e');
      return null;
    }
  }

  Future putTaskForm(PutTaskFormModel model) async {
    try {
      final response = await DioClient.dio
          .put('/tasks/api/v1/TaskForms', data: model.toJson());
      if (response.statusCode == 200) {
        return response.data;
      } else {
        logger.i('⚠️ Unexpected status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      logger.i('Profile fetch error: $e');
      return null;
    }
  }

  Future<TaskFormIdStateModel?> getFormByTypeId(
      int typeId, int routeSheetId, int userId) async {
    try {
      final response = await DioClient.dio.post(
        '/tasks/api/v1/TaskForms/search',
        data: json.encode({
          "filter": {
            "routeSheetId": {
              "operand1": routeSheetId,
              "operand2": 0,
              "operator": 1
            },
            "coordinatorEmployeeId": {"operand1": userId, "operator": 1},
            "type2Id": {"operand1": typeId, "operator": 1}
          },
        }),
      );
      if (response.statusCode == 200) {
        return TaskFormIdStateModel(
            id: response.data['result'][0]['id'],
            state: response.data['result'][0]['state']);
      } else {
        logger.i('⚠️ Unexpected status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      logger.i('Profile fetch error: $e');
      return null;
    }
  }
}
