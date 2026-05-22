import 'dart:typed_data';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:passflow_app/imei_provider.dart';
import 'package:passflow_app/l10n/app_localizations.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import 'package:passflow_app/pages/boardings_list/widgets/passenger_row.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;
import 'package:barcode/barcode.dart' as bc;
import 'package:barcode_image/barcode_image.dart';

class SunmiPrinterService {
  // Рисуем Code128 в PNG (ширина под 58мм принтер ~384px) и печатаем
  static Future<void> _printCode128AsImage(String data) async {
    final value = data.trim();
    if (value.isEmpty) return;

    const int headWidthPx = 384; // ширина термоголовки Sunmi 58мм @203dpi
    const int barHeightPx =
        70; // высота штрих-кода (чуть больше для надёжности)
    const int marginPx = 12; // тихая зона

    // белое RGBA-полотно
    final canvas =
        img.Image(width: headWidthPx, height: barHeightPx, numChannels: 4)
          ..clear(img.ColorRgba8(255, 255, 255, 255));

    // Генерируем Code128 и рисуем на полотно
    final code128 = bc.Barcode.code128();
    drawBarcode(
      canvas,
      code128,
      value,
      x: marginPx,
      y: marginPx,
      width: headWidthPx - marginPx * 2,
      height: barHeightPx - marginPx * 2,
      color: 0xff000000, // чёрный
    );

    // Кодируем в PNG и приводим к Uint8List — это важно для Sunmi
    final pngBytes = Uint8List.fromList(img.encodePng(canvas));

    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    await SunmiPrinter.printImage(pngBytes);
    await SunmiPrinter.lineWrap(1);
    await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
  }

  static Future<void> printTicket(
      PassengerRow row, BuildContext context) async {
    try {
      await SunmiPrinter.bindingPrinter();

      final status = (await SunmiConfig.getStatus() ?? '').toUpperCase();
      if (status != 'READY' && status != 'NORMAL') {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Принтер не готов: $status')),
          );
        }
        return;
      }

      await SunmiPrinter.initPrinter();
      final imei = await ImeiProvider.getImeis();
      if (imei.isEmpty) {
        final deviceInfo = DeviceInfoPlugin();
        final info = await deviceInfo.androidInfo;
        imei.add(info.id);
      }

      // === i18n strings (match PDF code order & fallbacks) ===
      final l10n = AppLocalizations.of(context);
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
      final sSeat = l10n?.seat ?? 'Место';

      try {
        await SunmiPrinter.startTransactionPrint(true);
      } catch (_) {}

      // =======================
      //  BARCODE В САМОМ ВЕРХУ
      // =======================
      if ((row.ticketNumber ?? '').isNotEmpty) {
        final tn = row.ticketNumber!.trim();
        // Sunmi нередко не печатает штрих‑код без "тихих зон" и переноса строк.
        await SunmiPrinter.lineWrap(1);
        await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
        // Печатаем штрих-код через изображение (самый надёжный способ)
        await _printCode128AsImage(tn);
        await SunmiPrinter.lineWrap(1);
        await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
      }

      final boarded = row.boarded == true ? 'Посажен' : 'Не посажен';

      const dash = '—';

      DateTime? _parseAnyDate(dynamic v) {
        if (v == null) return null;
        if (v is DateTime) return v;
        final s = v.toString().trim();
        if (s.isEmpty) return null;
        // Try ISO first
        final iso = DateTime.tryParse(s);
        if (iso != null) return iso;
        // Try dd.MM.yyyy[yy] [HH:mm]
        final re =
            RegExp(r'^(\d{2})[.](\d{2})[.](\d{2,4})(?:\s+(\d{2}):(\d{2}))?$');
        final m = re.firstMatch(s);
        if (m != null) {
          final dd = int.tryParse(m.group(1)!);
          final mm = int.tryParse(m.group(2)!);
          var yy = int.tryParse(m.group(3)!);
          final hh = m.group(4) != null ? int.tryParse(m.group(4)!) ?? 0 : 0;
          final mn = m.group(5) != null ? int.tryParse(m.group(5)!) ?? 0 : 0;
          if (dd != null && mm != null && yy != null) {
            if (yy < 100) yy += 2000; // normalize 2-digit year
            try {
              return DateTime(yy, mm, dd, hh, mn);
            } catch (_) {}
          }
        }
        return null;
      }

      String _fmtDate(dynamic v) {
        final d = _parseAnyDate(v);
        if (d == null) return dash;
        final local = d.toLocal();
        final dd = local.day.toString().padLeft(2, '0');
        final mm = local.month.toString().padLeft(2, '0');
        final yyyy = local.year.toString();
        return '$dd.$mm.$yyyy';
      }

      String _fmtTime(dynamic v) {
        final d = _parseAnyDate(v);
        if (d == null) return dash;
        final t = d.toLocal();
        final hh = t.hour.toString().padLeft(2, '0');
        final mn = t.minute.toString().padLeft(2, '0');
        return '$hh:$mn';
      }

      String edgeAlign(String left, String right, {int lineLength = 32}) {
        int maxRightLength = lineLength - left.length;
        if (maxRightLength < 0) maxRightLength = 0;
        if (right.length > maxRightLength)
          right = right.substring(0, maxRightLength);
        final spaces = ' ' * (lineLength - left.length - right.length);
        return '$left$spaces$right';
      }

      Future<void> printLine(
        String text, {
        bool bold = true,
        SunmiPrintAlign align = SunmiPrintAlign.LEFT,
        int fontSize = 22,
      }) async {
        await SunmiPrinter.printText(
          '$text\n',
          style: SunmiTextStyle(align: align, fontSize: fontSize, bold: bold),
        );
      }

      // ===== Функция черной полоски с текстом =====
      Future<void> printTrainBar(String text) async {
        // Render a solid black bar with centered white text to avoid "gaps"
        // Use printer width 384 px (Sunmi 58mm @ 203dpi)
        const int pxWidth = 384;
        const int pxHeight = 20;

        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);

        // Fill full line with black
        final bgPaint = Paint()..color = const Color(0xFF000000);
        canvas.drawRect(
            Rect.fromLTWH(0, 0, pxWidth.toDouble(), pxHeight.toDouble()),
            bgPaint);

        // Draw shadow below the bar
        final shadowPaint = Paint()..color = const Color(0x55000000);
        canvas.drawRect(
            Rect.fromLTWH(0, pxHeight.toDouble(), pxWidth.toDouble(), 6),
            shadowPaint);

        // Build white, bold, centered text
        final paragraphBuilder = ui.ParagraphBuilder(
          ui.ParagraphStyle(
            textAlign: TextAlign.center,
            fontSize: 16, // will be auto-fitted below if too wide
            fontWeight: FontWeight.w700,
          ),
        )
          ..pushStyle(ui.TextStyle(color: const Color(0xFFFFFFFF)))
          ..addText(text);

        var paragraph = paragraphBuilder.build();
        paragraph.layout(ui.ParagraphConstraints(width: pxWidth.toDouble()));

        // If text is wider than the bar height suggests, reduce font size iteratively
        double fontSize = 16;
        while (paragraph.maxIntrinsicWidth > pxWidth && fontSize > 12) {
          fontSize -= 2;
          final pb = ui.ParagraphBuilder(
            ui.ParagraphStyle(
              textAlign: TextAlign.center,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
            ),
          )
            ..pushStyle(ui.TextStyle(color: const Color(0xFFFFFFFF)))
            ..addText(text);
          paragraph = pb.build();
          paragraph.layout(ui.ParagraphConstraints(width: pxWidth.toDouble()));
        }

        // Center vertically
        final double y = (pxHeight - paragraph.height) / 2;
        canvas.drawParagraph(paragraph, Offset(0, y));

        final img = await recorder.endRecording().toImage(pxWidth, pxHeight);
        final bd = await img.toByteData(format: ui.ImageByteFormat.png);
        final bytes = bd!.buffer.asUint8List();

        // Print centered
        await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
        await SunmiPrinter.printImage(bytes);
        await SunmiPrinter.lineWrap(1);
        await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
      }

      // ===== HEADER =====
      final _ticketNo = (row.ticketNumber ?? '').trim();
      await printLine(sCompany, align: SunmiPrintAlign.CENTER, fontSize: 24);
      await printLine(sBoardingPass,
          align: SunmiPrintAlign.CENTER, fontSize: 24);
      await printLine('№${_ticketNo.isEmpty ? '—' : _ticketNo}',
          align: SunmiPrintAlign.CENTER, fontSize: 24, bold: true);
      await SunmiPrinter.lineWrap(1);

      // ===== PASSENGER INFO =====
      await printLine(edgeAlign(sFullName + ':', row.fullName ?? '—'));
      await SunmiPrinter.lineWrap(1);
      await printLine(edgeAlign(sDocument + ':', row.doc ?? '—'));
      await SunmiPrinter.lineWrap(1);
      // Discount/statusText similar to PDF's data.statusText
      String _resolveDiscount() {
        try {
          final v = (row as dynamic).statusText;
          final s = (v?.toString() ?? '').trim();
          if (s.isNotEmpty) return s;
        } catch (_) {}
        // fallback to boarded yes/no if needed
        return (row.boarded == true) ? 'Посажен' : 'Не посажен';
      }

      await printLine(edgeAlign(sDiscount + ':', _resolveDiscount()));

      // ===== TRAIN INFO =====
      await printTrainBar(sTrainBar);
      await printLine(
          edgeAlign(sDeparture + ':', row.ticket.deparute?.name ?? '—'));
      await SunmiPrinter.lineWrap(1);
      await printLine(edgeAlign(sArrival + ':',
          (row.station?.isNotEmpty ?? false) ? row.station! : '—'));
      await SunmiPrinter.lineWrap(1);
      await printLine(
          edgeAlign(sDepartureDate + ':', _fmtDate(row.ticket.departure)));
      await SunmiPrinter.lineWrap(1);
      await printLine(
          edgeAlign(sDepartureTime + ':', _fmtTime(row.ticket.departure)));
      await SunmiPrinter.lineWrap(1);
      // Arrival date resolver, like in PDF's _toPdfItem
      String _resolveArrivalDate() {
        try {
          final t = row.ticket.arrivalTime;
          if (t != null) return _fmtDate(t);
        } catch (_) {}
        return '—';
      }

      await printLine(edgeAlign(sArrivalDate + ':', _resolveArrivalDate()));

      // ===== OTHER INFO =====
      await printLine(edgeAlign(
          sOrderDate + ':', _fmtDate(row.ticket.operatorUpdatedTime)));
      await SunmiPrinter.lineWrap(1);
      await printLine(edgeAlign(
          sOrderTime + ':', _fmtTime(row.ticket.operatorUpdatedTime)));
      await SunmiPrinter.lineWrap(1);
      await printLine(edgeAlign(sTerminal + ':',
          (imei != null && imei.isNotEmpty) ? imei.first : '—'));
      await SunmiPrinter.lineWrap(1);
      await printLine(edgeAlign(
          sConductor + ':',
          row.ticket?.operatorEmployeeId != null
              ? '${row.ticket?.operatorEmployeeName ?? '—'} (${row.ticket?.operatorEmployeeTableNumber ?? ''})'
              : '—'));
      await SunmiPrinter.lineWrap(1);
      await printLine(edgeAlign(
          sTrainNumber + ':', row.ticket?.trainNumber?.toString() ?? ''));
      await SunmiPrinter.lineWrap(1);
      await printLine(edgeAlign(
          sWagonType + ':', row.ticket?.wagonCategory?.toString() ?? ''));
      await SunmiPrinter.lineWrap(1);
      await printLine(edgeAlign(
          sWagonNumber + ':', row.ticket?.wagonNumber?.toString() ?? ''));
      await printLine(edgeAlign(sSeat + ':', row.seat?.toString() ?? ''));
      await SunmiPrinter.lineWrap(1);

      // ===== PRICE SECTION =====
      // await printLine(edgeAlign(sTicketPrice + ':', '—'));
      await SunmiPrinter.lineWrap(2);

      try {
        await SunmiPrinter.exitTransactionPrint(true);
      } catch (_) {}

      // ===== FOOTER =====
      await printLine(sWish, align: SunmiPrintAlign.CENTER, fontSize: 24);
      await printLine(
          'Дата печати ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())}',
          align: SunmiPrintAlign.RIGHT,
          fontSize: 8);
      await SunmiPrinter.lineWrap(2);

      await SunmiPrinter.cutPaper();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Отправлено на печать')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Ошибка печати: $e')));
      }
    }
  }
}
