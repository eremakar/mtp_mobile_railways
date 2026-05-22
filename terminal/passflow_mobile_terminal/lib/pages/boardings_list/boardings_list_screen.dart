// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:passflow_app/data/models/boarding_model.dart';
// import 'package:passflow_app/data/models/ticket_model.dart';
// import 'package:passflow_app/pages/boardings_detail/detail_screen.dart';
// import 'package:passflow_app/pages/boardings_list/bloc/list_bloc.dart';
// import 'package:passflow_app/pages/boardings_list/bloc/list_event.dart';
// import 'package:passflow_app/pages/boardings_list/bloc/list_state.dart';
// import 'package:passflow_app/pages/image_constant.dart';

// class BoardingsListScreen extends StatefulWidget {
//   // final TicketsSearchModel ticketsSearchModel;

//   const BoardingsListScreen({Key? key}) : super(key: key);

//   @override
//   State<BoardingsListScreen> createState() => _BoardingsListScreenState();
// }

// class _BoardingsListScreenState extends State<BoardingsListScreen> {
//   int? selectedIndex;
//   TicketModel? selectedTicket;
//   PassengerModel? selectedPassenger;

//   void _openDetailScreen(BuildContext _context) {
//     if (selectedTicket == null || selectedPassenger == null) return;

//     Navigator.of(_context).push(
//       MaterialPageRoute(
//         builder: (context) => BlocProvider.value(
//           value: _context.read<BoardingsListBloc>(), // передаём текущий Bloc!
//           child: BoardingDetailScreen(
//             status: selectedTicket!.boardingPassed ? "Посажен" : "Не посажен",
//             ticketNumber: selectedTicket!.orderNumber,
//             fullName: selectedPassenger!.fullName.replaceAll('=', ' '),
//             documentNumber: selectedPassenger!.identityNumber,
//             departure: selectedTicket!.deparute?.name ?? '',
//             isPostletnoe: false,
//             departureDate: selectedTicket!.departure,
//             arrival: selectedTicket!.arrival?.name ?? '',
//             arrivalDate: '',
//             boardingPassed: selectedTicket!.boardingPassed,
//             onPressed: () => {
//               _context
//                   .read<BoardingsListBloc>()
//                   .add(PressBoardingEvent(selectedTicket!)),
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _onBoardingPressed(BuildContext context) async {
//     if (selectedTicket == null || selectedPassenger == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Пожалуйста, выберите пассажира')),
//       );
//       return;
//     }
//     context.read<BoardingsListBloc>().add(PressBoardingEvent(selectedTicket!));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider<BoardingsListBloc>(
//       create: (_) => BoardingsListBloc()..add(LoadTicketsEvent()),
//       child: BlocListener<BoardingsListBloc, BoardingsState>(
//         listener: (context, state) {
//           if (state is BoardingsListState && state.boardingSuccess != null) {
//             showDialog(
//               context: context,
//               builder: (context) => AlertDialog(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 title: Text(
//                   state.boardingSuccess == true ? 'Успех' : 'Ошибка',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: state.boardingSuccess == true
//                         ? Colors.green
//                         : Colors.red,
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 content: Text(
//                   state.boardingSuccess == true
//                       ? 'Пассажир успешно посажен'
//                       : 'Ошибка при посадке или нет интернета',
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(fontSize: 16),
//                 ),
//                 actions: [
//                   TextButton(
//                     onPressed: () => Navigator.of(context).pop(),
//                     style: TextButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 40, vertical: 12),
//                       backgroundColor: Colors.blueAccent,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: const Text(
//                       'ОК',
//                       style: TextStyle(color: Colors.white, fontSize: 16),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }
//         },
//         child: Builder(builder: (context) {
//           return Scaffold(
//             backgroundColor: Colors.white,
//             appBar: AppBar(
//               backgroundColor: Colors.white,
//               centerTitle: false,
//               leading: Padding(
//                 padding: const EdgeInsets.only(left: 16),
//                 child: IconButton(
//                   icon: SvgPicture.asset(
//                     ImageConstant.arrowLeft,
//                     width: 38,
//                     height: 38,
//                   ),
//                   onPressed: () => Navigator.of(context).pop(),
//                   padding: EdgeInsets.zero,
//                 ),
//               ),
//               title: const Text('Посадки'),
//               actions: [
//                 Padding(
//                   padding: const EdgeInsets.only(right: 16),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       IconButton(
//                         icon: SvgPicture.asset(
//                           ImageConstant.print,
//                           width: 38,
//                           height: 38,
//                         ),
//                         onPressed: () {
//                           showDialog(
//                             context: context,
//                             builder: (context) => AlertDialog(
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               contentPadding:
//                                   const EdgeInsets.fromLTRB(24, 24, 24, 16),
//                               content: const Text(
//                                 'Принтер не подключен',
//                                 style: TextStyle(
//                                     fontSize: 18, color: Colors.black87),
//                                 textAlign: TextAlign.center,
//                               ),
//                               actions: [
//                                 TextButton(
//                                   style: TextButton.styleFrom(
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 40, vertical: 12),
//                                     backgroundColor: Colors.blueAccent,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(12),
//                                     ),
//                                   ),
//                                   onPressed: () => Navigator.of(context).pop(),
//                                   child: const Text(
//                                     'ОК',
//                                     style: TextStyle(
//                                         color: Colors.white, fontSize: 16),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             body: BlocBuilder<BoardingsListBloc, BoardingsState>(
//               buildWhen: (previous, current) {
//                 return current is BoardingsListState;
//               },
//               builder: (context, state) {
//                 if (state is BoardingsListState) {
//                   if (state.isLoading) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//                   if (state.error != null) {
//                     return Center(child: Text('Ошибка: ${state.error}'));
//                   }
//                   return Column(
//                     children: [
//                       // Заголовок таблицы
//                       Padding(
//                         padding: const EdgeInsets.symmetric(),
//                         child: SizedBox(
//                           width: double.infinity,
//                           child: Table(
//                             columnWidths: const {
//                               0: FlexColumnWidth(2.5),
//                               1: FlexColumnWidth(1.4),
//                               2: FlexColumnWidth(1.3),
//                               3: FlexColumnWidth(1.3),
//                             },
//                             defaultVerticalAlignment:
//                                 TableCellVerticalAlignment.middle,
//                             children: [
//                               TableRow(
//                                 decoration:
//                                     BoxDecoration(color: Colors.blue[600]),
//                                 children: [
//                                   _tableHeader('ФИО'),
//                                   _tableHeader('№ док'),
//                                   _tableHeader('Место'),
//                                   _tableHeader('Посадка'),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       Expanded(
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 0),
//                           child: ListView.builder(
//                             physics:
//                                 Theme.of(context).platform == TargetPlatform.iOS
//                                     ? const BouncingScrollPhysics()
//                                     : const ClampingScrollPhysics(),
//                             itemCount: state.tickets.fold<int>(
//                                 0,
//                                 (prev, ticket) =>
//                                     prev + ticket.passengers.length),
//                             itemBuilder: (context, index) {
//                               int runningCount = 0;
//                               TicketModel? currentTicket;
//                               PassengerModel? currentPassenger;

//                               for (final ticket in state.tickets) {
//                                 if (index <
//                                     runningCount + ticket.passengers.length) {
//                                   currentTicket = ticket;
//                                   currentPassenger =
//                                       ticket.passengers[index - runningCount];
//                                   break;
//                                 }
//                                 runningCount += ticket.passengers.length;
//                               }

//                               if (currentTicket == null ||
//                                   currentPassenger == null) {
//                                 return const SizedBox.shrink();
//                               }

//                               bool isSelected = selectedIndex == index;

//                               return GestureDetector(
//                                 onTap: () {
//                                   setState(() {
//                                     selectedIndex = index;
//                                     selectedTicket = currentTicket;
//                                     selectedPassenger = currentPassenger;
//                                   });
//                                 },
//                                 child: Container(
//                                   color: isSelected
//                                       ? Colors.blue.withOpacity(0.3)
//                                       : Colors.white,
//                                   child: Table(
//                                     columnWidths: const {
//                                       0: FlexColumnWidth(2.4),
//                                       1: FlexColumnWidth(1.3),
//                                       2: FlexColumnWidth(1.0),
//                                       3: FlexColumnWidth(1.3),
//                                     },
//                                     defaultVerticalAlignment:
//                                         TableCellVerticalAlignment.middle,
//                                     border: TableBorder.all(
//                                         color: Colors.blue, width: 1.5),
//                                     children: [
//                                       TableRow(
//                                         children: [
//                                           Padding(
//                                             padding: const EdgeInsets.symmetric(
//                                                 horizontal: 8, vertical: 8),
//                                             child: Text(
//                                               currentPassenger.fullName
//                                                   .replaceAll('=', ' '),
//                                               style:
//                                                   const TextStyle(fontSize: 12),
//                                             ),
//                                           ),
//                                           Padding(
//                                             padding: const EdgeInsets.symmetric(
//                                                 horizontal: 8, vertical: 8),
//                                             child: Text(
//                                               currentPassenger.identityNumber
//                                                           .length >
//                                                       6
//                                                   ? currentPassenger
//                                                       .identityNumber
//                                                       .substring(currentPassenger
//                                                               .identityNumber
//                                                               .length -
//                                                           6)
//                                                   : currentPassenger
//                                                       .identityNumber,
//                                               textAlign: TextAlign.center,
//                                               style:
//                                                   const TextStyle(fontSize: 14),
//                                             ),
//                                           ),
//                                           Padding(
//                                             padding: const EdgeInsets.symmetric(
//                                                 horizontal: 8, vertical: 8),
//                                             child: Text(
//                                               int.tryParse(currentTicket
//                                                           .placeNumber)
//                                                       ?.toString() ??
//                                                   '',
//                                               textAlign: TextAlign.center,
//                                               style:
//                                                   const TextStyle(fontSize: 14),
//                                             ),
//                                           ),
//                                           Padding(
//                                             padding: const EdgeInsets.symmetric(
//                                                 horizontal: 8, vertical: 8),
//                                             child: Center(
//                                               child: _StatusIcon(
//                                                 boardingPassed: currentTicket
//                                                     .boardingPassed,
//                                                 documentKind:
//                                                     currentTicket.documentKind,
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.only(
//                             left: 24, right: 24, bottom: 10, top: 8),
//                         child: AnimatedSwitcher(
//                           duration: const Duration(milliseconds: 300),
//                           child: selectedIndex != null
//                               ? Row(
//                                   key: const ValueKey('buttons_visible'),
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceEvenly,
//                                   children: [
//                                     _ActionButton(
//                                         text: 'Подробнее',
//                                         onTap: () =>
//                                             _openDetailScreen(context)),
//                                     _ActionButton(
//                                         text: 'Посадка',
//                                         onTap: () =>
//                                             _onBoardingPressed(context)),
//                                   ],
//                                 )
//                               : const SizedBox.shrink(
//                                   key: ValueKey('buttons_hidden')),
//                         ),
//                       ),
//                     ],
//                   );
//                 } else {
//                   return const SizedBox.expand();
//                 }
//               },
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }

// Widget _tableHeader(String text) => Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       child: Text(
//         text,
//         style: const TextStyle(
//           fontWeight: FontWeight.bold,
//           color: Colors.white,
//           fontSize: 14,
//         ),
//         textAlign: TextAlign.center,
//       ),
//     );

// class _StatusIcon extends StatelessWidget {
//   final bool boardingPassed;
//   final String documentKind;

//   const _StatusIcon({required this.boardingPassed, required this.documentKind});

//   @override
//   Widget build(BuildContext context) {
//     if (boardingPassed) {
//       return SvgPicture.asset(
//         ImageConstant.done,
//         width: 25,
//         height: 25,
//       );
//     } else if (documentKind == 'ДЕТСКИЙ') {
//       return SvgPicture.asset(
//         ImageConstant.kid,
//         width: 25,
//         height: 25,
//       );
//     } else {
//       return SvgPicture.asset(
//         ImageConstant.man,
//         width: 38,
//         height: 38,
//       );
//     }
//   }
// }

// class _ActionButton extends StatelessWidget {
//   final String text;
//   final VoidCallback onTap;

//   const _ActionButton({required this.text, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: onTap,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: const Color.fromARGB(255, 33, 150, 243),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         elevation: 6,
//         shadowColor: const Color(0x22466DFF),
//       ),
//       child: Text(
//         text,
//         style: const TextStyle(
//           fontSize: 18,
//           fontWeight: FontWeight.bold,
//           color: Colors.white,
//         ),
//       ),
//     );
//   }
// }
