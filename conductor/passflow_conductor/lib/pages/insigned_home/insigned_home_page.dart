
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:passflow_app/data/models/route_sheet_model.dart';
import 'package:passflow_app/data/models/user_model.dart';
import 'package:passflow_app/pages/insigned_home/widgets/insigned_home_body.dart';
import 'package:passflow_app/pages/profile_page.dart';
import 'package:passflow_app/widgets/notifications/notification_screen.dart';

class TrainHomePage extends StatefulWidget {
  const TrainHomePage({
    super.key,
  });

  @override
  State<TrainHomePage> createState() => _TrainHomePageState();
}

class _TrainHomePageState extends State<TrainHomePage> {

  // bool _isOffline = false;
  // bool _checking = false;
  late final Box<RouteSheetModel> routeSheetBox;
  late final Box<UserModel> userBox;
  UserModel? user;
  String userName = '';
  String routeTitle = '';
  String wagonNumber = '';
  String statusText = '';
  late final RouteSheetModel? currentRouteSheet;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 44,
        centerTitle: true,
        leadingWidth: 52,
        leading: IconButton(
          tooltip: 'Профиль',
          icon: Icon(Icons.account_circle_outlined,
              color: Theme.of(context).iconTheme.color),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const ProfilePage(),
              ),
            );
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/svg_icons/train_logo.svg',
              height: 20,
            ),
            const SizedBox(width: 6),
            Text(
              'passflow',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.primary,
                height: 1.0,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Уведомления',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationsScreen(),
                ),
              );
            },
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.notifications_none_rounded,
                    color: Theme.of(context).iconTheme.color),
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: InsignedHomeBody(),
    );
  }
}
