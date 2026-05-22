import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passflow_app/pages/ai_chatbot/bloc/ai_bloc.dart';
import 'package:passflow_app/data/repositories/ai_repository.dart';
import 'package:passflow_app/widgets/notifications/notification_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ai_conductor_page.dart';

class AiAssistantsPage extends StatelessWidget {
  const AiAssistantsPage({super.key});

  Future<String> _getLastMessage(int agentId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('lastMessage_agent_$agentId') ?? 'Нет сообщений';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BlocProvider(
      create: (_) => AiBloc(AiRepository()),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Чат', style: TextStyle(color: colorScheme.onSurface)),
          centerTitle: true,
          backgroundColor: colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          elevation: Theme.of(context).appBarTheme.elevation ?? 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: colorScheme.onSurface),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                Navigator.of(context).pushReplacementNamed('/');
              }
            },
          ),
            actions: [
          IconButton(
            tooltip: 'Уведомления',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationsScreen(),
                ),
              );
            },
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.notifications_none_rounded,
                    color: colorScheme.onSurface),
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ],
        ),
        body: Container(
          color: colorScheme.surface,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'AI - помощники',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              FutureBuilder<String>(
                future: _getLastMessage(1),
                builder: (context, snapshot) {
                  final lastMessage = snapshot.data ?? 'Нет сообщений';
                  return _AssistantCard(
                    color: Colors.blue,
                    backgroundColor: const Color(0xFF1976D2),
                    title: 'Проводник',
                    subtitle: lastMessage,
                    iconPath: 'assets/svg_icons/inspect.svg',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (_) => AiBloc(AiRepository()),
                            child: const AiConductorPage(
                              title: 'Проводник',
                              agentId: 1,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 12),
              FutureBuilder<String>(
                future: _getLastMessage(2),
                builder: (context, snapshot) {
                  final lastMessage = snapshot.data ?? 'Нет сообщений';
                  return _AssistantCard(
                    color: Colors.green,
                    backgroundColor: const Color.fromARGB(255, 114, 189, 118),
                    title: 'Приемщик вагона',
                    subtitle: lastMessage,
                    iconPath: 'assets/svg_icons/train_front.svg',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (_) => AiBloc(AiRepository()),
                            child: const AiConductorPage(
                              title: 'Приемщик вагона',
                              agentId: 2,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssistantCard extends StatelessWidget {
  final Color color;
  final Color? backgroundColor;
  final String title;
  final String subtitle;
  final String iconPath;
  final VoidCallback onTap;

  const _AssistantCard({
    required this.color,
    this.backgroundColor,
    required this.title,
    required this.subtitle,
    required this.iconPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withValues(alpha:0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: backgroundColor ?? color,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SvgPicture.asset(
                  iconPath,
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}