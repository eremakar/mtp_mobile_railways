import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

class AddRemarkV2Page extends StatefulWidget {
  const AddRemarkV2Page({Key? key}) : super(key: key);

  @override
  State<AddRemarkV2Page> createState() => _AddRemarkV2PageState();
}

class _AddRemarkV2PageState extends State<AddRemarkV2Page> {
  final _picker = ImagePicker();
  final _textCtrl = TextEditingController(text: 'Обнаружено разбитое окно в первом купе,\nсрочно требуется ремонт!');
  String? _category = 'Окно';
  final List<File> _files = [];

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  bool get _canSave => (_category?.isNotEmpty ?? false) && _textCtrl.text.trim().isNotEmpty && _files.isNotEmpty;

  Future<void> _addPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Камера'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Галерея'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ]),
        ),
      ),
    );
    if (source == null) return;
    final x = await _picker.pickImage(source: source, imageQuality: 90);
    if (x == null) return;
    setState(() => _files.add(File(x.path)));
  }

  Future<void> _pickCategory() async {
    final list = ['Окно', 'Дверь', 'Пол', 'Потолок', 'Оборудование', 'Другое'];
    final value = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) => ListView.separated(
        padding: const EdgeInsets.only(bottom: 24),
        itemCount: list.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) => ListTile(
          title: Text(list[i]),
          trailing: _category == list[i] ? const Icon(Icons.check, color: Colors.blue) : null,
          onTap: () => Navigator.pop(context, list[i]),
        ),
      ),
    );
    if (value != null) setState(() => _category = value);
  }

  String _prettySize(int bytes) {
    if (bytes <= 0) return '0KB';
    const kb = 1024, mb = 1024 * 1024;
    if (bytes < mb) return '${(bytes / kb).ceil()}KB';
    return '${(bytes / mb).toStringAsFixed((bytes / mb) < 10 ? 1 : 0)}MB';
  }

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF1671E6);
    const lightBlue = Color(0xFFE9F2FF);
    final greyPill = Colors.black.withOpacity(0.06);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('ВУ-8', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: () => Navigator.pop(context)),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () {})],
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Tabs (пилюли)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(children: [
                _pill('Добавить замечание', selected: true, color: blue),
                const SizedBox(width: 8),
                _pill('История записей (2)', selected: false, color: Colors.black87, bg: greyPill),
              ]),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text(
                    'Выберите категорию замечания и\nопишите подробнее причину',
                    style: TextStyle(fontSize: 20, height: 1.25, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 14),

                  // Категория
                  _bigField(
                    onTap: _pickCategory,
                    child: Row(children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Категория', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                          const SizedBox(height: 6),
                          Text(_category ?? '—', style: const TextStyle(fontSize: 16)),
                        ]),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ]),
                  ),
                  const SizedBox(height: 12),

                  // Текст
                  _bigField(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Ваш текст', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _textCtrl,
                        maxLines: 4,
                        decoration: const InputDecoration(border: InputBorder.none, isDense: true, hintText: 'Опишите проблему'),
                        onChanged: (_) => setState(() {}),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 16),

                  // Добавить фото
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: _addPhoto,
                    child: Container(
                      height: 64,
                      decoration: BoxDecoration(color: lightBlue, borderRadius: BorderRadius.circular(20)),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                        Icon(Icons.photo_camera_outlined, color: blue),
                        SizedBox(width: 8),
                        Text('Добавить фото', style: TextStyle(color: blue, fontSize: 18, fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Список файлов (карточка)
                  if (_files.isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 10))],
                      ),
                      child: Column(children: [
                        for (int i = 0; i < _files.length; i++) _fileTile(_files[i], onRemove: () => setState(() => _files.removeAt(i))),
                      ]),
                    ),

                  const SizedBox(height: 28),

                  // Кнопки
                  _primaryButton(
                    text: 'Сохранить',
                    enabled: _canSave,
                    onTap: _canSave ? () {/* TODO: submit */} : null,
                  ),
                  const SizedBox(height: 12),
                  _secondaryButton(text: 'Отменить', onTap: () => Navigator.pop(context)),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // UI helpers
  Widget _pill(String text, {required bool selected, required Color color, Color bg = const Color(0xFFEDEFF1)}) {
    return Container(
      decoration: BoxDecoration(color: selected ? color : bg, borderRadius: BorderRadius.circular(22)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text(
        text,
        style: TextStyle(color: selected ? Colors.white : Colors.black87.withOpacity(0.75), fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _bigField({required Widget child, VoidCallback? onTap}) {
    final box = Container(
      decoration: BoxDecoration(color: const Color(0xFFF2F4F5), borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: child,
    );
    return onTap == null ? box : InkWell(borderRadius: BorderRadius.circular(20), onTap: onTap, child: box);
  }

  Widget _fileTile(File f, {required VoidCallback onRemove}) {
    return FutureBuilder<int>(
      future: f.length(),
      builder: (_, snap) {
        final size = snap.data ?? 0;
        final name = p.basename(f.path);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(children: [
            // Превью/плейсхолдер
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(f, width: 44, height: 44, fit: BoxFit.cover, errorBuilder: (_, __, ___) {
                return Container(width: 44, height: 44, color: const Color(0xFFF2F4F5), child: const Icon(Icons.image_not_supported, size: 20));
              }),
            ),
            const SizedBox(width: 12),
            // Имя + размер
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Container(
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.06), borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(_prettySize(size), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ]),
            ),
            const SizedBox(width: 8),
            // Крестик
            InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.06), shape: BoxShape.circle),
                child: const Icon(Icons.close, size: 18),
              ),
            ),
          ]),
        );
      },
    );
  }

  Widget _primaryButton({required String text, bool enabled = true, VoidCallback? onTap}) {
    return Opacity(
      opacity: enabled ? 1 : .6,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: enabled ? onTap : null,
        child: Container(
          height: 64,
          decoration: BoxDecoration(color: const Color(0xFF1671E6), borderRadius: BorderRadius.circular(28)),
          alignment: Alignment.center,
          child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }

  Widget _secondaryButton({required String text, VoidCallback? onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: Container(
        height: 64,
        decoration: BoxDecoration(color: const Color(0xFFF2F4F5), borderRadius: BorderRadius.circular(28)),
        alignment: Alignment.center,
        child: Text(text, style: const TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.w700)),
      ),
    );
  }
}