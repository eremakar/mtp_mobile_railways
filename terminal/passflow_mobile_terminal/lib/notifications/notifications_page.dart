import 'package:flutter/material.dart';

// Модель уведомления
class NotificationItem {
  final String title;       // Заголовок уведомления
  final String message;     // Короткое сообщение/описание
  final String dateTime;    // Дата и время уведомления
  final String avatarUrl;   // Ссылка на аватар отправителя/иконку
  final bool isNew;         // Новое ли уведомление (для выделения цветом)

  NotificationItem({
    required this.title,
    required this.message,
    required this.dateTime,
    required this.avatarUrl,
    this.isNew = false,
  });
}

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Пример данных уведомлений
    final List<NotificationItem> notifications = [
      NotificationItem(
        title: 'Явка на маршрут',
        message: 'Ваш маршрут №3/4 Астана Алматы готов к отправлению',
        dateTime: 'Сегодня, 09:15',
        avatarUrl: 'assets/images/profile/3.jpg',
        isNew: true,
      ),
      NotificationItem(
        title: 'Охрана поезда',
        message: 'Смена охраны начнётся через 1 час',
        dateTime: 'Сегодня, 07:50',
        avatarUrl: 'assets/images/profile/1.jpg',
      ),
      NotificationItem(
        title: 'Смена графика',
        message: 'Ваш график на февраль был обновлён',
        dateTime: 'Вчера, 18:30',
        avatarUrl: 'assets/images/profile/4.jpg',
      ),
      NotificationItem(
        title: 'Зарплатная ведомость',
        message: 'Ваша ведомость за январь доступна для просмотра',
        dateTime: 'Вчера, 14:10',
        avatarUrl: 'assets/images/profile/3.jpg',
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Уведомления',
          style: TextStyle(color: Colors.black87),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black54),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final item = notifications[index];
            return _buildNotificationCard(item);
          },
        ),
      ),
    );
  }

  // Карточка уведомления
  Widget _buildNotificationCard(NotificationItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).toInt()),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
        // Если уведомление новое, добавим цветную границу
        border: item.isNew
            ? Border.all(color: const Color(0xFF2EBB6B), width: 1.5)
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Аватар или иконка
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: NetworkImage(item.avatarUrl),
          ),
          const SizedBox(width: 12),

          // Основной текст
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок уведомления
                Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),

                // Сообщение
                Text(
                  item.message,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),

                // Дата/время
                Text(
                  item.dateTime,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
