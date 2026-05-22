import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TrainRouteDetailPage extends StatefulWidget {
  final String routeTitle; // Например, "Маршрут: 3/4 Астана - Алматы"
  // final String chiefName;       // Имя начальника
  final String
      noteLabel; // Примечание (например, "Началась подготовка к рейсу")
  // final List<String> avatars;   // Список аватарок участников

  const TrainRouteDetailPage({
    super.key,
    required this.routeTitle,
    // required this.chiefName,
    required this.noteLabel,
    // required this.avatars,
  });

  @override
  State<TrainRouteDetailPage> createState() => _TrainRouteDetailPageState();
}

class _TrainRouteDetailPageState extends State<TrainRouteDetailPage> {
  // Пример URL аватарки начальника (можно передавать через конструктор)
  final String chiefAvatarUrl =
      'assets/images/profile/936e5e2e839da4cad6027b6a83480b8076b81320.png';

  // Пример списка этапов
  final List<TrainStep> steps = [
    TrainStep(title: 'Явка', dateTime: '4 января 2025 г. 12:25'),
    TrainStep(title: 'Выезд', dateTime: '4 января 2025 г. 12:25'),
    TrainStep(title: 'Пункт оборота', dateTime: '4 января 2025 г. 12:25'),
    TrainStep(title: 'Выезд обратно', dateTime: '4 января 2025 г. 12:25'),
    TrainStep(title: 'Прибытие', dateTime: '4 января 2025 г. 12:25'),
    TrainStep(title: 'Сдача вагонов', dateTime: '4 января 2025 г. 12:25'),
  ];

  // Пример списка вагонов
  final List<WagonInfo> wagons = [
    WagonInfo(number: '20 П', isYourWagon: false),
    WagonInfo(number: '21 К', isYourWagon: true),
    WagonInfo(number: '22 К', isYourWagon: false),
    WagonInfo(number: '23 П', isYourWagon: false),
  ];

  @override
  void dispose() {
    // Если у вас будут контроллеры или подписки, очистите их здесь
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Используем параметры, переданные через widget
    final String routeTitle = widget.routeTitle;
    // final String chiefName = widget.chiefName;
    // final String noteLabel = widget.noteLabel;
    // final List<String> avatars = widget.avatars;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали маршрута'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- Верхний блок (Градиент, название маршрута, начальник) ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF366ED8), Color(0xFF3F87F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Название маршрута
                  Text(
                    routeTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Начальник поезда
                  Row(
                    children: [
                      const Text(
                        'Начальник поезда: ',
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundImage: AssetImage(chiefAvatarUrl),
                            ),
                            const SizedBox(width: 8),
                            // Text(
                            //   chiefName,
                            //   style: const TextStyle(fontSize: 14, color: Colors.white),
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            // --- Блок "Предрейсовая подготовка" + этапы ---
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Метка "Предрейсовая подготовка"
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade900,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      '● Предрейсовая подготовка',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Таблица этапов
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(3),
                    },
                    children: steps.map((step) {
                      return TableRow(
                        children: [
                          // Первая колонка
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Text(
                              step.title,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          // Вторая колонка, выравнивание по правому краю
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Text(
                              step.dateTime,
                              textAlign:
                                  TextAlign.right, // <-- ключевое изменение
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            // --- Горизонтальный список вагонов ---
            SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: wagons.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final wagon = wagons[index];
                  return _buildWagonCard(wagon);
                },
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildWagonCard(WagonInfo wagon) {
    return InkWell(
      onTap: () {
        // Проверка mounted перед вызовом диалога
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Вагон ${wagon.number}'),
            content:
                Text(wagon.isYourWagon ? 'Это ваш вагон!' : 'Обычный вагон.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Фон + SVG
          Container(
            width: 180,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SvgPicture.asset(
                'assets/images/wagon.svg',
                fit: BoxFit.contain,
              ),
            ),
          ),
          // Номер вагона
          Positioned(
            // Подкорректируйте отступы по вкусу
            top: 20,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                wagon.number, // например "21 K"
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
          // Метка "Ваш вагон"
          if (wagon.isYourWagon)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Ваш вагон',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Модель для этапа
class TrainStep {
  final String title;
  final String dateTime;
  TrainStep({required this.title, required this.dateTime});
}

// Модель для вагона
class WagonInfo {
  final String number;
  final bool isYourWagon;
  WagonInfo({required this.number, this.isYourWagon = false});
}
