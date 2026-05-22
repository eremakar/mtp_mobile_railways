import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:passflow_app/data/models/route_model/employ_modal.dart';
import 'package:passflow_app/data/models/route_sheet_employee_day_statistics.dart';
import 'package:passflow_app/data/repositories/employ_repo.dart';
import 'package:passflow_app/data/repositories/route_sheet_employee_day_statistics_repository.dart';
import 'package:passflow_app/pages/statistics_breakdown.dart';
import 'package:passflow_app/widgets/custom_loader.dart';

class StatisticsPage extends StatefulWidget {
  final int employeeId;
  final DateTime selectedDate;

  const StatisticsPage({
    super.key,
    required this.employeeId,
    required this.selectedDate,
  });

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class TripStatisticsRings extends StatelessWidget {
  final int employeeId;
  final DateTime selectedDate;

  const TripStatisticsRings({
    super.key,
    required this.employeeId,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EmployeeStatisticsModel>>(
      future: EmployeeStatisticsRepository()
          .getStatistics(
            employeeId: employeeId,
            year: selectedDate.year,
            month: selectedDate.month,
          )
          .then((value) => value ?? <EmployeeStatisticsModel>[]),
      builder: (context, snapshotTrips) {
        if (snapshotTrips.connectionState == ConnectionState.waiting) {
          return const Center(child: DotCircleLoader());
        } else if (snapshotTrips.hasError) {
          return const Center(child: Text('Ошибка загрузки данных'));
        } else {
          final trips = snapshotTrips.data ?? <EmployeeStatisticsModel>[];

          double workedHours = 0.0;
          double plannedHours = 0.0;
          double normHours = 0.0;
          final seenMonths = <String>{};

          for (final t in trips) {
            plannedHours += (t.plan);
            workedHours += (t.workedHours);

            final m = t.month;
            final monthKey = '${m.year}-${m.month}';

            final mn = t.monthlyNorm?.norm;
            if (mn != null && !seenMonths.contains(monthKey)) {
              normHours += mn.toDouble();
              seenMonths.add(monthKey);
            }
          }
          if (normHours <= 0) {
            normHours = 0.0;
          }

          final workedPct =
              normHours > 0 ? (workedHours / normHours).clamp(0.0, 1.0) : 0.0;
          final planPct =
              normHours > 0 ? (plannedHours / normHours).clamp(0.0, 1.0) : 0.0;

          return _SummaryCard(
            workedHours: workedHours,
            planHours: plannedHours,
            normHours: normHours,
            workedPct: workedPct,
            planPct: planPct,
            normPct: 1.0,
          );
        }
      },
    );
  }
}

class _StatisticsPageState extends State<StatisticsPage>
    with SingleTickerProviderStateMixin {
  DateTime? _startDate;
  DateTime? _endDateExclusive;

  @override
  void initState() {
    super.initState();
    final d = widget.selectedDate;
    _startDate = DateTime.utc(d.year, d.month, 1);
    _endDateExclusive = DateTime.utc(d.year, d.month + 1, 1);
  }

  @override
  Widget build(BuildContext context) {
    String formatPeriod(DateTime start, DateTime endExclusive) {
      String fmt(DateTime dt) =>
          '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
      final endInclusive = endExclusive.subtract(const Duration(days: 1));
      return '${fmt(start)} - ${fmt(endInclusive)}';
    }

    final startDate = _startDate!;
    final endDateExclusive = _endDateExclusive!;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Статистика'),
      ),
      body: Column(
        children: [
          _PeriodPickerCard(
            label: 'Выбрать период',
            value: formatPeriod(startDate, endDateExclusive),
            onPeriodSelected: (start, end) {
              final s = DateTime.utc(start.year, start.month, start.day);
              final eExclusive = DateTime.utc(end.year, end.month, end.day)
                  .add(const Duration(days: 1));
              setState(() {
                _startDate = s;
                _endDateExclusive = eExclusive;
              });
            },
          ),
          TripStatisticsRings(
            employeeId: widget.employeeId,
            selectedDate: startDate,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: "Подробнее"),
                      Tab(text: "По маршрутам"),
                      Tab(text: "По дням"),
                    ],
                    indicatorColor: Color(0xFF2563EB),
                    labelColor: Color(0xFF2563EB),
                    unselectedLabelColor: Color(0xFF6B7280),
                  ),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final statsFuture =
                            EmployeeStatisticsRepository().getStatistics(
                          employeeId: widget.employeeId,
                          year: startDate.year,
                          month: startDate.month,
                        );

                        final tripsFuture = EmployeeStatisticsRepository()
                            .getTripStatistics(
                              employeeId: widget.employeeId,
                              startDate: startDate,
                              endDate: endDateExclusive
                                  .subtract(const Duration(milliseconds: 1)),
                            )
                            .then((value) =>
                                (value ?? []).cast<Map<String, dynamic>>());

                        final detailsFuture =
                            RouteSheetEmployeeDayStatisticsRepository()
                                .search(
                                  from: startDate,
                                  to: endDateExclusive.subtract(
                                      const Duration(milliseconds: 1)),
                                  skip: 0,
                                  take: 1000,
                                  employeeId: widget.employeeId,
                                )
                                .then((paged) => (paged?.items ??
                                    const <RouteSheetEmployeeDayStatisticDto>[]));

                        return TabBarView(
                          children: [
                            _DetailsTab(
                              itemsFuture: detailsFuture,
                              startDate: startDate,
                              endDate: endDateExclusive
                                  .subtract(const Duration(days: 1)),
                            ),
                            _RoutesTab(
                              tripsFuture: tripsFuture,
                              employeeId: widget.employeeId,
                              startDate: startDate,
                              endDateExclusive: endDateExclusive,
                              onPeriodChanged: (start, end) {
                                final s = DateTime.utc(
                                    start.year, start.month, start.day);
                                final eExclusive =
                                    DateTime.utc(end.year, end.month, end.day)
                                        .add(const Duration(days: 1));
                                setState(() {
                                  _startDate = s;
                                  _endDateExclusive = eExclusive;
                                });
                              },
                            ),
                            _DaysTab(
                              statsFuture:
                                  statsFuture.then((value) => value ?? []),
                              startDate: startDate,
                              endDateExclusive: endDateExclusive,
                              onPeriodChanged: (start, end) {
                                final s = DateTime.utc(
                                    start.year, start.month, start.day);
                                final eExclusive =
                                    DateTime.utc(end.year, end.month, end.day)
                                        .add(const Duration(days: 1));
                                setState(() {
                                  _startDate = s;
                                  _endDateExclusive = eExclusive;
                                });
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Вкладка "По маршрутам"
class _RoutesTab extends StatelessWidget {
  final int employeeId;
  final DateTime startDate;
  final DateTime endDateExclusive;
  final void Function(DateTime, DateTime)? onPeriodChanged;
  final Future<List<Map<String, dynamic>>> tripsFuture;
  const _RoutesTab({
    required this.employeeId,
    required this.startDate,
    required this.endDateExclusive,
    this.onPeriodChanged,
    required this.tripsFuture,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: tripsFuture,
      builder: (context, snapshotTrips) {
        if (snapshotTrips.connectionState == ConnectionState.waiting) {
          return const Center(child: DotCircleLoader());
        } else if (snapshotTrips.hasError) {
          return const Center(child: Text('Ошибка загрузки данных'));
        } else {
          final trips = (snapshotTrips.data ?? []) as List;
          DateTime? parseDt(dynamic v) {
            if (v == null) return null;
            if (v is DateTime) return v;
            if (v is String && v.isNotEmpty) {
              return DateTime.tryParse(v);
            }
            return null;
          }

          final DateTime periodStart = startDate;
          final DateTime periodEnd = endDateExclusive;
          if (trips.isEmpty) {
            return const Center(
              child: Text('Нет поездок за выбранный период'),
            );
          } else {
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: trips.length,
              itemBuilder: (context, index) {
                final t = trips[index] as Map<String, dynamic>;
                final rs = t['routeSheet'] as Map<String, dynamic>?;
                // routeclass.name
                final name = rs?['routeclass']?['name'] ??
                    rs?['route']?['name'] ??
                    rs?['class']?['name'] ??
                    rs?['name'] ??
                    'Маршрут';
                final come =
                    parseDt(rs?['routeStartTime']) ?? parseDt(t['arriveTime']);
                final leave =
                    parseDt(rs?['routeEndTime']) ?? parseDt(t['leaveTime']);
                String fmt(DateTime? dt) => (dt == null)
                    ? '-'
                    : '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                double tripHours = 0.0;
                if (come != null && leave != null && leave.isAfter(come)) {
                  final s = come.isBefore(periodStart) ? periodStart : come;
                  final e = leave.isAfter(periodEnd) ? periodEnd : leave;
                  if (e.isAfter(s)) {
                    tripHours = e.difference(s).inMinutes / 60.0;
                  }
                }
                return _TripItem(
                  icon: index.isEven
                      ? _TripIconType.person
                      : _TripIconType.shield,
                  title: name,
                  subtitle: 'с ${fmt(come)} по ${fmt(leave)}',
                  deltaLabel: '+${tripHours.toStringAsFixed(2)} ч',
                );
              },
            );
          }
        }
      },
    );
  }
}

/// Вкладка "По дням"
class _DaysTab extends StatelessWidget {
  final Future<List<EmployeeStatisticsModel>> statsFuture;
  final DateTime startDate;
  final DateTime endDateExclusive;
  final void Function(DateTime, DateTime)? onPeriodChanged;
  const _DaysTab({
    required this.statsFuture,
    required this.startDate,
    required this.endDateExclusive,
    this.onPeriodChanged,
  });

  String _getStateNameById(int? id) {
    switch (id) {
      case 1:
        return 'Выходной';
      case 2:
        return 'Больничный';
      case 3:
        return 'Рабочий';
      default:
        return 'Неизвестно';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EmployeeStatisticsModel>>(
      future: statsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: DotCircleLoader());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Ошибка загрузки данных'));
        } else {
          final dayItems = snapshot.data!
              .expand((e) => e.employeeDayStatistics)
              .where((e) =>
                  !e.date.isBefore(startDate) &&
                  e.date.isBefore(endDateExclusive))
              .toList()
            ..sort((a, b) => a.date.compareTo(b.date));
          if (dayItems.isEmpty) {
            return const Center(child: Text('Нет данных за выбранный период'));
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: dayItems.length,
            itemBuilder: (context, index) {
              final stat = dayItems[index];
              final stateId = stat.employeeDayStateId;
              return _DayStatItem(
                date: stat.date,
                workedHours: stat.workedHours,
                stateId: stateId,
                stateName: _getStateNameById(stateId),
              );
            },
          );
        }
      },
    );
  }
}

class _DayStatItem extends StatelessWidget {
  final DateTime? date;
  final double? workedHours;
  final int? stateId;
  final String? stateName;
  const _DayStatItem({
    required this.date,
    required this.workedHours,
    required this.stateId,
    required this.stateName,
  });
  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color iconColor;
    String label;
    Widget trailing;
    switch (stateId) {
      case 1: // Выходной
        iconData = Icons.weekend_rounded;
        iconColor = Colors.blueGrey;
        label = "Выходной";
        trailing = const SizedBox();
        break;
      case 2: // Больничный
        iconData = Icons.healing_rounded;
        iconColor = Colors.purple;
        label = "Больничный";
        trailing = const SizedBox();
        break;
      case 3: // Рабочий
        iconData = Icons.work_rounded;
        iconColor = Colors.green;
        label = "Рабочий";
        trailing = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.access_time_rounded, size: 18, color: Colors.green),
            const SizedBox(width: 4),
            Text(
              workedHours != null
                  ? "${workedHours!.toStringAsFixed(2)} ч"
                  : "-",
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Colors.green),
            ),
          ],
        );
        break;
      default:
        iconData = Icons.info_outline_rounded;
        iconColor = Colors.grey;
        label = stateName ?? "Неизвестно";
        trailing = const SizedBox();
    }
    String dateStr = date == null
        ? "-"
        : "${date!.day.toString().padLeft(2, '0')}.${date!.month.toString().padLeft(2, '0')}.${date!.year}";
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: iconColor.withValues(alpha: 0.12),
            radius: 22,
            child: Icon(iconData, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dateStr,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 2),
                Text(label,
                    style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).textTheme.bodySmall?.color)),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _PeriodPickerCard extends StatelessWidget {
  const _PeriodPickerCard({
    required this.label,
    required this.value,
    required this.onPeriodSelected,
  });
  final String label;
  final String value;
  final Function(DateTime, DateTime) onPeriodSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
              final picked = await showPeriodRangePicker(context);
              if (picked != null) {
                onPeriodSelected(picked.start, picked.end);
              }
            },
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.workedHours,
    required this.planHours,
    required this.normHours,
    required this.workedPct,
    required this.planPct,
    required this.normPct,
  });

  final double workedHours;
  final double planHours;
  final double normHours;
  final double workedPct;
  final double planPct;
  final double normPct;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _RingStat(
            valueText: '${workedHours.toStringAsFixed(1)} ч',
            caption: 'Отработано',
            progress: workedPct.isFinite ? workedPct.clamp(0.0, 1.0) : 0.0,
            color: const Color(0xFF22C55E),
          ),
          _RingStat(
            valueText: '${planHours.toStringAsFixed(1)} ч',
            caption: 'План',
            progress: planPct.isFinite ? planPct.clamp(0.0, 1.0) : 0.0,
            color: const Color(0xFFF59E0B),
          ),
          _RingStat(
            valueText: '${normHours.toStringAsFixed(1)} ч',
            caption: 'Норма',
            progress: normPct.isFinite ? normPct.clamp(0.0, 1.0) : 0.0,
            color: const Color(0xFF2563EB),
          ),
        ],
      ),
    );
  }
}

class _RingStat extends StatelessWidget {
  const _RingStat({
    required this.valueText,
    required this.caption,
    required this.progress,
    required this.color,
  });
  final String valueText;
  final String caption;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RingGauge(
          size: 108,
          progress: progress,
          color: color,
          trackStrokeWidth: 8,
          progressStrokeWidth: 12,
          child: Text(
            valueText,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          caption,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).textTheme.bodySmall?.color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _RingGauge extends StatelessWidget {
  const _RingGauge({
    required this.size,
    required this.progress,
    required this.color,
    required this.child,
    this.trackStrokeWidth = 8,
    this.progressStrokeWidth = 12,
  });

  final double size;
  final double progress;
  final Color color;
  final Widget child;
  final double trackStrokeWidth;
  final double progressStrokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _RingGaugePainter(
              progress: progress.clamp(0.0, 1.0),
              trackColor: Theme.of(context).dividerColor,
              color: color,
              trackStrokeWidth: trackStrokeWidth,
              progressStrokeWidth: progressStrokeWidth,
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _RingGaugePainter extends CustomPainter {
  _RingGaugePainter({
    required this.progress,
    required this.trackColor,
    required this.color,
    required this.trackStrokeWidth,
    required this.progressStrokeWidth,
  });

  final double progress;
  final Color trackColor;
  final Color color;
  final double trackStrokeWidth;
  final double progressStrokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final double startAngle = -90 * 3.141592653589793 / 180;
    final double p = progress.clamp(0.0, 1.0);
    final double sweep = 2 * 3.141592653589793 * p;

    final Paint track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = trackStrokeWidth
      ..strokeCap = StrokeCap.round
      ..color = trackColor;

    final Paint progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = progressStrokeWidth
      ..strokeCap = StrokeCap.round
      ..color = color;

    final double inset = progressStrokeWidth / 2;
    final Rect arcRect = Rect.fromLTWH(
      rect.left + inset,
      rect.top + inset,
      rect.width - progressStrokeWidth,
      rect.height - progressStrokeWidth,
    );

    canvas.drawArc(arcRect, 0, 2 * 3.141592653589793, false, track);
    if (progress > 0) {
      canvas.drawArc(arcRect, startAngle, sweep, false, progressPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RingGaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.trackStrokeWidth != trackStrokeWidth ||
        oldDelegate.progressStrokeWidth != progressStrokeWidth ||
        oldDelegate.trackColor != trackColor;
  }
}

enum _TripIconType { person, shield }

class _TripItem extends StatelessWidget {
  const _TripItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.deltaLabel,
  });

  final _TripIconType icon;
  final String title;
  final String subtitle;
  final String deltaLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 15),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: _buildTripIcon(context),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).textTheme.bodySmall?.color),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              deltaLabel,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTripIcon(BuildContext context) {
    switch (icon) {
      case _TripIconType.person:
        return SvgPicture.asset(
          'assets/svg_icons/train_front.svg',
          width: 22,
          height: 22,
          colorFilter: ColorFilter.mode(
              Theme.of(context).colorScheme.primary, BlendMode.srcIn),
        );
      case _TripIconType.shield:
        return SvgPicture.asset(
          'assets/svg_icons/shield_check.svg',
          width: 22,
          height: 22,
          colorFilter: ColorFilter.mode(
              Theme.of(context).colorScheme.secondary, BlendMode.srcIn),
        );
    }
  }
}

class _DetailsTab extends StatelessWidget {
  final Future<List<RouteSheetEmployeeDayStatisticDto>> itemsFuture;
  final DateTime startDate;
  final DateTime endDate;

  const _DetailsTab({
    required this.itemsFuture,
    required this.startDate,
    required this.endDate,
  });

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RouteSheetEmployeeDayStatisticDto>>(
      future: itemsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: DotCircleLoader());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Ошибка загрузки данных'));
        }

        final items =
            snapshot.data ?? const <RouteSheetEmployeeDayStatisticDto>[];
        if (items.isEmpty) {
          return const Center(child: Text('Нет данных за выбранный период'));
        }

        double total = 0.0;
        double holiday = 0.0;
        double securityTotal = 0.0;

        final workedByEmployee = <int, double>{};
        final typeCount = <int, int>{};
        final typeName = <int, String>{};
        final typePlaceCount = <int, int?>{};

        for (final e in items) {
          total += e.total;
          holiday += e.holidayTime;
          securityTotal += e.securityTotal;

          final rseId = e.routeSheetEmployeeId;
          final wh = e.routeSheetEmployee?.workedHours;
          if (wh != null) {
            workedByEmployee.putIfAbsent(rseId, () => wh);
          }

          final wtId = e.wagonTypeId;
          final wt = e.wagonType;

          typeCount[wtId] = (typeCount[wtId] ?? 0) + 1;
          if (wt != null) {
            typeName[wtId] = wt.name;
            typePlaceCount[wtId] = wt.placeCount;
          }
        }
        final workedHours =
            workedByEmployee.values.fold<double>(0.0, (a, b) => a + b);

        int? topTypeId;
        int topCnt = -1;
        typeCount.forEach((k, v) {
          if (v > topCnt) {
            topCnt = v;
            topTypeId = k;
          }
        });

        final topTypeTitle = (topTypeId == null)
            ? '—'
            : (() {
                final n = typeName[topTypeId] ?? '—';
                final pc = typePlaceCount[topTypeId];
                return (pc == null) ? n : '$n($pc)';
              })();

        final totalPlusHoliday = total + holiday;

        Widget row(String label, String value, {bool bold = false}) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Text(
              'Нормы часов',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 18,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  row('Тип вагона:', topTypeTitle),
                  const SizedBox(height: 8),
                  row('Действует с:', _fmtDate(startDate)),
                  row('Действует по:', _fmtDate(endDate)),
                  const Divider(height: 22),
                  row('Рабочее время за рейс', workedHours.toStringAsFixed(2)),
                  row('Охрана', securityTotal.toStringAsFixed(2)),
                  row('Время работы', total.toStringAsFixed(2)),
                  row('Время отдыха', holiday.toStringAsFixed(2)),
                  const Divider(height: 22),
                  row('Итого', totalPlusHoliday.toStringAsFixed(2), bold: true),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
