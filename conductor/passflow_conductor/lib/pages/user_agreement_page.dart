import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserAgreementPageScreen extends StatelessWidget {
  const UserAgreementPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w800,
      height: 1.15,
      color: Theme.of(context).colorScheme.onSurface,
    );
    final h2Style = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      height: 1.35,
      color: Theme.of(context).colorScheme.onSurface,
    );
    final pStyle = TextStyle(
      fontSize: 16,
      height: 1.45,
      color: Theme.of(context).colorScheme.onSurface,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'Пользовательское соглашение',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
          ),
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
          Text('Пользовательское соглашение', style: titleStyle),
          const SizedBox(height: 20),

          Text('1. Общие положения', style: h2Style),
          const SizedBox(height: 8),
          Text(
            'Настоящее Пользовательское соглашение (далее — «Соглашение») регулирует отношения между Пользователем и владельцем мобильного приложения PassFlow (далее — «Приложение»), возникающие при установке, регистрации и использовании функционала Приложения. '
            'Устанавливая или используя Приложение, Пользователь подтверждает, что ознакомлен с условиями данного Соглашения, принимает их и обязуется соблюдать.',
            style: pStyle,
          ),
          const SizedBox(height: 16),

          Text('2. Назначение приложения', style: h2Style),
          const SizedBox(height: 8),
          Text(
            'PassFlow предназначено для сотрудников пассажирских поездов (проводников) и обеспечивает доступ к функционалу, необходимому в рамках исполнения служебных обязанностей:',
            style: pStyle,
          ),
          const SizedBox(height: 8),
          _Bullets(items: [
            'просмотр маршрутов и расписаний;',
            'управление пассажирскими списками;',
            'фиксация посадки и высадки;',
            'электронная отчётность;',
            'связь с диспетчерским центром;',
          ]),
          const SizedBox(height: 16),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('user_agreement_accepted', true);

                if (!context.mounted) return;
                Navigator.of(context).pushReplacementNamed('/');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                elevation: 0,
                shape: const StadiumBorder(),
              ),
              child: const Text(
                'Принимаю',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Bullets extends StatelessWidget {
  const _Bullets({required this.items});
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: _Dot(),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(t, style: TextStyle(fontSize: 16, height: 1.45, color: Theme.of(context).colorScheme.onSurface))),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6, height: 6,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface,
        shape: BoxShape.circle,
      ),
    );
  }
}