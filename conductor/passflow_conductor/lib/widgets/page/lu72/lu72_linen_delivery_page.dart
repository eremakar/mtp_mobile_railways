import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:passflow_app/data/models/user_model.dart';
import 'package:passflow_app/data/models/wagon_lu72_costs_models.dart';
import 'package:passflow_app/widgets/custom_loader.dart';
import 'package:passflow_app/widgets/page/lu72/bloc/lu72_bloc.dart';
import 'package:passflow_app/widgets/page/lu72/bloc/lu72_event.dart';
import 'package:passflow_app/widgets/page/lu72/bloc/lu72_state.dart';
import 'package:passflow_app/widgets/page/lu72/lu72_summary_page.dart';

class Lu72LinenDeliveryPage extends StatelessWidget {
  const Lu72LinenDeliveryPage({
    super.key,
    this.onNext,
  });

  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => Lu72Bloc(
        employeeIdProvider: () async {
          final box = Hive.box<UserModel>('userBox');
          return box.get('currentUser')?.employeeId;
        },
      )..add(Lu72LoadRequested()),
      child: _Lu72Step1View(onNext: onNext),
    );
  }
}

class _Lu72Step1View extends StatelessWidget {
  const _Lu72Step1View({this.onNext});

  final VoidCallback? onNext;

  void _openWagonPicker(BuildContext context, List<String> wagons) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      showDragHandle: true,
      builder: (BuildContext ctx) {
        final sortedWagons = <String>[...wagons]..sort((a, b) {
            int? num(String s) {
              final m = RegExp(r'^\s*(\d+)').firstMatch(s);
              return m == null ? null : int.tryParse(m.group(1)!);
            }

            final na = num(a);
            final nb = num(b);
            if (na != null && nb != null) return na.compareTo(nb);
            if (na != null) return -1;
            if (nb != null) return 1;
            return a.compareTo(b);
          });
        if (sortedWagons.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Нет доступных вагонов',
              style: TextStyle(
                color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                fontSize: 16,
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          itemCount: sortedWagons.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            color: Theme.of(ctx).colorScheme.outlineVariant,
          ),
          itemBuilder: (BuildContext _, int i) {
            final w = sortedWagons[i];
            return ListTile(
              title: Text(
                w,
                style: TextStyle(
                  color: Theme.of(ctx).colorScheme.onSurface,
                ),
              ),
              onTap: () {
                Navigator.pop(ctx);
                context.read<Lu72Bloc>().add(Lu72WagonSelected(w));
              },
            );
          },
        );
      },
    );
  }

  Widget _card({
    required Widget child,
    VoidCallback? onTap,
    bool enabled = true,
  }) {
    final content = Builder(
      builder: (ctx) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: enabled
              ? Theme.of(ctx).colorScheme.surfaceContainerHighest
              : Theme.of(ctx).disabledColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(24),
        ),
        child: child,
      ),
    );

    if (onTap == null) return content;

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: enabled ? onTap : null,
      child: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<Lu72Bloc, Lu72State>(
      builder: (context, s) {
        final isLoading = s.status == Lu72Status.loading;
        final isFailure = s.status == Lu72Status.failure;
        final scheme = Theme.of(context).colorScheme;

        return Scaffold(
          backgroundColor: scheme.surface,
          appBar: AppBar(
            backgroundColor: scheme.surface,
            foregroundColor: scheme.onSurface,
            elevation: 0,
            centerTitle: true,
            title: const Text('ЛУ-72'),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Выберите станцию и места для\nвыдачи постельного',
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontSize: 20,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (isLoading) ...[
                    Text(
                      'Загрузка...',
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (isFailure && s.errorMessage != null) ...[
                    Text(
                      s.errorMessage!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                    const SizedBox(height: 12),
                  ],
                  _card(
                    onTap: null,
                    child: Builder(
                      builder: (ctx) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            s.routeTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: scheme.onSurface,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Text(
                          //   s.routeSubtitle,
                          //   style: TextStyle(
                          //     color: scheme.onSurfaceVariant,
                          //     fontSize: 14,
                          //     fontWeight: FontWeight.w500,
                          //   ),
                          // ),
                          if (('').trim().isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              s.startStationName!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: scheme.onSurfaceVariant,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _card(
                    onTap: () => _openWagonPicker(context, s.wagons),
                    enabled: !isLoading,
                    child: Builder(
                      builder: (ctx) => Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              s.selectedWagon ?? 'Выбрать вагон',
                              style: TextStyle(
                                color: scheme.onSurface,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Icon(Icons.chevron_right,
                              color: scheme.onSurfaceVariant, size: 28),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (s.selectedWagon == null || isLoading)
                          ? null
                          : () {
                              if (onNext != null) {
                                onNext!.call();
                                return;
                              }

                              final bloc = context.read<Lu72Bloc>();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: bloc,
                                    child: const Lu72LinenDeliveryStep2Page(),
                                  ),
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: scheme.primary,
                        foregroundColor: scheme.onPrimary,
                        disabledBackgroundColor: Theme.of(context)
                            .disabledColor
                            .withValues(alpha: 0.12),
                        disabledForegroundColor:
                            Theme.of(context).disabledColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        'Перейти',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class Lu72LinenDeliveryStep2Page extends StatefulWidget {
  const Lu72LinenDeliveryStep2Page({
    super.key,
    this.onAdd,
  });

  final VoidCallback? onAdd;

  @override
  State<Lu72LinenDeliveryStep2Page> createState() =>
      _Lu72LinenDeliveryStep2PageState();
}

class _Lu72LinenDeliveryStep2PageState
    extends State<Lu72LinenDeliveryStep2Page> {
  bool _openSummaryAfterNo = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<Lu72Bloc, Lu72State>(
      listenWhen: (prev, curr) =>
          prev.isUpdatingLu72State != curr.isUpdatingLu72State ||
          prev.selectedLu72State != curr.selectedLu72State ||
          prev.errorMessage != curr.errorMessage,
      listener: (context, s) {
        final msg = (s.errorMessage ?? '').trim();
        if (msg.isNotEmpty) {
          _openSummaryAfterNo = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg)),
          );
          return;
        }

        if (!_openSummaryAfterNo) return;
        if (s.isUpdatingLu72State) return;
        if ((s.selectedLu72State ?? 0) != 0) {
          _openSummaryAfterNo = false;
          return;
        }

        _openSummaryAfterNo = false;
        final bloc = context.read<Lu72Bloc>();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: bloc,
              child: const Lu72SummaryPage(),
            ),
          ),
        );
      },
      builder: (context, s) {
        final costs = s.costItems;
        final hasData = costs.isNotEmpty;
        final scheme = Theme.of(context).colorScheme;

        return Scaffold(
          backgroundColor: scheme.surface,
          appBar: AppBar(
            backgroundColor: scheme.surface,
            foregroundColor: scheme.onSurface,
            elevation: 0,
            centerTitle: true,
            title: Text(
              'ЛУ-72 • ${s.selectedWagon ?? ''}',
              style: const TextStyle(fontSize: 20),
            ),
            bottom: (s.routeClassId == null)
                ? null
                : PreferredSize(
                    preferredSize: const Size.fromHeight(22),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      // child: Text(
                      //   'routeClassId: ${s.routeClassId}',
                      //   style: TextStyle(
                      //     fontSize: 12,
                      //     fontWeight: FontWeight.w600,
                      //     color: scheme.onSurfaceVariant,
                      //   ),
                      // ),
                    ),
                  ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Утвердить',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ToggleButtons(
                          borderRadius: BorderRadius.circular(18),
                          constraints:
                              const BoxConstraints(minHeight: 30, minWidth: 44),
                          isSelected: [
                            (s.selectedLu72State ?? 0) == 0,
                            (s.selectedLu72State ?? 0) == 1,
                          ],
                          onPressed: (!hasData || s.isUpdatingLu72State)
                              ? null
                              : (idx) {
                                  final approved = idx == 1;
                                  _openSummaryAfterNo = !approved;
                                  context.read<Lu72Bloc>().add(
                                        Lu72ApprovalToggled(
                                          approved: approved,
                                        ),
                                      );
                                },
                          children: const [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                'Нет',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                'Да',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (s.isUpdatingLu72State) ...[
                          const SizedBox(width: 8),
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (s.selectedLu72State == 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Не утверждено: доступно для изменений',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    'Станции / места / кол-во по выбранному маршруту:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'RouteSheetId: ${s.routeSheetId ?? '—'}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'RouteSheetItemId: ${s.routeSheetItemId ?? '—'}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'routeClassId: ${s.routeClassId ?? '—'}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (s.status == Lu72Status.loading) ...[
                    const Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: Center(child: DotCircleLoader()),
                    ),
                  ] else if (s.status == Lu72Status.failure &&
                      s.errorMessage != null) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Center(
                        child: Text(
                          s.errorMessage!,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: costs.isEmpty
                          ? Center(
                              child: Text(
                                'Нет данных по местам',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            )
                          : ListView.separated(
                              itemCount: costs.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, i) {
                                final c = costs[i];

                                final stationName =
                                    (c.station?.name ?? '').trim().isNotEmpty
                                        ? c.station!.name
                                        : '—';

                                final seatsLabel = c.occupiedSeatsLabel.trim();
                                final seatsText =
                                    seatsLabel.isEmpty ? '—' : seatsLabel;

                                final issuedCount =
                                    c.totalConsumed ?? c.occupiedSeats.length;
                                final issuedText =
                                    issuedCount > 0 ? '$issuedCount' : '0';

                                return Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: scheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        stationName,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: scheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Места: $seatsText',
                                        softWrap: true,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: scheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Выдано постельного: $issuedText',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: scheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (widget.onAdd != null) {
                      widget.onAdd!.call();
                      return;
                    }

                    final bloc = context.read<Lu72Bloc>();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: bloc,
                          child: const Lu72LinenDeliveryStep3Page(),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Добавить',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class Lu72LinenDeliveryStep3Page extends StatefulWidget {
  const Lu72LinenDeliveryStep3Page({super.key, this.onSubmit});

  final VoidCallback? onSubmit;

  @override
  State<Lu72LinenDeliveryStep3Page> createState() =>
      _Lu72LinenDeliveryStep3PageState();
}

class _Lu72LinenDeliveryStep3PageState
    extends State<Lu72LinenDeliveryStep3Page> {
  int? _selectedStationId;
  String? _selectedStationName;

  final Set<int> _selectedSeats = <int>{};
  bool _saveInProgress = false;
  String _fmtSeat(int n) => n.toString().padLeft(2, '0');

  void _openStationPicker(BuildContext context, List<dynamic> stations) {
    if (stations.isEmpty) return;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      showDragHandle: true,
      builder: (BuildContext ctx) {
        final scheme = Theme.of(ctx).colorScheme;

        int idOf(dynamic s) {
          final v = (s is Map) ? s['id'] : (s as dynamic).id;
          return (v as num?)?.toInt() ?? 0;
        }

        String nameOf(dynamic s) {
          final v = (s is Map) ? s['name'] : (s as dynamic).name;
          return (v as String?) ?? '';
        }

        final sorted = <dynamic>[...stations];

        return ListView.separated(
          shrinkWrap: true,
          itemCount: sorted.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            color: scheme.outlineVariant,
          ),
          itemBuilder: (_, i) {
            final st = sorted[i];
            final id = idOf(st);
            final name = nameOf(st);

            return ListTile(
              title: Text(
                name.isEmpty ? 'Станция $id' : name,
                style: TextStyle(color: scheme.onSurface),
              ),
              // subtitle: Text(
              //   'ID: $id',
              //   style: TextStyle(
              //     color: scheme.onSurfaceVariant,
              //     fontWeight: FontWeight.w600,
              //   ),
              // ),
              onTap: () {
                Navigator.pop(ctx);
                setState(() {
                  _selectedStationId = id;
                  _selectedStationName = name;
                  _selectedSeats.clear();
                });
              },
            );
          },
        );
      },
    );
  }

  void _openSeatPicker(
    BuildContext context, {
    required int seatCount,
    required Set<int> disabledSeats,
  }) {
    final localSelected = <int>{..._selectedSeats};
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext ctx) {
        final scheme = Theme.of(ctx).colorScheme;
        return StatefulBuilder(
          builder:
              (BuildContext _, void Function(void Function()) modalSetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'Выберите места пассажиров',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (seatCount <= 0) ...[
                        Text(
                          'Нет данных о количестве мест для выбранной станции',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ] else ...[
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 8,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 1.35,
                          ),
                          itemCount: seatCount,
                          itemBuilder: (context, index) {
                            final seat = index + 1;
                            final isDisabled = disabledSeats.contains(seat);
                            final isSelected = localSelected.contains(seat);

                            final scheme = Theme.of(ctx).colorScheme;
                            Color bg;
                            Color fg;
                            if (isDisabled) {
                              bg = Theme.of(ctx)
                                  .disabledColor
                                  .withValues(alpha: 0.12);
                              fg = Theme.of(ctx).disabledColor;
                            } else if (isSelected) {
                              bg = scheme.primary;
                              fg = scheme.onPrimary;
                            } else {
                              bg = scheme.surfaceContainerHighest;
                              fg = scheme.onSurface;
                            }

                            return InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: isDisabled
                                  ? null
                                  : () {
                                      modalSetState(() {
                                        if (isSelected) {
                                          localSelected.remove(seat);
                                        } else {
                                          localSelected.add(seat);
                                        }
                                      });
                                    },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 140),
                                curve: Curves.easeOut,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: bg,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color:
                                        isSelected ? bg : scheme.outlineVariant,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  _fmtSeat(seat),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: fg,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (seatCount <= 0)
                              ? null
                              : () {
                                  setState(() {
                                    _selectedSeats
                                      ..clear()
                                      ..addAll(localSelected);
                                  });
                                  Navigator.pop(ctx);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: scheme.primary,
                            foregroundColor: scheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Готово',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<Lu72Bloc, Lu72State>(builder: (context, s) {
      final stations = s.stations;
      if (_selectedStationId == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          int? stationId;
          String? stationName;

          if (s.costItems.isNotEmpty) {
            final first = s.costItems.first;
            stationId = first.station?.id ?? first.stationId;
            stationName = (first.station?.name ?? '').trim();
          } else if (stations.isNotEmpty) {
            stationId = stations.first.id;
            stationName = stations.first.name;
          }

          if (stationId == null) return;

          setState(() {
            _selectedStationId = stationId;
            _selectedStationName = stationName;
          });
        });
      }
      final int? selectedStationId = _selectedStationId;
      WagonLu72CostModel? selectedCost;
      if (selectedStationId != null) {
        for (final e in s.costItems) {
          final int id1 = e.station?.id ?? e.stationId;
          if (id1 == selectedStationId) {
            selectedCost = e;
            break;
          }
        }
      }

      final disabledSeats = selectedCost?.occupiedSeats ?? <int>{};
      int fallbackPlaceCount = 0;
      for (final c in s.costItems) {
        final pc = c.placeCount ?? 0;
        if (pc > fallbackPlaceCount) {
          fallbackPlaceCount = pc;
        }
      }
      int fallbackByOccupiedMax = 0;
      for (final c in s.costItems) {
        for (final seat in c.occupiedSeats) {
          if (seat > fallbackByOccupiedMax) {
            fallbackByOccupiedMax = seat;
          }
        }
      }
      final int seatCountRaw = s.selectedPlaceCount ??
          selectedCost?.placeCount ??
          fallbackPlaceCount;
      final int seatCount =
          seatCountRaw > 0 ? seatCountRaw : fallbackByOccupiedMax;

      if (selectedStationId != null && selectedCost == null) {
        // // ignore: avoid_print
        // print(
        //   '[LU72][DEBUG] selectedCost not found for stationId=$selectedStationId. costItems=${s.costItems.length}',
        // );
      }

      return BlocListener<Lu72Bloc, Lu72State>(
        listenWhen: (prev, curr) =>
            _saveInProgress && prev.status != curr.status,
        listener: (context, st) {
          if (!_saveInProgress) return;

          if (st.status == Lu72Status.loaded) {
            setState(() {
              _saveInProgress = false;
              _selectedSeats.clear();
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Сохранено')),
            );

            Navigator.of(context).pop(); // назад на Step2
            return;
          }

          if (st.status == Lu72Status.failure) {
            setState(() {
              _saveInProgress = false;
            });

            final msg = (st.errorMessage ?? '').trim();
            if (msg.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(msg)),
              );
            }
          }
        },
        child: Builder(
          builder: (ctx) {
            final scheme = Theme.of(ctx).colorScheme;
            return Scaffold(
              backgroundColor: scheme.surface,
              appBar: AppBar(
                backgroundColor: scheme.surface,
                foregroundColor: scheme.onSurface,
                elevation: 0,
                centerTitle: true,
                title: const Text('ЛУ-72.3'),
              ),
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: stations.isEmpty
                            ? null
                            : () => _openStationPicker(context, stations),
                        child: Opacity(
                          opacity: stations.isEmpty ? 0.6 : 1,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: scheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 14),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    (_selectedStationName ?? '')
                                            .trim()
                                            .isNotEmpty
                                        ? _selectedStationName!
                                        : (selectedStationId == null
                                            ? '—'
                                            : 'Станция $selectedStationId'),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: scheme.onSurface,
                                    ),
                                  ),
                                ),
                                Icon(Icons.expand_more,
                                    color: scheme.onSurfaceVariant),
                                // const SizedBox(height: 6),
                                // Text(
                                //   'DEBUG: stationId=${_selectedStationId ?? 'null'} • selectedStation="${(_selectedStationName ?? '').trim().isEmpty ? '—' : _selectedStationName!.trim()}" • routeClassId=${s.routeClassId ?? '—'}',
                                //   maxLines: 2,
                                //   overflow: TextOverflow.ellipsis,
                                //   style: TextStyle(
                                //     fontSize: 12,
                                //     fontWeight: FontWeight.w600,
                                //     color: scheme.onSurfaceVariant,
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: (_selectedStationId == null)
                            ? null
                            : () => _openSeatPicker(
                                  context,
                                  seatCount: seatCount,
                                  disabledSeats: disabledSeats,
                                ),
                        child: Opacity(
                          opacity: (_selectedStationId == null) ? 0.5 : 1,
                          child: Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(minHeight: 64),
                            decoration: BoxDecoration(
                              color: scheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Места пассажиров',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: scheme.onSurface,
                                        ),
                                      ),
                                      // const SizedBox(height: 4),
                                      // Text(
                                      //   'RouteSheetItemId: ${selectedCost?.routeSheetItemId ?? s.routeSheetItemId ?? '—'} • StationId: ${(selectedCost?.station?.id ?? selectedCost?.stationId ?? _selectedStationId) ?? '—'}',
                                      //   maxLines: 1,
                                      //   overflow: TextOverflow.ellipsis,
                                      //   style: TextStyle(
                                      //     fontSize: 12,
                                      //     fontWeight: FontWeight.w600,
                                      //     color: scheme.onSurfaceVariant,
                                      //   ),
                                      // ),
                                      if (_selectedSeats.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          (_selectedSeats.toList()..sort())
                                              .map(_fmtSeat)
                                              .join(', '),
                                          maxLines: 6,
                                          overflow: TextOverflow.visible,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: scheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Icon(Icons.expand_more,
                                    color: scheme.onSurfaceVariant),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              bottomNavigationBar: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_selectedStationId == null ||
                              _selectedSeats.isEmpty)
                          ? null
                          : () async {
                              final routeSheetItemId =
                                  selectedCost?.routeSheetItemId ??
                                      s.routeSheetItemId;
                              final stationId = selectedCost?.station?.id ??
                                  selectedCost?.stationId ??
                                  _selectedStationId;
                              final seats = (_selectedSeats.toList()..sort());

                              // logger.i(
                              //     '[LU72][DEBUG] SAVE pressed: routeSheetItemId=$routeSheetItemId, stationId=$stationId, seats=$seats');

                              if (routeSheetItemId == null ||
                                  stationId == null) {
                                // logger.i(
                                //     '[LU72][DEBUG] SAVE abort: routeSheetItemId/stationId is null');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Не удалось определить RouteSheetItemId или StationId')),
                                );
                                return;
                              }

                              final bloc = context.read<Lu72Bloc>();
                              setState(() {
                                _saveInProgress = true;
                              });
                              bloc.add(
                                Lu72SaveRequested(
                                  stationId: stationId,
                                  seats: seats.toSet(),
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: scheme.primary,
                        foregroundColor: scheme.onPrimary,
                        disabledBackgroundColor: Theme.of(context)
                            .disabledColor
                            .withValues(alpha: 0.12),
                        disabledForegroundColor:
                            Theme.of(context).disabledColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Сохранить',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
