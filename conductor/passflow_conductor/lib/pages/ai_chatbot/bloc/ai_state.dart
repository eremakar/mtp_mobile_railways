class AiMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  AiMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

abstract class AiState {
  final List<AiMessage> messages;
  const AiState(this.messages);
}

class AiInitialState extends AiState {
  const AiInitialState(super.messages);
}

class AiLoadingState extends AiState {
  const AiLoadingState(super.messages);
}

class AiMessageReceivedState extends AiState {
  const AiMessageReceivedState(super.messages);
}

class AiErrorState extends AiState {
  final String error;
  const AiErrorState(this.error, List<AiMessage> messages) : super(messages);
}