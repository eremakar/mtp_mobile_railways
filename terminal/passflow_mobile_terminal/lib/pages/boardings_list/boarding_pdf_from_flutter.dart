// import 'dart:typed_data';

// import 'package:flutter/material.dart'
//     show BuildContext, Material, Colors, SizedBox, Widget;
// import 'package:flutter/widgets.dart' show BoxConstraints;
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart' show WidgetWrapper;
// import 'package:flutter/services.dart' show rootBundle;

// /// Собирает PDF из Flutter-виджетов (карточек) 1:1 как на экране.
// /// [cardWidgets] — список уже подготовленных карточек (те же, что рендерятся в списке).
// /// [maxWidth] — ширина области рендеринга каждой карточки (600 подходит для A4 с полями).
// Future<Uint8List> buildBoardingPdfFromFlutter(
//   BuildContext context,
//   List<Widget> cardWidgets, {
//   String title = 'Посадка пассажиров',
//   double maxWidth = 600,
//   double maxHeightPerCard = 600,
// }) async {
//   final regularFont = pw.Font.ttf(
//     await rootBundle.load('assets/fonts/MontserratRegular.ttf'),
//   );
//   final boldFont = pw.Font.ttf(
//     await rootBundle.load('assets/fonts/MontserratRomanBold.ttf'),
//   );

//   final doc = pw.Document();

//   // Растрируем Flutter-виджеты в pdf-виджеты
//   final pwWidgets = <pw.Widget>[];
//   for (int i = 0; i < cardWidgets.length; i++) {
//     final child = Material(
//       color: Colors.white,
//       child: SizedBox(
//         width: maxWidth,
//         child: cardWidgets[i],
//       ),
//     );

//     final wrapper = await WidgetWrapper.fromWidget(
//       context: context,
//       widget: child,
//       constraints: BoxConstraints(
//         maxWidth: maxWidth,
//         maxHeight: maxHeightPerCard,
//       ),
//     );

//     pwWidgets.add(pw.Image(wrapper));

//     if (i != cardWidgets.length - 1) {
//       pwWidgets.add(pw.SizedBox(height: 12));
//     }
//   }

//   doc.addPage(
//     pw.MultiPage(
//       pageFormat: PdfPageFormat.a4,
//       margin: const pw.EdgeInsets.all(24),
//       header: (_) => pw.Center(
//         child: pw.Text(
//           title,
//           style: pw.TextStyle(fontSize: 18, font: boldFont),
//         ),
//       ),
//       footer: (ctx) => pw.Align(
//         alignment: pw.Alignment.centerRight,
//         child: pw.Text(
//           'Стр. ${ctx.pageNumber}/${ctx.pagesCount}',
//           style: pw.TextStyle(
//             fontSize: 10,
//             color: PdfColors.grey600,
//             font: regularFont,
//           ),
//         ),
//       ),
//       build: (_) => pwWidgets.isEmpty
//           ? [pw.Center(child: pw.Text('Нет данных', style: pw.TextStyle(font: regularFont)))]
//           : [pw.Column(children: pwWidgets)],
//     ),
//   );

//   return doc.save();
// }
