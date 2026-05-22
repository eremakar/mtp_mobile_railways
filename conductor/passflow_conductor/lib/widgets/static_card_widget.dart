// import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';
// import 'package:intl/intl.dart';
// import 'package:month_picker_dialog/month_picker_dialog.dart';
// import 'package:passflow_app/data/models/user_model.dart';
// import 'package:passflow_app/data/repositories/employ_repo.dart';
// import 'package:passflow_app/widgets/custom_calendar.dart';

// enum StatisticsCalendarType { month, day }

// class StatisticsCard extends StatefulWidget {
//   final int employeeId;
//   final StatisticsCalendarType calendarType;
//   Function(DateTimeRange date)? dateChanged;
//   StatisticsCard(
//       {super.key,
//       required this.calendarType,
//       this.dateChanged,
//       required this.employeeId});

//   @override
//   State<StatisticsCard> createState() => _StatisticsCardState();
// }

// class _StatisticsCardState extends State<StatisticsCard> {
//   DateTime _selectedDate = DateTime.now();
//   DateTimeRange? _selectedRange;

//   @override
//   Widget build(BuildContext context) {
//     String formattedPeriod;

//     if (_selectedRange != null) {
//       formattedPeriod =
//           'с ${DateFormat('d MMMM yy', 'ru').format(_selectedRange!.start)} '
//           '- ${DateFormat('d MMMM yy', 'ru').format(_selectedRange!.end)}';
//     } else if (widget.calendarType == StatisticsCalendarType.month) {
//       formattedPeriod = DateFormat('LLLL yyyy', 'ru').format(_selectedDate);
//     } else {
//       formattedPeriod = DateFormat('d MMMM yyyy', 'ru').format(_selectedDate);
//     }
//     Future<void> pickMonth() async {
//       final picked = await showMonthPicker(
//         context: context,
//         initialDate: _selectedDate,
//         firstDate: DateTime(2020),
//         lastDate: DateTime(DateTime.now().year + 2),
//       );
//       if (picked != null) {
//         setState(() => _selectedDate = picked);
//       }
//     }

//     Widget calendarSelector;
//     if (widget.calendarType == StatisticsCalendarType.month) {
//       calendarSelector = GestureDetector(
//         onTap: pickMonth,
//         child: Text(
//           'на $formattedPeriod г.',
//           style: const TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//             color: Color(0xFF2EBB6B),
//           ),
//         ),
//       );
//     } else {
//       calendarSelector = GestureDetector(
//         onTap: () => _showCustomCalendar(context),
//         child: Text(
//           '$formattedPeriod г.',
//           style: const TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//             color: Color(0xFF2EBB6B),
//           ),
//         ),
//       );
//     }

//     return FutureBuilder(
//       future: EmployeeStatisticsRepository().getStatistics(
//         employeeId: widget.employeeId,
//         month: _selectedDate.month,
//         year: _selectedDate.year,
//       ),
//       builder: (context, snapshot) {
//         return Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: Stack(
//             clipBehavior: Clip.none,
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: const Color.fromRGBO(51, 51, 51, 0.2),
//                       offset: const Offset(0, 4),
//                       blurRadius: 8,
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Верхняя строка
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'Статистика',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black.withAlpha((0.9 * 255).toInt()),
//                           ),
//                         ),
//                         calendarSelector,
//                       ],
//                     ),
//                     const SizedBox(height: 12),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         _buildStatItem('Отработано',
//                             '${snapshot.data != null && snapshot.data!.isNotEmpty ? (snapshot.data?[0].workedHours.toString() ?? '0') : '0'} ч'),
//                         _buildStatItem('План',
//                             '${snapshot.data != null && snapshot.data!.isNotEmpty ? (snapshot.data?[0].planHours.toString() ?? '0') : '0'} ч'),
//                         _buildStatItem('Норма',
//                             '${snapshot.data != null && snapshot.data!.isNotEmpty ? (snapshot.data?[0].monthlyNorm?.norm.toString() ?? '0') : '0'} ч'),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               Positioned(
//                 right: -8,
//                 bottom: -8,
//                 child: Icon(
//                   Icons.check_circle_outline,
//                   size: 64,
//                   color:
//                       const Color(0xFF2EBB6B).withAlpha((0.15 * 255).toInt()),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   void _showCustomCalendar(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (context) {
//         return SizedBox(
//           height: 500,
//           child: CustomCalendarWidget(
//             initialDate: _selectedDate,
//             onDateSelected: (date) {
//               setState(() {
//                 _selectedDate = date;
//                 _selectedRange = null;
//               });
//               widget.dateChanged?.call(DateTimeRange(start: date, end: date));
//               Navigator.pop(context);
//             },
//             onDateRangeSelected: (range) {
//               setState(() {
//                 _selectedRange = range;
//                 _selectedDate = range.start;
//               });
//               widget.dateChanged?.call(range);
//               Navigator.pop(context);
//             },
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildStatItem(String label, String value) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w400,
//             color: Color(0xFF4A64F8),
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           value,
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: Colors.black,
//           ),
//         ),
//       ],
//     );
//   }
// }
