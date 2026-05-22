import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:passflow_app/widgets/custom_loader.dart';
import 'notifications_bloc.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationsBloc()..add(const RestoreNotifications()),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            debugPrint('⬅ Закрытие NotificationsScreen через back');
            Navigator.of(context).pop(result);
          }
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text('Уведомления', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
              onPressed: () {
                debugPrint('⬅ Закрытие NotificationsScreen через кнопку в AppBar');
                Navigator.of(context).pop();
              },
            ),        
          ),
          body: BlocBuilder<NotificationsBloc, NotificationsState>(
            builder: (context, state) {
              if (state is NotificationsLoading) {
                return const Center(child: DotCircleLoader());
              }
              final items = (state as NotificationsLoaded).list;

              // 1) Считаем счётчики по категориям
              int cSchedule = 0, cJobs = 0, cStats = 0, cLeave = 0, cNews = 0;
              for (final it in items) {
                final t = (it.title).toLowerCase();
                if (t.contains('график') || t.contains('распис')) {
                  cSchedule++;
                } else if (t.contains('заявк') || t.contains('работ')) {
                  cJobs++;
                } else if (t.contains('статист')) {
                  cStats++;
                } else if (t.contains('отпуск') || t.contains('больнич')) {
                  cLeave++;
                } else if (t.contains('новост') || t.contains('событ')) {
                  cNews++;
                }
              }

              // 2) Фиксированный список категорий
              final categories = <Map<String, dynamic>>[
                {'title': 'Мой график работы', 'count': cSchedule},
                {'title': 'Заявки на работу',   'count': cJobs},
                {'title': 'Статистика',          'count': cStats},
                {'title': 'Отпуск/больничный',   'count': cLeave},
                {'title': 'Новости и события',   'count': cNews},
              ];

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, i) {
                  final cat = categories[i];
                  return _CategoryCard(
                    title: cat['title'] as String,
                    count: cat['count'] as int,
                    onTap: () {
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

// One place to decide which icon to show (SVG assets)
Widget _svgIconForTitle(String title) {
  final t = title.toLowerCase();
  String asset = 'assets/svg_icons/default.svg';
  if (t.contains('график') || t.contains('распис')) {
    asset = 'assets/svg_icons/calendar_days.svg';
  } else if (t.contains('заявк') || t.contains('работ')) {
    asset = 'assets/svg_icons/message_circle.svg';
  } else if (t.contains('статист')) {
    asset = 'assets/svg_icons/chart_pie.svg';
  } else if (t.contains('отпуск') || t.contains('больнич')) {
    asset = 'assets/svg_icons/clipboard_list.svg';
  } else if (t.contains('новост') || t.contains('событ')) {
    asset = 'assets/svg_icons/newspaper.svg';
  }
  return Builder(
    builder: (context) => SvgPicture.asset(
      asset,
      width: 28,
      height: 28,
      colorFilter: ColorFilter.mode(Theme.of(context).iconTheme.color ?? Colors.black, BlendMode.srcIn),
    ),
  );
}

class _RedBadge extends StatelessWidget {
  const _RedBadge({this.text});
  final String? text;

  @override
  Widget build(BuildContext context) {
    if (text == null || text!.isEmpty) return const SizedBox.shrink();
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(color: Theme.of(context).shadowColor.withValues(alpha:0.12), blurRadius: 14, offset: const Offset(0, 6)),
          ],
        ),
        child: Text(
          text!,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onError,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.title, required this.count, this.onTap});

  final String title;
  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(color: Color(0x14000000), blurRadius: 24, offset: Offset(0, 8)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: _svgIconForTitle(title),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            _RedBadge(text: '$count'),
          ],
        ),
      ),
    );
  }
}