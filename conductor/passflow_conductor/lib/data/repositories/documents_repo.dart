import 'package:passflow_app/core/dio/dio_client.dart';
import 'package:passflow_app/core/services/logger.dart';
import 'package:passflow_app/data/models/documents/documents_model.dart';

class DocumentsRepository {
  Future<DocumentsSearchResponse?> searchDocuments({
    required int ownerId,
    required int documentTypeId, 
  }) async {
    try {
      final body = {
        "filter": {
          "ownerId": {"operand1": ownerId, "operator": "1"},
          "documentTypeId": {"operand1": documentTypeId, "operator": "1"},
        }
      };

      final response = await DioClient.dio.post(
        '/documents/api/v1/documents/search',
        data: body,
      );

      if (response.statusCode == 200) {
        return DocumentsSearchResponse.fromJson(
          Map<String, dynamic>.from(response.data),
        );
      } else {
         logger.i('⚠️ Unexpected status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
       logger.i('Documents search error: $e');
      return null;
    }
  }
}