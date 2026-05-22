import 'package:flutter/material.dart';
import 'package:passflow_app/data/models/ticket_model.dart';

class FilterModalContent extends StatefulWidget {
  final List<String>? availableWagons;
  final List<String>? stations;
  final List<TicketModel> tickets;

  const FilterModalContent({
    Key? key,
    this.availableWagons,
    this.stations,
    required this.tickets,
  }) : super(key: key);

  @override
  State<FilterModalContent> createState() => _FilterModalContentState();
}

class _FilterModalContentState extends State<FilterModalContent> {
  late List<String> wagons; // уникальные + отсортированные
  late List<String> stations; // уникальные + отсортированные (без пустых)
  final Set<String> selectedWagons = {};
  String? selectedStation;

  @override
  void initState() {
    super.initState();
    _buildData();
  }

  @override
  void didUpdateWidget(covariant FilterModalContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tickets != widget.tickets ||
        oldWidget.availableWagons != widget.availableWagons ||
        oldWidget.stations != widget.stations) {
      _buildData();
    }
  }

  void _buildData() {
    // 1) Вагоны: берем из availableWagons, иначе собираем из tickets
    final srcWagons = (widget.availableWagons?.toList() ??
            widget.tickets.map((t) => '${t.wagonNumber}-${t.wagonCategory}'))
        .where((w) => (w).trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort(_naturalCompare);

    // 2) Станции: берем из stations, иначе из tickets.deparute?.name
    final srcStations = (widget.stations?.toList() ??
            widget.tickets.map((x) => x.deparute?.name ?? ''))
        .where((s) => s.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    wagons = srcWagons;
    stations = srcStations;

    // Сбрасываем выбранные, которые отсутствуют в новых списках
    selectedWagons.removeWhere((w) => !wagons.contains(w));
    if (selectedStation != null && !stations.contains(selectedStation)) {
      selectedStation = stations.isNotEmpty ? stations.first : null;
    } else {
      selectedStation ??= stations.isNotEmpty ? stations.first : null;
    }
    setState(() {});
  }

  // Натуральная сортировка для "12-К", "2-П", "2-К" → 2-К, 2-П, 12-К
  int _naturalCompare(String a, String b) {
    final re = RegExp(r'^\d+');
    int numOf(String s) => int.tryParse(re.firstMatch(s)?.group(0) ?? '') ?? -1;
    final an = numOf(a), bn = numOf(b);
    if (an != bn) return an.compareTo(bn);
    return a.compareTo(b);
  }

  void toggleWagon(String wagon) {
    setState(() {
      if (selectedWagons.contains(wagon)) {
        selectedWagons.remove(wagon);
      } else {
        selectedWagons.add(wagon);
      }
    });
  }

  void selectStation(String? station) {
    setState(() => selectedStation = station);
  }

  @override
  Widget build(BuildContext context) {
    const activeBlue = Color(0xFF0864D4);
    const wagonBgColor = Color(0xFFF0F2F4);

    final canSave =
        selectedWagons.isNotEmpty || (selectedStation?.isNotEmpty ?? false);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Фильтр',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: Colors.black),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Wagons
            const Text('Выберите вагоны',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 16),
            if (wagons.isEmpty)
              const Text('Нет доступных вагонов',
                  style: TextStyle(color: Colors.grey))
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: wagons.map((wagon) {
                  final isSelected = selectedWagons.contains(wagon);
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected ? activeBlue : wagonBgColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 12),
                      elevation: 0,
                    ),
                    onPressed: () => toggleWagon(wagon),
                    child: Text(
                      wagon,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 32),
            const Divider(
                height: 1,
                thickness: 1,
                color: Color.fromARGB(255, 193, 191, 191)),
            const SizedBox(height: 16),

            // Stations
            const Text('Выберите станцию',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 16),
            if (stations.isEmpty)
              const Text('Нет доступных станций',
                  style: TextStyle(color: Colors.grey))
            else
              ...stations.map((station) {
                final selected = station == selectedStation;
                return RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  value: station,
                  groupValue: selectedStation,
                  onChanged: selectStation,
                  title: Text(
                    station,
                    style: TextStyle(
                      color: selected ? activeBlue : Colors.black87,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                  activeColor: activeBlue,
                  controlAffinity: ListTileControlAffinity.trailing,
                );
              }).toList(),

            const SizedBox(height: 24),

            // Save
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: canSave
                    ? () {
                        final payload = <String, dynamic>{};
                        if (selectedWagons.isNotEmpty) {
                          payload['wagons'] = selectedWagons.toList();
                        }
                        if (selectedStation != null &&
                            selectedStation!.isNotEmpty) {
                          payload['station'] = selectedStation;
                        }
                        Navigator.of(context).pop(payload);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: activeBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Сохранить',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),

            // Cancel
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                      color: Color.fromARGB(255, 228, 231, 233)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  'Отменить',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
