// lib/pages/boardings_detail/ktz_ticket_pdf.dart
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:passflow_app/pages/boardings_list/widgets/passenger_row.dart';

Future<Uint8List> buildKtzTicketPdfFromPassengerRow(PassengerRow row) async {
  final doc = pw.Document();

  pw.Font? regular;
  pw.Font? bold;
  try {
    regular = pw.Font.ttf(
      (await rootBundle.load('assets/fonts/MontserratRegular.ttf'))
          .buffer
          .asByteData(),
    );
    bold = pw.Font.ttf(
      (await rootBundle.load('assets/fonts/MontserratRomanBold.ttf'))
          .buffer
          .asByteData(),
    );
  } catch (_) {
    // если шрифтов нет в ассетах — используем дефолт
  }

  pw.TextStyle _h1 = pw.TextStyle(font: bold, fontSize: 18);
  pw.TextStyle _k = pw.TextStyle(font: bold, fontSize: 12);
  pw.TextStyle _v = pw.TextStyle(font: regular, fontSize: 12);

  pw.Widget kv(String k, String v) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 8),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(width: 170, child: pw.Text(k, style: _k)),
            pw.Expanded(child: pw.Text(v, style: _v)),
          ],
        ),
      );

  String _fmtDate(dynamic v) {
    if (v == null) return '—';
    if (v is DateTime) return v.toLocal().toString();
    return v.toString();
  }

  final passengerName = row.fullName;
  final ticketNumber = '${row.ticketNumber}';
  final seat = '${row.seat}';
  final documentNumber = '${row.doc}';
  final departureStation = row.ticket.deparute?.name ?? '—';
  final arrivalStation = (row.station.isEmpty) ? '—' : row.station;
  final departureDateTime = _fmtDate(row.ticket.departure);
  final arrivalDateTime = '—'; // при необходимости подставьте

  final boarded = row.boarded == true;
  final statusText = boarded ? 'Посажен' : 'Не посажен';

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(24),
      build: (_) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(child: pw.Text('Талон', style: _h1)),
            pw.SizedBox(height: 16),

            // Чистый текст без иконок — то, что и будет печататься в Sunmi в текстовом режиме
            kv('Статус', statusText),
            kv('№ билета / место', '$ticketNumber / $seat'),
            kv('ФИО', passengerName),
            kv('№ документа', documentNumber),
            kv('Станция отправления', departureStation),
            kv('Постельное', 'нет'),
            kv('Дата отправления', departureDateTime),
            kv('Прибытие', arrivalStation),
            kv('Дата прибытия', arrivalDateTime),

            pw.SizedBox(height: 24),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Сгенерировано в приложении',
                style: pw.TextStyle(font: regular, fontSize: 10, color: PdfColors.grey600),
              ),
            ),
          ],
        );
      },
    ),
  );

  return doc.save();
}