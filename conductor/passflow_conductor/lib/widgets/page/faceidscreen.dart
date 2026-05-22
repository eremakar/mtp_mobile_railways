import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:passflow_app/data/repositories/facei_repo.dart';
import 'package:passflow_app/pages/image_constant.dart';

class _FaceIdData {
  const _FaceIdData({
    required this.comeTime,
    required this.arriveTime,
    required this.isArrived,
    required this.filialName,
    required this.routeName,
  });

  final DateTime? comeTime;
  final DateTime? arriveTime;
  final bool isArrived;
  final String? filialName;
  final String? routeName;
}

class FaceIdInfoScreen extends StatelessWidget {
  const FaceIdInfoScreen({
    super.key,
    required this.plannedArrival,
    required this.factArrival,
    this.arrivalStatus,
    this.sectionName,
    this.routeName,
    this.employeeId,
    this.filialId,
    this.onRefresh,
  });

  final DateTime plannedArrival;
  final DateTime factArrival;
  final String? arrivalStatus;
  final String? sectionName;
  final String? routeName;
  final int? employeeId;
  final int? filialId;
  final VoidCallback? onRefresh;

  String _fmt(DateTime dt) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(dt.day)}.${two(dt.month)}.${dt.year} ${two(dt.hour)}:${two(dt.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final scaffoldBg = theme.scaffoldBackgroundColor;
    final appBarBg = theme.appBarTheme.backgroundColor ?? cs.surface;
    final appBarFg = theme.appBarTheme.foregroundColor ?? cs.onSurface;

    final int? effectiveEmployeeId = employeeId;

    final repo = TransactionsRepository();

    final Future<_FaceIdData> dataFuture = () async {
      if (effectiveEmployeeId == null) {
        return _FaceIdData(
          comeTime: null,
          arriveTime: null,
          isArrived: false,
          filialName: null,
          routeName: routeName,
        );
      }

      final comeInfo =
          await repo.getLatestComeTimeRouteByEmployeeId(effectiveEmployeeId);

      final int? repoFilialId = (comeInfo.filialId is int && (comeInfo.filialId as int) > 0)
          ? (comeInfo.filialId as int)
          : null;
      final int? navFilialId = (filialId != null && filialId! > 0) ? filialId : null;
      final int? effectiveFilialId = repoFilialId ?? navFilialId;

      String? filialName;
      if (effectiveFilialId != null) {
        final name = await repo.getFilialNameByFilialId(effectiveFilialId);
        filialName = (name == null || name.trim().isEmpty) ? null : name.trim();
      }

      return _FaceIdData(
        comeTime: comeInfo.comeTime,
        arriveTime: comeInfo.arriveTime,
        isArrived: comeInfo.isArrived,
        filialName: filialName,
        routeName: comeInfo.routeName,
      );
    }();

    return FutureBuilder<_FaceIdData>(
      future: dataFuture,
      builder: (context, snap) {
        final comeTime = snap.data?.comeTime;
        final arriveTime = snap.data?.arriveTime;
        final isArrived = snap.data?.isArrived ?? false;
        final filialName = snap.data?.filialName;
        final routeNameFromApi = snap.data?.routeName;

        final items = <_InfoItem>[
          _InfoItem(
            assetPath: ImageConstant.train,
            title: 'Время явки',
            subtitle: comeTime == null ? '—' : _fmt(comeTime.toLocal()),
          ),
          _InfoItem(
            assetPath: ImageConstant.train,
            title: 'Время явки факт',
            subtitle: arriveTime == null ? '—' : _fmt(arriveTime.toLocal()),
          ),
          _InfoItem(
            assetPath: ImageConstant.train,
            iconColor: const Color(0xFF1E6AF2),
            title: 'Статус явки: ${snap.connectionState == ConnectionState.waiting ? '—' : (isArrived ? 'Явился' : '-')}',
          ),
          _InfoItem(
            assetPath: ImageConstant.tickets,
            title: 'Участок',
            subtitle: filialName ?? (sectionName ?? 'нет данных'),
          ),
          _InfoItem.plain(
            title: routeNameFromApi ?? (routeName ?? '—'),
          ),
        ];

        return Scaffold(
          backgroundColor: scaffoldBg,
          appBar: AppBar(
            backgroundColor: appBarBg,
            elevation: 2,
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              color: appBarFg,
              onPressed: () {
                Navigator.of(context).maybePop();
              },
            ),
            titleSpacing: 12,
            title: Row(
              children: [
                const SizedBox(width: 10),
                Text(
                  'Информация FaceId',
                  style: (theme.textTheme.titleLarge ?? const TextStyle(fontSize: 20)).copyWith(
                    fontWeight: FontWeight.w700,
                    color: appBarFg,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
                color: appBarFg,
                splashRadius: 22,
                tooltip: 'Обновить',
              ),
              const SizedBox(width: 6),
            ],
          ),
          body: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, i) => _InfoCard(item: items[i]),
          ),
        );
      },
    );
  }
}

class _AppIcon extends StatelessWidget {
  const _AppIcon({
    required this.path,
    required this.size,
  });

  final String path;
  final double size;

  @override
  Widget build(BuildContext context) {
    final lower = path.toLowerCase();
    final isSvg = lower.endsWith('.svg');

    if (isSvg) {
      return SvgPicture.asset(
        path,
        width: size,
        height: size,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        placeholderBuilder: (_) => Icon(
          Icons.image_outlined,
          size: size,
        ),
      );
    }

    return Image.asset(
      path,
      width: size,
      height: size,
      fit: BoxFit.cover,
      colorBlendMode: BlendMode.srcIn,
      errorBuilder: (_, __, ___) => Icon(
        Icons.image_not_supported_outlined,
        size: size,
      ),
    );
  }
}

class _InfoItem {
  const _InfoItem({
    required this.title,
    required this.assetPath,
    this.subtitle,
    this.iconColor,
  }) : isPlain = false;

  const _InfoItem.plain({
    required this.title,
  })  : subtitle = null,
        assetPath = null,
        iconColor = null,
        isPlain = true;

  final String title;
  final String? subtitle;
  final String? assetPath;
  final Color? iconColor;
  final bool isPlain;
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.item});

  final _InfoItem item;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(20);

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = theme.cardColor;
    final titleColor = cs.onSurface;
    final subtitleColor = cs.onSurfaceVariant;
    final chevronColor = cs.onSurfaceVariant;

    final boxShadow = isDark
        ? const <BoxShadow>[]
        : [
            BoxShadow(
              blurRadius: 22,
              offset: const Offset(0, 10),
              color: Colors.black.withValues(alpha:0.06),
            ),
          ];

    return InkWell(
      borderRadius: radius,
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: radius,
          boxShadow: boxShadow,
        ),
        child: Row(
          children: [
            if (!item.isPlain && item.assetPath != null) ...[
              SizedBox(
                width: 64,
                height: 64,
                child: Center(
                  child: _AppIcon(
                    path: item.assetPath!,
                    size: 44,
                  ),
                ),
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: item.isPlain ? 18 : 16,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      item.subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.chevron_right,
              size: 28,
              color: chevronColor,
            ),
          ],
        ),
      ),
    );
  }
}