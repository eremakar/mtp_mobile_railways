import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:localization/localization.dart';
import 'package:passflow_app/data/repositories/route_sheet_employees_repository.dart';
import 'package:passflow_app/data/models/user_model.dart';
import 'package:passflow_app/data/repositories/route_sheets_history_repository.dart';
import 'package:passflow_app/widgets/page/lu72/bloc/lu72_bloc.dart';
import 'package:passflow_app/widgets/page/lu72/bloc/lu72_event.dart';
import 'package:passflow_app/widgets/page/history_route.dart';
import 'package:passflow_app/widgets/page/lu72/lu72_linen_delivery_page.dart';
import 'package:passflow_app/widgets/page/lu72/lu72_summary_page.dart';
import 'package:passflow_app/pages/statistics_page.dart';
import 'package:passflow_app/widgets/calc_widget.dart';
import 'package:passflow_app/widgets/page/vu8/vu8_remarks.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({
    super.key,
    this.onTapVacation,
    this.onTapSickLeave,
  });

  final VoidCallback? onTapVacation;
  final VoidCallback? onTapSickLeave;

  Future<_ServicesLeadState> _loadLeadState() async {
    final employeeId = Hive.box<UserModel>('userBox').get('currentUser')?.employeeId;
    if (employeeId == null) {
      return const _ServicesLeadState(
        employeeId: null,
        routeSheetId: null,
        isLead: null,
      );
    }

    final repo = RouteSheetEmployeesRepository();
    final items = await repo.searchEmployeeRouteSheets(employeeId: employeeId) ?? [];
    if (items.isEmpty) {
      return _ServicesLeadState(
        employeeId: employeeId,
        routeSheetId: null,
        isLead: null,
      );
    }

    final now = DateTime.now().toUtc();
    final activeItems = items.where((e) => e.leaveTime.toUtc().isAfter(now)).toList()
      ..sort((a, b) => a.leaveTime.toUtc().compareTo(b.leaveTime.toUtc()));

    final picked = activeItems.isNotEmpty ? activeItems.first : items.first;
    return _ServicesLeadState(
      employeeId: employeeId,
      routeSheetId: picked.routeSheetId,
      isLead: picked.isLead,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'menu-section-services'.i18n(),
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: FutureBuilder<_ServicesLeadState>(
            future: _loadLeadState(),
            builder: (context, snapshot) {
              final leadState = snapshot.data ??
                  const _ServicesLeadState(
                    employeeId: null,
                    routeSheetId: null,
                    isLead: null,
                  );

              return Column(
                children: [
              _ServiceItem(
                title: 'menu-statistics'.i18n(),
                leading: Icon(CupertinoIcons.clock,
                    size: 26, color: Theme.of(context).iconTheme.color),
                onTap: () {
                  final employeeId = Hive.box<UserModel>('userBox')
                      .get('currentUser')
                      ?.employeeId;
                  if (employeeId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Ошибка: не удалось получить идентификатор сотрудника')),
                    );
                    return;
                  }
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => StatisticsPage(
                        employeeId: employeeId,
                        selectedDate: DateTime.now(),
                      ),
                    ),
                  );
                },
              ),
              Divider(
                  height: 1,
                  thickness: 1,
                  color: Theme.of(context).dividerColor),
              _ServiceItem(
                title: 'menu-vacation'.i18n(),
                leading: Icon(CupertinoIcons.briefcase,
                    size: 26, color: Theme.of(context).iconTheme.color),
                onTap: onTapVacation,
              ),
              Divider(
                  height: 1,
                  thickness: 1,
                  color: Theme.of(context).dividerColor),
              _ServiceItem(
                title: 'menu-sick-leave'.i18n(),
                leading: Icon(CupertinoIcons.bandage,
                    size: 26, color: Theme.of(context).iconTheme.color),
                onTap: onTapSickLeave,
              ),
              Divider(
                  height: 1,
                  thickness: 1,
                  color: Theme.of(context).dividerColor),
              _ServiceItem(
                title: 'menu-calc'.i18n(),
                leading: Icon(Icons.calculate_outlined,
                    size: 26, color: Theme.of(context).iconTheme.color),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CargoCalcPage(),
                    ),
                  );
                },
              ),
              Divider(
                  height: 1,
                  thickness: 1,
                  color: Theme.of(context).dividerColor),
              _ServiceItem(
                title: 'История маршрутов'.i18n(),
                leading: Transform.translate(
                  offset: const Offset(0, -1),
                  child: SvgPicture.asset(
                    'assets/svg_icons/train_front.svg',
                    width: 20,
                    height: 20,
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).iconTheme.color ?? Colors.black,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                onTap: () {
                  final employeeId = Hive.box<UserModel>('userBox')
                      .get('currentUser')
                      ?.employeeId;

                  if (employeeId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Ошибка: не удалось получить идентификатор сотрудника'),
                      ),
                    );
                    return;
                  }

                  final repo = RouteSheetsHistoryRepository();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RouteHistoryPage(
                        itemsFuture: repo.searchHistory(employeeId: employeeId),
                        onRefresh: () {},
                      ),
                    ),
                  );
                },
              ),
              Divider(
                  height: 1,
                  thickness: 1,
                  color: Theme.of(context).dividerColor),
              _ServiceItem(
                title: 'ЛУ-72'.i18n(),
                leading: Transform.translate(
                  offset: const Offset(0, -1),
                  child: SvgPicture.asset(
                    'assets/svg_icons/lu72.svg',
                    width: 20,
                    height: 20,
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).iconTheme.color ?? Colors.black,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                       builder: (_) => Lu72LinenDeliveryPage(
                      ),
                    ),
                  );
                },
              ),
              Divider(
                  height: 1,
                  thickness: 1,
                  color: Theme.of(context).dividerColor),
              if (leadState.isLead == true) ...[
                _ServiceItem(
                  title: 'ЛУ-72(Свод)',
                  leading: Transform.translate(
                    offset: const Offset(0, -1),
                    child: SvgPicture.asset(
                      'assets/svg_icons/lu72.svg',
                      width: 20,
                      height: 20,
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).iconTheme.color ?? Colors.black,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (_) => Lu72Bloc(
                            employeeIdProvider: () async {
                              final box = Hive.box<UserModel>('userBox');
                              return box.get('currentUser')?.employeeId;
                            },
                          )..add(Lu72LoadRequested()),
                          child: const Lu72SummaryPage(),
                        ),
                      ),
                    );
                  },
                ),
                Divider(
                    height: 1,
                    thickness: 1,
                    color: Theme.of(context).dividerColor),
              ],
              _ServiceItem(
                title: 'ВУ-8'.i18n(),
                leading: Transform.translate(
                  offset: const Offset(0, -1),
                  child: SvgPicture.asset(
                    'assets/svg_icons/vu8.svg',
                    width: 20,
                    height: 20,
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).iconTheme.color ?? Colors.black,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                onTap: () {
                  final employeeId =
                      Hive.box<UserModel>('userBox').get('currentUser')?.employeeId;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AddRemarkPage(
                        employeeId: employeeId,
                      ),
                    ),
                  );
                },
              ),
            ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ServicesLeadState {
  final int? employeeId;
  final int? routeSheetId;
  final bool? isLead;

  const _ServicesLeadState({
    required this.employeeId,
    required this.routeSheetId,
    required this.isLead,
  });
}

class _ServiceItem extends StatelessWidget {
  const _ServiceItem({
    required this.title,
    required this.leading,
    this.onTap,
  });

  final String title;
  final Widget leading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            SizedBox(
              width: 26,
              height: 26,
              child: Center(child: leading),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
