import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:passflow_app/pages/image_constant.dart';

class FaceIdInfoScreen extends StatelessWidget {
  FaceIdInfoScreen({
    Key? key,
    DateTime? plannedArrival,
    DateTime? factArrival,
    this.arrivalStatus = 'Явился',
    this.sectionName = 'Участок Северный',
    this.routeName = 'Астана–Семей',
    this.onRefresh,
  })  : plannedArrival = plannedArrival ?? DateTime(2025, 1, 1, 9, 0),
        factArrival = factArrival ?? DateTime(2025, 1, 1, 9, 5),
        super(key: key);

  final DateTime plannedArrival;
  final DateTime factArrival;
  final String arrivalStatus; 
  final String sectionName;   
  final String routeName;    
  final VoidCallback? onRefresh;

  String _fmt(DateTime dt) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(dt.day)}.${two(dt.month)}.${dt.year} ${two(dt.hour)}:${two(dt.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final items = <_InfoItem>[
      _InfoItem(
        assetPath: ImageConstant.train,
        title: 'Время явки',
        subtitle: _fmt(plannedArrival),
      ),
      _InfoItem(
        assetPath: ImageConstant.train,
        title: 'Время явки факт',
        subtitle: _fmt(factArrival),
      ),
      _InfoItem(
        assetPath: ImageConstant.train,
        iconColor: const Color(0xFF1E6AF2),
        title: 'Статус явки: $arrivalStatus',
      ),
      _InfoItem(
        assetPath: ImageConstant.tickets,
        title: sectionName,
      ),
      _InfoItem.plain(
        title: routeName,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        automaticallyImplyLeading: false,
        titleSpacing: 12,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFEFF6FF),
              ),
              child: Center(
                child: _AppIcon(
                  path: ImageConstant.train,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Информация FaceId',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
            color: const Color(0xFF111827),
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

    return InkWell(
      borderRadius: radius,
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              blurRadius: 22,
              offset: const Offset(0, 10),
              color: Colors.black.withOpacity(0.06),
            ),
          ],
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
                      color: const Color(0xFF111827),
                    ),
                  ),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      item.subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.chevron_right,
              size: 28,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }
}
