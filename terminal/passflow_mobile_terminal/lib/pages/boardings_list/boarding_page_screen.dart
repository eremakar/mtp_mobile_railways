import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:passflow_app/l10n/app_localizations.dart';
import 'dart:typed_data';
import 'package:passflow_app/pages/boardings_list/boarding_pdf_native.dart';
import 'package:passflow_app/pages/boardings_list/dialogs/load_filter_modal.dart';
import 'package:passflow_app/pages/boardings_list/with_loader.dart';
import 'package:passflow_app/widgets/custom_loader.dart';
import 'package:passflow_app/widgets/page/boarding_select_breakdown.dart';
import 'package:shimmer/shimmer.dart';

import 'package:passflow_app/pages/boardings_list/widgets/boarding_row_shimmer.dart';
import 'package:passflow_app/pages/boardings_list/widgets/border_counts.dart';
import 'package:passflow_app/pages/boardings_list/widgets/passenger_action.dart';
import 'package:passflow_app/pages/boardings_list/widgets/passenger_row.dart';
import 'package:passflow_app/pages/image_constant.dart';
import 'package:passflow_app/widgets/page/filtert_breakdown.dart';
import 'package:passflow_app/widgets/page/ticket_detail.dart';

import 'package:passflow_app/pages/boardings_list/bloc/list_bloc.dart';
import 'package:passflow_app/pages/boardings_list/bloc/list_event.dart';
import 'package:passflow_app/pages/boardings_list/bloc/list_state.dart';
import 'package:passflow_app/data/models/ticket_model.dart';
import 'dart:ui' as ui;
import 'package:printing/printing.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';

class BoardingPageScreen extends StatefulWidget {
  const BoardingPageScreen({Key? key}) : super(key: key);

  @override
  State<BoardingPageScreen> createState() => _BoardingPageScreenState();
}

class _BoardingPageScreenState extends State<BoardingPageScreen> {
  final TextEditingController _searchController = TextEditingController();

  // выбранные фильтры
  Map<String, dynamic> _currentFilter = {};

  int tab = 0; // 0: все, 1: не посажены, 2: посажены, 3: отказы, 4: высадки

  // Кэш результатов массовой загрузки (если потом нужно открыть деталь/предпросмотр)
  final Map<String, dynamic> _manifests = <String, dynamic>{};
  final Map<String, String> _manifestErrors = <String, String>{};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<BoardingsListBloc>().add(InitTicketsEvent());
  }

  void _showTopBanner(BuildContext context,
      {required bool ok, required String text}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..hideCurrentMaterialBanner();

    messenger.showMaterialBanner(
      MaterialBanner(
        content:
            Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
        leading: Icon(ok ? Icons.check_circle : Icons.error,
            color: ok ? const Color(0xFF2DB566) : Colors.red),
        backgroundColor: ok ? const Color(0xFFEAF7F1) : const Color(0xFFFFEBEE),
        elevation: 2,
        actions: [
          TextButton(
            onPressed: messenger.hideCurrentMaterialBanner,
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );

    Future.delayed(const Duration(seconds: 20), () {
      if (context.mounted) messenger.hideCurrentMaterialBanner();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BoardingsListBloc, BoardingsState>(
      listener: (context, state) {
        if (state is BoardingsListState && state.boardingSuccess != null) {
          final ok = state.boardingSuccess == true;
          _showTopBanner(context,
              ok: ok,
              text: ok
                  ? AppLocalizations.of(context)!.operation_success
                  : (state.boardingMessage ??
                      AppLocalizations.of(context)!.operation_error));
          context.read<BoardingsListBloc>().add(ClearBoardingSuccessEvent());
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _appBar(context),
        body: BlocBuilder<BoardingsListBloc, BoardingsState>(
          buildWhen: (p, c) => c is BoardingsListState,
          builder: (context, state) {
            if (state is! BoardingsListState) {
              return const SizedBox.shrink();
            }

            // if (state.isLoading && state.tickets.isEmpty) {
            //   return Padding(
            //     padding: const EdgeInsets.all(16),
            //     child: ListView.separated(
            //       itemCount: 10,
            //       separatorBuilder: (_, __) => const SizedBox(height: 12),
            //       itemBuilder: (context, index) => const BoardingRowShimmer(),
            //     ),
            //   );
            // }

            // if (state.error != null) {
            //   return Center(
            //     child: Text(
            //       'Ошибка: ${state.error}',
            //       textAlign: TextAlign.center,
            //       style: const TextStyle(color: Colors.red),
            //     ),
            //   );
            // }

            // 1) Преобразуем в «плоские» строки
            final rows = _flatten(state.tickets);

            // 2) Поиск + фильтры
            final filtered = _applyFilters(_applySearch(rows));

            // 3) Подсчёты по текущему набору
            final counts = _counts(
                filtered, state.refusedTicketIds, state.disembarkedTicketIds);

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _searchAndActions(
                      context,
                      state
                          .tickets), // компактный тулбар: поиск + фильтр + загрузить
                  if (state.tickets.length > 0) ...[
                    const SizedBox(height: 10),
                    _filterChips(),
                    const SizedBox(height: 15),
                    _segments(counts, filtered.length),
                    const SizedBox(height: 15),
                  ],
                  const SizedBox(height: 10),
                  if (state.error != null)
                    Expanded(
                        child: Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text(
                          state.error != null
                              ? '${AppLocalizations.of(context)!.error}: ${state.error}'
                              : AppLocalizations.of(context)!.operation_error,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 10),
                        _SmallBtn(
                          isNarrow: false,
                          icon: Icons.cloud_download,
                          label: AppLocalizations.of(context)!.load,
                          background: const Color(0xFF2DB566),
                          foreground: Colors.white,
                          onPressed: () => _onLoadAllPressed(),
                          tooltip:
                              AppLocalizations.of(context)!.load_filter_tooltip,
                        ),
                      ]),
                    ))
                  else if (state.tickets.length > 0)
                    Expanded(
                      child: _listView(filtered, state.refusedTicketIds,
                          state.disembarkedTicketIds),
                    )
                  else
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 42,
                              backgroundColor: const Color(0xFFF0F2F4),
                              child: SvgPicture.asset(
                                  'assets/svg_icons/filter.svg',
                                  width: 28,
                                  height: 28),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              AppLocalizations.of(context)!
                                  .boarding_filterPrompt,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: Color(0xFF6B7280)),
                            ),
                            const SizedBox(height: 10),
                            _SmallBtn(
                              isNarrow: false,
                              icon: Icons.cloud_download,
                              label: AppLocalizations.of(context)!.load,
                              background: const Color(0xFF2DB566),
                              foreground: Colors.white,
                              onPressed: () => _onLoadAllPressed(),
                              tooltip: AppLocalizations.of(context)!
                                  .load_filter_tooltip,
                            ),
                          ],
                        ),
                      ),
                    )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    return AppBar(
      leadingWidth: 44,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child:
                SvgPicture.asset(ImageConstant.train_logo, fit: BoxFit.contain),
          ),
        ),
      ),
      title: Text(AppLocalizations.of(context)!.boarding_title,
          style: TextStyle(fontWeight: FontWeight.w400, fontSize: 20)),
      centerTitle: true,
      elevation: 1,
      backgroundColor: const Color.fromARGB(111, 255, 255, 255),
      foregroundColor: Colors.black,
      actions: [
        // Builder(
        //   builder: (innerCtx) => IconButton(
        //     icon: SvgPicture.asset('assets/svg_icons/refresh.svg',
        //         width: 25, height: 25),
        //     onPressed: () =>
        //         innerCtx.read<BoardingsListBloc>().add(LoadTicketsEvent()),
        //   ),
        // ),
        IconButton(
          icon: SvgPicture.asset(
            'assets/svg_icons/share.svg',
            width: 25,
            height: 25,
          ),
          onPressed: () async {
            Uint8List? pdfBytes;

            // 1) Генерация PDF внутри лоадера
            await withLoader(context, () async {
              final st = context.read<BoardingsListBloc>().state;
              if (st is! BoardingsListState) return;

              final allRows = _flatten(st.tickets);
              final filteredRows = _applyFilters(_applySearch(allRows));
              final rowsToShow = _byTab(
                filteredRows,
                st.refusedTicketIds,
                st.disembarkedTicketIds,
              );

              if (rowsToShow.isEmpty) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text(AppLocalizations.of(context)!.no_data_export)),
                  );
                }
                return;
              }

              pdfBytes = await buildBoardingPdfNative(
                rowsToShow,
                title: AppLocalizations.of(context)!.boarding_title,
              );
            });

            // 2) Открываем предпросмотр после лоадера
            if (!mounted || pdfBytes == null || pdfBytes!.isEmpty) return;

            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => Scaffold(
                  appBar: AppBar(
                      title: Text(AppLocalizations.of(context)!.preview_title)),
                  body: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          children: [
                            FilledButton.icon(
                              icon: const Icon(Icons.print),
                              label: Text(AppLocalizations.of(context)!.print),
                              onPressed: () async {
                                await withLoader(context, () async {
                                  if (pdfBytes == null || pdfBytes!.isEmpty)
                                    return;

                                  try {
                                    final bound =
                                        await SunmiPrinter.bindingPrinter();
                                    if (bound == false) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                AppLocalizations.of(context)!
                                                    .printer_not_connected)),
                                      );
                                      return;
                                    }
                                    // проверка статуса
                                    final status =
                                        (await SunmiConfig.getStatus() ?? '')
                                            .toUpperCase();
                                    if (!(status == 'READY' ||
                                        status == 'NORMAL')) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              AppLocalizations.of(context)!
                                                  .printer_not_ready(status)),
                                        ),
                                      );
                                      return;
                                    }

                                    await SunmiPrinter.initPrinter();
                                    try {
                                      await SunmiPrinter.startTransactionPrint(
                                          true);
                                    } catch (_) {}

                                    const targetWidth = 384;
                                    await for (final page in Printing.raster(
                                        pdfBytes!,
                                        dpi: 203)) {
                                      final srcPng = await page.toPng();
                                      final codec = await ui
                                          .instantiateImageCodec(srcPng);
                                      final frame = await codec.getNextFrame();
                                      final src = frame.image;

                                      final outH = (src.height *
                                              targetWidth /
                                              (src.width == 0 ? 1 : src.width))
                                          .round();
                                      final recorder = ui.PictureRecorder();
                                      final canvas = Canvas(recorder);
                                      canvas.drawImageRect(
                                          src,
                                          Rect.fromLTWH(
                                              0,
                                              0,
                                              src.width.toDouble(),
                                              src.height.toDouble()),
                                          Rect.fromLTWH(
                                              0,
                                              0,
                                              targetWidth.toDouble(),
                                              outH.toDouble()),
                                          Paint()..isAntiAlias = false);
                                      final img = await recorder
                                          .endRecording()
                                          .toImage(targetWidth, outH);
                                      final bd = await img.toByteData(
                                          format: ui.ImageByteFormat.png);
                                      await SunmiPrinter.printImage(
                                          bd!.buffer.asUint8List());
                                      await SunmiPrinter.lineWrap(2);
                                    }

                                    try {
                                      await SunmiPrinter.exitTransactionPrint(
                                          true);
                                    } catch (_) {}
                                    try {
                                      await SunmiPrinter.cutPaper();
                                    } catch (_) {}

                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                AppLocalizations.of(context)!
                                                    .sent_to_print)),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              AppLocalizations.of(context)!
                                                  .print_error(e.toString())),
                                        ),
                                      );
                                    }
                                  }
                                });
                              },
                            ),
                            const Spacer(),
                            FilledButton.icon(
                              icon: const Icon(Icons.share),
                              label: Text(AppLocalizations.of(context)!.share),
                              onPressed: () async {
                                await withLoader(context, () async {
                                  if (pdfBytes == null || pdfBytes!.isEmpty)
                                    return;
                                  await Printing.sharePdf(
                                      bytes: pdfBytes!,
                                      filename: 'boarding_list.pdf');
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: PdfPreview(
                          build: (format) async => pdfBytes!,
                          canChangeOrientation: false,
                          canChangePageFormat: false,
                          allowPrinting: false,
                          allowSharing: false,
                          actions: const [],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        )
      ],
    );
  }

  // ======== КОМПАКТНЫЙ ТУЛБАР: ПОИСК + ФИЛЬТР + ЗАГРУЗИТЬ ========

  Widget _searchAndActions(BuildContext context, List<TicketModel> tickets) {
    final width = MediaQuery.of(context).size.width;
    final isNarrow = width < 360; // на узких — иконки

    return Row(
      children: [
        // Поиск — компактный
        Expanded(
          child: SizedBox(
            height: 36,
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.search_hint,
                prefixIcon: const Icon(Icons.search, size: 20),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Фильтр — с бейджем
        _FilterButtonSmall(
          count: _activeFilterCount(),
          isNarrow: isNarrow,
          onPressed: () => _onFilterPressed(tickets),
        ),

        const SizedBox(width: 6),

        // Загрузить — зелёная
        _SmallBtn(
          isNarrow: true,
          icon: Icons.cloud_download,
          label: AppLocalizations.of(context)!.load,
          background: const Color(0xFF2DB566),
          foreground: Colors.white,
          onPressed: () => _onLoadAllPressed(),
          tooltip: AppLocalizations.of(context)!.load_filter_tooltip,
        ),
      ],
    );
  }

  int _activeFilterCount() {
    final wagons = (_currentFilter['wagons'] as List?)?.length ?? 0;
    final station =
        ((_currentFilter['station'] as String?) ?? '').isNotEmpty ? 1 : 0;
    return wagons + station;
  }

  ButtonStyle _smallBtnStyle(
      {required Color background,
      required Color foreground,
      EdgeInsets? padding}) {
    return ButtonStyle(
      minimumSize: MaterialStateProperty.all(const Size(0, 36)),
      padding: MaterialStateProperty.all(
          padding ?? const EdgeInsets.symmetric(horizontal: 12)),
      visualDensity: VisualDensity.compact,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      backgroundColor: MaterialStateProperty.all(background),
      foregroundColor: MaterialStateProperty.all(foreground),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ===== Сегменты =====

  Widget _segments(BorderCounts counts, int totalFiltered) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _seg(0, AppLocalizations.of(context)!.segment_all, totalFiltered,
              color: const Color(0xFF0864D4)),
          _seg(1, AppLocalizations.of(context)!.segment_not_boarded,
              counts.notBoarded,
              color: const Color(0xFF0864D4)),
          _seg(2, AppLocalizations.of(context)!.segment_boarded, counts.boarded,
              color: const Color(0xFF2DB566)),
          _seg(4, AppLocalizations.of(context)!.segment_disembarked,
              counts.disembarked,
              color: const Color(0xFFEF4444)),
        ],
      ),
    );
  }

  // ===== Список =====

  Widget _listView(
    List<PassengerRow> filtered,
    Set<String> refusedSet,
    Set<String> disembSet,
  ) {
    final listToShow = _byTab(filtered, refusedSet, disembSet);

    return ListView.separated(
      itemCount: listToShow.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final row = listToShow[index];
        return GestureDetector(
          onTap: () => _onRowAction(row),
          child: _buildPassengerCard(row, refusedSet, disembSet),
        );
      },
    );
  }

  Widget _buildPassengerCard(
    PassengerRow row,
    Set<String> refusedSet,
    Set<String> disembSet,
  ) {
    final bool boarded = row.boarded; // из TicketModel.boardingPassed
    final bool refused = refusedSet.contains(row.ticket.orderNumber);
    final bool disemb = disembSet.contains(row.ticket.orderNumber);

    final Color accentColor = boarded
        ? const Color(0xFF23C16B)
        : refused
            ? const Color(0xFFF59E0B)
            : disemb
                ? const Color(0xFFEF4444)
                : const Color(0xFF0864D4);
    const Color infoTextColor = Colors.grey;

    final String wagonNum = row.ticket.wagonNumber ?? '';
    final String wagonCat = row.ticket.wagonCategory ?? '';
    final String wagonLabel = ((wagonNum.isNotEmpty ? wagonNum : '') +
            (wagonCat.isNotEmpty ? wagonCat : ''))
        .trim();

    // можно ли быстро посадить (кнопка активна)
    final bool canQuickBoard = !boarded && !refused && !disemb;

    // стиль компактной кнопки
    final ButtonStyle quickBtnStyle = ButtonStyle(
      minimumSize: MaterialStateProperty.all(const Size(0, 28)),
      padding: MaterialStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 10),
      ),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      backgroundColor: MaterialStateProperty.resolveWith((states) {
        return states.contains(MaterialState.disabled)
            ? const Color(0xFFE5E7EB) // серый фон когда disabled
            : accentColor; // основной — цвет статуса
      }),
      foregroundColor: MaterialStateProperty.resolveWith((states) {
        return states.contains(MaterialState.disabled)
            ? const Color(0xFF9CA3AF)
            : Colors.white;
      }),
      visualDensity: VisualDensity.compact,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    return Stack(
      children: [
        Positioned.fill(
          left: 0,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 15,
              decoration: const BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 12,
                offset: Offset(0, 6),
              )
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 8),
              // ------- ЛЕВЫЙ БЛОК: ФИО + инфо -------
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            ImageConstant.card,
                            width: 25,
                            height: 25,
                            color: accentColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            row.doc.isEmpty
                                ? AppLocalizations.of(context)!.dash_placeholder
                                : row.doc,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: infoTextColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          SvgPicture.asset(
                            ImageConstant.place,
                            width: 16,
                            height: 16,
                            color: accentColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            row.seat,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: infoTextColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          _gender(context, accentColor, row.gender),
                          const SizedBox(width: 12),
                          if (row.ticket.documentKind == "ДЕТСКИЙ")
                            SvgPicture.asset(
                              ImageConstant.kid,
                              width: 16,
                              height: 16,
                              color: accentColor,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // ------- ПРАВЫЙ БЛОК: № вагона + быстрая посадка / чек -------
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Пилюля с номером вагона
                  Container(
                    height: 28,
                    constraints: const BoxConstraints(minWidth: 36),
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        wagonLabel.isNotEmpty
                            ? wagonLabel
                            : AppLocalizations.of(context)!.dash_placeholder,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Если уже посажен — зелёная галочка
                  if (boarded || refused || disemb)
                    Icon(Icons.check_circle, color: accentColor, size: 28)
                  else
                    SizedBox(
                      height: 28,
                      child: FilledButton.icon(
                        style: quickBtnStyle,
                        onPressed: canQuickBoard
                            ? () {
                                // Быстрая посадка
                                context
                                    .read<BoardingsListBloc>()
                                    .add(RegisterBoardingEvent(row.ticket));
                              }
                            : null,
                        icon: const Icon(Icons.how_to_reg, size: 16),
                        label: Text(
                          AppLocalizations.of(context)!.quick_board,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===== Массовая загрузка данных по текущей выборке =====

  Future<void> _onLoadAllPressed() async {
    final bloc = context.read<BoardingsListBloc>();
    final st = bloc.state;
    if (st is! BoardingsListState) return;

    // 1) Открываем нашу новую модалку выбора
    final picked = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => LoadFilterModal(
        // stations: st.stations,
        trainDirections:
            st.trainDirections, // можно передать текущие чипы как дефолт
        history: st.history,
      ),
    );

    if (!mounted || picked == null) return;

    // 2) Сохраняем выбранный фильтр локально (для чипов/сегментов)
    // setState(() {
    //   _currentFilter = picked;
    //   tab = 0; // на "Все"
    // });

    // 3) Лоадер + запрос в блок (ждем завершения)
    await withLoader(context, () async {
      // 3.1 Диспатчим событие в блок
      // ЕСЛИ у тебя LoadTicketsByFilterEvent принимает позиционный аргумент:
      // bloc.add(LoadTicketsByFilterEvent(picked));
      // ИЛИ, если именованный:
      bloc.add(
          LoadTicketsByFilterEvent(picked, historyKey: picked['historyKey']));

      // 3.2 Ждём первое состояние "не загрузка" после отправки события
      final done = await bloc.stream.firstWhere(
        (s) => s is BoardingsListState && !(s).isLoading,
      );

      // 3.3 Можно собрать метрику «сколько загружено»
      // final loaded =
      //     done is BoardingsListState ? (done.tickets?.length ?? 0) : 0;

      // 3.4 Показать баннер (успех/ошибка)
      if (done is BoardingsListState && done.error == null) {
        _showTopBanner(
          context,
          ok: true,
          // text: 'Загружено: $loaded',
          text: 'Данные успешно загружены',
        );
      } else {
        _showTopBanner(
          context,
          ok: false,
          text: (done is BoardingsListState && done.error != null)
              ? done.error.toString()
              : 'Ошибка: не удалось загрузить данные',
        );
      }
    });
  }

  // ==== Actions ====

  PassengerAction? _existingActionFor(PassengerRow row, BoardingsListState st) {
    final id = row.ticket.orderNumber;
    if (st.refusedTicketIds.contains(id)) return PassengerAction.refuse;
    if (st.disembarkedTicketIds.contains(id)) return PassengerAction.disembark;
    if (row.boarded) return PassengerAction.boarding; // boardingPassed
    return null;
  }

  Future<void> _onRowAction(PassengerRow row) async {
    final bloc = context.read<BoardingsListBloc>();
    final st = bloc.state;
    if (st is! BoardingsListState) return;

    final preset = _existingActionFor(row, st);
    // if (preset != null) {
    final returned = await Navigator.push<PassengerAction>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            TicketDetailScreen(passengerAction: preset, passengerRow: row),
      ),
    );
    if (!mounted) return;

    final effective = returned;
    if (effective == null) return;
    switch (effective) {
      case PassengerAction.boarding:
        bloc.add(RegisterBoardingEvent(row.ticket));
        // setState(() => tab = 2);
        break;
      case PassengerAction.refuse:
        bloc.add(DenyBoardingEvent(row.ticket));
        // setState(() => tab = 3);
        break;
      case PassengerAction.disembark:
        bloc.add(CancelBoardingEvent(row.ticket));
        // setState(() => tab = 4);
        break;
    }
    return;
    // }

    // final action = await showModalBottomSheet<PassengerAction>(
    //   context: context,
    //   isScrollControlled: true,
    //   backgroundColor: Colors.white,
    //   shape: const RoundedRectangleBorder(
    //       borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    //   builder: (_) => PassengerActionPage(title: row.fullName),
    // );
    // if (!mounted || action == null) return;

    // switch (action) {
    //   case PassengerAction.boarding:
    //     bloc.add(RegisterBoardingEvent(row.ticket));
    //     // setState(() => tab = 2);
    //     break;
    //   case PassengerAction.refuse:
    //     bloc.add(DenyBoardingEvent(row.ticket));
    //     // setState(() => tab = 3);
    //     break;
    //   case PassengerAction.disembark:
    //     bloc.add(CancelBoardingEvent(row.ticket));
    //     // setState(() => tab = 4);
    //     break;
    // }
  }

  // ==== Data helpers ====

  List<PassengerRow> _flatten(List<TicketModel> tickets) {
    final rows = <PassengerRow>[];
    for (final t in tickets) {
      for (final p in t.passengers) {
        rows.add(PassengerRow(ticket: t, passenger: p));
      }
    }
    return rows;
  }

  List<PassengerRow> _applySearch(List<PassengerRow> rows) {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return rows;

    String norm(String s) => s.toLowerCase().replaceAll(' ', '');

    return rows
        .where((r) =>
            r.fullName.toLowerCase().contains(q) ||
            norm(r.doc).contains(norm(q)))
        .toList();
  }

  List<PassengerRow> _applyFilters(List<PassengerRow> rows) {
    if (_currentFilter.isEmpty) return rows;

    final wagons =
        (_currentFilter['wagons'] as List?)?.cast<String>() ?? const <String>[];
    final station = (_currentFilter['station'] as String?)?.trim();

    String norm(String? s) => (s ?? '').trim().toLowerCase();

    return rows.where((r) {
      if (wagons.isNotEmpty) {
        final keyNoDash =
            '${r.ticket.wagonNumber ?? ''}${r.ticket.wagonCategory ?? ''}';
        final keyWithDash =
            '${r.ticket.wagonNumber ?? ''}-${r.ticket.wagonCategory ?? ''}';
        if (!wagons.contains(keyNoDash) && !wagons.contains(keyWithDash)) {
          return false;
        }
      }

      if (station != null && station.isNotEmpty) {
        final depName = r.ticket.deparute?.name ?? r.station ?? '';
        if (norm(depName) != norm(station)) return false;
      }

      return true;
    }).toList();
  }

  BorderCounts _counts(
      List<PassengerRow> rows, Set<String> refusedSet, Set<String> disembSet) {
    int boarded = 0, notBoarded = 0, refused = 0, disemb = 0;
    for (final r in rows) {
      final id = r.ticket.orderNumber;
      final isBoarded = r.boarded;
      final isRefused = refusedSet.contains(id);
      final isDisemb = disembSet.contains(id);

      if (isRefused) {
        refused++;
      } else if (isDisemb) {
        disemb++;
      } else if (isBoarded) {
        boarded++;
      } else {
        notBoarded++;
      }
    }
    return BorderCounts(boarded, notBoarded, refused, disemb);
  }

  List<PassengerRow> _byTab(
      List<PassengerRow> rows, Set<String> refusedSet, Set<String> disembSet) {
    if (tab == 0) return rows;

    final res = <PassengerRow>[];
    for (final r in rows) {
      final id = r.ticket.orderNumber;
      final isBoarded = r.boarded;
      final isRefused = refusedSet.contains(id);
      final isDisemb = disembSet.contains(id);

      switch (tab) {
        case 1:
          if (!isBoarded && !isRefused && !isDisemb) res.add(r);
          break;
        case 2:
          if (isBoarded) res.add(r);
          break;
        case 3:
          if (isRefused) res.add(r);
          break;
        case 4:
          if (isDisemb) res.add(r);
          break;
      }
    }
    return res;
  }

  // ==== UI helpers ====

  Widget _seg(int value, String title, int count, {required Color color}) {
    final selected = tab == value;
    final bool isDisabled = count == 0;

    final backgroundColor =
        selected ? const Color(0xFF0864D4) : const Color(0xFFF4F6F8);
    final Color textColor =
        selected ? Colors.white : Colors.black.withOpacity(0.85);
    final Color dotColor = selected ? Colors.white : color;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: isDisabled ? null : () => setState(() => tab = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
            color: backgroundColor, borderRadius: BorderRadius.circular(22)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (value != 0) _dot(color: dotColor),
            if (value != 0) const SizedBox(width: 6),
            Text(title,
                style:
                    TextStyle(fontWeight: FontWeight.w600, color: textColor)),
            const SizedBox(width: 6),
            Text(
              '($count)',
              style: TextStyle(
                  color: selected
                      ? Colors.white.withOpacity(0.7)
                      : Colors.black.withOpacity(0.55)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot({required Color color}) => Container(
      width: 15,
      height: 15,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle));

  Widget _tag({required String text, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
          color: const Color(0xFF23C16B),
          borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text,
              style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  height: 1.0)),
          const SizedBox(width: 4),
          GestureDetector(
              onTap: onTap,
              child: SvgPicture.asset(ImageConstant.circle_close,
                  width: 14, height: 14)),
        ],
      ),
    );
  }

  Widget _gender(BuildContext context, Color acc, String genderRaw) {
    final g = genderRaw.toLowerCase();
    final isMale = g.isEmpty ? true : g.startsWith('м') || g.startsWith('m');
    final genderText = isMale ? 'муж' : 'жен';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(isMale ? ImageConstant.man : ImageConstant.woman,
            width: 16, height: 16, color: acc),
        const SizedBox(width: 6),
        Text(genderText,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey)),
      ],
    );
  }

  Future<void> _onFilterPressed(List<TicketModel> tickets) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterModalContent(tickets: tickets),
    );

    if (!mounted || result == null) return;

    setState(() {
      _currentFilter = result;
      tab = 0; // после применения фильтра — «Все»
    });
  }

  Widget _filterChips() {
    final wagons =
        (_currentFilter['wagons'] as List?)?.cast<String>() ?? const <String>[];
    final station = (_currentFilter['station'] as String?) ?? '';

    if (wagons.isEmpty && station.isEmpty) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.centerRight,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ...wagons.map(
              (wagon) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _tag(
                  text: AppLocalizations.of(context)!.wagon_tag(wagon),
                  onTap: () {
                    setState(() {
                      final list = List<String>.from(
                          (_currentFilter['wagons'] as List?)?.cast<String>() ??
                              const <String>[]);
                      list.remove(wagon);
                      if (list.isEmpty) {
                        _currentFilter.remove('wagons');
                      } else {
                        _currentFilter['wagons'] = list;
                      }
                    });
                  },
                ),
              ),
            ),
            if (station.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _tag(
                  text: AppLocalizations.of(context)!.station_tag(station),
                  onTap: () => setState(() => _currentFilter.remove('station')),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

ButtonStyle _smallBtnStyle({
  required Color background,
  required Color foreground,
  EdgeInsetsGeometry? padding,
}) {
  return ButtonStyle(
    minimumSize: MaterialStateProperty.all(const Size(0, 36)),
    padding: MaterialStateProperty.all(
      padding ?? const EdgeInsets.symmetric(horizontal: 12),
    ),
    visualDensity: VisualDensity.compact,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    backgroundColor: MaterialStateProperty.all(background),
    foregroundColor: MaterialStateProperty.all(foreground),
    shape: MaterialStateProperty.all(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}

class _SmallBtn extends StatelessWidget {
  const _SmallBtn({
    required this.isNarrow,
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
    required this.onPressed,
    this.tooltip,
  });

  final bool isNarrow;
  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    // Узкие экраны — показываем только иконку
    if (isNarrow) {
      return SizedBox(
        height: 36,
        child: FilledButton(
          onPressed: onPressed,
          style: _smallBtnStyle(
            background: background,
            foreground: foreground,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: Icon(icon, size: 18, color: foreground),
        ),
      );
    }

    // Обычная компактная кнопка с текстом
    return SizedBox(
      height: 36,
      child: FilledButton.icon(
        onPressed: onPressed,
        style: _smallBtnStyle(
          background: background,
          foreground: foreground,
        ),
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _FilterButtonSmall extends StatelessWidget {
  const _FilterButtonSmall({
    required this.count,
    required this.isNarrow,
    required this.onPressed,
  });

  final int count;
  final bool isNarrow;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final button = _SmallBtn(
      isNarrow: true,
      icon: Icons.tune_rounded,
      label: AppLocalizations.of(context)!.filter_label,
      background: const Color.fromARGB(255, 244, 244, 244),
      foreground: Colors.black,
      onPressed: onPressed,
      tooltip: AppLocalizations.of(context)!.filter_tooltip,
    );

    if (count <= 0) return button;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        button,
        Positioned(
          right: -2,
          top: -2,
          child: _CounterBadge(count: count),
        ),
      ],
    );
  }
}

class _CounterBadge extends StatelessWidget {
  const _CounterBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444),
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 2)],
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          height: 1.0,
        ),
      ),
    );
  }
}
