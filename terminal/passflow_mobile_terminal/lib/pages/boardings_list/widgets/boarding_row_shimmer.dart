import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Скелет для одной карточки пассажира
class BoardingRowShimmer extends StatelessWidget {
  const BoardingRowShimmer();

  @override
  Widget build(BuildContext context) {
    // цвета под твой скрин
    const base = Color(0xFFF2F4F7); // светло-серый фон «костей»
    const highlight = Color(0xFFFFFFFF); // блик
    const leftAccent = Color(0xFF0864D4); // синий слева

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight.withOpacity(0.7),
      period: const Duration(milliseconds: 1200),
      child: Stack(
        children: [
          // Карточка
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 8),
                // Текстовые «кости»
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Верхняя длинная
                      _bone(widthFactor: 0.72, height: 18, radius: 12),
                      const SizedBox(height: 10),
                      // Нижняя строка из двух коротких
                      Row(
                        children: [
                          Expanded(child: _bone(height: 14, radius: 10)),
                          const SizedBox(width: 12),
                          Expanded(
                              flex: 11, child: _bone(height: 14, radius: 10)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Правый квадрат (как бейдж)
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: base,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),

          // Левая цветная полоса (как у настоящего айтема)
          Positioned.fill(
            left: 0,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 6,
                decoration: const BoxDecoration(
                  color: leftAccent,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bone({double height = 14, double radius = 8, double? widthFactor}) {
    final bone = Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
    if (widthFactor != null) {
      return FractionallySizedBox(widthFactor: widthFactor, child: bone);
    }
    return bone;
  }
}

/// Список из N скелетов
class BoardingListShimmer extends StatelessWidget {
  final int items;
  const BoardingListShimmer({this.items = 8});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: items,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => const BoardingRowShimmer(),
    );
  }
}
