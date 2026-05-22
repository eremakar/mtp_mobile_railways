import 'dart:convert';
import 'package:passflow_app/core/dio/dio_client.dart';
import 'package:passflow_app/core/services/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AiRepository {
  Future<String?> sendMessage({
    required int userId,
    required int chatId,
    required int agentId,
    required String content,
  }) async {
    try {
      final response = await DioClient.dio.post(
        '/ai/api/v1/chatMessages',
        data: json.encode({
          'userId': userId,
          'chatId': chatId,
          'agentId': agentId,
          'content': content,
          'role': 'user',
        }),
      );

      logger.i('📤 Отправлено: $content');
      logger.i('📥 Ответ: ${response.data}');

      if (response.statusCode == 200) {
        // Если Dio вернул строку, нужно распарсить вручную
        final data =
            response.data is String ? jsonDecode(response.data) : response.data;

        final aiResponse = data['aiResponse'];
        final aiText = aiResponse?['content'];
        logger
            .i('💾 Сохраняю последнее сообщение для agentId=$agentId: $aiText');

        if (aiText != null && aiText.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('lastMessage_agent_$agentId', aiText);
          return aiText;
        } else {
          logger.i('⚠️ aiResponse.content пустой или null');
          return null;
        }
      } else {
        logger.i('⚠️ Ошибка: статус ${response.statusCode}');
        return null;
      }
    } catch (e) {
      logger.i('❌ Ошибка при отправке сообщения: $e');
      return null;
    }
  }
}
