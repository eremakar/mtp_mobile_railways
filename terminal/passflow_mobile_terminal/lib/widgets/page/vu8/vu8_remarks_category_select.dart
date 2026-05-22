import 'package:flutter/material.dart';

class AddRemarkSimplePage extends StatefulWidget {
  const AddRemarkSimplePage({Key? key}) : super(key: key);

  @override
  State<AddRemarkSimplePage> createState() => _AddRemarkSimplePageState();
}

class _AddRemarkSimplePageState extends State<AddRemarkSimplePage> {
  final textCtrl = TextEditingController();
  String category = 'Окно';

  @override
  void dispose() {
    textCtrl.dispose();
    super.dispose();
  }

  bool get canSave => category.isNotEmpty && textCtrl.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF1671E6);
    const lightBlue = Color(0xFFE9F2FF);
    const fieldBg = Color(0xFFF2F4F5);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('ВУ-8', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () {/* TODO */}),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Tabs
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  _pill('Добавить замечание', selected: true, color: blue),
                  const SizedBox(width: 8),
                  _pill('История записей (2)', selected: false, color: Colors.black87),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Выберите категорию замечания и\nопишите подробнее причину',
                      style: TextStyle(fontSize: 20, height: 1.25, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 16),

                    // Категория (сразу "Окно")
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {/* TODO: picker */},
                      child: Container(
                        height: 64,
                        decoration: BoxDecoration(color: fieldBg, borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(child: Text(category, style: const TextStyle(fontSize: 16))),
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Ваш текст
                    Container(
                      decoration: BoxDecoration(color: fieldBg, borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: textCtrl,
                        maxLines: 5,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Ваш текст',
                        ),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Добавить фото (синяя иконка, светло-голубой фон)
                    InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () {/* TODO: add photo */},
                      child: Container(
                        height: 64,
                        decoration: BoxDecoration(color: lightBlue, borderRadius: BorderRadius.circular(22)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.photo_camera_outlined, color: blue),
                            SizedBox(width: 8),
                            Text('Добавить фото',
                                style: TextStyle(color: blue, fontSize: 18, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Сохранить (disabled как на скрине)
                    Opacity(
                      opacity: canSave ? 1 : 1, // выглядит “серой” по цвету контейнера
                      child: Container(
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E5E7),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Сохранить',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Отменить
                    InkWell(
                      borderRadius: BorderRadius.circular(28),
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 64,
                        decoration: BoxDecoration(color: fieldBg, borderRadius: BorderRadius.circular(28)),
                        alignment: Alignment.center,
                        child: const Text('Отменить',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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