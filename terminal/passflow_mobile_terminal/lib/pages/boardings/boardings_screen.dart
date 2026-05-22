// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:passflow_app/data/models/boarding_model.dart';
// import 'package:passflow_app/data/models/name_id.pair_model.dart';
// import 'package:passflow_app/pages/boardings/bloc/boardings_bloc.dart';
// import 'package:passflow_app/pages/boardings/bloc/boardings_event.dart';
// import 'package:passflow_app/pages/boardings/bloc/boardings_state.dart';
// import 'package:passflow_app/pages/boardings_list/boardings_list_screen.dart';
// import 'package:passflow_app/pages/image_constant.dart';
// import 'package:passflow_app/widgets/page/passenger.dart';

// class BoardingScreen extends StatefulWidget {
//   final num routeSheetId;
//   const BoardingScreen({Key? key, required this.routeSheetId})
//       : super(key: key);

//   @override
//   State<BoardingScreen> createState() => _BoardingScreenState();
// }

// class _BoardingScreenState extends State<BoardingScreen> {
//   late final TextEditingController _controller;
//   @override
//   void initState() {
//     super.initState();
//     _controller = TextEditingController();
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//   }

//   String formatDate(String dateString) {
//     try {
//       final date = DateTime.parse(dateString);
//       return '${date.day.toString().padLeft(2, '0')}.'
//           '${date.month.toString().padLeft(2, '0')}.'
//           '${date.year}';
//     } catch (_) {
//       return dateString;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider<BoardingBloc>(
//         create: (_) => BoardingBloc()
//           ..add(LoadInitialData(routeSheetId: widget.routeSheetId)),
//         child: Builder(builder: (context) {
//           return Scaffold(
//             backgroundColor: Colors.white,
//             appBar: AppBar(
//               automaticallyImplyLeading: false,
//               centerTitle: false,
//               title: const Text('Посадки',
//                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
//               actions: [
//                 Stack(
//                   children: [
//                     IconButton(
//                       icon: SvgPicture.asset(
//                         ImageConstant.refresh,
//                         width: 38,
//                         height: 38,
//                       ),
//                       onPressed: () {
//                         context.read<BoardingBloc>().add(
//                             LoadInitialData(routeSheetId: widget.routeSheetId));
//                       },
//                     ),
//                     const Positioned(
//                       right: 6,
//                       top: 8,
//                       child: CircleAvatar(
//                         radius: 10,
//                         backgroundColor: Colors.red,
//                         child: Text('!',
//                             style:
//                                 TextStyle(color: Colors.white, fontSize: 16)),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//               backgroundColor: Colors.white,
//               elevation: 0,
//               foregroundColor: Colors.black,
//             ),
//             body: Padding(
//               padding: const EdgeInsets.all(24.0),
//               child: BlocBuilder<BoardingBloc, BoardingState>(
//                 builder: (context, state) {
//                   _controller.text = state.date != null
//                       ? formatDate(state.date!)
//                       : 'Дата не выбрана';
//                   return ListView(
//                     children: [
//                       _buildLabel('N поезда'),
//                       _buildDropdown(
//                         value: state.train,
//                         hint: 'Выберите поезд',
//                         items: state.trains,
//                         onChanged: (value) {
//                           if (value != null) {
//                             context
//                                 .read<BoardingBloc>()
//                                 .add(TrainChanged(value));
//                           }
//                         },
//                       ),
//                       const SizedBox(height: 28),
//                       _buildLabel('Дата отправления'),
//                       TextFormField(
//                         enabled: false,
//                         controller: _controller,
//                         decoration: InputDecoration(
//                           contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 16, vertical: 12),
//                           filled: true,
//                           fillColor: const Color(0xFFF9FAFB),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 28),
//                       _buildLabel('Номер вагона'),
//                       _buildDropdown(
//                         value: state.car,
//                         hint: 'Выберите вагон',
//                         items: state.cars,
//                         onChanged: (value) {
//                           if (value != null) {
//                             context.read<BoardingBloc>().add(CarChanged(value));
//                           }
//                         },
//                       ),
//                       const SizedBox(height: 28),
//                       _buildLabel('Станция посадки'),
//                       _buildDropdownStation(
//                         value: state.station,
//                         hint: 'Выберите станцию',
//                         items: state.stations,
//                         onChanged: (value) {
//                           if (value != null) {
//                             context
//                                 .read<BoardingBloc>()
//                                 .add(StationChanged(value));
//                           }
//                         },
//                       ),
//                       const SizedBox(height: 40),
//                       Align(
//                         alignment: Alignment.centerRight,
//                         child: ElevatedButton(
//                           onPressed: (state.train != null &&
//                                   state.car != null &&
//                                   state.date != null &&
//                                   state.station != null)
//                               ? () {
//                                   // Navigator.of(context).push(
//                                   //   MaterialPageRoute(
//                                   //     builder: (_) => PassengerBoardingPage(
//                                   //   ), ),
//                                   // );
                                  
                                  
//                                 }
//                               : null, // <- если хотя бы одно пустое, кнопка будет disabled
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFF466DFF),
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 23, vertical: 12),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             elevation: 6,
//                             shadowColor: const Color(0x22466DFF),
//                           ),
//                           child: state.isLoading
//                               ? const SizedBox(
//                                   width: 20,
//                                   height: 20,
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 2,
//                                     valueColor: AlwaysStoppedAnimation<Color>(
//                                         Colors.white),
//                                   ),
//                                 )
//                               : const Text(
//                                   'Выбрать',
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                         ),
//                       ),
//                     ],
//                   );
//                 },
//               ),
//             ),
//           );
//         }));
//   }

//   Widget _buildLabel(String text) => Padding(
//         padding: const EdgeInsets.only(bottom: 8.0),
//         child: Text(text,
//             style: const TextStyle(
//               fontWeight: FontWeight.w500,
//               fontSize: 18,
//               color: Color(0xFF232323),
//             )),
//       );

//   Widget _buildDropdown({
//     String? value,
//     required String hint,
//     required List<String> items,
//     required ValueChanged<String?> onChanged,
//   }) {
//     final effectiveValue = items.contains(value) ? value : null;

//     return DropdownButtonFormField<String>(
//       value: effectiveValue,
//       hint: Text(hint, style: TextStyle(color: Colors.grey[400])),
//       isExpanded: true,
//       icon: const Icon(Icons.keyboard_arrow_down),
//       decoration: InputDecoration(
//         contentPadding:
//             const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         filled: true,
//         fillColor: const Color(0xFFF9FAFB),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide(color: Colors.grey[300]!),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(color: Colors.blueAccent, width: 1),
//         ),
//       ),
//       items: items
//           .map((item) => DropdownMenuItem(value: item, child: Text(item)))
//           .toList(),
//       onChanged: onChanged,
//     );
//   }

//   Widget _buildDropdownStation({
//     NameIdPairModel? value,
//     required String hint,
//     required List<NameIdPairModel> items,
//     required ValueChanged<NameIdPairModel?> onChanged,
//   }) {
//     final effectiveValue = items.contains(value) ? value : null;

//     return DropdownButtonFormField<NameIdPairModel>(
//       value: effectiveValue,
//       hint: Text(hint, style: TextStyle(color: Colors.grey[400])),
//       isExpanded: true,
//       icon: const Icon(Icons.keyboard_arrow_down),
//       decoration: InputDecoration(
//         contentPadding:
//             const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         filled: true,
//         fillColor: const Color(0xFFF9FAFB),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide(color: Colors.grey[300]!),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(color: Colors.blueAccent, width: 1),
//         ),
//       ),
//       items: items.map(
//         (item) {
//           return DropdownMenuItem<NameIdPairModel>(
//             value: item,
//             child: Text(item.name),
//           );
//         },
//       ).toList(),
//       onChanged: onChanged,
//     );
//   }
// }
