// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/services.dart';
// import 'package:passflow_app/pages/boardings_detail/detail_pdf_native.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:passflow_app/pages/image_constant.dart';
// import 'package:passflow_app/pages/boardings_list/boarding_pdf_native.dart';

// class BoardingDetailScreen extends StatelessWidget {
//   final String status;
//   final String ticketNumber;
//   final String fullName;
//   final String documentNumber;
//   final String departure;
//   final bool isPostletnoe;
//   final String departureDate;
//   final String arrival;
//   final String arrivalDate;
//   final bool boardingPassed;
//   final Function()? onPressed;

//   const BoardingDetailScreen({
//     Key? key,
//     required this.status,
//     required this.ticketNumber,
//     required this.fullName,
//     required this.documentNumber,
//     required this.departure,
//     required this.isPostletnoe,
//     required this.departureDate,
//     required this.arrival,
//     required this.arrivalDate,
//     required this.boardingPassed,
//     required this.onPressed,
//   }) : super(key: key);

//   Future<Uint8List> _buildDetailPdfBytes() async {
//     final item = TicketPdfItem(
//       statusText: status,             
//       ticketAndSeat: ticketNumber,    
//       fullName: fullName,
//       documentNumber: documentNumber,
//       departure: departure,
//       isPostel: isPostletnoe,            
//       departureDate: departureDate,
//       arrival: arrival,
//       arrivalDate: arrivalDate,
//     );

//     final bytes = await buildTicketPdfNative(
//       <TicketPdfItem>[item],
//       title: 'Талон',
//     );
//     return bytes;
//   }

//   pw.Widget _kv(String title, String value, pw.Font regular, pw.Font bold) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.only(bottom: 10),
//       child: pw.Row(
//         crossAxisAlignment: pw.CrossAxisAlignment.start,
//         children: [
//           pw.Container(
//             width: 180,
//             child: pw.Text(title, style: pw.TextStyle(font: regular, fontSize: 12, color: PdfColors.grey700)),
//           ),
//           pw.SizedBox(width: 12),
//           pw.Expanded(
//             child: pw.Text(value, style: pw.TextStyle(font: bold, fontSize: 14, color: PdfColors.black)),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: SvgPicture.asset(
//             ImageConstant.arrowLeft,
//             width: 38,
//             height: 38,
//           ),
//           onPressed: () => Navigator.of(context).pop(),
//           padding: EdgeInsets.zero,
//         ),
//         actions: [
//           IconButton(
//             icon: SvgPicture.asset(
//               ImageConstant.print,
//               width: 38,
//               height: 38,
//             ),
//             padding: EdgeInsets.zero,
//             onPressed: () {
//               showDialog(
//                 context: context,
//                 builder: (context) => AlertDialog(
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
//                   content: const Text(
//                     'Принтер не подключен',
//                     style: TextStyle(fontSize: 18, color: Colors.black87),
//                     textAlign: TextAlign.center,
//                   ),
//                   actions: [
//                     TextButton(
//                       style: TextButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 40, vertical: 12),
//                         backgroundColor: Colors.blueAccent,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       onPressed: () => Navigator.of(context).pop(),
//                       child: const Text(
//                         'ОК',
//                         style: TextStyle(color: Colors.white, fontSize: 16),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//           IconButton(
//             icon: SvgPicture.asset(
//               ImageConstant.refresh,
//               width: 38,
//               height: 38,
//             ),
//             onPressed: () {},
//             padding: EdgeInsets.zero,
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
//         child: Column(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF0D6EFD),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: const Text(
//                     'Талон (1)',
//                     style: TextStyle(color: Colors.white, fontSize: 16),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFF1F1F1),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: const Text(
//                     'Отказ (0)',
//                     style: TextStyle(color: Colors.black, fontSize: 16),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFF1F1F1),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: const Text(
//                     'Высадка (0)',
//                     style: TextStyle(color: Colors.black, fontSize: 16),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 24),

//             Expanded(
//               child: SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     _detailItem(
//                       iconPath: ImageConstant.userRoundCheck,
//                       title: 'Статус',
//                       subtitle: boardingPassed ? 'Посажен' : 'Не посажен',
//                     ),
//                     _detailItem(
//                       iconPath: ImageConstant.ticket,
//                       title: '№ билета / место',
//                       subtitle: ticketNumber,
//                     ),
//                     _detailItem(
//                       iconPath: ImageConstant.captions,
//                       title: 'ФИО',
//                       subtitle: fullName,
//                     ),
//                     _detailItem(
//                       iconPath: ImageConstant.idCard,
//                       title: '№ документа',
//                       subtitle: documentNumber.length > 6
//                           ? documentNumber.substring(documentNumber.length - 6)
//                           : documentNumber,
//                     ),
//                     _detailItem(
//                       iconPath: ImageConstant.arrowRightFromLine,
//                       title: 'Станция отправления',
//                       subtitle: departure,
//                     ),
//                     _detailItem(
//                       iconPath: ImageConstant.shell,
//                       title: 'Постельное',
//                       subtitle: isPostletnoe ? 'да' : 'нет',
//                     ),
//                     _detailItem(
//                       iconPath: ImageConstant.calendarClock,
//                       title: 'Дата отправления',
//                       subtitle: departureDate,
//                     ),
//                     _detailItem(
//                       iconPath: ImageConstant.arrowRightToLine,
//                       title: 'Прибытие',
//                       subtitle: arrival,
//                     ),
//                     _detailItem(
//                       iconPath: ImageConstant.calendarCheck,
//                       title: 'Дата прибытия',
//                       subtitle: arrivalDate,
//                       isLast: true,
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 24),

//             // Bottom buttons
//             Column(
//               children: [
//                 SizedBox(
//                   width: double.infinity,
//                   height: 56,
//                   child: ElevatedButton(
//                     onPressed: onPressed,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF0D6EFD),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                       elevation: 6,
//                       shadowColor: const Color(0xFF0D6EFD).withOpacity(0.3),
//                     ),
//                     child: const Text(
//                       'Изменить статус',
//                       style: TextStyle(fontSize: 18, color: Colors.white),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 SizedBox(
//                   width: double.infinity,
//                   height: 56,
//                   child: ElevatedButton(
//                     onPressed: () async {
//                       try {
//                         final bytes = await _buildDetailPdfBytes();
//                         final dir = await getApplicationDocumentsDirectory();
//                         final file = File('${dir.path}/ticket_detail.pdf');
//                         await file.writeAsBytes(bytes, flush: true);

//                         const MethodChannel ch = MethodChannel('native_share');
//                         await ch.invokeMethod('sharePdf', {'path': file.path});
//                       } catch (e) {
//                         if (Navigator.of(context).mounted) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(content: Text('Не удалось поделиться PDF: $e')),
//                           );
//                         }
//                       }
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFFF1F1F1),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                       elevation: 0,
//                     ),
//                     child: const Text(
//                       'Печатать талон',
//                       style: TextStyle(fontSize: 18, color: Colors.black),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _detailItem({
//     required String iconPath,
//     required String subtitle,
//     required String title,
//     bool isLast = false,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Column(
//             children: [
//               Container(
//                 width: 46,
//                 height: 46,
//                 decoration: const BoxDecoration(
//                   color: Color.fromARGB(255, 243, 243, 243),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Center(
//                   child: SvgPicture.asset(
//                     iconPath,
//                     width: 24,
//                     height: 24,
//                     color: const Color(0xFF0D6EFD),
//                   ),
//                 ),
//               ),
//               if (!isLast)
//                 Container(
//                   width: 5,
//                   height: 25,
//                   color: Colors.grey.shade200,
//                 ),
//             ],
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   subtitle,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: Colors.black,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey.shade600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
