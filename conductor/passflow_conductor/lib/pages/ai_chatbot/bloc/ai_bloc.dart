import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:passflow_app/data/repositories/ai_repository.dart';
import 'package:passflow_app/core/dio/dio_client.dart';
import 'ai_event.dart';
import 'ai_state.dart';

class AiBloc extends Bloc<AiEvent, AiState> {
  final AiRepository repository;
  final _box = Hive.box('chatHistory');

  AiBloc(this.repository) : super(AiInitialState(const [])) {
    on<AiSendMessageEvent>(_sendMessage);
    on<AiLoadHistoryEvent>(_loadHistory);
    on<AiClearHistoryEvent>(_clearHistory);
  }

  Future<void> _loadHistory(
      AiLoadHistoryEvent event, Emitter<AiState> emit) async {
    final storedMessages =
        _box.get('messages_${event.agentId}', defaultValue: <Map>[]);
    final messages = storedMessages
        .map<AiMessage>(
          (m) => AiMessage(text: m['text'], isUser: m['isUser']),
        )
        .toList();
    if (messages.isEmpty) {
      messages.add(AiMessage(
        text: 'Привет, я AI-помощник проводника! Я здесь, чтобы помочь тебе с информацией о маршрутах, расписании, правилах работы, пассажирских запросах и многом другом',
        isUser: false,
      ));
      _saveMessages(messages, event.agentId);
    }
    emit(AiMessageReceivedState(messages));
  }

  Future<void> _sendMessage(
      AiSendMessageEvent event, Emitter<AiState> emit) async {
    DioClient.dio.options.receiveTimeout = const Duration(minutes: 2);
    DioClient.dio.options.connectTimeout = const Duration(seconds: 20);

    final currentMessages = List<AiMessage>.from(state.messages)
      ..add(AiMessage(text: event.userMessage, isUser: true));

    _saveMessages(currentMessages, event.agentId);

    emit(AiLoadingState(currentMessages));

    try {
      final response = await repository.sendMessage(
        userId: 1,
        chatId: 4,
        agentId: event.agentId,
        content: event.userMessage,
      );

      if (response != null) {
        currentMessages.add(AiMessage(text: response, isUser: false));
        _saveMessages(currentMessages, event.agentId);
        emit(AiMessageReceivedState(currentMessages));
      } else {
        _saveMessages(currentMessages, event.agentId);
        emit(AiErrorState('Пустой ответ от AI', currentMessages));
      }
    } catch (e) {
      _saveMessages(currentMessages, event.agentId);
      emit(AiErrorState('Ошибка: $e', currentMessages));
    }
  }

  void _saveMessages(List<AiMessage> messages, int agentId) {
    final data =
        messages.map((m) => {'text': m.text, 'isUser': m.isUser}).toList();
    _box.put('messages_$agentId', data);
  }

  Future<void> _clearHistory(
      AiClearHistoryEvent event, Emitter<AiState> emit) async {
    await _box.delete('messages_${event.agentId}');
    emit(AiInitialState(const []));
  }
}
