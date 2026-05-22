import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class CustomCalendarWidget extends StatefulWidget {
  const CustomCalendarWidget({Key? key}) : super(key: key);

  @override
  State<CustomCalendarWidget> createState() => _CustomCalendarWidgetState();
}

class _CustomCalendarWidgetState extends State<CustomCalendarWidget> {
  DateTime _focusedDay = DateTime(2025, 3, 1);
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  PageController? _pageController;

  @override
  Widget build(BuildContext context) {
    final String monthLabel = DateFormat('MMMM yyyy', 'ru_RU').format(_focusedDay).toUpperCase();

    return Column(
      children: [
        // Заголовок (МАРТ 2025) + стрелки
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                monthLabel,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  InkWell(
                    onTap: _prevMonth,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.arrow_left),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _nextMonth,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_right,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Встроенные дни недели (Пн, Вт, Ср, ...)
        TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          locale: 'ru_RU',
          startingDayOfWeek: StartingDayOfWeek.monday,
          calendarFormat: CalendarFormat.month,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              if (_rangeStart == null ||
                  (_rangeStart != null && _rangeEnd != null)) {
                _rangeStart = selectedDay;
                _rangeEnd = null;
              } else if (_rangeStart != null && _rangeEnd == null) {
                if (selectedDay.isBefore(_rangeStart!)) {
                  _rangeStart = selectedDay;
                } else {
                  _rangeEnd = selectedDay;
                }
              }

              // Одиночное выделение
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          onPageChanged: (focusedDay) {
            setState(() {
              _focusedDay = focusedDay;
            });
          },
          onCalendarCreated: (controller) => _pageController = controller,

          // Включаем стандартные дни недели
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            leftChevronVisible: false,
            rightChevronVisible: false,
            titleCentered: false,
            titleTextFormatter: (_, __) => '',
            headerPadding: EdgeInsets.zero,
            leftChevronMargin: EdgeInsets.zero,
            rightChevronMargin: EdgeInsets.zero,
          ),
          daysOfWeekStyle: const DaysOfWeekStyle(
            weekdayStyle: TextStyle(fontSize: 14, color: Colors.black),
            weekendStyle: TextStyle(fontSize: 14, color: Colors.black),
          ),

          // Стили ячеек
          calendarStyle: const CalendarStyle(
            cellMargin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            outsideDaysVisible: true,
            defaultDecoration: BoxDecoration(),
            weekendDecoration: BoxDecoration(),
            outsideDecoration: BoxDecoration(),
          ),

          // Кастомные билдеры
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              return _buildDayCell(
                day,
                isToday: _isToday(day),
                isSelected: false,
                isOutside: false,
              );
            },
            outsideBuilder: (context, day, focusedDay) {
              return _buildDayCell(
                day,
                isToday: _isToday(day),
                isSelected: false,
                isOutside: true,
              );
            },
            todayBuilder: (context, day, focusedDay) {
              return _buildDayCell(
                day,
                isToday: true,
                isSelected: false,
                isOutside: false,
              );
            },
            selectedBuilder: (context, day, focusedDay) {
              return _buildDayCell(
                day,
                isToday: _isToday(day),
                isSelected: true,
                isOutside: false,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDayCell(
    DateTime day, {
    required bool isToday,
    required bool isSelected,
    required bool isOutside,
  }) {
    final bool inRange = _isWithinRange(day);
    final bool isStart = _rangeStart != null && isSameDay(day, _rangeStart);
    final bool isEnd = _rangeEnd != null && isSameDay(day, _rangeEnd);

    Color textColor = isOutside ? Colors.grey.shade400 : Colors.black;

    BoxDecoration decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: const Color(0xFFE2E5EE), width: 2),
      color: Colors.transparent,
    );

    if (inRange && !isStart && !isEnd) {
      decoration = decoration.copyWith(color: Colors.blue.shade50);
      textColor = Colors.blue.shade700;
    }

    if (isStart || isEnd) {
      decoration = decoration.copyWith(
        color: Colors.blue.shade100,
        border: Border.all(color: Colors.blue, width: 2),
      );
      textColor = Colors.blue.shade800;
    }

    if (isToday) {
      decoration = decoration.copyWith(
        border: Border.all(color: Colors.orange, width: 2),
      );
    }

    if (isSelected) {
      decoration = decoration.copyWith(
        border: Border.all(color: Colors.deepPurple, width: 2),
        color: Colors.deepPurple.shade100,
      );
      textColor = Colors.deepPurple.shade800;
    }

    return Container(
      margin: const EdgeInsets.all(6),
      alignment: Alignment.center,
      decoration: decoration,
      child: Text(
        '${day.day}',
        style: TextStyle(color: textColor, fontSize: 16),
      ),
    );
  }

  bool _isWithinRange(DateTime day) {
    if (_rangeStart == null || _rangeEnd == null) return false;
    return !day.isBefore(_rangeStart!) && !day.isAfter(_rangeEnd!);
  }

  bool _isToday(DateTime day) {
    final now = DateTime.now();
    return day.year == now.year && day.month == now.month && day.day == now.day;
  }

  void _prevMonth() {
    _pageController?.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _nextMonth() {
    _pageController?.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}
