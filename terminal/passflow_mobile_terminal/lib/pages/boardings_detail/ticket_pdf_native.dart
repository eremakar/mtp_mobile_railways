import 'dart:typed_data';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:passflow_app/imei_provider.dart';
import 'package:passflow_app/l10n/app_localizations.dart';
import 'package:passflow_app/pages/boardings_list/widgets/passenger_row.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/widgets.dart' show BuildContext;

class TicketPdfItem {
  final String statusText;
  final String ticketAndSeat;
  final String fullName;
  final String documentNumber;
  final String departure;
  final bool isPostel;
  final String departureDate;
  final String arrival;
  final String arrivalDate;
  final String departureTime;
  final String? regDate;
  final String? regTime;
  final String? trainNumber;
  final String? wagonNumber;
  final String? totalPrice;
  final String? seat;
  final String? wagonCategory;
  final num? operatorEmployeeId;
  final String? operatorEmployeeTableNumber;
  final String? operatorEmployeeName;
  final String? operatorUpdatedTime;

  const TicketPdfItem({
    required this.statusText,
    required this.ticketAndSeat,
    required this.fullName,
    required this.documentNumber,
    required this.departure,
    required this.isPostel,
    required this.departureDate,
    required this.arrival,
    required this.arrivalDate,
    this.departureTime = '',
    this.regDate,
    this.regTime,
    this.trainNumber,
    this.wagonNumber,
    this.totalPrice,
    this.seat,
    this.wagonCategory,
    this.operatorEmployeeId,
    this.operatorEmployeeName,
    this.operatorUpdatedTime,
    this.operatorEmployeeTableNumber,
  });
}

/// [items]
Future<Uint8List> buildTicketPdfNative(
  List<dynamic> items, {
  String title = 'Талон',
  BuildContext? context,
}) async {
  final normalized = <TicketPdfItem>[
    for (final it in items) _toPdfItem(it),
  ];

  final imei = await ImeiProvider.getImeis();

  if (imei.isEmpty) {
    final deviceInfo = DeviceInfoPlugin();
    final info = await deviceInfo.androidInfo;
    imei.add(info.id);
  }

  final doc = pw.Document();

  pw.Font? fontRegular;
  pw.Font? fontBold;
  try {
    fontRegular = pw.Font.ttf(
      (await rootBundle.load('assets/fonts/MontserratRegular.ttf'))
          .buffer
          .asByteData(),
    );
    fontBold = pw.Font.ttf(
      (await rootBundle.load('assets/fonts/MontserratRomanBold.ttf'))
          .buffer
          .asByteData(),
    );
  } catch (_) {}

  final textColor = PdfColors.black;

  final l10n = context != null ? AppLocalizations.of(context) : null;
  final sBoardingPass = l10n?.boarding_pass ?? 'Посадочный талон';
  final sDocument = l10n?.document ?? 'Документ';
  final sDeparture = l10n?.departure ?? 'Отправление';
  final sArrival = l10n?.arrival ?? 'Прибытие';
  final sDepartureDate = l10n?.departure_date ?? 'Дата отправления';
  final sDepartureTime = l10n?.departure_time ?? 'Время отправления';
  final sOrderDate = l10n?.order_date ?? 'Дата регистрации';
  final sOrderTime = l10n?.order_time ?? 'Время регистрации';
  final sTerminal = l10n?.terminal ?? 'Терминал';
  final sConductor = l10n?.conductor ?? 'Проводник';
  final sTrainNumber = l10n?.train_number_label ?? 'Поезд №';
  final sWagonType = l10n?.wagon_type ?? 'Тип вагона';
  final sWagonNumber = l10n?.wagon_number_label ?? 'Вагон №';
  final sTicketPrice =
      l10n?.ticket_price ?? 'Стоимость электронного проездного документа';
  final sWish = l10n?.wish ?? 'Счастливого пути!';

  final sCompany = l10n?.company_label ?? '«КТЖ» «УК» АҚ';
  final sDiscount = l10n?.status_label ?? 'Статус';
  final sFullName = l10n?.full_name ?? 'ФИО';
  final sTrainBar = l10n?.train_bar ?? 'ПОЕЗД';
  final sArrivalDate = l10n?.arrival_date ?? 'Дата прибытия';
  final sGenerated = l10n?.generated ?? 'Сгенерировано в приложении';
  final sSeat = l10n?.seat ?? 'Место';
  pw.TextStyle h1([double size = 18]) =>
      pw.TextStyle(font: fontBold, fontSize: size, color: textColor);

  for (final data in normalized) {
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        build: (ctx) {
          // helpers
          pw.Widget kv(String left, String right) => pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 2),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                        child: pw.Text(left,
                            style:
                                pw.TextStyle(font: fontRegular, fontSize: 12))),
                    pw.SizedBox(width: 8),
                    pw.Text(right,
                        style: pw.TextStyle(font: fontRegular, fontSize: 12)),
                  ],
                ),
              );

          pw.Widget blackBar(String text) => pw.Container(
                width: double.infinity,
                height: 20,
                color: PdfColors.black,
                alignment: pw.Alignment.center,
                margin: const pw.EdgeInsets.only(top: 6, bottom: 6),
                child: pw.Text(text,
                    style: pw.TextStyle(
                        font: fontBold, fontSize: 12, color: PdfColors.white)),
              );

          // Extract ticket number & seat if present (format: "<ticket> / <seat>")
          String ticketNo = '';
          final ts = data.ticketAndSeat.split('/');
          if (ts.isNotEmpty) {
            ticketNo = ts.first.trim();
            if (ts.length > 1) {}
          }

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // ===== BARCODE (CODE128) — TOP =====
              if (ticketNo.isNotEmpty)
                pw.Container(
                  alignment: pw.Alignment.center,
                  margin: const pw.EdgeInsets.only(bottom: 10),
                  child: pw.BarcodeWidget(
                    barcode: pw.Barcode.code128(),
                    data: ticketNo,
                    width: 300,
                    height: 30,
                    drawText: false, // только штрихы, без подписи под кодом
                  ),
                ),

              // ===== HEADER =====
              pw.Text(sCompany, textAlign: pw.TextAlign.center, style: h1(20)),
              pw.SizedBox(height: 4),
              pw.Text(sBoardingPass,
                  textAlign: pw.TextAlign.center, style: h1(20)),
              pw.SizedBox(height: 4),
              pw.Text('№' + (ticketNo.isEmpty ? '—' : ticketNo),
                  textAlign: pw.TextAlign.center, style: h1(20)),
              pw.SizedBox(height: 10),

              // ===== PASSENGER INFO =====
              kv(sFullName + ':', data.fullName),
              kv(sDocument + ':', data.documentNumber),
              kv(sDiscount + ':', data.statusText),
              pw.SizedBox(height: 6),

              // ===== TRAIN INFO =====
              blackBar(sTrainBar),
              kv(sDeparture + ':', data.departure),
              kv(sArrival + ':', data.arrival.isEmpty ? '—' : data.arrival),
              kv(sDepartureDate + ':', data.departureDate),
              kv(sDepartureTime + ':',
                  data.departureTime.isEmpty ? '—' : data.departureTime),
              kv(sArrivalDate + ':',
                  data.arrivalDate.isEmpty ? '—' : data.arrivalDate),
              pw.SizedBox(height: 6),

              // ===== OTHER INFO =====
              kv(
                  sOrderDate + ':',
                  (data.regDate == null || data.regDate!.trim().isEmpty)
                      ? '—'
                      : data.regDate!),
              kv(
                  sOrderTime + ':',
                  data.regTime != null && data.regTime!.isNotEmpty
                      ? data.regTime!
                      : '—'),
              kv(sTerminal + ':',
                  (imei != null && imei.isNotEmpty) ? imei.first : '—'),
              kv(
                  sConductor + ':',
                  data.operatorEmployeeId != null
                      ? '${data.operatorEmployeeName ?? '—'} (${data.operatorEmployeeTableNumber ?? ''})'
                      : '—'),
              kv(sTrainNumber + ':', data.trainNumber ?? '—'),
              kv(sWagonType + ':', data.wagonCategory ?? '—'),
              kv(sWagonNumber + ':', data.wagonNumber ?? '—'),
              kv(sSeat + ':', data.seat ?? '—'),
              pw.SizedBox(height: 6),

              // ===== PRICE SECTION =====
              // kv(
              //     sTicketPrice + ':',
              //     (data.totalPrice == null || data.totalPrice!.trim().isEmpty)
              //         ? '—'
              //         : data.totalPrice!),
              pw.SizedBox(height: 12),

              // ===== FOOTER =====
              pw.Text(sWish, textAlign: pw.TextAlign.center, style: h1(18)),
              pw.SizedBox(height: 8),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  sGenerated,
                  style: pw.TextStyle(
                      font: fontRegular,
                      fontSize: 10,
                      color: PdfColors.grey600),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  return doc.save();
}

TicketPdfItem _toPdfItem(PassengerRow it) {
  try {
    final row = it; // dynamic row from UI
    final boardingPassed = row.boarded == true;

    // Ticket number and seat, e.g. "123456789 / 12A"
    final ticketNumber = (row.ticketNumber ?? '').toString().trim();
    final seat = (row.seat ?? '').toString().trim();
    final ticketAndSeat = ticketNumber.isEmpty
        ? (seat.isEmpty ? '—' : '— / ' + seat)
        : (seat.isEmpty ? ticketNumber : ticketNumber + ' / ' + seat);

    final fullName = row.fullName ?? '';
    final doc = (row.doc ?? '').toString();
    final docShort = doc.length > 6
        ? doc.substring(doc.length - 6)
        : (doc.isEmpty ? '—' : doc);

    final departureStation = row.ticket?.deparute?.name ?? (row.station ?? '—');
    final arrivalStation = row.ticket?.arrival?.name ?? '—';

    String _fmtDT(dynamic v) {
      if (v == null) return '—';
      try {
        if (v is DateTime) {
          final d = v.toLocal();
          final dd = d.day.toString().padLeft(2, '0');
          final mm = d.month.toString().padLeft(2, '0');
          final yy = d.year.toString();
          final hh = d.hour.toString().padLeft(2, '0');
          final mn = d.minute.toString().padLeft(2, '0');
          return '$dd.$mm.$yy $hh:$mn';
        }
        // try parse from string
        final d = DateTime.tryParse(v.toString());
        if (d != null) {
          final dd = d.day.toString().padLeft(2, '0');
          final mm = d.month.toString().padLeft(2, '0');
          final yy = d.year.toString();
          final hh = d.hour.toString().padLeft(2, '0');
          final mn = d.minute.toString().padLeft(2, '0');
          return '$dd.$mm.$yy $hh:$mn';
        }
      } catch (_) {}
      return v.toString();
    }

    // Departure
    String depDateStr = '—';
    String depTimeStr = '—';
    final depDt = row.ticket?.departure;
    if (depDt != null) {
      final d = DateTime.tryParse(depDt.toString());
      if (d != null) {
        final dd = d.day.toString().padLeft(2, '0');
        final mm = d.month.toString().padLeft(2, '0');
        final yy = d.year.toString();
        final hh = d.hour.toString().padLeft(2, '0');
        final mn = d.minute.toString().padLeft(2, '0');
        depTimeStr = '$hh:$mn';
        depDateStr = '$dd.$mm.$yy';
      }
    }

    String regateStr = '—';
    String regTimeStr = '—';
    final regDt = row.ticket?.operatorUpdatedTime;
    if (depDt != null) {
      final d = DateTime.tryParse(regDt.toString());
      if (d != null) {
        final dd = d.day.toString().padLeft(2, '0');
        final mm = d.month.toString().padLeft(2, '0');
        final yy = d.year.toString();
        final hh = d.hour.toString().padLeft(2, '0');
        final mn = d.minute.toString().padLeft(2, '0');
        regTimeStr = '$hh:$mn';
        regateStr = '$dd.$mm.$yy';
      }
    }

    // Arrival (try several possible fields)
    String arrDateStr = '—';
    try {
      final t = row.ticket?.arrivalTime;
      if (t != null) arrDateStr = _fmtDT(t);
    } catch (_) {}
    // if (arrDateStr == '—') {
    //   try {
    //     final t = (row.ticket as dynamic).arrival;
    //     // if this is an object with .date, try it
    //     try {
    //       final tt = (t as dynamic).date;
    //       if (tt != null) arrDateStr = _fmtDT(tt);
    //     } catch (_) {
    //       if (t != null) arrDateStr = _fmtDT(t);
    //     }
    //   } catch (_) {}
    // }

    // Try to read total price from different possible fields and format it
    String? _fmtMoney(dynamic v) {
      if (v == null) return null;
      if (v is num) {
        // show without trailing .0 if integer-like
        if (v == v.roundToDouble()) return v.toInt().toString();
        return v.toStringAsFixed(2);
      }
      final s = v.toString().trim();
      if (s.isEmpty) return null;
      // try parse to number to normalize
      final parsed = num.tryParse(s.replaceAll(' ', '').replaceAll(',', '.'));
      if (parsed != null) {
        if (parsed == parsed.roundToDouble()) return parsed.toInt().toString();
        return parsed.toStringAsFixed(2);
      }
      return s;
    }

    String? totalPrice;
    try {
      final t = (row.ticket as dynamic);
      // Common field names
      final candidates = [
        () => t.total,
        () => t.totalAmount,
        () => t.amount,
        () => t.price,
        () => t.fare,
      ];
      for (final get in candidates) {
        try {
          final v = get();
          final f = _fmtMoney(v);
          if (f != null && f.isNotEmpty) {
            totalPrice = f;
            break;
          }
        } catch (_) {}
      }
    } catch (_) {}

    return TicketPdfItem(
      statusText: boardingPassed ? 'Посажен' : 'Не посажен',
      ticketAndSeat: ticketAndSeat,
      fullName: fullName.isEmpty ? '—' : fullName,
      documentNumber: doc,
      departure: departureStation,
      isPostel: false,
      departureDate: depDateStr,
      arrival: arrivalStation,
      arrivalDate: arrDateStr,
      departureTime: depTimeStr,
      regDate: regateStr,
      regTime: regTimeStr,
      trainNumber: row.ticket?.trainNumber?.toString(),
      wagonNumber: row.ticket?.wagonNumber?.toString(),
      totalPrice: totalPrice,
      seat: seat,
      wagonCategory: row.ticket.wagonCategory,
      operatorEmployeeId: row.ticket.operatorEmployeeId,
      operatorEmployeeName: row.ticket.operatorEmployeeName,
      operatorUpdatedTime: row.ticket.operatorUpdatedTime,
    );
  } catch (_) {
    return const TicketPdfItem(
      statusText: '—',
      ticketAndSeat: '—',
      fullName: '—',
      documentNumber: '—',
      departure: '—',
      isPostel: false,
      departureDate: '—',
      arrival: '—',
      arrivalDate: '—',
      departureTime: '',
      regDate: null,
      regTime: null,
      operatorEmployeeId: null,
      operatorEmployeeName: null,
      operatorUpdatedTime: null,
      trainNumber: null,
      wagonNumber: null,
      totalPrice: null,
      seat: null,
      wagonCategory: null,
    );
  }
}
