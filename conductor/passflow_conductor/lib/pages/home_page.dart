// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:hive/hive.dart';
// import 'package:passflow_app/auth/auth_provider.dart';
// import 'package:passflow_app/data/models/user_model.dart';
// import 'package:passflow_app/pages/styles/app_text_styles.dart';
// import 'package:passflow_app/widgets/custom_app_bar_text.dart';
// import 'package:passflow_app/pages/route_card/route_card_widget.dart';
// import 'package:passflow_app/widgets/notifications/notification_screen.dart';
// import 'package:passflow_app/widgets/notifications_badge/notification_bell.dart';
// import 'package:passflow_app/widgets/static_card_widget.dart'; 
// import 'package:provider/provider.dart';

// class HomePage extends StatelessWidget {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final userId = Hive.box<UserModel>('userBox').get('currentUser')?.id ?? 0;
//     final selectedMonth = DateTime.now();

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: EdgeInsets.zero,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Padding(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                 child: Row(
//                   children: const [
//                     Expanded(child: CustomAppBarText()),
//                     NotificationBell(), 
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 24),

//               /* ─── Следующий маршрут ─────────────────────────────── */
//               NextRouteCard(
//                 key: ValueKey(selectedMonth),
//                 selectedMonth: selectedMonth,
//                 employeeId: userId,
//               ),
//               const SizedBox(height: 24),

//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Text(
//                   'Заявки на работу',
//                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black,
//                       ),
//                 ),
//               ),
//               const SizedBox(height: 16),

//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Stack(
//                   children: [
//                     Column(
//                       children: [
//                         _buildJobRequestCard(
//                           context: context,
//                           title: 'Срочная замена!',
//                           trainInfo:
//                               'Поезд 7/8 Астана Туркестан\n18/03 12:00 по 19/03 13:00',
//                           avatarUrl:
//                               'assets/images/profile/936e5e2e839da4cad6027b6a83480b8076b81320.png',
//                           onPressed: () {},
//                         ),
//                         const SizedBox(height: 12),
//                         _buildJobRequestCard(
//                           context: context,
//                           title: 'Охрана вагона',
//                           trainInfo:
//                               'Поезд 7/8 Астана Туркестан\nс 19/03 12:00 по 20/03 13:00',
//                           avatarUrl: 'assets/images/profile/2.jpg',
//                           onPressed: () {},
//                         ),
//                       ],
//                     ),
//                     Positioned.fill(
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(12),
//                         child: BackdropFilter(
//                           filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
//                           child: Container(
//                             color: Colors.black.withValues(alpha:0.35),
//                           ),
//                         ),
//                       ),
//                     ),
//                     // Текст "В разработке"
//                     Positioned.fill(
//                       child: Center(
//                         child: Text(
//                           'В разработке',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 28,
//                             fontWeight: FontWeight.bold,
//                             letterSpacing: 1.2,
//                             shadows: [
//                               Shadow(
//                                 color: Colors.black54,
//                                 offset: Offset(1, 1),
//                                 blurRadius: 6,
//                               ),
//                             ],
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 32),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   ImageProvider getImageProvider(String avatarUrl) {
//     if (avatarUrl.startsWith('http')) {
//       return NetworkImage(avatarUrl);
//     } else {
//       return AssetImage(avatarUrl);
//     }
//   }

//   Widget _buildJobRequestCard({
//     required BuildContext context,
//     required String title,
//     required String trainInfo,
//     required String avatarUrl,
//     required VoidCallback onPressed,
//   }) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(12),
//       margin: const EdgeInsets.only(bottom: 0), 
//       decoration: BoxDecoration(
//         color: const Color.fromARGB(255, 237, 242, 246),
//         border: Border.all(color: Colors.grey.shade200),
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: const Color.fromARGB(255, 255, 255, 255),
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 20,
//             backgroundColor: Colors.grey.shade300,
//             backgroundImage: getImageProvider(avatarUrl),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   trainInfo,
//                   style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 12),
//           ElevatedButton(
//             onPressed: onPressed,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color.fromARGB(255, 65, 128, 237),
//               minimumSize: const Size(
//                 26,
//                 26,
//               ), 
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 16,
//               ), 
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             child: const Text('Запись', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }
// }
