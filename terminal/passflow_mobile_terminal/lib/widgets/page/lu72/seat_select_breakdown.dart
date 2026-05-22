import 'package:flutter/material.dart';

/// Показать модалку выбора мест пассажиров.
/// Возвращает выбранные места в виде ["01","07","13", ...] или null, если закрыли без выбора.
Future<List<String>?> showSeatSelectionModal(
  BuildContext context, {
  required int seatCount,                         // общее кол-во мест (напр. 36)
  Set<int>? initialSelected,                      // начально выбранные (1..seatCount)
  Set<int>? disabled,                             // занятые/недоступные (не кликаются)
  String title = 'Места пассажиров',
  String confirmText = 'Выбрать',
  String resetText = 'Сбросить выбор',
}) {
  final _initial = Set<int>.from(initialSelected ?? const {});
  final _disabled = Set<int>.from(disabled ?? const {});
  _initial.removeWhere(_disabled.contains);

  return showModalBottomSheet<List<String>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          final selected = Set<int>.from(_initial);

          String _fmt(int n) => n.toString().padLeft(2, '0');

          Color seatBg(int n) {
            if (selected.contains(n)) return const Color(0xFF0864D4);
            if (_disabled.contains(n)) return const Color(0xFFE5E7EB);
            return const Color(0xFFF1F2F4);
          }

          Color seatFg(int n) {
            if (selected.contains(n)) return Colors.white;
            if (_disabled.contains(n)) return const Color(0xFF9CA3AF);
            return Colors.black87;
          }

          BoxBorder? seatBorder(int n) {
            if (_disabled.contains(n)) {
              return Border.all(color: const Color(0xFFD1D5DB));
            }
            return null;
          }

          Widget seatTile(int n) {
            final isDisabled = _disabled.contains(n);
            final isSelected = selected.contains(n);
            return GestureDetector(
              onTap: isDisabled
                  ? null
                  : () {
                      setState(() {
                        if (isSelected) {
                          selected.remove(n);
                        } else {
                          selected.add(n);
                        }
                        // обновляем исходный сет, чтобы кнопки и стиль не терялись
                        _initial
                          ..clear()
                          ..addAll(selected);
                      });
                    },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: seatBg(n),
                  borderRadius: BorderRadius.circular(10),
                  border: seatBorder(n),
                ),
                child: Text(
                  _fmt(n),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: seatFg(n),
                  ),
                ),
              ),
            );
          }

          // Контент
          final media = MediaQuery.of(context);
          final bottomInset = media.viewInsets.bottom + media.padding.bottom;

          // 8 колонок как на примере
          const cols = 8;
          final items = List<Widget>.generate(seatCount, (i) => seatTile(i + 1));

          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: bottomInset > 0 ? bottomInset : 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Хэндл и заголовок
                Container(
                  width: 44,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3E6EA),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Сетка мест
                GridView.count(
                  crossAxisCount: cols,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.0,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: items,
                ),

                const SizedBox(height: 20),

                // Кнопка "Выбрать"
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0864D4),
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      elevation: 0,
                    ),
                    onPressed: _initial.isEmpty
                        ? null
                        : () {
                            final result = _initial
                                .toList()
                                ..sort()
                                ;
                            final strings = result.map((n) => _fmt(n)).toList();
                            Navigator.of(context).pop(strings);
                          },
                    child: Text(
                      confirmText,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Кнопка "Сбросить выбор"
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEFF2F6),
                      foregroundColor: const Color(0xFF0864D4),
                      shape: const StadiumBorder(),
                      elevation: 0,
                    ),
                    onPressed: () {
                      setState(() {
                        _initial.clear();
                      });
                    },
                    child: Text(
                      resetText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}