import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class RequestsPage extends StatefulWidget {
  const RequestsPage({super.key});

  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  bool _calendarEnabled = true;

  // active tab: 0 - Все, 1 - Явки на маршрут, 2 - Охрана вагонов
  int _activeTab = 0;

  // Colors
  static const _cardShadow = BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 8));

  @override
  Widget build(BuildContext context) {
    final monthName = DateFormat('LLLL', 'ru_RU').format(_focusedDay);
    final yearStr = DateFormat('y', 'ru_RU').format(_focusedDay);

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.iconTheme.color),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Заявки на работу',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: theme.colorScheme.onSurface,
          ),
        ), //добав жирности
  
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(Icons.notifications_none_rounded, color: theme.iconTheme.color),
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
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [_cardShadow],
              ),
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Календарь', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface)),
                      const Spacer(),
                      Transform.scale(
                        scale: 0.9,
                        child: CupertinoSwitch(
                          value: _calendarEnabled,
                          onChanged: (v) => setState(() => _calendarEnabled = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Header controls
                  Row(
                    children: [
                      _iconButton(Icons.chevron_left, () => _changeMonth(-12)),
                      const SizedBox(width: 6),
                      Text(yearStr, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface)),
                      const SizedBox(width: 6),
                      _iconButton(Icons.chevron_right, () => _changeMonth(12)),
                      const SizedBox(width: 18),
                      _iconButton(Icons.chevron_left, () => _changeMonth(-1)),
                      const SizedBox(width: 6),
                      Text(_capitalize(monthName), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface)),
                      const SizedBox(width: 6),
                      _iconButton(Icons.chevron_right, () => _changeMonth(1)),
                    ],
                  ),
                  const SizedBox(height: 8),

                  _buildCalendar(),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Requests list
            _requestCard(
              color: const Color(0xFFFF4D4F),
              icon: SvgPicture.asset(
                'assets/svg_icons/arro_down.svg',
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(theme.colorScheme.onPrimary, BlendMode.srcIn),
              ),
              title: 'Срочная замена!',
              subtitleTop: 'Астана - Туркестан',
              subtitleBottom: 'с 15/07 12:00 по 17/07 14:15',
            ),
            const SizedBox(height: 12),
            _requestCard(
              color: const Color(0xFFF59E0B),
              icon: SvgPicture.asset(
                'assets/svg_icons/shiel_check_white.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(theme.colorScheme.onPrimary, BlendMode.srcIn),
              ),
              title: 'Охрана вагона',
              subtitleTop: 'Астана - Туркестан',
              subtitleBottom: 'с 28/07 12:00 по 31/07 14:15',
            ),
          ],
        ),
      ),
    );
  }

  // Chips
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
            color: active ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // Calendar
  Widget _buildCalendar() {
    final theme = Theme.of(context);
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      locale: 'ru_RU',
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarFormat: CalendarFormat.month,
      selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
      onDaySelected: (day, focused) => setState(() { _selectedDay = day; _focusedDay = focused; }),
      onPageChanged: (focused) => setState(() => _focusedDay = focused),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        leftChevronVisible: false,
        rightChevronVisible: false,
        titleCentered: false,
        titleTextFormatter: _empty,
        headerPadding: EdgeInsets.zero,
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface, fontWeight: FontWeight.w600),
        weekendStyle: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface, fontWeight: FontWeight.w600),
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
              style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface, fontWeight: FontWeight.w600),
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
    final theme = Theme.of(context);
    final d = DateTime(day.year, day.month, day.day);

    // Markers: 15-17 red, 28-31 orange for the focused month
    final isFocusedMonth = d.month == _focusedDay.month && d.year == _focusedDay.year;
    final red = isFocusedMonth && d.day >= 15 && d.day <= 17;
    final orange = isFocusedMonth && d.day >= 28 && d.day <= 31;

    // Base visual
    Color textColor = isOutside ? theme.disabledColor : theme.colorScheme.onSurface;
    Widget child = Text('${d.day}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor));

    if (red || orange) {
      final bg = red ? const Color(0xFFFF4D4F) : const Color(0xFFF59E0B);
      child = Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Text('${d.day}', style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
      );
    } else if (isToday || isSelected) {
      // today/selected — thin black circle + small dot inside for today
      child = Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: theme.colorScheme.primary, width: 2)),
          ),
          Text('${d.day}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: theme.colorScheme.primary)),
          if (isToday)
            Positioned(
              bottom: 7,
              child: CircleAvatar(radius: 2.5, backgroundColor: theme.colorScheme.primary),
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
  }) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(16), boxShadow: const [_cardShadow]),
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
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface)),
                const SizedBox(height: 4),
                Text(subtitleTop, style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface)),
                const SizedBox(height: 4),
                Text(subtitleBottom, style: TextStyle(fontSize: 14, color: theme.textTheme.bodySmall?.color)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, size: 28, color: theme.iconTheme.color?.withValues(alpha:0.7)),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    final theme = Theme.of(context);
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 22, color: theme.iconTheme.color),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      splashRadius: 18,
    );
  }

  void _changeMonth(int offset) {
    final next = DateTime(_focusedDay.year, _focusedDay.month + offset, 1);
    setState(() => _focusedDay = next);
  }
}

String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
