abstract class AiEvent {}

class AiSendMessageEvent extends AiEvent {
  final String userMessage;
  final int agentId;
  AiSendMessageEvent(this.userMessage, {this.agentId = 1});
}
class AiLoadHistoryEvent extends AiEvent {
  final int agentId;
  AiLoadHistoryEvent({required this.agentId});
}
class AiClearHistoryEvent extends AiEvent {
  final int agentId;
  AiClearHistoryEvent({required this.agentId});
}