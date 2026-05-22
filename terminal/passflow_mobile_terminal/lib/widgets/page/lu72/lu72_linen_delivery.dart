import 'dart:async';

import 'package:flutter/material.dart';
import 'package:passflow_app/data/models/services_model/services_lu72model.dart';
import 'package:passflow_app/data/repositories/lu72_repository.dart';
import 'package:passflow_app/widgets/page/lu72/seat_select_breakdown.dart';
import 'package:passflow_app/widgets/page/lu72/station_select_breakdown.dart';

class Lu72CostItem {
  final String stationName;
  final List<int> seats;
  final int placeCount;

  const Lu72CostItem({
    required this.stationName,
    required this.seats,
    required this.placeCount,
  });

  String get seatsText => seats.isEmpty ? '—' : seats.join(', ');
}

class Lu72LinenDeliveryPage extends StatefulWidget {
  final int conductorId;
  final int? routeSheetId;
  final int? wagonId;
  final Lu72Repository? repository;

  const Lu72LinenDeliveryPage({
    Key? key,
    required this.conductorId,
    this.routeSheetId,
    this.wagonId,
    this.repository,
  }) : super(key: key);

  @override
  State<Lu72LinenDeliveryPage> createState() => _Lu72LinenDeliveryPageState();
}

class _Lu72LinenDeliveryPageState extends State<Lu72LinenDeliveryPage> {
  int currentTab = 0;
  String? stationTitle;
  String? placesTitle;

  bool _loading = false;
  String? _error;

  int _issueCount = 0;
  int _issuedCount = 0;
  List<String> _stations = const [];
  List<Lu72CostItem> _issuedCosts = const [];
  final Map<String, List<int>> _seatsByStation = <String, List<int>>{};
  Set<int> _selectedSeats = <int>{};

  final Color blue = const Color(0xFF0864D4);
  final Color blueFg = Colors.white;
  final Color greyPill = const Color(0xFFF0F2F5);
  final Color tileBg = const Color(0xFFF2F5F7);
  final Color titleColor = Colors.black;
  final Color hintColor = const Color(0xFF9AA3AE);

  bool get canSave =>
      currentTab == 0 && stationTitle != null && _selectedSeats.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loading = true;
    unawaited(_refresh());
  }

  Future<void> _refresh() async {
    final conductorId = widget.conductorId;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final repo = widget.repository ?? Lu72Repository();
      final raw = await repo.searchByConductor(
        conductorId: conductorId,
        routeSheetId: widget.routeSheetId,
        wagonId: widget.wagonId,
        take: 20,
        skip: 0,
      );

      if (raw == null) {
        throw Exception('LU72 search: empty response');
      }

      final parsed =
          Lu72SearchResponse.fromJson(Map<String, dynamic>.from(raw as Map));
      final items = List<WagonLu72Dto>.from(parsed.result)
        ..sort((a, b) => b.createdTime.compareTo(a.createdTime));

      final active = items.isEmpty ? null : items.first;

      final issueCount = active?.remainingToIssue ?? 0;
      final issuedCount = active?.totalConsumed ?? 0;

      final map = <String, Lu72CostItem>{};
      for (final c in (active?.costs ?? const <Lu72CostDto>[])) {
        final station = c.stationName;
        final existing = map[station];
        if (existing == null) {
          map[station] = Lu72CostItem(
            stationName: station,
            seats: List<int>.from(c.occupiedSeats)..sort(),
            placeCount: c.placeCount,
          );
        } else {
          final mergedSeats =
              <int>{...existing.seats, ...c.occupiedSeats}.toList()..sort();
          map[station] = Lu72CostItem(
            stationName: station,
            seats: mergedSeats,
            placeCount: existing.placeCount + c.placeCount,
          );
        }
      }

      final issuedList = map.values.toList()
        ..sort((a, b) => a.stationName.compareTo(b.stationName));
      final stations = issuedList
          .map((e) => e.stationName)
          .where((e) => e.trim().isNotEmpty)
          .toSet()
          .toList()
        ..sort();

      final seatsByStation = <String, List<int>>{};
      for (final c in (active?.costs ?? const <Lu72CostDto>[])) {
        final name = c.stationName;
        final seats = List<int>.from(c.occupiedSeats)..sort();
        if (name.trim().isEmpty) continue;
        seatsByStation[name] = seats;
      }

      final shouldResetSelection =
          stationTitle != null && !stations.contains(stationTitle);

      setState(() {
        _issueCount = issueCount;
        _issuedCount = issuedCount;
        _issuedCosts = issuedList;
        _stations = stations;
        _seatsByStation
          ..clear()
          ..addAll(seatsByStation);

        if (shouldResetSelection) {
          stationTitle = null;
          placesTitle = null;
          _selectedSeats = <int>{};
        }

        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'ЛУ‑72',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading
                ? null
                : () {
                    unawaited(_refresh());
                  },
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
              child: Row(
                children: [
                  _pill(
                    selected: currentTab == 0,
                    label: 'Выдача ($_issueCount)',
                    selectedBg: blue,
                    selectedFg: blueFg,
                    unselectedBg: greyPill,
                    onTap: () => setState(() => currentTab = 0),
                  ),
                  const SizedBox(width: 12),
                  _pill(
                    selected: currentTab == 1,
                    label: 'Выдано ($_issuedCount)',
                    selectedBg: blue,
                    selectedFg: blueFg,
                    unselectedBg: greyPill,
                    onTap: () => setState(() => currentTab = 1),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                children: [
                  if (currentTab == 0) ...[
                    const Text(
                      'Выберите станцию и места для\nвыдачи постельного',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _selectTile(
                      title: 'Станция посадки',
                      value: stationTitle,
                      onTap: () async {
                        final pick = await showStationSelectionBreakdownModal(
                          context,
                          stations: _stations,
                          initial: stationTitle,
                        );
                        if (pick != null) {
                          setState(() {
                            stationTitle = pick;
                            _selectedSeats = <int>{};
                            placesTitle = null;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    _selectTile(
                      title: 'Места пассажиров',
                      value: placesTitle,
                      onTap: () async {
                        final station = stationTitle;
                        if (station == null || station.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Сначала выберите станцию')),
                          );
                          return;
                        }

                        final occupied =
                            _seatsByStation[station] ?? const <int>[];
                        final disabledSeats = occupied.toSet();
                        final maxSeat = occupied.isEmpty
                            ? 36
                            : occupied.reduce((a, b) => a > b ? a : b);

                        final pick = await showSeatSelectionModal(
                          context,
                          seatCount: maxSeat,
                          initialSelected:
                              _selectedSeats.difference(disabledSeats),
                          disabled: disabledSeats,
                        );
                        if (pick != null) {
                          final selected = _asSeatSet(pick);
                          final sorted = selected.toList()..sort();
                          setState(() {
                            _selectedSeats = selected;
                            placesTitle =
                                sorted.isEmpty ? null : sorted.join(', ');
                          });
                        }
                      },
                    ),
                  ] else ...[
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1F2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Ошибка загрузки: $_error',
                          style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFFB91C1C),
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ] else if (_loading) ...[
                      const SizedBox(height: 16),
                      const Center(child: CircularProgressIndicator()),
                    ] else if (_issuedCosts.isEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Нет данных по выданному белью',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 8),
                      ..._issuedCosts.map(_issuedCard),
                    ]
                  ],
                ],
              ),
            ),
            if (currentTab == 0)
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SizedBox(
                    height: 60,
                    child: ElevatedButton(
                      onPressed: canSave
                          ? () {
                              _applySavedSelection();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Сохранено')),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            canSave ? blue : const Color(0xFFE6E9EC),
                        disabledBackgroundColor: const Color(0xFFE6E9EC),
                        shape: const StadiumBorder(),
                        elevation: 0,
                      ),
                      child: Text(
                        'Сохранить',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color:
                              canSave ? Colors.white : const Color(0xFF98A2AE),
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

  Widget _pill({
    required bool selected,
    required String label,
    required Color selectedBg,
    required Color selectedFg,
    required Color unselectedBg,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? selectedBg : unselectedBg,
          borderRadius: BorderRadius.circular(999),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x220B66FF),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? selectedFg : Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _selectTile({
    required String title,
    String? value,
    required VoidCallback onTap,
  }) {
    final hasValue = value != null && value!.trim().isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: tileBg,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    hasValue ? value! : title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: hasValue ? FontWeight.w600 : FontWeight.w500,
                      color: hasValue ? titleColor : hintColor,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey.shade600),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Set<int> _asSeatSet(dynamic value) {
    if (value is Set<int>) return value;

    if (value is List<int>) return value.toSet();

    if (value is List<String>) {
      return value.map((e) => int.tryParse(e.trim())).whereType<int>().toSet();
    }

    if (value is Iterable) {
      final out = <int>{};
      for (final e in value) {
        if (e is int) {
          out.add(e);
        } else if (e is num) {
          out.add(e.toInt());
        } else {
          final parsed = int.tryParse(e.toString().trim());
          if (parsed != null) out.add(parsed);
        }
      }
      return out;
    }

    return <int>{};
  }

  Widget _issuedCard(Lu72CostItem item) {
    final seatsText = item.seatsText;

    const radius = 18.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 8,
                  color: blue,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14 + 8, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.stationName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Места: $seatsText',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B7280),
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Выдано постельного: ${item.placeCount}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B7280),
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _applySavedSelection() {
    final station = stationTitle;
    if (station == null || station.trim().isEmpty) return;

    final selected = Set<int>.from(_selectedSeats);
    if (selected.isEmpty) return;

    final idx = _issuedCosts.indexWhere((e) => e.stationName == station);
    final existingSeats = idx >= 0 ? _issuedCosts[idx].seats.toSet() : <int>{};

    final newlyAdded = selected.difference(existingSeats);
    final mergedSeats = <int>{...existingSeats, ...selected}.toList()..sort();

    final updatedItem = Lu72CostItem(
      stationName: station,
      seats: mergedSeats,
      placeCount: mergedSeats.length,
    );

    final updatedList = List<Lu72CostItem>.from(_issuedCosts);
    if (idx >= 0) {
      updatedList[idx] = updatedItem;
    } else {
      updatedList.add(updatedItem);
    }
    updatedList.sort((a, b) => a.stationName.compareTo(b.stationName));

    final delta = newlyAdded.length;

    setState(() {
      _issuedCosts = updatedList;

      _issuedCount = _issuedCount + delta;
      _issueCount = (_issueCount - delta) < 0 ? 0 : (_issueCount - delta);

      _selectedSeats = <int>{};
      placesTitle = null;

      currentTab = 1;
    });
  }
}
