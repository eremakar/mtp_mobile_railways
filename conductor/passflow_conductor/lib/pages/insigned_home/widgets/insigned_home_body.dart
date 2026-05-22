import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:passflow_app/data/models/user_model.dart';
import 'package:passflow_app/data/repositories/route_sheets_repository.dart';
import 'package:passflow_app/data/repositories/pdf_repository.dart';
import 'package:passflow_app/pages/insigned_home/widgets/route_card/route_card_widget.dart';
import 'package:passflow_app/pages/statistics_page.dart';
import 'package:passflow_app/widgets/custom_loader.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class InsignedHomeBody extends StatefulWidget {
  const InsignedHomeBody({super.key});

  @override
  State<InsignedHomeBody> createState() => _InsignedHomeBodyState();
}

class _InsignedHomeBodyState extends State<InsignedHomeBody> {
  final bool _isOffline = false;
  bool _isGeneratingPdf = false;
  final PdfRepository _pdfRepository = PdfRepository();
  late final Future<List<Map<String, dynamic>>> _requestsFuture;
  late final int _userId;
  late final DateTime _now;
  late final String _monthName;

  late final DateTime _statisticsMonth;

  @override
  void initState() {
    super.initState();

    _now = DateTime.now();

    _statisticsMonth = DateTime.utc(_now.year, _now.month, 1);
    _monthName = DateFormat.MMMM('ru').format(_statisticsMonth);

    _userId =
        Hive.box<UserModel>('userBox').get('currentUser')?.employeeId ?? 0;
    _requestsFuture = _fetchRequests(_userId);
  }

  Future<List<Map<String, dynamic>>> _fetchRequests(int userId) async {
    try {
      final repo = RouteSheetsRepository();

      final banner = await repo.getNextOrCurrentRouteBanner(
        employeeId: userId,
      );

      if (banner == null) {
        return [];
      }
      return [
        {
          'routeSheetId': banner.routeSheetId,
          'className': banner.routeName,
          'wagonsLine': '',
          'comeTime': banner.comeTime.toIso8601String(),
        }
      ];
    } catch (e) {
      debugPrint('Ошибка при загрузке баннера маршрута: $e');
      return [];
    }
  }

  List<_PdfMenuItem> _pdfMenuItems(DateTime now) {
    final departureDate = now.toUtc();
    final arrivalDate = departureDate.add(const Duration(hours: 12));

    return [
      _PdfMenuItem(
        title: 'Отчет по сотрудникам',
        templateName: 'employee-report',
        payload: {
          "routeNumber": "ML-12345",
          "trainNumber": "007",
          "departureStation": "Алматы-1",
          "arrivalStation": "Астана-1",
          "departureDate": departureDate.toIso8601String(),
          "arrivalDate": arrivalDate.toIso8601String(),
          "employees": [
            {
              "fullName": "Иванов Иван Иванович",
              "position": "Проводник",
              "wagonNumber": "5"
            },
            {
              "fullName": "Петрова Мария Сергеевна",
              "position": "Старший проводник",
              "wagonNumber": "6"
            }
          ],
          "notes": "Сводный отчет по бригаде за рейс"
        },
      ),
    ];
  }

  Future<void> _onPdfMenuSelected(_PdfMenuItem item) async {
    if (_isGeneratingPdf) return;

    setState(() {
      _isGeneratingPdf = true;
    });

    try {
      final pdfBytes = await _pdfRepository.generatePdf(
        templateName: item.templateName,
        data: item.payload,
      );

      if (!mounted) return;
      if (pdfBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось сформировать PDF')),
        );
        return;
      }

      await _showPdfDialog(
        context: context,
        pdfBytes: pdfBytes,
        title: item.title,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка формирования PDF: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingPdf = false;
        });
      }
    }
  }

  Future<void> _showPdfDialog({
    required BuildContext context,
    required Uint8List pdfBytes,
    required String title,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FractionallySizedBox(
          widthFactor: 1,
          heightFactor: 0.9,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: SfPdfViewer.memory(pdfBytes),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pdfMenuItems = _pdfMenuItems(_now);

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Картинка-шапка
                AspectRatio(
                  aspectRatio: 18 / 6.8,
                  child: Image.asset(
                    'assets/images/train_image.png',
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),

                // Индикатор оффлайна
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(
                      14, _isOffline ? 12 : 0, 14, _isOffline ? 12 : 0),
                  color:
                      _isOffline ? const Color(0xFFFFF3F3) : Colors.transparent,
                  child: _isOffline
                      ? Row(
                          children: [
                            Icon(
                              Icons.cloud_off,
                              color: Theme.of(context).colorScheme.error,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Нет соединения с интернетом. Доступен оффлайн-режим.',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
                NextRouteCard(employeeId: _userId, selectedMonth: _now),
                Padding(
                  padding: const EdgeInsets.only(top: 8, right: 12),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isGeneratingPdf)
                          const Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: DotCircleLoader(),
                            ),
                          ),
                        PopupMenuButton<_PdfMenuItem>(
                          tooltip: 'Сформировать PDF',
                          position: PopupMenuPosition.under,
                          offset: const Offset(0, 6),
                          onSelected: _onPdfMenuSelected,
                          itemBuilder: (context) => pdfMenuItems
                              .map(
                                (item) => PopupMenuItem<_PdfMenuItem>(
                                  value: item,
                                  child: Text(item.title),
                                ),
                              )
                              .toList(),
                          icon: const Icon(
                            Icons.picture_as_pdf_outlined,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _requestsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: DotCircleLoader(),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Text(
                          'Ошибка при загрузке данных',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.8),
                          ),
                        ),
                      );
                    }

                    final data = snapshot.data ?? [];

                    if (data.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 24),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x14000000),
                                blurRadius: 12,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.7),
                                size: 36,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Нет данных за выбранный период',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              Text(
                                'Статистика на $_monthName ${_statisticsMonth.year}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => StatisticsPage(
                                        employeeId: _userId,
                                        selectedDate: _statisticsMonth,
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Все',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                CupertinoIcons.right_chevron,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TripStatisticsRings(
                            employeeId: _userId,
                            selectedDate: _statisticsMonth,
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// class _RequestItem extends StatelessWidget {
//   const _RequestItem({
//     required this.color,
//     required this.iconAsset,
//     required this.title,
//     required this.route,
//     required this.datetime,
//   });

//   final Color color;
//   final String iconAsset;
//   final String title;
//   final String route;
//   final String datetime;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       child: Container(
//         decoration: BoxDecoration(
//           color: Theme.of(context).cardColor,
//           borderRadius: BorderRadius.circular(14),
//           boxShadow: const [
//             BoxShadow(
//               color: Color(0x14000000),
//               blurRadius: 12,
//               offset: Offset(0, 8),
//             ),
//           ],
//         ),
//         padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
//         child: Row(
//           children: [
//             Container(
//               width: 40,
//               height: 40,
//               decoration: BoxDecoration(color: color, shape: BoxShape.circle),
//               child: Center(
//                 child: SvgPicture.asset(
//                   iconAsset,
//                   width: 18,
//                   height: 18,
//                   colorFilter: const ColorFilter.mode(
//                     Colors.white,
//                     BlendMode.srcIn,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w800,
//                       color: Theme.of(context).colorScheme.onSurface,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     route,
//                     style: TextStyle(
//                       fontSize: 13,
//                       color: Theme.of(context).colorScheme.onSurface,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     datetime,
//                     style: TextStyle(
//                       fontSize: 13,
//                       color: Theme.of(context).textTheme.bodySmall?.color,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Icon(
//               CupertinoIcons.right_chevron,
//               color: Theme.of(context).iconTheme.color?.withValues(alpha:0.7),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class _PdfMenuItem {
  const _PdfMenuItem({
    required this.title,
    required this.templateName,
    required this.payload,
  });

  final String title;
  final String templateName;
  final Map<String, dynamic> payload;
}
