import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

enum CalendarViewMode { monthSelection, daySelection }

class CustomCalendarWidget extends StatefulWidget {
  final DateTime? initialDate;
  final ValueChanged<DateTime>? onDateSelected;
  final ValueChanged<DateTimeRange>? onDateRangeSelected;

  const CustomCalendarWidget({
    super.key,
    this.initialDate,
    this.onDateSelected,
    this.onDateRangeSelected,
  });

  @override
  State<CustomCalendarWidget> createState() => _CustomCalendarWidgetState();
}

class _CustomCalendarWidgetState extends State<CustomCalendarWidget> {
  CalendarViewMode _viewMode = CalendarViewMode.daySelection;
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  PageController? _pageController;

  // Для диапазона:
  DateTime? _tempRangeStart;
  DateTime? _tempRangeEnd;

  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.initialDate ?? DateTime.now();
    _selectedDay = null;
    _tempRangeStart = null;
    _tempRangeEnd = null;
  }

  @override
  Widget build(BuildContext context) {
    switch (_viewMode) {
      case CalendarViewMode.monthSelection:
      case CalendarViewMode.daySelection:
        return _buildDaySelection();
    }
  }

  Widget _buildDaySelection() {
  final String monthLabel = toBeginningOfSentenceCase(
          DateFormat('LLLL yyyy', 'ru').format(_focusedDay)) ??
      "";

  return Stack(
    children: [
      // Основной контент календаря
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Хедер с месяцем и кнопками
          SizedBox(
            height: 68,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Название месяца по центру
                Center(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _viewMode = CalendarViewMode.monthSelection;
                      });
                    },
                    child: Text(
                      monthLabel,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                ),
                // Кнопки по краям
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, size: 20),
                      splashRadius: 18,
                      onPressed: _prevMonth,
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_right, size: 20),
                          splashRadius: 18,
                          onPressed: _nextMonth,
                        ),
                        if (_tempRangeStart != null || _tempRangeEnd != null)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 20, color: Colors.redAccent),
                            splashRadius: 18,
                            tooltip: 'Сбросить диапазон',
                            onPressed: () {
                              setState(() {
                                _tempRangeStart = null;
                                _tempRangeEnd = null;
                                _rangeSelectionMode = RangeSelectionMode.toggledOff;
                              });
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Сам календарь
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: double.infinity,
              height: 390,
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                locale: 'ru_RU',
                startingDayOfWeek: StartingDayOfWeek.monday,
                calendarFormat: CalendarFormat.month,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                rangeStartDay: _tempRangeStart,
                rangeEndDay: _tempRangeEnd,
                rangeSelectionMode: _rangeSelectionMode,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    if (_tempRangeStart != null && _tempRangeEnd != null) {
                      _tempRangeStart = selectedDay;
                      _tempRangeEnd = null;
                      _rangeSelectionMode = RangeSelectionMode.toggledOn;
                    } else if (_tempRangeStart == null || (_tempRangeStart != null && _tempRangeEnd != null)) {
                      _tempRangeStart = selectedDay;
                      _tempRangeEnd = null;
                      _rangeSelectionMode = RangeSelectionMode.toggledOn;
                    } else if (_tempRangeStart != null && _tempRangeEnd == null) {
                      if (selectedDay.isBefore(_tempRangeStart!)) {
                        _tempRangeStart = selectedDay;
                      } else {
                        _tempRangeEnd = selectedDay;
                      }
                      _rangeSelectionMode = RangeSelectionMode.toggledOn;
                    }
                    _focusedDay = focusedDay;
                    _selectedDay = null;
                  });
                },
              onCalendarCreated: (controller) => _pageController = controller,
              headerVisible: false,
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500),
                weekendStyle: TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500),
              ),
              calendarStyle: CalendarStyle(
                cellMargin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                defaultDecoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E5EE), width: 2),
                ),
                outsideDecoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E5EE), width: 2),
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.orange.withAlpha((0.08 * 255).round()),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withAlpha((0.25 * 255).round()), width: 2),
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.deepPurple.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.deepPurple, width: 2),
                ),
                rangeStartDecoration: BoxDecoration(
                  color: Colors.deepPurple.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.deepPurple, width: 2),
                ),
                rangeEndDecoration: BoxDecoration(
                  color: Colors.deepPurple.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.deepPurple, width: 2),
                ),
                withinRangeDecoration: BoxDecoration(
                  color: Colors.deepPurple.withValues(alpha:0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                weekendDecoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E5EE), width: 2),
                ),
                defaultTextStyle: const TextStyle(fontSize: 16, color: Colors.black),
                weekendTextStyle: const TextStyle(fontSize: 16, color: Colors.black),
                outsideTextStyle: TextStyle(fontSize: 16, color: Colors.grey.shade400),
                todayTextStyle: const TextStyle(fontSize: 16, color: Colors.orange),
                selectedTextStyle: TextStyle(fontSize: 16, color: Colors.deepPurple.shade800, fontWeight: FontWeight.bold),
                rangeStartTextStyle: TextStyle(fontSize: 16, color: Colors.deepPurple.shade800, fontWeight: FontWeight.bold),
                rangeEndTextStyle: TextStyle(fontSize: 16, color: Colors.deepPurple.shade800, fontWeight: FontWeight.bold),
                withinRangeTextStyle: TextStyle(fontSize: 16, color: Colors.deepPurple.shade700),
              ),
              calendarBuilders: CalendarBuilders(),
            ),
          ),
        ),
        ],
    ),
    if (_tempRangeStart != null && _tempRangeEnd != null)
  Positioned(
    bottom: 32,
    left: 0,
    right: 0,
    child: AnimatedScale(
      duration: const Duration(milliseconds: 200),
      scale: 1.0,
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color.fromARGB(255, 159, 159, 159), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 180, 180, 180).withValues(alpha:0.11),
                blurRadius: 10,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                if (widget.onDateRangeSelected != null) {
                  widget.onDateRangeSelected!(
                    DateTimeRange(start: _tempRangeStart!, end: _tempRangeEnd!),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 12),
                    Text(
                      'Подтвердить',
                      style: TextStyle(
                        fontSize: 18,
                        color: const Color.fromARGB(255, 75, 75, 75),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  ),
  ],
    );
  }

  void _prevMonth() {
  final prevMonth = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
  setState(() {
    _focusedDay = prevMonth;
  });
  _pageController?.previousPage(
    duration: const Duration(milliseconds: 250),
    curve: Curves.easeOut,
  );
}

void _nextMonth() {
  final nextMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
  setState(() {
    _focusedDay = nextMonth;
  });
  _pageController?.nextPage(
    duration: const Duration(milliseconds: 250),
    curve: Curves.easeOut,
  );
}

}
