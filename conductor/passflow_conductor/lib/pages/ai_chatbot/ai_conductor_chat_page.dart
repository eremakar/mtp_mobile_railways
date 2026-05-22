import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passflow_app/pages/ai_chatbot/bloc/ai_bloc.dart';
import 'package:passflow_app/pages/ai_chatbot/bloc/ai_event.dart';
import 'package:passflow_app/pages/ai_chatbot/bloc/ai_state.dart';
import 'package:passflow_app/widgets/custom_loader.dart';

class AiConductorChatPage extends StatelessWidget {
  const AiConductorChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('История общения'),
      ),
      body: BlocBuilder<AiBloc, AiState>(
        builder: (context, state) {
          if (state is AiLoadingState) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: state.messages.length + 1,
                itemBuilder: (context, index) {
                  if (index == state.messages.length) {
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
                  final msg = state.messages[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: msg.isUser ? Colors.blue[100] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Text(
                        msg.text,
                        style: const TextStyle(fontSize: 16.0),
                      ),
                    ),
                  );
                },
              ),
            );
          } else if (state is AiMessageReceivedState) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: state.messages.length,
                itemBuilder: (context, index) {
                  final msg = state.messages[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: msg.isUser ? Colors.blue[100] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Text(
                        msg.text,
                        style: const TextStyle(fontSize: 16.0),
                      ),
                    ),
                  );
                },
              ),
            );
          } else if (state is AiErrorState) {
            return Center(child: Text(state.error));
          } else {
            context.read<AiBloc>().add(AiLoadHistoryEvent(agentId: 1));
            return const Center(child: DotCircleLoader());
          }
        },
      ),
    );
  }
}
