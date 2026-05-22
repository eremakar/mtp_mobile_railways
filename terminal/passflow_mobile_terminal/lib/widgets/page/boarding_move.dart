// import 'package:flutter/material.dart';
// import 'package:passflow_app/widgets/page/refusal_signed_page.dart';
// import 'package:passflow_app/widgets/page/disembark_signed_page.dart';

// class TicketDetailScreen extends StatefulWidget {
//   const TicketDetailScreen({Key? key}) : super(key: key);

//   @override
//   State<TicketDetailScreen> createState() => _TicketDetailScreenState();
// }

// class _TicketDetailScreenState extends State<TicketDetailScreen> {
//   int _selectedTabIndex = 0;
//   String _selectedReason = 'Причина отказа';

//   @override
//   Widget build(BuildContext context) {
//     // ---- Read values from arguments (from Boarding) ----
//     final args = ModalRoute.of(context)?.settings.arguments as Map<dynamic, dynamic>?;
//     Map<String, dynamic>? passenger = args != null && args['passenger'] is Map
//         ? (args['passenger'] as Map).map((k, v) => MapEntry(k.toString(), v)) as Map<String, dynamic>
//         : null;

//     String _str(dynamic v) => v == null ? '' : v.toString();
//     String fullName = _str(args?['fullName']).isNotEmpty
//         ? _str(args?['fullName'])
//         : _str(passenger?['name']).isNotEmpty
//             ? _str(passenger?['name'])
//             : '—';
//     String docNumber = _str(args?['documentNumber']).isNotEmpty
//         ? _str(args?['documentNumber'])
//         : _str(passenger?['doc']).isNotEmpty
//             ? _str(passenger?['doc'])
//             : _str(passenger?['docNumber']).isNotEmpty
//                 ? _str(passenger?['docNumber'])
//                 : _str(passenger?['iin']);
//     String wagon = _str(passenger?['wagon']);
//     String seat = _str(passenger?['seat']);
//     String stationFrom = _str(args?['departure']).isNotEmpty ? _str(args?['departure']) : 'Нурлы Жол';
//     String stationTo   = _str(args?['arrival']).isNotEmpty   ? _str(args?['arrival'])   : _str(passenger?['station']).isNotEmpty ? _str(passenger?['station']) : 'Алматы 2';
//     String depDate = _str(args?['departureDate']).isNotEmpty ? _str(args?['departureDate']) : '16.07.2025 - 20:20';
//     String arrDate = _str(args?['arrivalDate']).isNotEmpty   ? _str(args?['arrivalDate'])   : '17.07.2025 - 13:10';
//     bool isPost = (args?['isPostletnoe'] ?? false) == true;
//     String status = _str(args?['status']).isNotEmpty ? _str(args?['status']) : 'Посажен';

//     String ticketNumber = _str(args?['ticketNumber']).isNotEmpty
//         ? _str(args?['ticketNumber'])
//         : '${wagon.isEmpty ? '00' : wagon}-${seat.isEmpty ? '0' : seat}-${docNumber.isEmpty ? '000000' : docNumber}';

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: Text(
//           fullName.isEmpty ? '—' : (fullName.length > 22 ? fullName.substring(0, 22) + '…' : fullName),
//           overflow: TextOverflow.ellipsis,
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.share, color: Colors.black),
//             onPressed: () {},
//           ),
//         ],
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 _buildTab('Талон', 1, index: 0),
//                 _buildTab('Отказ', 1, index: 1),
//                 _buildTab('Высадка', 0, index: 2),
//               ],
//             ),
//           ),
//           const SizedBox(height: 16),
//           Expanded(child: _buildTabContent(
//             status: status,
//             ticketNumber: ticketNumber,
//             seat: seat,
//             fullName: fullName,
//             docNumber: docNumber,
//             stationFrom: stationFrom,
//             isPost: isPost,
//             depDate: depDate,
//             stationTo: stationTo,
//             arrDate: arrDate,
//           )),
//         ],
//       ),
//     );
//   }

//   Widget _buildTab(String label, int count, {required int index}) {
//     final selected = _selectedTabIndex == index;

//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           _selectedTabIndex = index;
//         });
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//         decoration: BoxDecoration(
//           color: selected ? const Color(0xFF007AFF) : const Color(0xFFF2F2F2),
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const SizedBox(width: 0),
//             Text(
//               '$label ($count)',
//               style: TextStyle(
//                 color: selected ? Colors.white : Colors.black,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTabContent({
//     required String status,
//     required String ticketNumber,
//     required String seat,
//     required String fullName,
//     required String docNumber,
//     required String stationFrom,
//     required bool isPost,
//     required String depDate,
//     required String stationTo,
//     required String arrDate,
//   }) {
//     switch (_selectedTabIndex) {
//       case 0:
//         return _buildTicketInfo(
//           status: status,
//           ticket: ticketNumber,
//           seat: seat,
//           fullName: fullName,
//           doc: docNumber,
//           from: stationFrom,
//           isPost: isPost,
//           depDate: depDate,
//           to: stationTo,
//           arrDate: arrDate,
//         );
//       case 1:
//         return _buildRefusalContent();
//       case 2:
//         return Navigator(
//           onGenerateRoute: (_) => MaterialPageRoute(
//             builder: (_) => DisembarkSignedPage(),
//           ),
//         );
//       default:
//         return Container();
//     }
//   }

//   Widget _buildTicketInfo({
//     required String status,
//     required String ticket,
//     required String seat,
//     required String fullName,
//     required String doc,
//     required String from,
//     required bool isPost,
//     required String depDate,
//     required String to,
//     required String arrDate,
//   }) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildInfoRow(Icons.person_outline, status, 'Статус'),
//           _buildInfoRow(Icons.confirmation_number_outlined, '$ticket / ${seat.isEmpty ? '—' : seat}', '№ билета / место'),
//           _buildInfoRow(Icons.badge_outlined, fullName, 'ФИО'),
//           _buildInfoRow(Icons.credit_card_outlined, doc.isEmpty ? '—' : doc, '№ документа'),
//           _buildInfoRow(Icons.train, from, 'Станция отправления'),
//           _buildInfoRow(Icons.bed_outlined, isPost ? 'Да' : 'Нет', 'Постельное'),
//           _buildInfoRow(Icons.calendar_today, depDate, 'Дата отправления'),
//           _buildInfoRow(Icons.train_outlined, to, 'Прибытие'),
//           _buildInfoRow(Icons.calendar_today_outlined, arrDate, 'Дата прибытия'),
//           const SizedBox(height: 24),
//           ElevatedButton(
//             onPressed: () async {
//               final result = await showModalBottomSheet<String>(
//                 context: context,
//                 shape: const RoundedRectangleBorder(
//                   borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//                 ),
//                 builder: (context) {
//                   String? selected = 'Посадка';
//                   return StatefulBuilder(
//                     builder: (context, setState) {
//                       return Padding(
//                         padding: const EdgeInsets.all(16),
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             const Text('Выберите статус',
//                                 style: TextStyle(
//                                     fontSize: 18, fontWeight: FontWeight.bold)),
//                             const SizedBox(height: 12),
//                             ...['Посадка', 'Отказ', 'Высадка'].map((s) {
//                               return RadioListTile<String>(
//                                 value: s,
//                                 groupValue: selected,
//                                 title: Text(
//                                   s,
//                                   style: TextStyle(
//                                     color: s == 'Посадка'
//                                         ? Colors.green
//                                         : s == 'Отказ'
//                                             ? Colors.red
//                                             : Colors.orange,
//                                   ),
//                                 ),
//                                 activeColor: s == 'Посадка'
//                                     ? Colors.green
//                                     : s == 'Отказ'
//                                         ? Colors.red
//                                         : Colors.orange,
//                                 onChanged: (value) {
//                                   setState(() => selected = value);
//                                 },
//                               );
//                             }).toList(),
//                             const SizedBox(height: 16),
//                             ElevatedButton(
//                               onPressed: () {
//                                 Navigator.of(context).pop(selected);
//                               },
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.blue,
//                                 minimumSize: const Size.fromHeight(50),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(30),
//                                 ),
//                               ),
//                               child: const Text('Сохранить'),
//                             ),
//                             const SizedBox(height: 8),
//                             TextButton(
//                               onPressed: () => Navigator.of(context).pop(),
//                               child: const Text('Отменить'),
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   );
//                 },
//               );

//               if (result != null) {
//                 Navigator.of(context).pop(result);
//               }
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF007AFF),
//               foregroundColor: Colors.white,
//               minimumSize: const Size.fromHeight(50),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(30),
//               ),
//             ),
//             child: const Text('Изменить статус'),
//           ),
//           const SizedBox(height: 12),
//           ElevatedButton(
//             onPressed: () {},
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFF2F2F2),
//               foregroundColor: Colors.black,
//               minimumSize: const Size.fromHeight(50),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(30),
//               ),
//             ),
//             child: const Text('Печатать талон'), //сделай кноп
//           ),
//           const SizedBox(height: 32),
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoRow(IconData icon, String title, String subtitle) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             margin: const EdgeInsets.only(top: 4),
//             width: 36,
//             height: 36,
//             decoration: const BoxDecoration(
//               color: Color(0xFFF2F2F2),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(icon, size: 20, color: Colors.black54),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(title,
//                     style: const TextStyle(
//                         fontSize: 16, fontWeight: FontWeight.w600)),
//                 const SizedBox(height: 2),
//                 Text(subtitle,
//                     style:
//                         const TextStyle(fontSize: 13, color: Colors.black54)),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   Widget _buildRefusalContent() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           const SizedBox(height: 24),
//           const Text(
//             'Выберите причину отказа и опишите ситуацию при наличии',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 16),
//           GestureDetector(
//             onTap: _showRefusalReasonsModal,
//             child: Container(
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF2F2F2),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               height: 60,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     _selectedReason,
//                     style: const TextStyle(color: Colors.black54, fontSize: 16),
//                   ),
//                   const Icon(Icons.arrow_forward_ios,
//                       size: 16, color: Colors.black54),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 12),
//           Container(
//             decoration: BoxDecoration(
//               color: const Color(0xFFF2F2F2),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             height: 100,
//             alignment: Alignment.topLeft,
//             child: const TextField(
//               maxLines: null,
//               decoration: InputDecoration(
//                 border: InputBorder.none,
//                 hintText: 'Ваш текст',
//                 hintStyle: TextStyle(color: Colors.black45),
//               ),
//               style: TextStyle(fontSize: 16),
//             ),
//           ),
//           const Spacer(),
//           ElevatedButton(
//             onPressed: () {
//               setState(() {
//                 _selectedTabIndex = 1; // Stay on refusal tab
//               });

//               Navigator.of(context).push(
//                 MaterialPageRoute(
//                   builder: (_) => const RefusalSignedPage(),
//                 ),
//               );
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF007AFF),
//               foregroundColor: Colors.white,
//               minimumSize: const Size.fromHeight(50),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(30),
//               ),
//             ),
//             child: const Text('Подписать акт отказа'),
//           ),
//           const SizedBox(height: 12),
//           ElevatedButton(
//             onPressed: () {},
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFF2F2F2),
//               foregroundColor: Colors.black,
//               minimumSize: const Size.fromHeight(50),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(30),
//               ),
//             ),
//             child: const Text('Отменить'),
//           ),
//           const SizedBox(height: 32),
//         ],
//       ),
//     );
//   }

//   void _showRefusalReasonsModal() {
//     final reasons = [
//       'Заболел пассажир',
//       'Семейные обстоятельства',
//       'Изменились планы / смена маршрута',
//       'Пропущен поезд',
//       'Задержка на работе / учёбе',
//       'Утеря документов',
//       'Ошибка при покупке билета',
//       'Другое',
//     ];
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setStateBottom) {
//             return Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: SingleChildScrollView(
//                 padding: EdgeInsets.only(
//                     bottom: MediaQuery.of(context).viewInsets.bottom),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Text(
//                       'Причина отказа',
//                       style:
//                           TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 12),
//                     ...reasons.map((reason) {
//                       return RadioListTile<String>(
//                         value: reason,
//                         groupValue: _selectedReason,
//                         title: Text(
//                           reason,
//                           style: const TextStyle(fontSize: 16),
//                         ),
//                         visualDensity: const VisualDensity(vertical: -2),
//                         contentPadding: EdgeInsets.zero,
//                         dense: true,
//                         onChanged: (value) {
//                           if (value != null) {
//                             setState(() {
//                               _selectedReason = value;
//                             });
//                             setStateBottom(() {});
//                             Navigator.of(context).pop();
//                           }
//                         },
//                       );
//                     }).toList(),
//                     const SizedBox(height: 12),
//                     ElevatedButton(
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF007AFF),
//                         foregroundColor: Colors.white,
//                         minimumSize: const Size.fromHeight(50),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(30),
//                         ),
//                       ),
//                       child: const Text('Выбрать'),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }
