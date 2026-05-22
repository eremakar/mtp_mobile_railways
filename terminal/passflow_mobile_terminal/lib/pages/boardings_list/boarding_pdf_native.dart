import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:passflow_app/pages/boardings_list/widgets/passenger_row.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:passflow_app/data/models/ticket_model.dart';
import 'package:passflow_app/pages/image_constant.dart';


// Палитра под экранный дизайн
const _blue = PdfColor.fromInt(0xFF0864D4);
const _green = PdfColor.fromInt(0xFF23C16B);
const _orange = PdfColor.fromInt(0xFFF59E0B);
const _red = PdfColor.fromInt(0xFFEF4444);
const _textPrimary = PdfColor.fromInt(0xFF111827);
const _textInfo = PdfColor.fromInt(0xFF9CA3AF);

const double _sunmi58mmWidth = 48.0; // mm, ~384px @ 203dpi

/// Генерирует PDF-документ с пассажирами
Future<Uint8List> buildBoardingPdfNative(
  List<PassengerRow> rows, {
  String title = 'Посадка пассажиров',
  Set<String> refusedSet = const <String>{},
  Set<String> disembSet = const <String>{},
}) async {
  // Шрифты
  final regularFont = pw.Font.ttf(
    (await rootBundle.load('assets/fonts/MontserratRegular.ttf')).buffer.asByteData(),
  );
  final boldFont = pw.Font.ttf(
    (await rootBundle.load('assets/fonts/MontserratRomanBold.ttf')).buffer.asByteData(),
  );

  // Иконки из тех же ассетов, что и в UI (SVG)
  final svgCard   = await rootBundle.loadString(ImageConstant.card);
  final svgPlace  = await rootBundle.loadString(ImageConstant.place);
  final svgMan    = await rootBundle.loadString(ImageConstant.man);
  final svgWoman  = await rootBundle.loadString(ImageConstant.woman);
  final svgKid    = await rootBundle.loadString(ImageConstant.kid);

  final pdf = pw.Document();

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(24),
      header: (_) => pw.Center(
        child: pw.Text(
          title,
          style: pw.TextStyle(font: boldFont, fontSize: 18),
        ),
      ),
      footer: (ctx) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          'Стр. ${ctx.pageNumber}/${ctx.pagesCount}',
          style: pw.TextStyle(font: regularFont, fontSize: 10, color: PdfColors.grey600),
        ),
      ),
      build: (_) {
        if (rows.isEmpty) {
          return [
            pw.Center(
              child: pw.Text(
                'Нет данных',
                style: pw.TextStyle(font: regularFont, fontSize: 14),
              ),
            ),
          ];
        }

        return rows
            .map((row) => _buildPassengerCard(
                  row,
                  regularFont,
                  boldFont,
                  refusedSet,
                  disembSet,
                  svgCard,
                  svgPlace,
                  svgMan,
                  svgWoman,
                  svgKid,
                ))
            .toList();
      },
    ),
  );

  return pdf.save();
}

/// Карточка пассажира — максимально близко к экранному дизайну
pw.Widget _buildPassengerCard(
  PassengerRow row,
  pw.Font regular,
  pw.Font bold,
  Set<String> refusedSet,
  Set<String> disembSet,
  String svgCard,
  String svgPlace,
  String svgMan,
  String svgWoman,
  String svgKid,
) {
  final bool boarded = row.boarded;
  final bool refused = refusedSet.contains(row.ticket.orderNumber);
  final bool disemb = disembSet.contains(row.ticket.orderNumber);

  final PdfColor accent =
      boarded ? _green : (refused ? _orange : (disemb ? _red : _blue));

  final String wagonNum = row.ticket.wagonNumber ?? '';
  final String wagonCat = row.ticket.wagonCategory ?? '';
  final String wagonLabel =
      ((wagonNum.isNotEmpty ? wagonNum : '') + (wagonCat.isNotEmpty ? wagonCat : '')).trim();

  return pw.Container(
    margin: const pw.EdgeInsets.symmetric(vertical: 6),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.SizedBox(width: 3),
        // Белая карточка
        pw.Expanded(
          child: pw.Container(
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(24),
              border: pw.Border.all(color: PdfColors.grey300, width: 1),
            ),
            padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.SizedBox(width: 8),
                // Левый блок: ФИО + инфо
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        row.fullName.toUpperCase(),
                        maxLines: 1,
                        overflow: pw.TextOverflow.clip,
                        style: pw.TextStyle(
                          font: bold,
                          fontSize: 18,
                          color: _textPrimary,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Wrap(
                        crossAxisAlignment: pw.WrapCrossAlignment.center,
                        spacing: 16,
                        runSpacing: 2,
                        children: [
                          _svgIcon(svgCard, _blue, 16),
                          pw.Text(
                            row.doc.isEmpty ? '—' : row.doc,
                            style: pw.TextStyle(font: regular, fontSize: 12, color: _blue),
                          ),
                          _svgIcon(svgPlace, _blue, 14),
                          pw.Text(
                            row.seat.isEmpty ? '—' : row.seat,
                            style: pw.TextStyle(font: regular, fontSize: 12, color: _blue),
                          ),
                          _svgIcon(
                            (_genderLabel(row.gender) == 'муж') ? svgMan : svgWoman,
                            _blue,
                            14,
                          ),
                          pw.Text(
                            _genderLabel(row.gender),
                            style: pw.TextStyle(font: regular, fontSize: 12, color: _textInfo),
                          ),
                          if (row.ticket.documentKind == 'ДЕТСКИЙ') _svgIcon(svgKid, _blue, 14),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(width: 8),
                // Правый блок: пилюля вагона + статус
                pw.Row(
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    // Пилюля вагона
                    pw.Container(
                      height: 34,
                      constraints: const pw.BoxConstraints(minWidth: 36),
                      padding: const pw.EdgeInsets.symmetric(horizontal: 6),
                      decoration: pw.BoxDecoration(
                        color: accent,
                        borderRadius: pw.BorderRadius.circular(14),
                      ),
                      alignment: pw.Alignment.center,
                      child: pw.Text(
                        wagonLabel.isNotEmpty ? wagonLabel : '',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          font: bold,
                          fontSize: 14,
                          color: PdfColors.white,
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    // Статусная зона: галочка либо "Посадить"
                    if (boarded || refused || disemb)
                      pw.Container(
                        width: 34,
                        height: 34,
                        decoration: pw.BoxDecoration(
                          color: accent,
                          borderRadius: pw.BorderRadius.circular(17),
                        ),
                        alignment: pw.Alignment.center,
                        child: pw.Text(
                          '✓',
                          style: pw.TextStyle(
                            font: bold,
                            fontSize: 16,
                            color: PdfColors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}


String _genderLabel(String genderRaw) {
  final g = genderRaw.toLowerCase();
  final isMale = g.isEmpty ? true : g.startsWith('м') || g.startsWith('m');
  return isMale ? 'муж' : 'жен';
}


// Простая тонировка SVG: подменяем fill/stroke на нужный цвет

pw.Widget _svgIcon(String svgRaw, PdfColor color, double size) {
  return pw.SizedBox(
    width: size,
    height: size,
    child: pw.SvgImage(svg: svgRaw),
  );
}

Future<Uint8List> buildBoardingPdfThermal58mm(
  List<PassengerRow> rows, {
  String title = 'Посадка пассажиров',
}) async {
  final regularFont = pw.Font.ttf(
    (await rootBundle.load('assets/fonts/MontserratRegular.ttf')).buffer.asByteData(),
  );
  final boldFont = pw.Font.ttf(
    (await rootBundle.load('assets/fonts/MontserratRomanBold.ttf')).buffer.asByteData(),
  );

  // Ширину делаем ~48мм (384px при 203dpi), высоту ограничиваем и MultiPage сам разобьет
  final pageFormat = PdfPageFormat(
    _sunmi58mmWidth * PdfPageFormat.mm,
    220 * PdfPageFormat.mm,
    marginAll: 3 * PdfPageFormat.mm,
  );

  final pdf = pw.Document();

  pdf.addPage(
    pw.MultiPage(
      pageFormat: pageFormat,
      header: (_) => pw.Center(
        child: pw.Text(
          title,
          style: pw.TextStyle(font: boldFont, fontSize: 10, color: PdfColors.black),
        ),
      ),
      build: (_) {
        if (rows.isEmpty) {
          return [
            pw.Center(
              child: pw.Text(
                'Нет данных',
                style: pw.TextStyle(font: regularFont, fontSize: 9),
              ),
            ),
          ];
        }

        // Монохромная, компактная карточка под термопринтер
        return rows.map((r) {
          final wagonNum = r.ticket.wagonNumber ?? '';
          final wagonCat = r.ticket.wagonCategory ?? '';
          final wagon = ((wagonNum.isNotEmpty ? wagonNum : '') + (wagonCat.isNotEmpty ? wagonCat : '')).trim();

          return pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 2),
            margin: const pw.EdgeInsets.symmetric(vertical: 2),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(6),
              border: pw.Border.all(color: PdfColors.grey700, width: 0.6),
            ),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Левый блок — ФИО + ИИН/место/пол (моно)
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        r.fullName.toUpperCase(),
                        maxLines: 1,
                        overflow: pw.TextOverflow.clip,
                        style: pw.TextStyle(font: boldFont, fontSize: 9.5, color: PdfColors.black),
                      ),
                      pw.SizedBox(height: 1.5),
                      pw.Wrap(
                        spacing: 6,
                        runSpacing: 1,
                        crossAxisAlignment: pw.WrapCrossAlignment.center,
                        children: [
                          pw.Text(
                            r.doc.isEmpty ? '—' : r.doc,
                            style: pw.TextStyle(font: regularFont, fontSize: 8.2, color: PdfColors.grey800),
                          ),
                          pw.Text('•', style: pw.TextStyle(font: regularFont, fontSize: 8.2, color: PdfColors.grey800)),
                          pw.Text(
                            r.seat.isEmpty ? '—' : r.seat,
                            style: pw.TextStyle(font: regularFont, fontSize: 8.2, color: PdfColors.grey800),
                          ),
                          pw.Text('•', style: pw.TextStyle(font: regularFont, fontSize: 8.2, color: PdfColors.grey800)),
                          pw.Text(
                            _genderLabel(r.gender),
                            style: pw.TextStyle(font: regularFont, fontSize: 8.2, color: PdfColors.grey800),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(width: 4),
                // Правый блок — пилюля вагона (моно)
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: pw.BoxDecoration(
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: PdfColors.black, width: 0.8),
                    color: PdfColors.white,
                  ),
                  child: pw.Text(
                    wagon.isNotEmpty ? wagon : '',
                    style: pw.TextStyle(font: boldFont, fontSize: 9.5, color: PdfColors.black),
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
    ),
  );

  return pdf.save();
}
