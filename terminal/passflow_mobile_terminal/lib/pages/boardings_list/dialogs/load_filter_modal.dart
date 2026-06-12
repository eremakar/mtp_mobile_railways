import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ваши модели
import 'package:passflow_app/core/di/service_locator.dart';
import 'package:passflow_app/data/models/class_station_model.dart';
import 'package:passflow_app/data/models/tickets_search_entry_model.dart';
import 'package:passflow_app/data/models/train_direction_model.dart';
import 'package:passflow_app/data/repositories/class_stations_repo.dart';
import 'package:passflow_app/l10n/app_localizations.dart';
import 'package:passflow_app/pages/boardings_list/widgets/date_picker_field.dart';

class LoadFilterModal extends StatefulWidget {
  const LoadFilterModal({
    this.history,
    this.trainDirections,
  });

  final List<TrainDirectionModel>? trainDirections;
  final List<TicketSearchEntryModel>? history;

  @override
  State<LoadFilterModal> createState() => _LoadFilterModalState();
}

class _LoadFilterModalState extends State<LoadFilterModal> {
  final StationsRepo _stationsRepo = sl<StationsRepo>();

  late final List<TrainDirectionModel> _allTrains; // список уникальных поездов
  List<ClassStationModel> _allStations = const []; // список станций (модели)

  TrainDirectionModel? _selectedTrain; // выбранный поезд (модель)
  ClassStationModel? _selectedStation; // выбранная станция (модель)
  DateTime? _selectedDate; // выбранная дата

  bool _isLoadingStations = false;

  // Нормализация строк
  String _normString(String s) => s
      .replaceAll('\u00A0', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceAll('–', '-')
      .trim();

  // Метка для поезда в выпадающем списке
  String _trainLabel(TrainDirectionModel s) {
    final code = _normString(s.code.isNotEmpty ? s.code : s.asuName);
    final title = _normString(s.fullName);
    if (code.isEmpty && title.isEmpty) {
      return AppLocalizations.of(context)!.choose;
    }
    if (code.isEmpty) return title;
    if (title.isEmpty) return code;
    return '$code • $title';
  }

  /// Ключ для дедупликации поездов (по коду или id)
  String _trainKey(TrainDirectionModel s) {
    final code = _normString(s.code.isNotEmpty ? s.code : s.asuName);
    return code.isNotEmpty ? code : s.id.toString();
  }

  String _stationLabel(ClassStationModel s) => s.name ?? '';

  void _onTrainSelected(TrainDirectionModel? value) {
    if (value == null) {
      setState(() {
        _selectedTrain = null;
        _selectedStation = null;
        _selectedDate = null;
        _allStations = const [];
        _isLoadingStations = false;
      });
      return;
    }

    setState(() {
      _selectedTrain = value;
      _selectedStation = null;
      _selectedDate = null;
      _allStations = const [];
    });

    print('value: ${value?.toJson()}');

    _loadStationsForTrain(value);
  }

  Future<void> _loadStationsForTrain(TrainDirectionModel? train) async {
    if (train == null) return;

    final classId = train.routeClassId;
    if (classId <= 0) {
      setState(() {
        _allStations = const [];
        _isLoadingStations = false;
      });
      return;
    }

    setState(() {
      _isLoadingStations = true;
    });

    try {
      final stations = await _stationsRepo.getStationNamesByClassId(classId);
      if (!mounted) return;
      if (_selectedTrain?.routeClassId != classId) {
        return;
      }
      setState(() {
        _allStations = stations;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _allStations = const [];
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingStations = false;
      });
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final base = _selectedDate ?? now;
    final firstDate = DateTime(now.year - 5, 1, 1);
    final lastDate = DateTime(now.year + 5, 12, 31);

    final initialDate = base.isBefore(firstDate)
        ? firstDate
        : base.isAfter(lastDate)
            ? lastDate
            : base;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked == null) return;

    setState(() {
      _selectedDate = DateUtils.dateOnly(picked);
    });
  }

  // Короткий вывод времени "когда был запрос"
  String _whenShort(DateTime d) {
    final now = DateTime.now();
    bool sameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;

    if (sameDay(now, d)) {
      return AppLocalizations.of(context)!
          .today_time(DateFormat('HH:mm').format(d));
    }
    final y = now.subtract(const Duration(days: 1));
    if (sameDay(y, d)) {
      return AppLocalizations.of(context)!
          .yesterday_time(DateFormat('HH:mm').format(d));
    }
    return DateFormat('dd.MM.yyyy HH:mm').format(d);
  }

  @override
  void initState() {
    super.initState();

    // Поезда: фильтр null, дедуп по code+startDate, сортировка по метке
    final map = <String, TrainDirectionModel>{};
    for (final w in (widget.trainDirections ?? [])) {
      if (w == null) continue;
      map[_trainKey(w)] = w;
    }
    _allTrains = map.values.toList()
      ..sort((a, b) => _trainKey(a).compareTo(_trainKey(b)));
  }

  // Подбор поезда по коду (если нужно использовать из истории)
  TrainDirectionModel? _matchTrainFromCode(String trainCode) {
    final t = _normString(trainCode);
    for (final train in _allTrains) {
      final code = _normString(
        train.code.isNotEmpty ? train.code : train.asuName,
      );
      if (code == t) return train;
    }
    return null;
  }

  // Универсальный Dropdown со строками и кнопкой очистки (оставим для прочих случаев)
  Widget _dropdownWithClear({
    required String label,
    required List<String> items,
    required String? value,
    required String hintIfEmpty,
    required ValueChanged<String?> onChanged,
    required VoidCallback onClear,
  }) {
    final theme = Theme.of(context);
    final hasValue = value != null && value.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleSmall),
        const SizedBox(height: 6),
        Stack(
          alignment: Alignment.centerRight,
          children: [
            DropdownButtonFormField<String>(
              value: (hasValue && items.contains(value)) ? value : null,
              items: items
                  .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(s, overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: onChanged,
              isExpanded: true,
              decoration: InputDecoration(
                hintText: items.isEmpty
                    ? hintIfEmpty
                    : AppLocalizations.of(context)!.choose,
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12)
                        .copyWith(right: 40),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            if (hasValue)
              Positioned(
                right: 6,
                child: IconButton(
                  splashRadius: 18,
                  tooltip: AppLocalizations.of(context)!.clear,
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: onClear,
                ),
              ),
          ],
        ),
      ],
    );
  }

  // Типизированный Dropdown для станций (NameIdPairModel)
  Widget _stationDropdown({
    required String label,
    required List<ClassStationModel> items,
    required ClassStationModel? value,
    required String hintIfEmpty,
    ValueChanged<ClassStationModel?>? onChanged,
    VoidCallback? onClear,
    bool isLoading = false,
    bool enabled = true,
  }) {
    final theme = Theme.of(context);
    final hasValue = value != null;

    // Важно: значение (value) должно быть одним из элементов списка по ссылке.
    final ClassStationModel? selected = hasValue
        ? items.firstWhere((e) => e.id == value!.id, orElse: () => value!)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleSmall),
        const SizedBox(height: 6),
        Stack(
          alignment: Alignment.centerRight,
          children: [
            DropdownButtonFormField<ClassStationModel>(
              value: selected,
              items: items
                  .map((s) => DropdownMenuItem<ClassStationModel>(
                        value: s,
                        child: Text(
                          _stationLabel(s),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ))
                  .toList(),
              onChanged: enabled ? onChanged : null,
              isExpanded: true,
              // style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                enabled: enabled,
                hintText: items.isEmpty
                    ? hintIfEmpty
                    : AppLocalizations.of(context)!.choose,
                // hintStyle: TextStyle(
                //   color: enabled
                //       ? theme.hintColor
                //       : theme.disabledColor.withOpacity(0.1),
                // ),
                // isDense: true,

                contentPadding: hasValue && onClear != null
                    ? const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ).copyWith(right: 40)
                    : const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            if (isLoading)
              const Positioned(
                right: 12,
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else if (hasValue && onClear != null)
              Positioned(
                right: 6,
                child: IconButton(
                  splashRadius: 18,
                  tooltip: AppLocalizations.of(context)!.clear,
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: onClear,
                ),
              ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canSubmit = (_selectedTrain != null) &&
        (_selectedStation != null) &&
        (_selectedDate != null);

    return SafeArea(
      top: false,
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        minChildSize: 0.35,
        maxChildSize: 0.95,
        builder: (ctx, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              children: [
                // ---------- Грип ----------
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),

                // ---------- Заголовок ----------
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedTrain = null;
                            _selectedStation = null;
                            _selectedDate = null;
                            _allStations = const [];
                            _isLoadingStations = false;
                          });
                        },
                        icon: const Icon(Icons.refresh, size: 18),
                        label: Text(AppLocalizations.of(context)!.reset_all),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),

                // ---------- Контент ----------
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    children: [
                      // ===== История (чипы с временем внутри) =====
                      if ((widget.history?.isNotEmpty ?? false)) ...[
                        Row(
                          children: [
                            const Icon(Icons.history,
                                size: 18, color: Colors.black54),
                            const SizedBox(width: 6),
                            Text(AppLocalizations.of(context)!.recent_requests,
                                style: theme.textTheme.titleSmall),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: widget.history!.map((e) {
                              final title = '${e.train} • ${e.station}';
                              final when = _whenShort(e.createdAt);
                              final dep =
                                  (e.departure.isNotEmpty) ? e.departure : '—';

                              return Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: () {
                                    // Пример автозаполнения по истории (опционально):
                                    // final matchedTrain = _matchTrainFromCode(e.train);
                                    // final matchedStation = _allStations.firstWhereOrNull((s) => _normString(s.name) == _normString(e.station));
                                    // setState(() { _selectedTrain = matchedTrain; _selectedStation = matchedStation; });

                                    Navigator.of(context).pop(<String, dynamic>{
                                      'historyKey': e.key,
                                    });
                                  },
                                  child: Container(
                                    width: 300,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                          color: const Color(0xFFE5E7EB)),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x0F000000),
                                          blurRadius: 10,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Заголовок
                                        Row(
                                          children: [
                                            const Icon(Icons.train,
                                                size: 16,
                                                color: Color(0xFF0B5ED7)),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                title,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            const Icon(Icons.chevron_right,
                                                size: 18,
                                                color: Colors.black45),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        // Две метки с датами
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: [
                                            _infoPill(
                                              Icons.calendar_month,
                                              AppLocalizations.of(context)!
                                                  .departure_label(dep),
                                              bg: const Color(0xFFEFF6FF),
                                              fg: const Color(0xFF0B5ED7),
                                            ),
                                            _infoPill(
                                              Icons.access_time,
                                              AppLocalizations.of(context)!
                                                  .request_label(when),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 16),
                      ],

                      // ===== Поезд, дата и время (Dropdown по МОДЕЛЯМ) =====
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppLocalizations.of(context)!.train_section,
                              style: theme.textTheme.titleSmall),
                          const SizedBox(height: 6),
                          Stack(
                            alignment: Alignment.centerRight,
                            children: [
                              DropdownButtonFormField<TrainDirectionModel>(
                                value: _selectedTrain != null &&
                                        _allTrains.contains(_selectedTrain)
                                    ? _selectedTrain
                                    : null,
                                items: _allTrains
                                    .map((m) =>
                                        DropdownMenuItem<TrainDirectionModel>(
                                          value: m,
                                          child: Text(
                                            _trainLabel(m),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ))
                                    .toList(),
                                onChanged: _onTrainSelected,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  hintText: _allTrains.isEmpty
                                      ? AppLocalizations.of(context)!.no_trains
                                      : AppLocalizations.of(context)!.choose,
                                  isDense: true,
                                  contentPadding: _selectedTrain != null
                                      ? const EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 12,
                                        ).copyWith(right: 40)
                                      : const EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 12,
                                        ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              if (_selectedTrain != null)
                                Positioned(
                                  right: 6,
                                  child: IconButton(
                                    splashRadius: 18,
                                    tooltip:
                                        AppLocalizations.of(context)!.clear,
                                    icon: const Icon(Icons.close_rounded,
                                        size: 18),
                                    onPressed: () {
                                      setState(() {
                                        _selectedTrain = null;
                                        _selectedStation = null;
                                        _selectedDate = null;
                                        _allStations = const [];
                                        _isLoadingStations = false;
                                      });
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ===== Дата отправления =====
                      DatePickerField(
                        label: AppLocalizations.of(context)!.departure_date,
                        hint: AppLocalizations.of(context)!.choose,
                        enabled: _selectedTrain != null,
                        value: _selectedDate,
                        onTap: _pickDate, // ваш метод выбора даты
                      ),
                      const SizedBox(height: 16),

                      // ===== Станция (Dropdown по NameIdPairModel) =====
                      _stationDropdown(
                        label: AppLocalizations.of(context)!.station,
                        items: _allStations,
                        value: _selectedStation,
                        hintIfEmpty: _selectedTrain == null
                            ? AppLocalizations.of(context)!.choose
                            : AppLocalizations.of(context)!.no_stations,
                        onChanged: (v) => setState(() => _selectedStation = v),
                        onClear: _selectedStation != null
                            ? () => setState(() => _selectedStation = null)
                            : null,
                        isLoading: _isLoadingStations,
                        enabled: !_isLoadingStations && _allStations.isNotEmpty,
                      ),
                    ],
                  ),
                ),

                // ---------- Кнопки ----------
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(AppLocalizations.of(context)!.cancel),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          icon: const Icon(Icons.cloud_download, size: 18),
                          label: Text(AppLocalizations.of(context)!.download),
                          onPressed: canSubmit
                              ? () {
                                  final train = _selectedTrain!;
                                  print('train: ${train.toJson()}');
                                  final trainTitle = _trainLabel(train);
                                  final trainCode = train.asuName.isNotEmpty
                                      ? train.asuName
                                      : train.code;

                                  Navigator.of(context).pop(<String, dynamic>{
                                    'train': trainTitle,
                                    'trainModel': train,
                                    'trainCode': trainCode, // код (829А и т.п.)
                                    'trainAsuName': trainCode,
                                    'trainTitle': trainTitle, // строка для UI
                                    'routeClassId': train.routeClassId,
                                    'date': _selectedDate,
                                    'station': _selectedStation!.name,
                                    'stationModel':
                                        _selectedStation, // модель станции
                                    'stationId': _selectedStation!.id,
                                    'stationName': _selectedStation!.name,
                                    'stationCode': _selectedStation!.code,
                                  });
                                }
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

Widget _infoPill(IconData icon, String text,
    {Color bg = const Color(0xFFF1F5F9), Color fg = const Color(0xFF111827)}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: const Color(0xFFE5E7EB)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: fg.withOpacity(0.9)),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: fg.withOpacity(0.9),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            height: 1.1,
          ),
        ),
      ],
    ),
  );
}
