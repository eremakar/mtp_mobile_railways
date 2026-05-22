import 'package:flutter/material.dart';
import 'package:passflow_app/data/models/route_sheet_model.dart';

/// Что вернёт модалка при закрытии
enum RouteSheetAction { select }

/// Удобный хелпер для показа модального окна.
/// Пример:
/// final action = await showRouteSheetModal(context, route: model);
/// if (action == RouteSheetAction.select) { ... }
Future<RouteSheetAction?> showRouteSheetModal(
  BuildContext context, {
  required RouteSheetModel route,
}) {
  return showModalBottomSheet<RouteSheetAction>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => RouteSheetModal(route: route),
  );
}

/// Контент модального окна
class RouteSheetModal extends StatelessWidget {
  const RouteSheetModal({required this.route});

  final RouteSheetModel route;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trainNumbers = route.trainNumbers ?? const [];
    final wagons = route.wagons ?? const [];

    return SafeArea(
      top: false,
      child: Padding(
        padding: MediaQuery.of(context)
            .viewInsets, // чтобы не перекрывал клавиатурой
        child: ConstrainedBox(
          constraints: BoxConstraints(
            // «пол-экрана» (примерно)
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Хедер с «ручкой»
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        route.routeSheetName.isNotEmpty
                            ? route.routeSheetName
                            : 'Маршрутный лист',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: 'Закрыть',
                      onPressed: () =>
                          Navigator.of(context).pop<RouteSheetAction?>(null),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Состояние/бейджи
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 16),
              //   child: Wrap(
              //     spacing: 8,
              //     runSpacing: 8,
              //     children: [
              //       if ((route.routeSheetState).isNotEmpty)
              //         _Chip(label: 'Статус: ${route.routeSheetState}'),
              //       if (route.taskListTypeId > 0)
              //         _Chip(label: 'Тип задач: ${route.taskListTypeId}'),
              //       _Chip(label: 'ID: ${route.id}'),
              //       if ((route.sapId ?? '').isNotEmpty)
              //         _Chip(label: 'SAP: ${route.sapId}'),
              //       if (route.classId != null)
              //         _Chip(label: 'ClassId: ${route.classId}'),
              //     ],
              //   ),
              // ),
              const SizedBox(height: 8),

              // Контент со скроллом
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: [
                    _Section(
                      title: 'Даты и время',
                      children: [
                        _InfoRow('Дата листа', _fmtDate(route.routeSheetDate)),
                        _InfoRow('Начало маршрута',
                            _fmtDateTime(route.routeStartTime)),
                        _InfoRow('Прибытие', _fmtDateTime(route.comeTime)),
                        _InfoRow('Отправление', _fmtDateTime(route.leaveTime)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _Section(
                      title: 'Станция',
                      children: [
                        _InfoRow('Код станции', route.startStationCode ?? '—'),
                        _InfoRow('Наименование', route.startStationName ?? '—'),
                        _InfoRow('ID', route.startStationId?.toString() ?? '—'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _Section(
                      title: 'Поезда',
                      children: [
                        if (trainNumbers.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text('Нет данных по поездам'),
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: trainNumbers
                                .map((t) => Chip(
                                      label: Text(t),
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ))
                                .toList(),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _Section(
                      title: 'Вагоны',
                      children: [
                        _InfoRow('Количество', wagons.length.toString()),
                        if (wagons.isNotEmpty) const SizedBox(height: 8),
                        if (wagons.isNotEmpty)
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: wagons.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1, thickness: 1),
                              itemBuilder: (_, i) {
                                final w = wagons[i];
                                return ListTile(
                                  dense: true,
                                  visualDensity: VisualDensity.compact,
                                  title: Text(w.order ?? '—'),
                                  subtitle: (w.typeName != null &&
                                          w.typeName!.isNotEmpty)
                                      ? Text('Тип: ${w.typeName}')
                                      : const Text('Тип не указан'),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Кнопки действий
              // Padding(
              //   padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              //   child: Row(
              //     children: [
              //       Expanded(
              //         child: OutlinedButton(
              //           onPressed: () =>
              //               Navigator.of(context).pop<RouteSheetAction?>(null),
              //           child: const Text('Отмена'),
              //         ),
              //       ),
              //       const SizedBox(width: 12),
              //       Expanded(
              //         child: ElevatedButton(
              //           onPressed: () =>
              //               Navigator.of(context).pop<RouteSheetAction>(
              //             RouteSheetAction.select,
              //           ),
              //           child: const Text('Выбрать'),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  // Форматтеры (без дополнительных пакетов)
  static String _fmtDate(DateTime? d) {
    if (d == null) return '—';
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yy = d.year.toString().padLeft(4, '0');
    return '$dd.$mm.$yy';
  }

  static String _fmtDateTime(DateTime? d) {
    if (d == null) return '—';
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${_fmtDate(d)} $h:$m';
  }
}

/// Маленький чип для бейджей
class _Chip extends StatelessWidget {
  const _Chip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

/// Блок с заголовком
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        ...children,
      ],
    );
  }
}

/// «лейбл — значение» в одной строке
class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value, {this.icon});
  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final styleLabel =
        Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54);
    final styleValue = Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: Colors.black45),
            const SizedBox(width: 6),
          ],
          Expanded(child: Text(label, style: styleLabel)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: styleValue,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
