import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:passflow_app/widgets/custom_loader.dart';

class RouteHistoryPage extends StatefulWidget {
  const RouteHistoryPage({
    super.key,
    this.items = const [],
    this.itemsFuture,
    this.onRefresh,
    this.onTapItem,
    this.onRangeChanged,
    this.emptyText = 'Нет маршрутов за выбранный период',
  });

  final List<RouteHistoryItem> items;
  final Future<List<RouteHistoryItem>>? itemsFuture;
  final VoidCallback? onRefresh;
  final ValueChanged<RouteHistoryItem>? onTapItem;
  final ValueChanged<DateTimeRange?>? onRangeChanged;
  final String emptyText;

  @override
  State<RouteHistoryPage> createState() => _RouteHistoryPageState();
}

class _RouteHistoryPageState extends State<RouteHistoryPage> {
  DateTimeRange? _range;

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final initial = _range ??
        DateTimeRange(
          start: DateTime(now.year, now.month, now.day)
              .subtract(const Duration(days: 30)),
          end: DateTime(now.year, now.month, now.day),
        );

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 2),
      initialDateRange: initial,
      helpText: 'Выберите период',
      cancelText: 'Отмена',
      confirmText: 'Готово',
      saveText: 'Готово',
    );

    if (!mounted) return;
    if (picked != null) {
      setState(() => _range = picked);
      widget.onRangeChanged?.call(_range);
    }
  }

  void _clearRange() {
    setState(() => _range = null);
    widget.onRangeChanged?.call(_range);
  }

  String _fmtDate(DateTime dt) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(dt.day)}.${two(dt.month)}.${dt.year}';
  }

  List<RouteHistoryItem> _applyRange(List<RouteHistoryItem> items) {
    final r = _range;
    if (r == null) return items;

    final start = DateTime(r.start.year, r.start.month, r.start.day);
    final end = DateTime(r.end.year, r.end.month, r.end.day, 23, 59, 59, 999);

    return items.where((it) {
      return !it.start.isBefore(start) && !it.start.isAfter(end);
    }).toList();
  }

  Widget _buildRangeBar() {
    final r = _range;
    if (r == null) return const SizedBox.shrink();

    final text = 'с ${_fmtDate(r.start)} по ${_fmtDate(r.end)}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          TextButton(
            onPressed: _clearRange,
            child: const Text('Сбросить'),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, List<RouteHistoryItem> items) {
    final filtered = _applyRange(items);

    if (filtered.isEmpty) {
      return Column(
        children: [
          _buildRangeBar(),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  widget.emptyText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        _buildRangeBar(),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, i) {
              final item = filtered[i];
              return _RouteCard(
                item: item,
                onTap: () => widget.onTapItem?.call(item),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = widget.itemsFuture == null
        ? _buildBody(context, widget.items)
        : FutureBuilder<List<RouteHistoryItem>>(
            future: widget.itemsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: DotCircleLoader());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Ошибка загрузки: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ),
                );
              }
              final data = snapshot.data ?? const <RouteHistoryItem>[];

              return _buildBody(context, data);
            },
          );

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        automaticallyImplyLeading: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            color: const Color(0xFF111827),
            onPressed: () => Navigator.of(context).maybePop(),
            splashRadius: 22,
          ),
        ),
        titleSpacing: 8,
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFEFF6FF),
              ),
              child: const Center(
                child: _AppIcon(
                  path: 'assets/svg_icons/train_front.svg',
                  size: 20,
                  tint: Color(0xFF1E6AF2),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'История маршрутов',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _pickRange,
            icon: const Icon(Icons.date_range_outlined),
            color: const Color(0xFF111827),
            splashRadius: 22,
            tooltip: 'Период',
          ),
          IconButton(
            onPressed: () {
              widget.onRangeChanged?.call(_range);
              widget.onRefresh?.call();
            },
            icon: const Icon(Icons.refresh),
            color: const Color(0xFF111827),
            splashRadius: 22,
            tooltip: 'Обновить',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: body,
    );
  }
}

class RouteHistoryItem {
  final int? id;
  final String routeName;
  final double hours;
  final DateTime start;
  final DateTime end;

  const RouteHistoryItem({
    this.id,
    required this.routeName,
    required this.hours,
    required this.start,
    required this.end,
  });

  String get titleText {
    String s = hours.toStringAsFixed(2);
    if (s.endsWith('00')) {
      s = s.substring(0, s.length - 3);
    } else if (s.endsWith('0')) {
      s = s.substring(0, s.length - 1);
    }
    return 'Маршрут: $routeName $s часов';
  }
}

class _RouteCard extends StatelessWidget {
  const _RouteCard({
    required this.item,
    required this.onTap,
  });

  final RouteHistoryItem item;
  final VoidCallback onTap;

  String _fmtDate(DateTime dt) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(dt.day)}.${two(dt.month)}.${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(22);
    final subtitle = '${_fmtDate(item.start)} - ${_fmtDate(item.end)}';

    return InkWell(
      borderRadius: radius,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              blurRadius: 24,
              offset: const Offset(0, 10),
              color: Colors.black.withValues(alpha:0.06),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF1E6AF2),
              ),
              child: Center(
                child: _AppIcon(
                  path: 'assets/svg_icons/train_front.svg',
                  size: 30,
                  tint: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.titleText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}

class _AppIcon extends StatelessWidget {
  const _AppIcon({
    required this.path,
    required this.size,
    this.tint,
  });

  final String path;
  final double size;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final lower = path.toLowerCase();
    final isSvg = lower.endsWith('.svg');

    if (isSvg) {
      return SvgPicture.asset(
        path,
        width: size,
        height: size,
        fit: BoxFit.contain,
        colorFilter:
            tint == null ? null : ColorFilter.mode(tint!, BlendMode.srcIn),
        placeholderBuilder: (_) => Icon(Icons.image_outlined, size: size),
      );
    }

    return Image.asset(
      path,
      width: size,
      height: size,
      fit: BoxFit.contain,
      color: tint,
      errorBuilder: (_, __, ___) =>
          Icon(Icons.image_not_supported_outlined, size: size),
    );
  }
}
