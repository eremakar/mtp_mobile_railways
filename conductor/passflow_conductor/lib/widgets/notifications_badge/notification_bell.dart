import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passflow_app/widgets/notifications/notification_screen.dart';
import 'package:passflow_app/widgets/notifications_badge/notifications_badge_bloc.dart';
import 'package:passflow_app/widgets/notifications_badge/notifications_badge_event.dart';
import 'package:passflow_app/widgets/notifications_badge/notifications_badge_state.dart';


class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBadgeBloc, BadgeState>(
      builder: (_, state) {
        final count = state is BadgeReady ? state.unread : 0;

        return InkWell(
          onTap: () {
            context.read<NotificationBadgeBloc>().add(const ResetBadge());
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const SizedBox(
                width: 36,
                height: 36,
                child: Icon(Icons.notifications_none, color: Colors.black54),
              ),
              if (count > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints:
                        const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '$count',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
