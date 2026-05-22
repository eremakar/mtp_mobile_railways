import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passflow_app/data/models/wagon_lu72_costs_models.dart';
import 'package:passflow_app/widgets/page/lu72/bloc/lu72_bloc.dart';
import 'package:passflow_app/widgets/page/lu72/bloc/lu72_event.dart';
import 'package:passflow_app/widgets/page/lu72/bloc/lu72_state.dart';

class Lu72SummaryPage extends StatefulWidget {
  const Lu72SummaryPage({super.key});

  @override
  State<Lu72SummaryPage> createState() => _Lu72SummaryPageState();
}

class _Lu72SummaryPageState extends State<Lu72SummaryPage> {
  final TextEditingController _conductorsCtrl = TextEditingController();
  final TextEditingController _staffCtrl = TextEditingController();
  int? _lastAttendantsValue;
  int? _lastStaffValue;

  @override
  void dispose() {
    _conductorsCtrl.dispose();
    _staffCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;
    final horizontalPad = width < 380 ? 12.0 : 16.0;

    return BlocBuilder<Lu72Bloc, Lu72State>(
      builder: (context, s) {
        final costs = s.costItems;
        final hasData = costs.isNotEmpty;
        final attendants = s.routeSheetLu72AttendantsCount;
        final staff = s.routeSheetLu72StaffCount;

        if (_lastAttendantsValue != attendants) {
          _lastAttendantsValue = attendants;
          _conductorsCtrl.text = attendants?.toString() ?? '';
        }
        if (_lastStaffValue != staff) {
          _lastStaffValue = staff;
          _staffCtrl.text = staff?.toString() ?? '';
        }

        return Scaffold(
          backgroundColor: scheme.surface,
          appBar: AppBar(
            backgroundColor: scheme.surface,
            foregroundColor: scheme.onSurface,
            elevation: 0,
            centerTitle: false,
            title: const Text('ЛУ-72(Свод)'),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding:
                  EdgeInsets.fromLTRB(horizontalPad, 10, horizontalPad, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Сводная информация ЛУ-72',
                    style: TextStyle(
                      fontSize: 18,
                      height: 1.2,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    child: hasData
                        ? _summaryTable(context, s, costs)
                        : Padding(
                            padding: const EdgeInsets.all(18),
                            child: Text(
                              'Нет данных для свода',
                              style: TextStyle(
                                color: scheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(width < 380 ? 12 : 14),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    child: Column(
                      children: [
                        _editableRow(
                          title: 'Проводники',
                          controller: _conductorsCtrl,
                          onApply: () async {
                            final bloc = context.read<Lu72Bloc>();
                            final value = await _openValueEditor(
                              title: 'Проводники',
                              initialValue: _conductorsCtrl.text,
                            );
                            if (!mounted || value == null) return;
                            bloc.add(
                              Lu72SummaryMetaSaveRequested(
                                lu72AttendantsCount: value,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        _editableRow(
                          title: 'Персонал',
                          controller: _staffCtrl,
                          onApply: () async {
                            final bloc = context.read<Lu72Bloc>();
                            final value = await _openValueEditor(
                              title: 'Персонал',
                              initialValue: _staffCtrl.text,
                            );
                            if (!mounted || value == null) return;
                            bloc.add(
                              Lu72SummaryMetaSaveRequested(
                                lu72StaffiCount: value,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding:
                  EdgeInsets.fromLTRB(horizontalPad, 10, horizontalPad, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: hasData ? () {} : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    disabledBackgroundColor:
                        Theme.of(context).disabledColor.withValues(alpha: 0.12),
                    disabledForegroundColor: Theme.of(context).disabledColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Сформировать ведомость',
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

  Widget _summaryTable(
    BuildContext context,
    Lu72State s,
    List<WagonLu72CostModel> costs,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;
    int passOf(WagonLu72CostModel c) {
      final lu72Consumed = c.lu72?.totalConsumed;
      if (lu72Consumed != null && lu72Consumed > 0) return lu72Consumed;

      final consumed = c.totalConsumed;
      if (consumed != null && consumed > 0) return consumed;

      final occupiedCount = c.occupiedSeats.length;
      if (occupiedCount > 0) return occupiedCount;

      final passengers = c.totalPassengers;
      if (passengers != null && passengers > 0) return passengers;

      final places = c.placeCount;
      if (places != null && places > 0) return places;

      return 0;
    }

    final totalPass = costs.fold<int>(0, (sum, c) => sum + passOf(c));

    String titleOf(WagonLu72CostModel c) {
      final stationName = (c.station?.name ?? '').trim();
      return stationName.isNotEmpty ? stationName : '—';
    }

    TableRow row({
      required List<Widget> cells,
      Color? bg,
      EdgeInsetsGeometry padding =
          const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
    }) {
      return TableRow(
        decoration: BoxDecoration(color: bg),
        children: cells
            .map((w) => Padding(
                  padding: padding,
                  child: w,
                ))
            .toList(growable: false),
      );
    }

    final tableWidth = width < 380 ? 330.0 : width - 35;
    final w0 = tableWidth * 0.70;
    final w1 = tableWidth * 0.16;
    final w2 = tableWidth * 0.10;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: tableWidth,
        decoration: BoxDecoration(
          border: Border.all(
              color: const Color.fromARGB(136, 36, 36, 36), width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Table(
          border: const TableBorder(
            horizontalInside:
                BorderSide(color: Color.fromARGB(137, 78, 78, 78), width: 1),
            verticalInside:
                BorderSide(color: Color.fromARGB(137, 78, 78, 78), width: 1),
          ),
          columnWidths: {
            0: FixedColumnWidth(w0),
            1: FixedColumnWidth(w1),
            2: FixedColumnWidth(w2),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            row(
              cells: [
                const Center(
                  child: Text(
                    'Вагон',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                ),
                const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Выдано',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Пасс',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                const SizedBox.shrink(),
              ],
              padding: const EdgeInsets.symmetric(vertical: 6),
              bg: scheme.surface,
            ),
            ...costs.asMap().entries.map(
                  (entry) => row(
                    cells: [
                      Text(
                        titleOf(entry.value),
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      Center(
                        child: Text(
                          '${passOf(entry.value)}',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                      ),
                      Center(
                        child: Icon(
                          (entry.value.lu72?.state == 1)
                              ? Icons.check
                              : Icons.close,
                          size: 18,
                        ),
                      ),
                    ],
                    bg: Colors.transparent,
                  ),
                ),
            row(
              cells: [
                const Text(
                  'Итого',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                Center(
                  child: Text(
                    '$totalPass',
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox.shrink(),
              ],
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              bg: scheme.surface,
            ),
          ],
        ),
      ),
    );
  }

  Widget _editableRow({
    required String title,
    required TextEditingController controller,
    required VoidCallback onApply,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(
          width: 50,
          child: TextField(
            controller: controller,
            readOnly: true,
            enableInteractiveSelection: false,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: scheme.onPrimary,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: onApply,
          borderRadius: BorderRadius.circular(10),
          child: const Padding(
            padding: EdgeInsets.all(2),
            child: Icon(Icons.edit_outlined, size: 22),
          ),
        ),
      ],
    );
  }

  Future<int?> _openValueEditor({
    required String title,
    required String initialValue,
  }) async {
    String currentValue = initialValue;
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextFormField(
          initialValue: initialValue,
          autofocus: true,
          keyboardType: TextInputType.number,
          onChanged: (value) => currentValue = value,
          decoration: const InputDecoration(
            hintText: 'Введите значение',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              final value = int.tryParse(currentValue.trim());
              Navigator.of(context).pop(value);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
    return result;
  }
}
