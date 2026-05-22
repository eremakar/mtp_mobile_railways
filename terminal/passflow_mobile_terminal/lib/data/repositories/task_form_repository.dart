import 'dart:convert';

import 'package:passflow_app/core/dio/dio_client.dart';
import 'package:passflow_app/data/models/taskForm/add_form_model.dart';
import 'package:passflow_app/data/models/taskForm/put_task_form_model.dart';
import 'package:passflow_app/data/models/taskForm/taks_form_id_state_model.dart';
import 'package:passflow_app/data/models/taskForm/task_form_model.dart';
import 'package:passflow_app/helpers/task_form_helper.dart';

class TaskFormRepository {

  Future<TaskFormModel?> getFromTaskByTypeId(int typeId) async {
    try {
      final response =
          await DioClient.dio.get('/api/v1/TaskFormTypes/$typeId');
      if (response.statusCode == 200) {
      final result = response.data;
      final configString = result['configuration'];
      final replacedConfig = await TaskFormHelper.replacePlaceholders(configString);
      result['configuration'] = replacedConfig;
      final model = TaskFormModel.fromJson(result);
        return model;
      } else {
        print('⚠️ Unexpected status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Profile fetch error: $e');
      return null;
    }
  }

  Future<int?> addTaskForm(AddFormModel model) async {
    try {
      final response = await DioClient.dio
          .post('/api/v1/TaskForms', data: model.toJson());
      if (response.statusCode == 200) {
        return response.data;
      } else {
        print('⚠️ Unexpected status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Profile fetch error: $e');
      return null;
    }
  }

  Future putTaskForm(PutTaskFormModel model) async {
    try {
      final response = await DioClient.dio
          .put('/api/v1/TaskForms', data: model.toJson());
      if (response.statusCode == 200) {
        return response.data;
      } else {
        print('⚠️ Unexpected status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Profile fetch error: $e');
      return null;
    }
  }

  Future<TaskFormIdStateModel?> getFormByTypeId(
      int typeId, int routeSheetId, int userId) async {
    try {
      final response = await DioClient.dio.post(
        '/api/v1/TaskForms/search',
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
        print('⚠️ Unexpected status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Profile fetch error: $e');
      return null;
    }
  }
}
