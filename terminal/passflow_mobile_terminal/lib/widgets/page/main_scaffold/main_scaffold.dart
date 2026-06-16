import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:passflow_app/data/models/route_sheet_model.dart';
import 'package:passflow_app/data/models/user_model.dart';
import 'package:passflow_app/pages/boardings_list/boarding_page_screen.dart';
import 'package:passflow_app/pages/route_sheet/screen/task_route.dart';
import 'package:passflow_app/data/models/boarding_model.dart';
import 'package:passflow_app/widgets/bottom_nagivation.dart';
import 'package:passflow_app/widgets/offline_mode_banner.dart';
import 'package:passflow_app/widgets/page/Equipment/equipment_fiu11.dart';
import 'package:passflow_app/widgets/page/Services_Carriage/sanitary_condition.dart';
import 'package:passflow_app/widgets/page/Services_Carriage/services_carriage_start.dart';
import 'package:passflow_app/widgets/page/Services_Carriage/technical_condition.dart';
import 'package:passflow_app/widgets/page/boarding.dart';
import 'package:passflow_app/widgets/page/carriage_select.dart';
import 'package:passflow_app/widgets/page/insigned_home.dart';
import 'package:passflow_app/widgets/page/lu72/lu72_linen_delivery.dart';
import 'package:passflow_app/widgets/page/main_scaffold/dialogs/main_scaffold_dialogs.dart';
import 'package:passflow_app/widgets/page/menu.dart';
import 'package:passflow_app/widgets/page/select_wagon.dart';
import 'package:passflow_app/widgets/page/vu8/vu8_remarks.dart';
import 'package:passflow_app/data/repositories/vu8_repository.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({
    Key? key,
    this.initialIndex = 0,
    this.isOnline = true,
    this.offlineTickets,
  }) : super(key: key);

  final int initialIndex;
  final bool isOnline;
  final TicketsSearchModel? offlineTickets;
  static _MainScaffoldState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MainScaffoldState>();

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  UserModel? user;
  late final Box<UserModel> userBox;
  late final Box<RouteSheetModel> routeSheetBox;
  int _currentIndex = 0;
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    userBox = Hive.box<UserModel>('userBox');
    user = userBox.get('currentUser');
    // userBox.clear();
    routeSheetBox = Hive.box<RouteSheetModel>('routeSheets');
  }

  final List<String> _tabs = [
    '/main',
    '/boarding',
    '/menu',
  ];

  void goToTab(int index) {
    if (index < 0 || index >= _tabs.length) return;
    setState(() => _currentIndex = index);
    _navigatorKey.currentState!.pushReplacementNamed(_tabs[index]);
  }

  Widget _buildPage(String name, {Object? args}) {
    switch (name) {
      case '/services':
        return WagonServicesPage(
          wagonId: (user?.wagonNumber is int)
              ? (user!.wagonNumber as int)
              : int.tryParse(user?.wagonNumber?.toString() ?? '') ?? 0,
          counters: const WagonServicesCounters(
            sanitaryDone: 0,
            sanitaryTotal: 3,
            technicalDone: 0,
            technicalTotal: 5,
            equipmentDone: 0,
            equipmentTotal: 0,
            lu72Done: 0,
            lu72Total: 100,
            vu8Count: 0,
          ),
          onOpenSanitary: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SanitaryStatePage()),
            );
          },
          onOpenTechnical: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TechnicalStatePage()),
            );
          },
          onOpenEquipment: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EquipmentMainPage()),
            );
          },
          onOpenLU72: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const Lu72LinenDeliveryPage(conductorId: 251,)), //временно для теста
            );
          },
          onOpenVU8: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddRemarkPage(
                  repository: Vu8Repository(),
                  wagonId: 16, // для теста указал 16
                ),
              ),
            );
          },
          onRefresh: () async {/* TODO: refresh logic */},
        );
      case '/boarding':
        // if (args is TicketsSearchModel) {
        //   return BoardingsListScreen(ticketsSearchModel: args);
        // }
        // if (widget.offlineTickets != null) {
        //   return BoardingsListScreen(
        //       ticketsSearchModel: widget.offlineTickets!);
        // }
        // return const SizedBox.expand(
        //   child: Center(
        //       child: Text(
        //           'Не передана ticketsSearchModel для BoardingsListScreen')),
        // );
        // return BoardingPassengersPage();
        return BoardingPageScreen();
      case '/menu':
        return MenuPage(
          onTapChangeRoute: () async {
            if (user != null) {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TaskRouteScreen(
                    onPressed: (int selectedRouteSheetId) async {
                      user!.routeSheetId = selectedRouteSheetId;
                      user!.save();
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted)
                          openSelectTrainNumberModel(
                            context: context,
                            onTap: () {
                              goToTab(_currentIndex);
                              Navigator.of(context).pop();
                            },
                            routeSheetBox: routeSheetBox,
                            user: user,
                          );
                      });
                    },
                  ),
                ),
              );
            }
          },
        );
      case '/main':
      default:
        if (widget.isOnline &&
            user?.routeSheetId != null &&
            user?.trainNumber != null &&
            user?.wagonNumber != null) {
          return TrainHomePage(onTap: goToTab);
        } else {
          return TaskRouteScreen(
            onPressed: (int selectedRouteSheetId) async {
              if (user != null) {
                user!.routeSheetId = selectedRouteSheetId;
                user!.save();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted)
                    openSelectTrainNumberModel(
                        context: context,
                        onTap: () {
                          goToTab(_currentIndex);
                        },
                        routeSheetBox: routeSheetBox,
                        user: user);
                });
              }
            },
          );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const OfflineModeBanner(),
          Expanded(
            child: Navigator(
        key: _navigatorKey,
        onGenerateInitialRoutes: (navigator, initialRoute) => [
          PageRouteBuilder(
            settings: RouteSettings(name: _tabs[_currentIndex]),
            pageBuilder: (_, __, ___) => _buildPage(_tabs[_currentIndex]),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        ],
        onGenerateRoute: (settings) {
          final String routeName = settings.name ?? '/main';
          final Widget page = _buildPage(routeName, args: settings.arguments);
          return PageRouteBuilder(
            settings: settings,
            pageBuilder: (_, __, ___) => page,
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          );
        },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: goToTab,
      ),
    );
  }
}
