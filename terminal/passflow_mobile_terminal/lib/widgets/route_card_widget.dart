import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NextRouteCard extends StatelessWidget {
  const NextRouteCard({Key? key}) : super(key: key);

  Future<void> showCustomNotification() async {
  const channel = MethodChannel('custom_notification');
  try {
    await channel.invokeMethod('showNotification', {
      'title': 'Астана → Алматы через 5 часов 35 минут',
      'message': 'Явка через 5 ч 35 мин',
    });
  } catch (e) {
    if (kDebugMode) {
      print('Ошибка уведомления: $e');
    }
  }
}

  @override
  Widget build(BuildContext context) {
    final gradient = const LinearGradient(
      colors: [
        Color(0xFF8370D8),
        Color.fromARGB(255, 162, 131, 255),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16), 
  child: Container(
    width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(51, 51, 51, 0.2),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Следующий маршрут:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withAlpha((0.8 * 255).toInt()),
                ),
              ),
              InkWell(
                onTap: () {
                  if (kDebugMode) print('Нажато');
                  showCustomNotification(); // ✅ Запуск нативного уведомления
                },
                borderRadius: BorderRadius.circular(20),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '3/4 Астана-Алматы',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Spacer(),
              Text(
                'Явка через',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withAlpha((0.25 * 255).toInt()),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((0.25 * 255).toInt()),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '5 часов 35 минут',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
  )
    );
  }
}
