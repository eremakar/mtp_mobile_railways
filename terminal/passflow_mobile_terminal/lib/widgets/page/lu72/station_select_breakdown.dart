import 'package:flutter/material.dart';

const List<String> _fallbackStations = [
  'Астана',
  'Сары-Шаган',
  'Берлик 2',
  'Чемолган',
  'Бурундай',
  'Алматы-1',
  'Алматы-2',
];

Future<String?> showStationSelectionBreakdownModal(
  BuildContext context, {
  List<String> stations = const [],
  String? initial,
  String title = 'Станция посадки',
  String confirmText = 'Выбрать',
}) {
  final List<String> items = stations.isNotEmpty ? stations : _fallbackStations;
  String? selected = initial ?? (items.isNotEmpty ? items.first : null);

  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      final media = MediaQuery.of(context);
      final modalMaxHeight = media.size.height * 0.58;

      return StatefulBuilder(
        builder: (context, setState) {
          void choose(String value) {
            setState(() => selected = value);
          }

          return ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: modalMaxHeight,
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 12),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                // drag handle
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
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: items.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Text(
                              'Станции не найдены',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black.withOpacity(0.6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          itemCount: items.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 2),
                          itemBuilder: (context, index) {
                            final s = items[index];
                            final isSelected = s == selected;
                            return InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => choose(s),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        s,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: isSelected ? const Color(0xFF0864D4) : Colors.black,
                                        ),
                                      ),
                                    ),
                                    Theme(
                                      data: Theme.of(context).copyWith(
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
                                      ),
                                      child: Radio<String>(
                                        value: s,
                                        groupValue: selected,
                                        activeColor: const Color(0xFF0864D4),
                                        onChanged: (v) => choose(v!),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                SafeArea(
                  top: false,
                  child: SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0864D4),
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                        elevation: 0,
                      ),
                      onPressed: selected == null
                          ? null
                          : () => Navigator.of(context).pop(selected),
                      child: Text(
                        confirmText,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ],
            ),),
          );
        },
      );
    },
  );
}