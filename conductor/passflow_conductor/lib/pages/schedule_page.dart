import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:passflow_app/widgets/custom_loader.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:passflow_app/core/di/service_locator.dart';
import 'package:passflow_app/data/models/routeSheetEmployees/route_sheet_employee_model.dart';
import 'package:passflow_app/data/repositories/route_sheet_employees_repository.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key, required this.employeeId});
  final int employeeId;

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  bool _calendarEnabled = true;

  // 0 - Все, 1 - Явки на маршрут, 2 - Охрана вагонов
  int _activeTab = 0;

  // Data
  List<RouteSheetEmployeeModel> _routes = [];
  bool _isLoading = false;

  // Colors (как в примере)
  static const _cardShadow =
      BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 8));

  @override
  void initState() {
    super.initState();
    _fetchRoutesForMonth(_focusedDay);
  }

  Future<void> _fetchRoutesForMonth(DateTime month) async {
    setState(() => _isLoading = true);
    final fromDate =
        DateFormat('yyyy-MM-dd').format(DateTime(month.year, month.month, 1));
    final toDate = DateFormat('yyyy-MM-dd')
        .format(DateTime(month.year, month.month + 1, 0));
    final repo = sl<RouteSheetEmployeesRepository>();
    final routes = await repo.searchEmployeeRouteSheets(
      employeeId: widget.employeeId,
      fromDate: fromDate,
      toDate: toDate,
    );
    setState(() {
      _routes = routes ?? [];
      _isLoading = false;
    });
  }

  List<RouteSheet> _routesForDay(DateTime day) {
    return _routes
        .where((r) => _isInRange(
            day, DateTimeRange(start: r.arriveTime, end: r.leaveTime)))
        .map((r) => r.routeSheet)
        .toList();
  }

  bool _isInRange(DateTime day, DateTimeRange range) {
    final d = DateTime(day.year, day.month, day.day).toUtc();
    final start =
        DateTime(range.start.year, range.start.month, range.start.day).toUtc();
    final end =
        DateTime(range.end.year, range.end.month, range.end.day).toUtc();
    return !d.isBefore(start) && !d.isAfter(end);
  }

  @override
  Widget build(BuildContext context) {
    final monthName = DateFormat('LLLL', 'ru_RU').format(_focusedDay);
    final yearStr = DateFormat('y', 'ru_RU').format(_focusedDay);

    final dayRoutes = _selectedDay != null ? _routesForDay(_selectedDay!) : [];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: Theme.of(context).iconTheme.color,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Мой график',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Theme.of(context).colorScheme.onSurface),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.notifications_none_rounded),
              color: Theme.of(context).iconTheme.color,
              onPressed: () {},
            ),
          )
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            // Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip('Все', 0),
                  const SizedBox(width: 12),
                  _filterChip('Явки на маршрут', 1),
                  const SizedBox(width: 12),
                  _filterChip('Охрана вагонов', 2),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Calendar Card
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [_cardShadow],
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Календарь',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).colorScheme.onSurface)),
                      const Spacer(),
                      Transform.scale(
                        scale: 0.9,
                        child: CupertinoSwitch(
                          value: _calendarEnabled,
                          onChanged: (v) =>
                              setState(() => _calendarEnabled = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Header controls
                  Row(
                    children: [
                      Expanded(
                        flex: 10,
                        child: Row(
                          children: [
                            _iconButton(
                                Icons.chevron_left, () => _changeMonth(-12)),
                            Text(yearStr,
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(context).colorScheme.onSurface)),
                            _iconButton(
                                Icons.chevron_right, () => _changeMonth(12)),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 11,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _iconButton(
                                Icons.chevron_left, () => _changeMonth(-1)),
                            Flexible(
                              child: Text(_capitalize(monthName),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context).colorScheme.onSurface)),
                            ),
                            _iconButton(
                                Icons.chevron_right, () => _changeMonth(1)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  _buildCalendar(),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (_isLoading)
              const Center(
                  child: Padding(
                      padding: EdgeInsets.all(16),
                      child: DotCircleLoader()))
            else if (dayRoutes.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                    child: Text('Нет маршрутов в этот день',
                        style: TextStyle(
                          fontSize: 16,
                        ))),
              )
            else
              ...dayRoutes.map((route) {
  final subtitleTop = route.name ?? '';
  final subtitleBottom = route.comeTime != null
      ? DateFormat('dd.MM.yyyy HH:mm').format(route.comeTime!.toLocal())
      : '—';

  final routeSheetEmployee = _routes.firstWhere(
    (r) => r.routeSheet.id == route.id,
    orElse: () => RouteSheetEmployeeModel(
      id: 0,
      employeeId: widget.employeeId,
      routeSheet: RouteSheet(
        id: 0,
        name: '',
        state: '3',
        isArchive: false,
        sapId: '',
        type: 0,
        comeTime: DateTime.now(),
        leaveTime: DateTime.now(),
        editedDate: DateTime.now(),
        ownerEmployeeId: 0,
        routeId: 0,
        departmentId: 0,
        taskListTypeId: 0,
        taskMenuTypeId: 0,
        state2Id: 3,
      ),
      routeSheetItem: RouteSheetItem(
        id: 0,
        groupNumber: 0,
        routeSheetId: 0,
      ),
      employee: Employee(id: widget.employeeId, firstName: '', lastName: '', fatherName: '', phone: '', iin: ''),
      arriveTime: DateTime.now(),
      leaveTime: DateTime.now(),
      workedHours: 0,
      plannedHours: 0,
      isArrived: false,
      routeSheetId: 0,
    ),
  );

  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: _requestCard(
      color: const Color(0xFF0A60DE),
      icon: const Icon(Icons.person_outline, color: Colors.white, size: 22),
      title: 'Явка на маршрут',
      subtitleTop: subtitleTop,
      subtitleBottom: subtitleBottom,
      plannedHours: routeSheetEmployee.plannedHours?.toString(),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  // Tabs (chips)
  Widget _filterChip(String label, int index) {
    final active = _activeTab == index;
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => setState(() => _activeTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? theme.colorScheme.primary : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // Calendar
  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      locale: 'ru_RU',
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarFormat: CalendarFormat.month,
      selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
      onDaySelected: (day, focused) => setState(() {
        _selectedDay = day;
        _focusedDay = focused;
      }),
      onPageChanged: (focused) {
        setState(() {
          _focusedDay = focused;
          _selectedDay = focused;
        });
        _fetchRoutesForMonth(focused);
      },
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        leftChevronVisible: false,
        rightChevronVisible: false,
        titleCentered: false,
        titleTextFormatter: _empty,
        headerPadding: EdgeInsets.zero,
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(
            fontSize: 14,
            color: Theme.of(context).textTheme.bodySmall?.color,
            fontWeight: FontWeight.w600),
        weekendStyle: TextStyle(
            fontSize: 14,
            color: Theme.of(context).textTheme.bodySmall?.color,
            fontWeight: FontWeight.w600),
      ),
      calendarStyle: const CalendarStyle(
        outsideDaysVisible: true,
        cellMargin: EdgeInsets.all(4),
      ),
      rowHeight: 44,
      daysOfWeekHeight: 24,
      calendarBuilders: CalendarBuilders(
        dowBuilder: (context, day) {
          const labels = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
          final text = labels[day.weekday - 1];
          return Center(
            child: Text(
              text,
              style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontWeight: FontWeight.w600),
            ),
          );
        },
        defaultBuilder: (context, day, _) => _dayCell(day, isOutside: false),
        outsideBuilder: (context, day, _) => _dayCell(day, isOutside: true),
        todayBuilder: (context, day, _) => _dayCell(day, isToday: true),
        selectedBuilder: (context, day, _) => _dayCell(day, isSelected: true),
      ),
    );
  }

  Widget _dayCell(
    DateTime day, {
    bool isToday = false,
    bool isSelected = false,
    bool isOutside = false,
  }) {
    final d = DateTime(day.year, day.month, day.day);
    final theme = Theme.of(context);

    final isFocusedMonth =
        d.month == _focusedDay.month && d.year == _focusedDay.year;
    final dayEntries = _routes
        .where((r) =>
            _isInRange(d, DateTimeRange(start: r.arriveTime, end: r.leaveTime)))
        .toList();

    Color? highlightColor;
    if (isFocusedMonth && dayEntries.isNotEmpty) {
      var hasYellow = false;
      var hasRed = false;
      for (final entry in dayEntries) {
        final stateValue = int.tryParse(entry.routeSheet.state) ?? 3;
        if (stateValue < 3) {
          hasYellow = true;
        } else {
          hasRed = true;
        }
      }

      if (hasYellow) {
        highlightColor = const Color(0xFFF59E0B);
      } else if (hasRed) {
        highlightColor = const Color(0xFFFF4D4F);
      }
    }

    Color textColor =
        isOutside ? theme.disabledColor : theme.colorScheme.onSurface;
    Widget child = Text('${d.day}',
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w600, color: textColor));

    if (highlightColor != null) {
      child = Stack(alignment: Alignment.center, children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration:
              BoxDecoration(color: highlightColor, shape: BoxShape.circle),
          child: Text('${d.day}',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
        ),
        if (isSelected)
          const Positioned(
            bottom: 7,
            child: CircleAvatar(radius: 2.5, backgroundColor: Colors.white),
          )
      ]);
    } else if (isToday || isSelected) {
      child = Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: theme.colorScheme.primary, width: 2)),
          ),
          Text('${d.day}',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface)),
          if (isSelected)
            Positioned(
              bottom: 7,
              child: CircleAvatar(
                  radius: 2.5, backgroundColor: theme.colorScheme.primary),
            ),
        ],
      );
    }

    return Container(
      margin: const EdgeInsets.all(4),
      alignment: Alignment.center,
      child: child,
    );
  }

  static String _empty(_, __) => '';

  Widget _requestCard({
    required Color color,
    required Widget icon,
    required String title,
    required String subtitleTop,
    required String subtitleBottom,
    String? plannedHours,
  }) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [_cardShadow]),
      padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Center(child: icon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface)),
                const SizedBox(height: 4),
                Text(subtitleTop,
                    style: TextStyle(
                        fontSize: 14, color: theme.colorScheme.onSurface)),
                const SizedBox(height: 4),
                Text(subtitleBottom,
                    style: TextStyle(
                        fontSize: 14,
                        color: theme.textTheme.bodySmall?.color)),
              ],
            ),
          ),
          if (plannedHours != null)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(
              '$plannedHours ч',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              size: 28, color: theme.iconTheme.color?.withValues(alpha:0.7)),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 22, color: Theme.of(context).iconTheme.color),
      padding: EdgeInsets.zero,
      // constraints: const BoxConstraints(minWidth: 1, minHeight: 1),
      splashRadius: 18,
    );
  }

  void _changeMonth(int offset) {
    final next = DateTime(_focusedDay.year, _focusedDay.month + offset, 1);
    setState(() => _focusedDay = next);
    _fetchRoutesForMonth(next);
  }
}

String _capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
