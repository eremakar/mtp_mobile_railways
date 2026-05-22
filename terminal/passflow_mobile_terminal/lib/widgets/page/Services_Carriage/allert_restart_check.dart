import 'package:flutter/material.dart';

class ReassessWarningPage extends StatelessWidget {
  final String title;                // Заголовок в аппбаре: "Мойка вагона - наружная"
  final VoidCallback? onReassess;    // Нажали "Оценить заново"
  final VoidCallback? onCancel;      // Нажали "Отмена"/закрыть

  const ReassessWarningPage({
    Key? key,
    required this.title,
    this.onReassess,
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
        centerTitle: true,
        elevation: 0,
        leadingWidth: 56,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: onCancel ?? close,
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onCancel ?? close,
            tooltip: 'Закрыть',
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            children: [
              const SizedBox(height: 8),
              // Большой круг с "i"
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
                  fontSize: 40, // крупный, как на макете
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                ),
              ),

              const SizedBox(height: 14),

              const Text(
                'Вы уже отправили свою оценку, если желаете провести оценку заново то нажмите кнопку ниже',
                textAlign: TextAlign.center,
                style: TextStyle(
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
                    if (onReassess != null) onReassess!();
                    close();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blue,
                    shape: const StadiumBorder(),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Оценить заново',
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