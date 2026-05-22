import 'package:flutter/material.dart';

class AddRemarkCompactPage extends StatefulWidget {
  const AddRemarkCompactPage({Key? key}) : super(key: key);

  @override
  State<AddRemarkCompactPage> createState() => _AddRemarkCompactPageState();
}

class _AddRemarkCompactPageState extends State<AddRemarkCompactPage> {
  final textCtrl = TextEditingController(
    text: 'Обнаружено разбитое окно в первом купе,\nсрочно требуется ремонт!',
  );
  String category = 'Окно';

  @override
  void dispose() {
    textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF1671E6);
    const lightBlue = Color(0xFFE9F2FF);
    const field = Color(0xFFF2F4F5);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text('ВУ-8', style: TextStyle(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Пилюли
              Row(
                children: [
                  _pill('Добавить замечание', selected: true, color: blue),
                  const SizedBox(width: 8),
                  _pill('История записей (2)', selected: false, color: Colors.black87),
                ],
              ),
              const SizedBox(height: 18),

              const Text(
                'Выберите категорию замечания и\nопишите подробнее причину',
                style: TextStyle(fontSize: 20, height: 1.25, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),

              // Категория (неактивное поле с chevron)
              _bigField(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Категория', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                          const SizedBox(height: 6),
                          Text(category, style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Ваш текст (заполнено)
              _bigField(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ваш текст', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: textCtrl,
                      maxLines: 4,
                      decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Кнопка "Добавить фото"
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {},
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(color: lightBlue, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.photo_camera_outlined, color: blue),
                      SizedBox(width: 8),
                      Text('Добавить фото', style: TextStyle(color: blue, fontSize: 18, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bigField({required Widget child}) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF2F4F5), borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: child,
    );
  }

  Widget _pill(String text, {required bool selected, required Color color}) {
    final bg = selected ? color : const Color(0xFFEDEFF1);
    final fg = selected ? Colors.white : Colors.black87.withOpacity(0.75);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(22)),
      child: Text(text, style: TextStyle(color: fg, fontWeight: FontWeight.w700)),
    );
  }
}