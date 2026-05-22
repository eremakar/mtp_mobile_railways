import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:passflow_app/pages/ai_chatbot/bloc/ai_bloc.dart';
import 'package:passflow_app/pages/ai_chatbot/bloc/ai_event.dart';
import 'package:passflow_app/pages/ai_chatbot/bloc/ai_state.dart';
import 'package:passflow_app/widgets/custom_loader.dart';

class AiConductorPage extends StatefulWidget {
  final String title;
  final int agentId;

  const AiConductorPage({
    super.key,
    required this.title,
    required this.agentId,
  });

  @override
  State<AiConductorPage> createState() => _AiConductorPageState();
}

class _AiConductorPageState extends State<AiConductorPage> {
  final TextEditingController _controller = TextEditingController();
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasInitialized) {
        context.read<AiBloc>().add(AiLoadHistoryEvent(agentId: widget.agentId));
        _hasInitialized = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.title, style: TextStyle(color: colorScheme.onSurface)),
        centerTitle: true,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        actions: [
          PopupMenuButton<String>(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            offset: const Offset(0, 50),
            onSelected: (value) {
              switch (value) {
                case 'history':
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('История пока не реализована')),
                  );
                  break;
                case 'delete':
                  context
                      .read<AiBloc>()
                      .add(AiClearHistoryEvent(agentId: widget.agentId));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('История чата удалена')),
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'new',
                child: Row(
                  children: [
                    Icon(Icons.chat_bubble_outline,
                        color: colorScheme.onSurface),
                    const SizedBox(width: 12),
                    Text('Новый чат', style: TextStyle(color: colorScheme.onSurface)),
                    const Spacer(),
                    Icon(Icons.arrow_forward_ios,
                        size: 14, color: colorScheme.onSurface),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'history',
                child: Row(
                  children: [
                    Icon(Icons.history, color: colorScheme.onSurface),
                    const SizedBox(width: 12),
                    Text('История', style: TextStyle(color: colorScheme.onSurface)),
                    const Spacer(),
                    Icon(Icons.arrow_forward_ios,
                        size: 14, color: colorScheme.onSurface),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: colorScheme.error),
                    const SizedBox(width: 12),
                    Text('Удалить чат',
                        style: TextStyle(color: colorScheme.error)),
                    const Spacer(),
                    Icon(Icons.arrow_forward_ios,
                        size: 14, color: colorScheme.error),
                  ],
                ),
              ),
            ],
            icon: Icon(Icons.more_vert, color: colorScheme.onSurface),
          ),
        ],
      ),
      body: Container(
        color: colorScheme.surface,
        child: BlocBuilder<AiBloc, AiState>(
          builder: (context, state) {
            Widget content;
            if (state is AiInitialState) {
              content = const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Привет, я AI-помощник проводника! Я здесь, чтобы помочь тебе с информацией о маршрутах, расписании, правилах работы, пассажирских запросах и многом другом',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              );
            } else if (state is AiLoadingState) {
              content = Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: state.messages.length + 1,
                  itemBuilder: (context, index) {
                    if (index < state.messages.length) {
                      final msg = state.messages[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        alignment: msg.isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment:
                              msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: msg.isUser
                                    ? colorScheme.primary
                                    : colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                msg.text,
                                style: TextStyle(
                                  color: msg.isUser ? colorScheme.onPrimary : colorScheme.onSurface,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('HH:mm, dd.MM.yy').format(msg.timestamp),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: DotCircleLoader(),
                          ),
                        ),
                      );
                    }
                  },
                ),
              );
            } else if (state is AiMessageReceivedState) {
              content = Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final msg = state.messages[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      alignment: msg.isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment:
                            msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: msg.isUser
                                  ? colorScheme.primary
                                  : colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              msg.text,
                              style: TextStyle(
                                color: msg.isUser ? colorScheme.onPrimary : colorScheme.onSurface,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('HH:mm, dd.MM.yy').format(msg.timestamp),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
              // content = Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 20),
              //   child: Text(
              //     state.message,
              //     textAlign: TextAlign.center,
              //     style: TextStyle(
              //       fontSize: 16,
              //       color: Theme.of(context).textTheme.bodyLarge?.color,
              //     ),
              //   ),
              // );
            } else if (state is AiErrorState) {
              content = Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Ошибка: ${state.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                  ),
                ),
              );
            } else {
              content = const SizedBox.shrink();
            }

            return Column(
              children: [
                const SizedBox(height: 40),
                content,
                const SizedBox(height: 20),

                /// Поле ввода
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              decoration: const InputDecoration(
                                hintText: 'Сообщение',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 14),
                              ),
                              onSubmitted: (_) =>
                                  FocusScope.of(context).unfocus(),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: colorScheme.primaryContainer,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: Icon(Icons.arrow_upward_rounded,
                                    color: colorScheme.onPrimaryContainer, size: 20),
                                onPressed: () {
                                  final txt = _controller.text.trim();
                                  if (txt.isEmpty) return;
                                  context.read<AiBloc>().add(AiSendMessageEvent(
                                        txt,
                                        agentId: widget.agentId,
                                      ));
                                  _controller.clear();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
