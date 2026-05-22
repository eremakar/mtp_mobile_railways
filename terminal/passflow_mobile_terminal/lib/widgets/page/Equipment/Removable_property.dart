import 'package:flutter/material.dart';

class RemovableAssetsPage extends StatefulWidget {
  const RemovableAssetsPage({Key? key}) : super(key: key);

  @override
  State<RemovableAssetsPage> createState() => _RemovableAssetsPageState();
}

class _RemovableAssetsPageState extends State<RemovableAssetsPage> {
  final List<String> _items = const [
    'Пожарный топор',
    'Аптечка',
    'Огнетушитель',
    'Лом',
    'Фонарь',
  ];

  String? _selected;
  int _qty = 0;

  bool get _canSave => _selected != null && _qty > 0;

  @override
  Widget build(BuildContext context) {
    const fieldBg = Color(0xFFF2F4F5);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: const Text('Съёмное имущество',
            style: TextStyle(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              const Text(
                'Выберите наименование имущества и\nукажите количество',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),

              // Поле выбора + счётчик
              Row(
                children: [
                  // Выпадающий список
                  Expanded(
                    flex: 3,
                    child: Container(
                      height: 54,
                      decoration: BoxDecoration(
                        color: fieldBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selected,
                          icon: const Icon(Icons.expand_more),
                          hint: Row(
                            children: const [
                              Text('1. Выберите имущество',
                                  style: TextStyle(
                                      color: Colors.black54, fontSize: 15)),
                            ],
                          ),
                          items: _items
                              .map((e) => DropdownMenuItem<String>(
                                    value: e,
                                    child: Text(e,
                                        overflow: TextOverflow.ellipsis),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() => _selected = v),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Счётчик
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 54,
                      decoration: BoxDecoration(
                        color: fieldBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _circleBtn(
                            icon: Icons.remove,
                            onTap: _qty > 0
                                ? () => setState(() => _qty--)
                                : null,
                          ),
                          Text('$_qty',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w700)),
                          _circleBtn(
                            icon: Icons.add,
                            onTap: () => setState(() => _qty++),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Кнопка "Сохранить"
              Opacity(
                opacity: _canSave ? 1 : 1,
                child: InkWell(
                  onTap: _canSave ? () {/* TODO: submit */} : null,
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: _canSave
                          ? Colors.blue
                          : const Color(0xFFE2E5E7),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Сохранить',
                      style: TextStyle(
                        color: _canSave ? Colors.white : Colors.grey[600],
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circleBtn({required IconData icon, VoidCallback? onTap}) {
    return InkResponse(
      onTap: onTap,
      radius: 24,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFFE9ECEF),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: Colors.black87),
      ),
    );
  }
}