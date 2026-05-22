import 'package:flutter/material.dart';

/// Opens a full-screen modal page to pick a period (start and end date).
/// Returns a DateTimeRange when user taps "Применить" or null when closed/cancelled.
Future<DateTimeRange?> showPeriodRangePicker(
  BuildContext context, {
  DateTime? initialStart,
  DateTime? initialEnd,
}) {
  return Navigator.of(context).push<DateTimeRange>(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black54,
      pageBuilder: (_, __, ___) => _PeriodRangePickerPage(
        initialStart: initialStart,
        initialEnd: initialEnd,
      ),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
  );
}

class _PeriodRangePickerPage extends StatefulWidget {
  const _PeriodRangePickerPage({this.initialStart, this.initialEnd});
  final DateTime? initialStart;
  final DateTime? initialEnd;

  @override
  State<_PeriodRangePickerPage> createState() => _PeriodRangePickerPageState();
}

class _PeriodRangePickerPageState extends State<_PeriodRangePickerPage> {
  late DateTime? _start = _stripTime(widget.initialStart);
  late DateTime? _end = _stripTime(widget.initialEnd);

  // 0 => "Период с ...*", 1 => "Период до ...*"
  int _tabIndex = 0;

  // calendar cursor (what month/year are shown)
  late DateTime _cursor = DateTime.now();

  static DateTime? _stripTime(DateTime? d) => d == null
      ? null
      : DateTime(d.year, d.month, d.day);

  @override
  void initState() {
    super.initState();
    // Center calendar around picked date or now
    _cursor = _start ?? _end ?? DateTime.now();
  }

  void _apply() {
    if (_start != null && _end != null) {
      final start = _start!;
      final end = _end!;
      final range = start.isBefore(end)
          ? DateTimeRange(start: start, end: end)
          : DateTimeRange(start: end, end: start);
      Navigator.of(context).pop(range);
    } else {
      // If one of dates not set, do nothing or show a hint
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите даты начала и окончания периода')),
      );
    }
  }

  void _reset() {
    setState(() {
      _start = null;
      _end = null;
      _tabIndex = 0;
      _cursor = DateTime.now();
    });
  }

  void _pickDay(DateTime day) {
    setState(() {
      if (_tabIndex == 0) {
        _start = day;
        _tabIndex = 1; // move to end tab
        _cursor = day;
      } else {
        _end = day;
      }
    });
  }

  bool _isSelected(DateTime day) {
    final d = _stripTime(day);
    return d == _start || d == _end;
  }

  bool _isInRange(DateTime day) {
    if (_start == null || _end == null) return false;
    final start = _start!;
    final end = _end!;
    final a = start.isBefore(end) ? start : end;
    final b = start.isBefore(end) ? end : start;
    return day.isAfter(a) && day.isBefore(b);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      child: SafeArea(
        bottom: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Выбрать период',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 28, color: theme.iconTheme.color),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Закрыть',
                  )
                ],
              ),
            ),

            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _TabChip(
                    title: 'Период с ...*',
                    active: _tabIndex == 0,
                    onTap: () => setState(() => _tabIndex = 0),
                  ),
                  const SizedBox(width: 18),
                  _TabChip(
                    title: 'Период до ...*',
                    active: _tabIndex == 1,
                    onTap: () => setState(() => _tabIndex = 1),
                  ),
                ],
              ),
            ),

            // Year / Month row
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    _Arrow(onTap: () => setState(() => _cursor = DateTime(_cursor.year - 1, _cursor.month))),
                    const SizedBox(width: 8),
                    Text('${_cursor.year}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                    const SizedBox(width: 8),
                    _Arrow(direction: AxisDirection.right, onTap: () => setState(() => _cursor = DateTime(_cursor.year + 1, _cursor.month))),
                  ]),
                  Row(children: [
                    _Arrow(onTap: () => setState(() => _cursor = DateTime(_cursor.year, _cursor.month - 1))),
                    const SizedBox(width: 8),
                    Text(_monthName(_cursor.month), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                    const SizedBox(width: 8),
                    _Arrow(direction: AxisDirection.right, onTap: () => setState(() => _cursor = DateTime(_cursor.year, _cursor.month + 1))),
                  ]),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Weekday names
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Weekday('Пн'),
                  _Weekday('Вт'),
                  _Weekday('Ср'),
                  _Weekday('Чт'),
                  _Weekday('Пт'),
                  _Weekday('Сб'),
                  _Weekday('Вс'),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Calendar grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _MonthGrid(
                  month: DateTime(_cursor.year, _cursor.month, 1),
                  isSelected: _isSelected,
                  isInRange: _isInRange,
                  onPick: _pickDay,
                ),
              ),
            ),

            // Bottom actions
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: _apply,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                    child: const Text('Применить', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: _reset,
                    style: TextButton.styleFrom(
                      backgroundColor: theme.colorScheme.surface,
                      foregroundColor: theme.colorScheme.onSurface,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                    child: const Text('Сбросить', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const List<String> _ruMonths = [
    'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
    'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь',
  ];

  String _monthName(int m) => _ruMonths[(m - 1) % 12];
}

class _TabChip extends StatelessWidget {
  const _TabChip({required this.title, required this.active, required this.onTap});
  final String title;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = active ? theme.colorScheme.primary : theme.textTheme.bodySmall?.color;
    final underlineColor = active ? theme.colorScheme.primary : Colors.transparent;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 6),
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(height: 10),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 2,
              color: underlineColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow({this.direction = AxisDirection.left, required this.onTap});
  final AxisDirection direction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isRight = direction == AxisDirection.right;
    final color = Theme.of(context).iconTheme.color;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Icon(isRight ? Icons.arrow_forward_ios_rounded : Icons.arrow_back_ios_new_rounded, size: 18, color: color),
      ),
    );
  }
}

class _Weekday extends StatelessWidget {
  const _Weekday(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).textTheme.bodySmall?.color;
    return Text(text, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w600));
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({required this.month, required this.isSelected, required this.isInRange, required this.onPick});

  final DateTime month; // first day of month
  final bool Function(DateTime) isSelected;
  final bool Function(DateTime) isInRange;
  final void Function(DateTime) onPick;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month, 1);
    final firstWeekday = (first.weekday + 6) % 7; // Mon=0..Sun=6
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final totalCells = firstWeekday + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rows, (r) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (c) {
            final index = r * 7 + c;
            final dayNum = index - firstWeekday + 1;

            late DateTime cellDate;
            bool disabled = false;
            if (dayNum < 1) {
              // previous month
              final prevMonthLastDay = DateTime(month.year, month.month, 0).day;
              final prevDay = prevMonthLastDay + dayNum; // dayNum is negative/zero offset
              cellDate = DateTime(month.year, month.month - 1, prevDay);
              disabled = true;
            } else if (dayNum > daysInMonth) {
              // next month
              final nextDay = dayNum - daysInMonth;
              cellDate = DateTime(month.year, month.month + 1, nextDay);
              disabled = true;
            } else {
              cellDate = DateTime(month.year, month.month, dayNum);
            }

            final selected = !disabled && isSelected(cellDate);
            final inRange = !disabled && isInRange(cellDate);

            return _DayCell(
              date: cellDate,
              label: '${cellDate.day}',
              selected: selected,
              inRange: inRange,
              disabled: disabled,
              onTap: disabled ? null : () => onPick(cellDate),
            );
          }),
        );
      }),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.label,
    required this.selected,
    required this.inRange,
    this.disabled = false,
    required this.onTap,
  });

  final DateTime date;
  final String label;
  final bool selected;
  final bool inRange;
  final bool disabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color baseColor = theme.colorScheme.onSurface;
    final Color disabledColor = theme.disabledColor;
    final Color textColor = disabled ? disabledColor : baseColor;

    final isToday = _isSameDay(date, DateTime.now());

    final child = Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected
            ? Colors.transparent
            : (inRange ? theme.colorScheme.surface : Colors.transparent),
        shape: BoxShape.circle,
        border: selected ? Border.all(color: theme.colorScheme.primary, width: 2) : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: selected ? theme.colorScheme.primary : textColor,
            ),
          ),
          if (isToday)
            Positioned(
              bottom: 8,
              child: CircleAvatar(radius: 2.5, backgroundColor: theme.colorScheme.primary),
            ),
        ],
      ),
    );

    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: child,
      ),
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}
