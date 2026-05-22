// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:passflow_app/widgets/page/ticketDetail.dart';

// class PassengerBoardingPage extends StatefulWidget {
//   const PassengerBoardingPage({Key? key}) : super(key: key);

//   @override
//   State<PassengerBoardingPage> createState() => _PassengerBoardingPageState();
// }

// class _PassengerBoardingPageState extends State<PassengerBoardingPage> {
//   int selectedTab = 0;
//   final List<Map<String, String>> passengers = [
//     {'name': 'Жумиров Бексултан Аманбекович', 'doc': '012342988', 'seat': '1'},
//     {'name': 'Аманбаева Гульмира Аскарбековна', 'doc': '563123856', 'seat': '2'},
//     {'name': 'Крыкбаев Кайрат Жумабекович', 'doc': '000236966', 'seat': '3'},
//     {'name': 'Байкуатова Асель Кайратовна', 'doc': '568966332', 'seat': '4'},
//     {'name': 'Бектемиров Канат Оразбекович', 'doc': '789654123', 'seat': '5'},
//     {'name': 'Маралбаева Жанна Идрисовна', 'doc': '558999777', 'seat': '6'},
//     {'name': 'Алиутова Динара Аманжоловна', 'doc': '456951753', 'seat': '7'},
//     {'name': 'Адамова Лидия Евгеньевна', 'doc': '666533988', 'seat': '8'},
//   ];

//   Widget buildSearchField() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: TextField(
//         decoration: InputDecoration(
//           hintText: 'Введите № документа или ФИО',
//           prefixIcon: const Icon(Icons.search),
//           filled: true,
//           fillColor: Colors.grey[200],
//           contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide.none,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildPassengerCard(Map<String, String> passenger) {
//     final seatNumber = passenger['seat']!;
//     final gender = (seatNumber == '1' || seatNumber == '3' || seatNumber == '5') ? 'муж' : 'жен';
//     final isChild = int.tryParse(seatNumber) != null && int.parse(seatNumber) >= 4;

//     Color borderColor;
//     switch (passenger['status']) {
//       case 'Посадка':
//         borderColor = Colors.green;
//         break;
//       case 'Отказ':
//         borderColor = Colors.red;
//         break;
//       case 'Высадка':
//         borderColor = Colors.orange;
//         break;
//       default:
//         borderColor = Colors.blue.shade600;
//     }

//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: borderColor, width: 2),
//       ),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(14),
//         onTap: () async {
//           final selectedStatus = await Navigator.push(context, MaterialPageRoute(builder: (_) => const TicketDetailScreen()));
//           if (selectedStatus != null) {
//             setState(() {
//               passenger['status'] = selectedStatus;
//             });
//           }
//         },
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//              SvgPicture.asset('assets/svg_icons/card.svg', width: 16, height: 16, colorFilter: const ColorFilter.mode(Colors.blue, BlendMode.srcIn)),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(passenger['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//                     const SizedBox(height: 4),
//                     Row(
//                       children: [
//                         Text(passenger['doc']!, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
//                         const SizedBox(width: 12),
//                         SvgPicture.asset('assets/svg_icons/place.svg', width: 16, height: 16, colorFilter: const ColorFilter.mode(Colors.blue, BlendMode.srcIn)),
//                         const SizedBox(width: 4),
//                         Text(seatNumber, style: const TextStyle(fontSize: 13)),
//                         const SizedBox(width: 12),
//                         SvgPicture.asset(
//                           gender == 'муж'
//                               ? 'assets/svg_icons/man.svg'
//                               : 'assets/svg_icons/woman.svg',
//                           width: 16,
//                           height: 16,
//                           colorFilter: const ColorFilter.mode(Colors.blue, BlendMode.srcIn),
//                         ),
//                         const SizedBox(width: 4),
//                         Text(gender, style: const TextStyle(fontSize: 13)),
//                         if (isChild) ...[
//                           const SizedBox(width: 8),
//                           SvgPicture.asset('assets/svg_icons/kid.svg', width: 16, height: 16, colorFilter: const ColorFilter.mode(Colors.blue, BlendMode.srcIn)),
//                         ],
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               CircleAvatar(
//                 radius: 14,
//                 backgroundColor: Colors.blue.shade600,
//                 child: Text(seatNumber, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }


//   Widget buildTabButton(int index, String label, {Color? iconColor}) {
//     final isSelected = selectedTab == index;
//     return GestureDetector(
//       onTap: () => setState(() => selectedTab = index),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//         decoration: BoxDecoration(
//           color: isSelected ? Colors.blue : Colors.grey.shade100,
//           borderRadius: BorderRadius.circular(24),
//         ),
//         child: Row(
//           children: [
//             if (index != 0)
//               Container(
//                 width: 14,
//                 height: 14,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: isSelected ? (iconColor ?? Colors.blue) : Colors.grey.shade300,
//                 ),
//               ),
//             if (index != 0) const SizedBox(width: 6),
//             Text(
//               label,
//               style: TextStyle(
//                 color: index == 0 ? const Color(0xFF4D4D4D) : Colors.black,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final filteredList = passengers;
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0.6,
//         title: const Text('Посадка пассажиров', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh, color: Colors.black87),
//             onPressed: () {},
//           ),
//         ],
//         iconTheme: const IconThemeData(color: Colors.black),
//       ),
//       body: Column(
//         children: [
//           const SizedBox(height: 8),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             child: Row(
//               children: [
//                 buildTabButton(0, 'Все (44)'),
//                 const SizedBox(width: 8),
//                 buildTabButton(1, 'Не посажены (44)', iconColor: Colors.blue),
//                 const SizedBox(width: 8),
//                 buildTabButton(2, 'Посажены (0)', iconColor: Colors.green),
//               ],
//             ),
//           ),
//           buildSearchField(),
//           Expanded(
//             child: filteredList.isEmpty
//                 ? const Center(child: Text('Нет данных'))
//                 : ListView.builder(
//                     itemCount: filteredList.length,
//                     itemBuilder: (context, index) => buildPassengerCard(filteredList[index]),
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }
