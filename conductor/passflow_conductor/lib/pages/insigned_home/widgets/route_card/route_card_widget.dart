import 'package:flutter/material.dart';
import 'package:passflow_app/data/repositories/route_sheets_repository.dart';
import 'package:passflow_app/widgets/custom_loader.dart';

class NextRouteCard extends StatelessWidget {
  final DateTime selectedMonth;
  final int employeeId;

  final RouteSheetsRepository _repo = RouteSheetsRepository();

   NextRouteCard({
    super.key,
    required this.selectedMonth,
    required this.employeeId,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RouteSheetBannerResult>(
      future: _repo.getNextOrCurrentRouteBannerResult(employeeId: employeeId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: DotCircleLoader());
        }
        final result = snapshot.data;
        final banner = result?.banner;
        final hasLoadError = result?.hasError == true;
        final hasRoute = banner != null;

        final title = hasRoute ? banner.title : 'График не сформирован';
        final subtitle = hasRoute ? banner.subtitle : '';
        final routeName = hasRoute ? banner.routeName : '';
        final wagonNumber = hasRoute ? (banner.wagonNumber ?? '') : '';

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: const BoxDecoration(
            color: Color(0xFF1E61C6),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              if (hasLoadError) ...[
                const SizedBox(height: 8),
                InkWell(
                  onTap: () {
                    final status = result?.statusCode?.toString() ?? 'unknown';
                    final rawMessage = result?.errorMessage?.trim();
                    final message = (rawMessage != null && rawMessage.isNotEmpty)
                        ? rawMessage
                        : 'Не удалось загрузить активный маршрут';
                    showDialog<void>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Ошибка маршрута'),
                        content: Text('Статус: $status\n$message'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.amberAccent,
                        size: 18,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Ошибка загрузки маршрута',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (routeName.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  routeName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (wagonNumber.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  'Вагон: $wagonNumber',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 10),
                Builder(
                  builder: (_) {
                    final idx = subtitle.indexOf(':');
                    final hasParts = idx != -1 && idx < subtitle.length - 1;
                    final label = hasParts ? subtitle.substring(0, idx + 1) : '';
                    final value = hasParts ? subtitle.substring(idx + 1).trim() : subtitle;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (label.isNotEmpty) ...[
                          Text(
                            label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 184, 63, 63),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            value,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        );
      },
    );
  }
}
