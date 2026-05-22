import 'package:flutter/material.dart';

class TechnicalStatePage extends StatefulWidget {
  const TechnicalStatePage({Key? key}) : super(key: key);

  @override
  State<TechnicalStatePage> createState() => _TechnicalStatePageState();
}

class _TechnicalStatePageState extends State<TechnicalStatePage> {
  final Color blue = const Color(0xFF0B66FF);
  final Color pillBg = const Color(0xFFE6F0FF); // светло-голубая “пилюля”

  final List<_TechItem> items = [
    const _TechItem(title: 'Освещение (лампы, розетки)'),
    const _TechItem(title: 'Система охлаждения'),
    const _TechItem(title: 'Туалеты №1, №2'),
    const _TechItem(title: 'Кипятильник'),
    const _TechItem(title: 'СКНБ, УПС, утечка тока'),
  ];

  bool get canSave => items.any((e) => e.checked);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Техническое состояние',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // TODO: обновить данные
              setState(() {});
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 18),
                itemBuilder: (context, i) {
                  final item = items[i];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Текст + кнопка “Оценить качество”
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _QualityPill(
                              label: 'Оценить качество',
                              bg: pillBg,
                              fg: blue,
                              onTap: () async {
                                // TODO: открыть форму оценки качества
                                setState(() => items[i] = item.copyWith(checked: true));
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Чекбокс справа
                      SizedBox(
                        width: 66,
                        height: 66,
                        child: Checkbox(
                          value: item.checked,
                          onChanged: (v) => setState(() =>
                              items[i] = item.copyWith(checked: v ?? false)),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(4), 
                          ),
                          fillColor: WidgetStateProperty.resolveWith((states) {
                            return states.contains(WidgetState.selected)
                                ? const Color(0xFF0B66FF)
                                : Colors.transparent;
                          }),
                          checkColor: Colors.white,
                          side: WidgetStateBorderSide.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return const BorderSide(
                                  color: Color(0xFF0B66FF), width: 0);
                            }
                            return BorderSide(
                                color: Colors.grey.shade400, width: 2);
                          }),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Нижняя кнопка
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SizedBox(
                  height: 60,
                  child: ElevatedButton(
                    onPressed: canSave
                        ? () {
                            // TODO: сохранить результаты
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Сохранено')),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canSave ? blue : const Color(0xFFE6E9EC),
                      disabledBackgroundColor: const Color(0xFFE6E9EC),
                      elevation: 0,
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      'Сохранить',
                      style: TextStyle(
                        color: canSave ? Colors.white : const Color(0xFF98A2AE),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ——— helpers ———

class _QualityPill extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;

  const _QualityPill({
    required this.label,
    required this.bg,
    required this.fg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: fg,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _TechItem {
  final String title;
  final bool checked;
  const _TechItem({required this.title, this.checked = false});

  _TechItem copyWith({String? title, bool? checked}) =>
      _TechItem(title: title ?? this.title, checked: checked ?? this.checked);
}