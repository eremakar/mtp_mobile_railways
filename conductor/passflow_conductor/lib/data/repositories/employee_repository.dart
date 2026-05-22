import 'package:dio/dio.dart';
import 'package:passflow_app/core/dio/dio_client.dart';
import 'package:passflow_app/data/models/employee_profile_model.dart';

class EmployeeRepository {
  final Dio _dio;
  
  EmployeeRepository([Dio? dio]) : _dio = dio ?? DioClient.dio;

  Future<EmployeeProfile> getEmployeeProfile({
    required int employeeId,
  }) async {
    try {
      final res = await _dio.get(
          '/employees/api/v1/employees/$employeeId',
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      final data = res.data;
      if (data is! Map) {
        throw Exception('Unexpected response type: ${data.runtimeType}');
      }

      return EmployeeProfile.fromJson(data.cast<String, dynamic>());
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final body = e.response?.data;
      final url = e.requestOptions.uri.toString();
      final type = e.type;
      final msg = e.message;
      throw Exception(
        'Employees API failed (status=$status, type=$type, url=$url): $msg; body=$body',
      );
    }
  }
}