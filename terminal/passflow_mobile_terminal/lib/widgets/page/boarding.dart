// import 'package:passflow_app/pages/boardings_list/widgets/passenger_action.dart';
// import 'package:passflow_app/pages/image_constant.dart';
// import 'package:passflow_app/widgets/page/boarding_move.dart';
// import 'package:passflow_app/widgets/page/filtert_breakdown.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:passflow_app/widgets/page/boarding_select_breakdown.dart';
// import 'package:passflow_app/widgets/page/disembark_signed_page.dart';
// import 'package:passflow_app/pages/boardings_detail/detail_screen.dart';
// import 'package:passflow_app/widgets/page/ticket_detail.dart';

// class BoardingPassengersPage extends StatefulWidget {
//   final Future<List<Map<String, dynamic>>> Function(
//       Map<String, dynamic> filter)? loadData;
//   const BoardingPassengersPage({Key? key, this.loadData}) : super(key: key);

//   @override
//   State<BoardingPassengersPage> createState() => _BoardingPassengersPageState();
// }

// class _BoardingPassengersPageState extends State<BoardingPassengersPage> {
//   Future<void> _showPassengerActionSheet(Map<String, dynamic> passenger) async {
//     final result = await showModalBottomSheet<Map<String, dynamic>>(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (_) {
//         return PassengerActionPage(
//           title: (passenger['name'] ?? '').toString(),
//           passenger: passenger,
//           onCancel: () => Navigator.of(context).pop(),
//         );
//       },
//     );

//     if (result == null) return; // пользователь закрыл модалку

//     // Достаём action; мутируем исходную карту из списка
//     final dynamic actionDyn = result['action'];
//     final Map<String, dynamic> p =
//         passenger; // важно: не создавать новый Map, иначе UI не обновится

//     // Определяем выбранную операцию; поддержим enum и строки
//     final String s = actionDyn?.toString().toLowerCase() ?? '';
//     final bool isBoarding = (actionDyn == PassengerAction.boarding) ||
//         s.contains('board') ||
//         s.contains('посад');
//     final bool isDisembark = (actionDyn == PassengerAction.disembark) ||
//         s.contains('disembark') ||
//         s.contains('высад');
//     final bool isRefuse = (actionDyn == PassengerAction.refuse) ||
//         s.contains('refus') ||
//         s.contains('отказ');

//     if (isDisembark) {
//       final Map<String, dynamic> p = passenger;

//       setState(() {
//         p['action'] = actionDyn;
//         // make state mutually exclusive
//         p['boarded'] = false;
//         p['refused'] = false;
//         p['disembarked'] = true;
//         tab = 4; // вкладка "Высадки"
//       });

//       final String fullName = (p['name'] ?? '').toString();
//       if (!mounted) return;

//       // Открываем сразу общий экран с табами, на вкладке «Высадка»
//       final String documentNumber =
//           (p['doc'] ?? p['docNumber'] ?? p['iin'] ?? '').toString();
//       final String wagon = (p['wagon'] ?? '').toString();
//       final String seat = (p['seat'] ?? '').toString();
//       final String station = (p['station'] ?? '').toString();
//       final bool isPostletnoe = (p['hasChild'] ?? false) == true;

//       final String ticketNumber =
//           '${wagon.isEmpty ? '00' : wagon}-${seat.isEmpty ? '0' : seat}-${documentNumber.isEmpty ? '000000' : documentNumber}';
//       final String departure = 'Алматы-1';
//       final String departureDate = '16.07.2025 - 20:20';
//       final String arrival = station.isEmpty ? '—' : station;
//       final String arrivalDate = '17.07.2025 - 13:10';

//       // Navigator.push(
//       //   context,
//       //   MaterialPageRoute(
//       //     builder: (_) => TicketDetailScreen(
//       //       initialTabIndex:
//       //           2, // сразу вкладка «Высадка» с embedded DisembarkSignedPage
//       //       passengerName: fullName,
//       //       ticketNumber: ticketNumber,
//       //       seat: seat,
//       //       documentNumber: documentNumber,
//       //       departureStation: departure,
//       //       arrivalStation: arrival,
//       //       departureDateTime: departureDate,
//       //       arrivalDateTime: arrivalDate,
//       //       status: 'Высажен',
//       //       bedding: isPostletnoe ? 'Да' : 'Нет',
//       //       // индивидуальный кейс: считаем на одного пассажира
//       //       ticketsCount: 1,
//       //       refusedCount: 0,
//       //       disembarkedCount: 1,
//       //       boarding: p,
//       //     ),
//       //   ),
//       // );
//       return;
//     }

//     if (isRefuse) {
//       // ▶️ При отказе открываем TicketDetailScreen с данными из boarding
//       final String fullName = (p['name'] ?? '').toString();
//       final String documentNumber =
//           (p['doc'] ?? p['docNumber'] ?? p['iin'] ?? '').toString();
//       final String wagon = (p['wagon'] ?? '').toString();
//       final String seat = (p['seat'] ?? '').toString();
//       final String station = (p['station'] ?? '').toString();
//       final bool isPostletnoe = (p['hasChild'] ?? false) == true;

//       setState(() {
//         p['action'] = actionDyn;
//         // make state mutually exclusive
//         p['boarded'] = false;
//         p['disembarked'] = false;
//         p['refused'] = true;
//         tab = 3; // переключаемся на вкладку "Отказы"
//       });

//       final String ticketNumber =
//           '${wagon.isEmpty ? '00' : wagon}-${seat.isEmpty ? '0' : seat}-${documentNumber.isEmpty ? '000000' : documentNumber}';
//       final String departure = 'Алматы-1';
//       final String departureDate = '16.07.2025 - 20:20';
//       final String arrival = station.isEmpty ? '—' : station;
//       final String arrivalDate = '17.07.2025 - 13:10';

//       if (!mounted) return;
//       // Navigator.push(
//       //   context,
//       //   MaterialPageRoute(
//       //     builder: (_) => TicketDetailScreen(
//       //       initialTabIndex: 1,
//       //       passengerName: fullName,
//       //       ticketNumber: ticketNumber,
//       //       seat: seat,
//       //       documentNumber: documentNumber,
//       //       departureStation: departure,
//       //       arrivalStation: arrival,
//       //       departureDateTime: departureDate,
//       //       arrivalDateTime: arrivalDate,
//       //       status: 'Отказ',
//       //       bedding: isPostletnoe ? 'Да' : 'Нет',
//       //     ),
//       //   ),
//       // );
//       return;
//     }

//     if (!isBoarding) {
//       // для высадки/других действий пока ничего не меняем
//       return;
//     }

//     // ✅ Сохраняем выбор: помечаем пассажира как посаженного и переключаемся на вкладку "Посажены"
//     setState(() {
//       p['action'] =
//           actionDyn; // может быть enum или строка — сохраняем как есть
//       // make state mutually exclusive
//       p['refused'] = false;
//       p['disembarked'] = false;
//       p['boarded'] = true; // явный флаг для отрисовки
//       tab = 2; // переключаемся на вкладку "Посажены"
//     });

//     // Формируем данные индивидуально для каждого пассажира
//     final String fullName = (p['name'] ?? '').toString();
//     final String documentNumber =
//         (p['doc'] ?? p['docNumber'] ?? p['iin'] ?? '').toString();
//     final String wagon = (p['wagon'] ?? '').toString();
//     final String seat = (p['seat'] ?? '').toString();
//     final String station = (p['station'] ?? '').toString();
//     final bool isPostletnoe = (p['hasChild'] ?? false) == true;

//     final String ticketNumber =
//         '${wagon.isEmpty ? '00' : wagon}-${seat.isEmpty ? '0' : seat}-${documentNumber.isEmpty ? '000000' : documentNumber}';
//     final String departure = 'Алматы-1';
//     final String departureDate = '16.07.2025 - 20:20';
//     final String arrival = station.isEmpty ? '—' : station;
//     final String arrivalDate = '17.07.2025 - 13:10';

//     if (!mounted) return;
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => BoardingDetailScreen(
//           status: 'Посажен',
//           ticketNumber: ticketNumber,
//           fullName: fullName,
//           documentNumber: documentNumber,
//           departure: departure,
//           isPostletnoe: isPostletnoe,
//           departureDate: departureDate,
//           arrival: arrival,
//           arrivalDate: arrivalDate,
//           boardingPassed: true,
//           onPressed: () {},
//         ),
//       ),
//     );
//   }

//   final TextEditingController _searchController = TextEditingController();

//   // Хранит выбранные фильтры (например, список вагонов, выбранная станция)
//   Map<String, dynamic> _currentFilter = {};

//   // Пример данных пассажиров
//   final List<Map<String, dynamic>> _allPassengers = [
//     {
//       'name': 'Жумиров Бексултан',
//       'wagon': '07',
//       'station': 'Чамалган',
//       'doc': '012342988',
//       'cart': 1,
//       'seat': 1,
//       'gender': 'муж',
//       'hasChild': false,
//     },
//     {
//       'name': 'Аманбаева Гульмира',
//       'wagon': '05',
//       'station': 'Чамалган',
//       'doc': '563123856',
//       'cart': 2,
//       'seat': 2,
//       'gender': 'жен',
//       'hasChild': false,
//     },
//     {
//       'name': 'Иванов Иван',
//       'wagon': '02',
//       'station': 'Алматы',
//       'doc': '666552344',
//       'cart': 3,
//       'seat': 3,
//       'gender': 'муж',
//       'hasChild': true,
//       'childCount': 1,
//     },

//     // Дополнительно — больше пассажиров для станции Чамалган
//     {
//       'name': 'Сарипаева Айнура',
//       'wagon': '03',
//       'station': 'Чамалган',
//       'doc': '701234567',
//       'cart': 1,
//       'seat': 4,
//       'gender': 'жен',
//       'hasChild': true,
//       'childCount': 2,
//     },
//     {
//       'name': 'Тлеуханов Нурсултан',
//       'wagon': '07',
//       'station': 'Чамалган',
//       'doc': '701111222',
//       'cart': 0,
//       'seat': 5,
//       'gender': 'муж',
//       'hasChild': false,
//     },
//     {
//       'name': 'Жаксылыкова Дана',
//       'wagon': '05',
//       'station': 'Чамалган',
//       'doc': '709876543',
//       'cart': 1,
//       'seat': 6,
//       'gender': 'жен',
//       'hasChild': false,
//     },
//     {
//       'name': 'Ахметов Рустем',
//       'wagon': '04',
//       'station': 'Чамалган',
//       'doc': '700456789',
//       'cart': 2,
//       'seat': 7,
//       'gender': 'муж',
//       'hasChild': true,
//       'childCount': 1,
//     },
//     {
//       'name': 'Калыкова Айгерим',
//       'wagon': '01',
//       'station': 'Чамалган',
//       'doc': '708765432',
//       'cart': 1,
//       'seat': 8,
//       'gender': 'жен',
//       'hasChild': false,
//     },
//     {
//       'name': 'Муратов Данияр',
//       'wagon': '06',
//       'station': 'Чамалган',
//       'doc': '707654321',
//       'cart': 3,
//       'seat': 9,
//       'gender': 'муж',
//       'hasChild': false,
//     },
//     {
//       'name': 'Токтаганова Асия',
//       'wagon': '03',
//       'station': 'Чамалган',
//       'doc': '706543210',
//       'cart': 2,
//       'seat': 10,
//       'gender': 'жен',
//       'hasChild': true,
//       'childCount': 1,
//     },
//     {
//       'name': 'Ермекбаев Олжас',
//       'wagon': '02',
//       'station': 'Чамалган',
//       'doc': '705432109',
//       'cart': 1,
//       'seat': 11,
//       'gender': 'муж',
//       'hasChild': false,
//     },
//     {
//       'name': 'Саятова Назгуль',
//       'wagon': '05',
//       'station': 'Чамалган',
//       'doc': '704321098',
//       'cart': 0,
//       'seat': 12,
//       'gender': 'жен',
//       'hasChild': false,
//     },
//     {
//       'name': 'Умаров Тимур',
//       'wagon': '07',
//       'station': 'Чамалган',
//       'doc': '703210987',
//       'cart': 2,
//       'seat': 13,
//       'gender': 'муж',
//       'hasChild': true,
//       'childCount': 2,
//     },
//     {
//       'name': 'Алиева Аружан',
//       'wagon': '01',
//       'station': 'Чамалган',
//       'doc': '702109876',
//       'cart': 1,
//       'seat': 14,
//       'gender': 'жен',
//       'hasChild': false,
//     },
//   ];

//   List<Map<String, dynamic>> _loadedPassengers = [];
//   bool _isLoading = false;
//   String? _error;
//   int tab = 0; // 0: Все, 1: Не посажены, 2: Посажены, 3: Отказы, 4: Высадки

//   List<Map<String, dynamic>> get _filteredPassengers {
//     // если фильтр пуст, показываем пустой экран с подсказкой (как и было)
//     if (_currentFilter.isEmpty) return [];

//     final source =
//         _loadedPassengers.isNotEmpty ? _loadedPassengers : _allPassengers;

//     final selectedWagons = _currentFilter['wagons'] as List<String>? ?? [];
//     final selectedStation = _currentFilter['station'] as String? ?? '';
//     final q = _searchController.text.trim().toLowerCase();

//     return source.where((passenger) {
//       final wagonMatch =
//           selectedWagons.isEmpty || selectedWagons.contains(passenger['wagon']);
//       final stationMatch =
//           selectedStation.isEmpty || selectedStation == passenger['station'];
//       final searchMatch = q.isEmpty ||
//           (passenger['name']?.toString().toLowerCase().contains(q) ?? false) ||
//           (passenger['doc']?.toString().toLowerCase().contains(q) ?? false) ||
//           (passenger['docNumber']?.toString().toLowerCase().contains(q) ??
//               false) ||
//           (passenger['iin']?.toString().toLowerCase().contains(q) ?? false);
//       return wagonMatch && stationMatch && searchMatch;
//     }).toList();
//   }

//   Future<void> _applyFilterAndLoad(Map<String, dynamic> filter) async {
//     if (widget.loadData == null) {
//       // Если лоадер не передан — оставляем демо-данные
//       setState(() {
//         _loadedPassengers = _allPassengers;
//         _isLoading = false;
//         _error = null;
//       });
//       return;
//     }
//     setState(() {
//       _isLoading = true;
//       _error = null;
//     });
//     try {
//       final data = await widget.loadData!.call(filter);
//       setState(() {
//         _loadedPassengers = data;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//         _error = e.toString();
//       });
//     }
//   }

//   void _onFilterPressed() async {
//     // final result = await showModalBottomSheet<Map<String, dynamic>>(
//     //   context: context,
//     //   isScrollControlled: true,
//     //   backgroundColor: Colors.transparent,
//     //   builder: (context) => const FilterModalContent(),
//     // );

//     // if (result != null) {
//     //   setState(() {
//     //     _currentFilter = result;
//     //   });
//     //   await _applyFilterAndLoad(result);
//     // }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Dynamic counts based on actual passenger state
//     final List<Map<String, dynamic>> _src = _filteredPassengers;
//     final int boardedCount = _src.where((p) {
//       final a = p['action'];
//       return p['boarded'] == true ||
//           a == PassengerAction.boarding ||
//           (a?.toString().toLowerCase().contains('board') ?? false) ||
//           (a?.toString().toLowerCase().contains('посад') ?? false);
//     }).length;
//     final int notBoardedCount =
//         _src.where((p) => !(p['boarded'] == true)).length;
//     final int refusedCount = _src.where((p) {
//       final a = p['action'];
//       return p['refused'] == true ||
//           a == PassengerAction.refuse ||
//           (a?.toString().toLowerCase().contains('refus') ?? false) ||
//           (a?.toString().toLowerCase().contains('отказ') ?? false);
//     }).length;
//     final int disembarkedCount = _src.where((p) {
//       final a = p['action'];
//       return p['disembarked'] == true ||
//           a == PassengerAction.disembark ||
//           (a?.toString().toLowerCase().contains('disembark') ?? false) ||
//           (a?.toString().toLowerCase().contains('высад') ?? false);
//     }).length;
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text(
//           'Посадка пассажиров',
//           style: TextStyle(fontWeight: FontWeight.w400, fontSize: 20),
//         ),
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         actions: [
//           IconButton(
//             icon: SvgPicture.asset(
//               'assets/svg_icons/refresh.svg',
//               width: 24,
//               height: 24,
//             ),
//             onPressed: () {},
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: SizedBox(
//                     height: 44,
//                     child: TextField(
//                       controller: _searchController,
//                       onChanged: (_) => setState(() {}),
//                       decoration: InputDecoration(
//                         hintText: 'Поиск',
//                         prefixIcon: const Icon(Icons.search),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide.none,
//                         ),
//                         fillColor: const Color(0xFFF0F2F4),
//                         filled: true,
//                         contentPadding:
//                             const EdgeInsets.symmetric(vertical: 12),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 SizedBox(
//                   height: 42,
//                   child: ElevatedButton(
//                     onPressed: _onFilterPressed,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF0864D4),
//                       foregroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       padding: const EdgeInsets.symmetric(horizontal: 20),
//                     ),
//                     child: const Text(
//                       'Фильтр',
//                       style:
//                           TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 10),
//             if (_currentFilter.isNotEmpty) ...[
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: Wrap(
//                   spacing: 5, // чуть меньше горизонтальный отступб
//                   runSpacing: 5,
//                   crossAxisAlignment: WrapCrossAlignment.end,
//                   children: [
//                     if (_currentFilter['wagons'] != null &&
//                         (_currentFilter['wagons'] as List).isNotEmpty)
//                       ...(_currentFilter['wagons'] as List<String>).map(
//                         (wagon) => tag(
//                             text: '# Вагон: №$wagon',
//                             onTap: () {
//                               setState(() {
//                                 (_currentFilter['wagons'] as List)
//                                     .remove(wagon);
//                                 if ((_currentFilter['wagons'] as List)
//                                     .isEmpty) {
//                                   _currentFilter.remove('wagons');
//                                 }
//                               });
//                             }),
//                       ),
//                     if (_currentFilter['station'] != null &&
//                         (_currentFilter['station'] as String).isNotEmpty)
//                       tag(
//                           text: '# Станция: ${_currentFilter['station']}',
//                           onTap: () {
//                             setState(() {
//                               _currentFilter.remove('station');
//                             });
//                           })
//                   ],
//                 ),
//               ),
//             ],
//             if (_currentFilter.isNotEmpty) ...[
//               const SizedBox(height: 15),
//               // Segmented tabs (one row like previous screen)
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 0),
//                 child: SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   child: Row(
//                     children: [
//                       _seg(0, 'Все', _filteredPassengers.length,
//                           color: const Color(0xFF0864D4)),
//                       const SizedBox(width: 10),
//                       _seg(1, 'Не посажены', notBoardedCount,
//                           color: const Color(0xFF0864D4)),
//                       const SizedBox(width: 10),
//                       _seg(2, 'Посажены', boardedCount,
//                           color: const Color(0xFF2DB566)),
//                       const SizedBox(width: 10),
//                       _seg(3, 'Отказы', refusedCount,
//                           color: const Color(0xFFF59E0B)),
//                       const SizedBox(width: 10),
//                       _seg(4, 'Высадки', disembarkedCount,
//                           color: const Color(0xFFEF4444)),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 15),
//             ],
//             if (_currentFilter.isEmpty)
//               Expanded(
//                 child: Center(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       CircleAvatar(
//                         radius: 42,
//                         backgroundColor: const Color(0xFFF0F2F4),
//                         child: SvgPicture.asset(
//                           'assets/svg_icons/filter.svg',
//                           width: 28,
//                           height: 28,
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       const Text(
//                         'Выберите в фильтре параметры для\n посадки',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontWeight: FontWeight.w400,
//                           fontSize: 14,
//                           color: Color(0xFF6B7280),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               )
//             else if (_isLoading)
//               const Expanded(
//                 child: Center(child: CircularProgressIndicator()),
//               )
//             else if (_error != null)
//               Expanded(
//                 child: Center(
//                   child: Text(
//                     _error!,
//                     style: const TextStyle(color: Colors.red),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               )
//             else
//               Expanded(
//                 child: _filteredPassengers.isEmpty
//                     ? const Center(
//                         child: Text('Нет данных по выбранному фильтру'),
//                       )
//                     : ListView.separated(
//                         itemCount: (() {
//                           final base = _filteredPassengers;
//                           if (tab == 1) {
//                             return base
//                                 .where((p) => p['boarded'] != true)
//                                 .length;
//                           } else if (tab == 2) {
//                             return base
//                                 .where((p) =>
//                                     p['boarded'] == true ||
//                                     (p['action'] == PassengerAction.boarding) ||
//                                     (p['action']
//                                             ?.toString()
//                                             .toLowerCase()
//                                             .contains('board') ??
//                                         false) ||
//                                     (p['action']
//                                             ?.toString()
//                                             .toLowerCase()
//                                             .contains('посад') ??
//                                         false))
//                                 .length;
//                           } else if (tab == 3) {
//                             return base.where((p) {
//                               final a = p['action'];
//                               return p['refused'] == true ||
//                                   a == PassengerAction.refuse ||
//                                   (a
//                                           ?.toString()
//                                           .toLowerCase()
//                                           .contains('refus') ??
//                                       false) ||
//                                   (a
//                                           ?.toString()
//                                           .toLowerCase()
//                                           .contains('отказ') ??
//                                       false);
//                             }).length;
//                           } else if (tab == 4) {
//                             return base.where((p) {
//                               final a = p['action'];
//                               return p['disembarked'] == true ||
//                                   a == PassengerAction.disembark ||
//                                   (a
//                                           ?.toString()
//                                           .toLowerCase()
//                                           .contains('disembark') ??
//                                       false) ||
//                                   (a
//                                           ?.toString()
//                                           .toLowerCase()
//                                           .contains('высад') ??
//                                       false);
//                             }).length;
//                           } else {
//                             return base.length;
//                           }
//                         })(),
//                         separatorBuilder: (context, index) =>
//                             const SizedBox(height: 12),
//                         itemBuilder: (context, index) {
//                           final base = _filteredPassengers;
//                           late final List<Map<String, dynamic>> listToShow;
//                           if (tab == 1) {
//                             listToShow = base
//                                 .where((p) => p['boarded'] != true)
//                                 .toList();
//                           } else if (tab == 2) {
//                             listToShow = base.where((p) {
//                               final a = p['action'];
//                               return p['boarded'] == true ||
//                                   a == PassengerAction.boarding ||
//                                   (a
//                                           ?.toString()
//                                           .toLowerCase()
//                                           .contains('board') ??
//                                       false) ||
//                                   (a
//                                           ?.toString()
//                                           .toLowerCase()
//                                           .contains('посад') ??
//                                       false);
//                             }).toList();
//                           } else if (tab == 3) {
//                             listToShow = base.where((p) {
//                               final a = p['action'];
//                               return p['refused'] == true ||
//                                   a == PassengerAction.refuse ||
//                                   (a
//                                           ?.toString()
//                                           .toLowerCase()
//                                           .contains('refus') ??
//                                       false) ||
//                                   (a
//                                           ?.toString()
//                                           .toLowerCase()
//                                           .contains('отказ') ??
//                                       false);
//                             }).toList();
//                           } else if (tab == 4) {
//                             listToShow = base.where((p) {
//                               final a = p['action'];
//                               return p['disembarked'] == true ||
//                                   a == PassengerAction.disembark ||
//                                   (a
//                                           ?.toString()
//                                           .toLowerCase()
//                                           .contains('disembark') ??
//                                       false) ||
//                                   (a
//                                           ?.toString()
//                                           .toLowerCase()
//                                           .contains('высад') ??
//                                       false);
//                             }).toList();
//                           } else {
//                             listToShow = base;
//                           }
//                           if (index >= listToShow.length)
//                             return const SizedBox.shrink();
//                           final passenger = listToShow[index];

//                           // accent color relies on a single active flag thanks to mutual exclusivity above
//                           // Accent color logic based on passenger state (ignores current tab)
//                           final dynamic action = passenger['action'];
//                           final bool boardedFlag = passenger['boarded'] == true;
//                           final bool isBoarded = boardedFlag ||
//                               action == PassengerAction.boarding ||
//                               (action
//                                       ?.toString()
//                                       .toLowerCase()
//                                       .contains('board') ??
//                                   false) ||
//                               (action
//                                       ?.toString()
//                                       .toLowerCase()
//                                       .contains('посад') ??
//                                   false);

//                           final bool isRefused =
//                               action == PassengerAction.refuse ||
//                                   (action
//                                           ?.toString()
//                                           .toLowerCase()
//                                           .contains('refus') ??
//                                       false) ||
//                                   (action
//                                           ?.toString()
//                                           .toLowerCase()
//                                           .contains('отказ') ??
//                                       false);
//                           final bool isDisembarked =
//                               action == PassengerAction.disembark ||
//                                   (action
//                                           ?.toString()
//                                           .toLowerCase()
//                                           .contains('disembark') ??
//                                       false) ||
//                                   (action
//                                           ?.toString()
//                                           .toLowerCase()
//                                           .contains('высад') ??
//                                       false);

//                           final Color accentColor = isBoarded
//                               ? const Color(0xFF23C16B)
//                               : isRefused
//                                   ? const Color(
//                                       0xFFF59E0B) // orange for refusal
//                                   : isDisembarked
//                                       ? const Color(
//                                           0xFFEF4444) // red for disembarked
//                                       : const Color(0xFF0864D4);
//                           const Color infoTextColor = Colors.grey;

//                           return GestureDetector(
//                             onTap: () => _showPassengerActionSheet(passenger),
//                             child: Stack(
//                               children: [
//                                 // Card container
//                                 Container(
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(18),
//                                     color: Colors.white,
//                                     boxShadow: const [
//                                       BoxShadow(
//                                           color: Color(0x14000000),
//                                           blurRadius: 12,
//                                           offset: Offset(0, 6)),
//                                     ],
//                                   ),
//                                   padding: const EdgeInsets.symmetric(
//                                       vertical: 4, horizontal: 10),
//                                   child: Row(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.center,
//                                     children: [
//                                       const SizedBox(width: 8),
//                                       Expanded(
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             // Top row: name
//                                             Row(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.center,
//                                               children: [
//                                                 Expanded(
//                                                   child: Text(
//                                                     (passenger['name'] ?? '')
//                                                         .toString(),
//                                                     maxLines: 1,
//                                                     overflow:
//                                                         TextOverflow.ellipsis,
//                                                     style: const TextStyle(
//                                                       fontSize: 16,
//                                                       fontWeight:
//                                                           FontWeight.w700,
//                                                       color: Color(0xFF111827),
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                             const SizedBox(height: 2),
//                                             // Bottom row: responsive icons + labels
//                                             FittedBox(
//                                               fit: BoxFit.scaleDown,
//                                               alignment: Alignment.centerLeft,
//                                               child: Row(
//                                                 mainAxisSize: MainAxisSize.min,
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.center,
//                                                 children: [
//                                                   // document framed icon
//                                                   Container(
//                                                     padding:
//                                                         const EdgeInsets.all(2),
//                                                     decoration: BoxDecoration(),
//                                                     child: SvgPicture.asset(
//                                                       ImageConstant.card,
//                                                       width: 25,
//                                                       height: 25,
//                                                       color: accentColor,
//                                                     ),
//                                                   ),
//                                                   const SizedBox(width: 8),
//                                                   Text(
//                                                     (passenger['docNumber'] ??
//                                                             passenger['doc'] ??
//                                                             passenger['iin'] ??
//                                                             '—')
//                                                         .toString(),
//                                                     style: const TextStyle(
//                                                       fontSize: 14,
//                                                       fontWeight:
//                                                           FontWeight.w600,
//                                                       color: infoTextColor,
//                                                     ),
//                                                   ),
//                                                   const SizedBox(width: 12),
//                                                   // cart icon + count
//                                                   SvgPicture.asset(
//                                                     ImageConstant.place,
//                                                     width: 16,
//                                                     height: 16,
//                                                     color: accentColor,
//                                                   ),
//                                                   const SizedBox(width: 6),
//                                                   Text(
//                                                     (passenger['cart'] ??
//                                                             passenger[
//                                                                 'baggage'] ??
//                                                             passenger[
//                                                                 'items'] ??
//                                                             '1')
//                                                         .toString(),
//                                                     style: const TextStyle(
//                                                       fontSize: 14,
//                                                       fontWeight:
//                                                           FontWeight.w600,
//                                                       color: infoTextColor,
//                                                     ),
//                                                   ),
//                                                   // location pin (icon only, no number)
//                                                   const SizedBox(width: 12),
//                                                   // gender
//                                                   Builder(builder: (context) {
//                                                     final genderRaw =
//                                                         (passenger['gender'] ??
//                                                                 '')
//                                                             .toString()
//                                                             .toLowerCase();
//                                                     final isMale = genderRaw
//                                                             .isEmpty
//                                                         ? true
//                                                         : genderRaw
//                                                             .startsWith('м');
//                                                     final genderText =
//                                                         isMale ? 'муж' : 'жен';
//                                                     return Row(
//                                                       mainAxisSize:
//                                                           MainAxisSize.min,
//                                                       children: [
//                                                         SvgPicture.asset(
//                                                           isMale
//                                                               ? ImageConstant
//                                                                   .man
//                                                               : ImageConstant
//                                                                   .woman,
//                                                           width: 16,
//                                                           height: 16,
//                                                           color: accentColor,
//                                                         ),
//                                                         const SizedBox(
//                                                             width: 6),
//                                                         Text(
//                                                           genderText,
//                                                           style:
//                                                               const TextStyle(
//                                                             fontSize: 14,
//                                                             fontWeight:
//                                                                 FontWeight.w600,
//                                                             color:
//                                                                 infoTextColor,
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     );
//                                                   }),
//                                                   // child indicator
//                                                   Builder(builder: (context) {
//                                                     final hasChild = (passenger[
//                                                             'hasChild'] ==
//                                                         true);
//                                                     final int childCount =
//                                                         int.tryParse((passenger[
//                                                                         'childCount'] ??
//                                                                     '0')
//                                                                 .toString()) ??
//                                                             0;
//                                                     if (!hasChild &&
//                                                         childCount <= 0)
//                                                       return const SizedBox
//                                                           .shrink();
//                                                     return Row(
//                                                       mainAxisSize:
//                                                           MainAxisSize.min,
//                                                       children: [
//                                                         const SizedBox(
//                                                             width: 8),
//                                                         SvgPicture.asset(
//                                                           ImageConstant
//                                                               .not_send,
//                                                           width: 16,
//                                                           height: 16,
//                                                           color: accentColor,
//                                                         ),
//                                                       ],
//                                                     );
//                                                   }),
//                                                 ],
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                       const SizedBox(width: 8),
//                                       // Right index badge
//                                       Container(
//                                         height: 28,
//                                         width: 28,
//                                         decoration: BoxDecoration(
//                                           color: accentColor,
//                                           borderRadius:
//                                               BorderRadius.circular(8),
//                                         ),
//                                         child: Center(
//                                           child: Text(
//                                             '${index + 1}',
//                                             textAlign: TextAlign.center,
//                                             style: const TextStyle(
//                                               color: Colors.white,
//                                               fontWeight: FontWeight.w700,
//                                               fontSize: 14,
//                                               height: 1.0,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),

//                                 // Left accent bar
//                                 Positioned.fill(
//                                   left: 0,
//                                   child: Align(
//                                     alignment: Alignment.centerLeft,
//                                     child: Container(
//                                       width: 6,
//                                       height: double.infinity,
//                                       decoration: BoxDecoration(
//                                         color: accentColor,
//                                         borderRadius: const BorderRadius.only(
//                                           topLeft: Radius.circular(18),
//                                           bottomLeft: Radius.circular(18),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                       ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget tag({required String text, required Function() onTap}) {
//     return Container(
//       decoration: BoxDecoration(
//         color: const Color(0xFF23C16B),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             text,
//             style: const TextStyle(
//               fontSize: 12,
//               color: Colors.white,
//               fontWeight: FontWeight.w800,
//               height: 1.0,
//             ),
//           ),
//           const SizedBox(width: 4),
//           GestureDetector(
//             onTap: onTap,
//             child: SvgPicture.asset(
//               ImageConstant.circle_close,
//               width: 14,
//               height: 14,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _onSegTap(int value) {
//     final base = _filteredPassengers;

//     int boardedCount = base.where((p) {
//       final a = p['action'];
//       return p['boarded'] == true ||
//           a == PassengerAction.boarding ||
//           (a?.toString().toLowerCase().contains('board') ?? false) ||
//           (a?.toString().toLowerCase().contains('посад') ?? false);
//     }).length;

//     int notBoardedCount = base.where((p) => !(p['boarded'] == true)).length;

//     int refusedCount = base.where((p) {
//       final a = p['action'];
//       return p['refused'] == true ||
//           a == PassengerAction.refuse ||
//           (a?.toString().toLowerCase().contains('refus') ?? false) ||
//           (a?.toString().toLowerCase().contains('отказ') ?? false);
//     }).length;

//     int disembarkedCount = base.where((p) {
//       final a = p['action'];
//       return p['disembarked'] == true ||
//           a == PassengerAction.disembark ||
//           (a?.toString().toLowerCase().contains('disembark') ?? false) ||
//           (a?.toString().toLowerCase().contains('высад') ?? false);
//     }).length;

//     int targetCount;
//     switch (value) {
//       case 0:
//         targetCount = base.length;
//         break;
//       case 1:
//         targetCount = notBoardedCount;
//         break;
//       case 2:
//         targetCount = boardedCount;
//         break;
//       case 3:
//         targetCount = refusedCount;
//         break;
//       case 4:
//         targetCount = disembarkedCount;
//         break;
//       default:
//         targetCount = 0;
//     }

//     if (targetCount == 0) {
//       // Do nothing if the target tab has zero items
//       return;
//     }

//     setState(() => tab = value);
//   }

//   Widget _seg(int value, String title, int count, {required Color color}) {
//     final selected = tab == value;
//     final bool isDisabled =
//         count == 0; // остаётся для блокировки onTap, но без серого вида

//     // Фон: как у обычных вкладок, без обесцвечивания при isDisabled
//     Color backgroundColor;
//     if (value == 0) {
//       backgroundColor = selected
//           ? const Color(0xFF0864D4)
//           : const Color(0xFF0864D4).withOpacity(0.15);
//     } else {
//       backgroundColor =
//           selected ? color.withOpacity(0.15) : const Color(0xFFF4F6F8);
//     }

//     // Текст: без приглушения при isDisabled
//     final Color textColor = (value == 0 && selected)
//         ? Colors.white
//         : Colors.black.withOpacity(0.85);

//     // Точка-метка: без приглушения при isDisabled
//     final Color dotColor = (value == 1)
//         ? const Color(0xFF0864D4)
//         : (value == 2)
//             ? const Color(0xFF2DB566)
//             : (value == 3)
//                 ? const Color(0xFFF59E0B)
//                 : const Color(0xFFEF4444);

//     return InkWell(
//       borderRadius: BorderRadius.circular(22),
//       onTap: isDisabled ? null : () => _onSegTap(value),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         decoration: BoxDecoration(
//           color: backgroundColor,
//           borderRadius: BorderRadius.circular(22),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             if (value != 0) _dot(color: dotColor),
//             if (value != 0) const SizedBox(width: 6),
//             Text(
//               title,
//               style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
//             ),
//             const SizedBox(width: 6),
//             Text(
//               '($count)',
//               style: TextStyle(
//                 color: (value == 0 && selected)
//                     ? Colors.white.withOpacity(0.7)
//                     : Colors.black.withOpacity(0.55),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _dot({required Color color}) => Container(
//         width: 15,
//         height: 15,
//         decoration: BoxDecoration(color: color, shape: BoxShape.circle),
//       );
// }
