import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final h1 = TextStyle(fontSize: 32, fontWeight: FontWeight.w800, height: 1.15, color: Theme.of(context).colorScheme.onSurface);
    final h2 = TextStyle(fontSize: 18, fontWeight: FontWeight.w700, height: 1.35, color: Theme.of(context).colorScheme.onSurface);
    final p  = TextStyle(fontSize: 16, height: 1.45, color: Theme.of(context).colorScheme.onSurface);
    const m  = EdgeInsets.only(bottom: 12);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'Политика конфиденциальности',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface),
        ),
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          const SizedBox(height: 8),
          Text('Политика конфиденциальности', style: h1),
          const SizedBox(height: 16),

          Padding(
            padding: m,
            child: RichText(
              text: TextSpan(style: p, children: [
                const TextSpan(text: 'Дата вступления в силу: ', style: TextStyle(fontWeight: FontWeight.w700)),
                const TextSpan(text: '15 июля 2025 г.\n'),
                
                const TextSpan(text: 'Последнее обновление: ', style: TextStyle(fontWeight: FontWeight.w700)),
                const TextSpan(text: '15 июля 2025 г.'),
              ]),
            ),
          ),

          Padding(
            padding: m,
            child: Text(
              'Настоящая Политика конфиденциальности (далее — «Политика») описывает, как приложение PassFlow (далее — «Приложение») собирает, использует, обрабатывает и хранит персональные данные пользователей — сотрудников пассажирских железнодорожных перевозок. Используя Приложение, вы соглашаетесь с условиями данной Политики.',
              style: p,
            ),
          ),

          Text('1. Какие данные мы собираем', style: h2),
          const SizedBox(height: 8),
          Padding(
            padding: m,
            child: Text('При использовании Приложения мы можем собирать следующие типы данных:', style: p),
          ),

          _Bullets(items: [
            'Персональные данные:',
            '• ФИО',
            '• Табельный номер, должность, бригада',
            '• Контактный номер (служебный)',
            '• Данные о маршрутах, рейсах и сменах',
            '• Лог действий в приложении (например: отметки о посадке/высадке)',
            '📌 Фото и медиа:',
            '• Фотофиксация ситуаций (по инициативе пользователя)',
          ]),
        ],
      ),
    );
  }
}

class _Bullets extends StatelessWidget {
  const _Bullets({required this.items});
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final itemStyle = TextStyle(fontSize: 16, height: 1.45, color: Theme.of(context).colorScheme.onSurface);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((t) {
        if (t.endsWith(':')) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(t, style: TextStyle(fontSize: 16, height: 1.45, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
          );
        }
        if (t.startsWith('•') || t.startsWith('📌')) {
          return Padding(
            padding: const EdgeInsets.only(left: 0, bottom: 6),
            child: Text(t, style: itemStyle),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(left: 0, bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(padding: const EdgeInsets.only(top: 6), child: _Dot(color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(width: 10),
              Expanded(child: Text(t, style: itemStyle)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }
}