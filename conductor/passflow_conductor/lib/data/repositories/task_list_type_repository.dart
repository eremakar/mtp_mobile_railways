import 'package:passflow_app/core/dio/dio_client.dart';
import 'package:passflow_app/core/services/logger.dart';
import 'package:passflow_app/data/models/taskListType/task_model.dart';

class TaskListTypeRepository {
  Future<TaskListTypeModel?> getById(int id) async {
    try {
      final response =
          await DioClient.dio.get('/tasks/api/v1/TaskMenuTypes/$id');
      if (response.statusCode == 200) {
        return TaskListTypeModel.fromJson(response.data);
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
