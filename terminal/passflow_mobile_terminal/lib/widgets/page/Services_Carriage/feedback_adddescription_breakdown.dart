import 'package:flutter/material.dart';

class QualityRatingPage extends StatefulWidget {
  final String title;                 // заголовок в AppBar: "Мойка вагона - наружная"
  final void Function(int rating, String comment, List<String> photos)? onSubmit;

  const QualityRatingPage({
    Key? key,
    required this.title,
    this.onSubmit,
  }) : super(key: key);

  @override
  State<QualityRatingPage> createState() => _QualityRatingPageState();
}

class _QualityRatingPageState extends State<QualityRatingPage> {
  static const _blue = Color(0xFF0B66FF);
  static const _lightBlue = Color(0xFFE8F1FF);
  static const _green = Color(0xFF16A34A);
  static const _fieldBg = Color(0xFFF1F3F5);

  int? _rating; // 1..5
  final _commentCtrl = TextEditingController(text: 'Вагон полностью соответствует нормам,\nпревосходно помыли!');
  final List<String> _photos = []; // здесь можно хранить пути/urls

  bool get _canSubmit => _rating != null;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).maybePop(),
          )
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const Text(
              'Оцените качество',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                height: 1.05,
              ),
            ),
            const SizedBox(height: 18),

            // Ряд смайлов 1..5
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (i) {
                final idx = i + 1;
                final selected = _rating == idx;
                IconData icon;
                switch (idx) {
                  case 1: icon = Icons.sentiment_very_dissatisfied; break;
                  case 2: icon = Icons.sentiment_dissatisfied; break;
                  case 3: icon = Icons.sentiment_neutral; break;
                  case 4: icon = Icons.sentiment_satisfied_alt; break;
                  default: icon = Icons.sentiment_very_satisfied; // 5
                }
                final color = selected ? _green : Colors.black26;
                return InkWell(
                  borderRadius: BorderRadius.circular(40),
                  onTap: () => setState(() => _rating = idx),
                  child: Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? _green.withOpacity(0.12) : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 40, color: idx == 5 ? (selected ? _green : Colors.black26) : color),
                  ),
                );
              }),
            ),

            const SizedBox(height: 16),
            const Text(
              'Данный опрос проводится с целью улучшения качества услуг, просим честно оценить качество получения услуги!',
              style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.35),
            ),

            const SizedBox(height: 26),
            const Text('Напишите отзыв', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),

            // Поле ввода
            Container(
              decoration: BoxDecoration(
                color: _fieldBg,
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: TextField(
                controller: _commentCtrl,
                maxLines: 4,
                minLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Ваш текст',
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Добавить фото
            InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: _onAddPhoto,
              child: Ink(
                decoration: BoxDecoration(
                  color: _lightBlue,
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: const [
                    Icon(Icons.photo_camera_outlined, color: _blue),
                    SizedBox(width: 12),
                    Text(
                      'Добавить фото',
                      style: TextStyle(
                        color: _blue,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (_photos.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _photos.map((p) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 72,
                      height: 72,
                      color: Colors.black12,
                      alignment: Alignment.center,
                      child: const Icon(Icons.image, size: 28, color: Colors.black38),
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 24),

            // Отправить
            SizedBox(
              height: 64,
              child: ElevatedButton(
                onPressed: _canSubmit ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _blue,
                  disabledBackgroundColor: const Color(0xFFE6E9EC),
                  shape: const StadiumBorder(),
                  elevation: 0,
                ),
                child: Text(
                  'Отправить',
                  style: TextStyle(
                    color: _canSubmit ? Colors.white : const Color(0xFF98A2AE),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onAddPhoto() async {
    // TODO: интегрировать image_picker / file picker
    // демо — просто добавим заглушку
    setState(() => _photos.add('placeholder'));
  }

  void _submit() {
    if (widget.onSubmit != null) {
      widget.onSubmit!(_rating!, _commentCtrl.text.trim(), _photos);
    }
    Navigator.of(context).maybePop();
  }
}