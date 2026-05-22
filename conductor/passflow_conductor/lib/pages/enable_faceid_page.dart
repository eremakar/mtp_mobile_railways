import 'package:flutter/material.dart';

class EnableFaceIdPage extends StatelessWidget {
  const EnableFaceIdPage({
    super.key,
    this.onEnable,
    this.onLater,
  });

  /// Колбэк, если пользователь согласился включить Face ID
  final VoidCallback? onEnable;

  /// Колбэк, если нажали «Позже»
  final VoidCallback? onLater;

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w800,
      height: 1.1,
      color: Theme.of(context).colorScheme.onSurface,
    );
    final subStyle = TextStyle(
      fontSize: 18,
      height: 1.35,
      color: Theme.of(context).colorScheme.onSurface,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 150),

              // Иллюстрация Face ID с градиентом
              Center(
                child: Image.asset(
                  'assets/images/FaceID.png',
                  height: 180,
                ),
              ),

              const SizedBox(height: 24),
              Text(
                'Включить вход\nчерез Face ID',
                textAlign: TextAlign.center,
                style: titleStyle,
              ),
              const SizedBox(height: 12),
              Text(
                'С помощью Face ID можно\nвойти без использования пароля',
                textAlign: TextAlign.center,
                style: subStyle,
              ),

              const Spacer(),

              // Кнопка «Включить Face ID»
              SizedBox(
                height: 58,
                child: ElevatedButton(
                  onPressed: () {
                    if (onEnable != null) {
                      onEnable!();
                    } else {
                      Navigator.of(context).pop(true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Включить Face ID',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Кнопка «Позже»
              SizedBox(
                height: 58,
                child: ElevatedButton(
                  onPressed: () {
                    if (onLater != null) {
                      onLater!();
                    } else {
                      Navigator.of(context).pop(false);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Позже',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}