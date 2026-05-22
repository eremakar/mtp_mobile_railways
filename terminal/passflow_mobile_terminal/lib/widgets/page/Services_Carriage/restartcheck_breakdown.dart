import 'package:flutter/material.dart';

class SanitaryRestartWarningPage extends StatelessWidget {
  final String appBarTitle;         // Заголовок в аппбаре: "Санитарное состояние"
  final String message;             // Основной текст под "Внимание!"
  final VoidCallback? onRestart;    // Нажали "Запустить заново"
  final VoidCallback? onCancel;     // Нажали "Отмена"/крестик

  const SanitaryRestartWarningPage({
    Key? key,
    this.appBarTitle = 'Санитарное состояние',
    this.message =
        'Вы уже отправили отчет о проверке, если желаете запустить процесс заново то нажмите кнопку ниже',
    this.onRestart,
    this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF0B66FF);
    const greyBtn = Color(0xFFEFF2F5);
    const orange = Color(0xFFF7A41A);

    void close() => Navigator.of(context).maybePop();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        title: Text(
          appBarTitle,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
        ),
        leading: const SizedBox(), // как на макете — без стрелки «назад»
        actions: [
          IconButton(
            icon: const Icon(Icons.close, size: 28),
            onPressed: onCancel ?? close,
            tooltip: 'Закрыть',
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            children: [
              const SizedBox(height: 8),
              // Круг с "i"
              Container(
                width: 132,
                height: 132,
                decoration: const BoxDecoration(
                  color: orange,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Center(
                      child: Icon(Icons.info, color: Colors.white, size: 24),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),
              const Text(
                'Внимание!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  height: 1.35,
                  color: Colors.black87,
                ),
              ),

              const Spacer(),

              // Кнопки
              SizedBox(
                height: 64,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (onRestart != null) onRestart!();
                    close();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blue,
                    shape: const StadiumBorder(),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Запустить заново',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 64,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onCancel ?? close,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: greyBtn,
                    foregroundColor: Colors.black,
                    shape: const StadiumBorder(),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Отмена',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}