import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:passflow_app/core/services/task_hive_service.dart';
import 'package:passflow_app/data/models/route_sheet_model.dart';
import 'package:passflow_app/data/models/user_model.dart';
import 'package:passflow_app/l10n/app_localizations.dart';
import 'package:passflow_app/utils/network_utils.dart';
import 'package:passflow_app/widgets/dialogs/route_sheet_info_dialog.dart';
import 'package:passflow_app/widgets/faceidscreen.dart';
import 'package:passflow_app/widgets/hours_norms_screen.dart';

class TrainHomePage extends StatefulWidget {
  final ValueChanged<int> onTap;
  const TrainHomePage({
    Key? key,
    required this.onTap,
    // this.routeTitle = '004Ц Нурлы Жол - Алматы-2',
    // this.wagonNumber = '07K',
    // this.statusText = 'Старт рейса',
  }) : super(key: key);

  @override
  State<TrainHomePage> createState() => _TrainHomePageState();
}

class _TrainHomePageState extends State<TrainHomePage> {
  bool _isOffline = false;
  bool _checking = false;
  late final Box<RouteSheetModel> routeSheetBox;
  late final Box<UserModel> userBox;
  UserModel? user;
  String userName = '';
  String routeTitle = '';
  String wagonNumber = '';
  String statusText = '';
  bool _routeStarted = false;
  late final RouteSheetModel? currentRouteSheet;

  StreamSubscription<List<ConnectivityResult>>? _connSub;

  @override
  void initState() {
    super.initState();
    // Инициализация userBox и пользователя
    userBox = Hive.box<UserModel>('userBox');
    user = userBox.get('currentUser');
    routeSheetBox = Hive.box<RouteSheetModel>('routeSheets');
    if (user?.id != null) {
      userName = user!.name;
      currentRouteSheet = routeSheetBox.get(user!.routeSheetId);
      wagonNumber = user?.wagonNumber ?? '';
      if (currentRouteSheet != null) {
        routeTitle = currentRouteSheet?.routeSheetName ?? '';
        final now = DateTime.now();
        final routeStartTime = currentRouteSheet?.routeStartTime;
        final comeTime = currentRouteSheet?.comeTime;

        if ((routeStartTime != null && routeStartTime.isAfter(now)) ||
            (routeStartTime == null &&
                comeTime != null &&
                comeTime.isAfter(now))) {
          _routeStarted = false;
        } else {
          _routeStarted = true;
        }
      }
    }
    _checkConnectionAndInit();
    // _connSub = Connectivity()
    //     .onConnectivityChanged
    //     .listen((results) => _evaluateConnectivity(results));
  }

  @override
  void dispose() {
    _connSub?.cancel();
    super.dispose();
  }

  /// Обработка события смены сетевых интерфейсов
  // Future<void> _evaluateConnectivity(List<ConnectivityResult> results) async {
  //   final hasInterface = results.any((r) =>
  //       r == ConnectivityResult.wifi ||
  //       r == ConnectivityResult.mobile ||
  //       r == ConnectivityResult.ethernet ||
  //       r == ConnectivityResult.vpn ||
  //       r == ConnectivityResult.other);

  //   if (!hasInterface) {
  //     if (mounted) setState(() => _isOffline = true);
  //     return;
  //   }

  //   // Подтверждаем реальный интернет
  //   final online = await NetworkUtils.hasConnection();
  //   if (!mounted) return;

  //   setState(() => _isOffline = !online);

  //   // При возврате в онлайн — мягкая инициализация хранилищ/очередей
  //   if (online) {
  //     await HiveService.initAllHive();
  //   }
  // }

  /// Ручная проверка + инициализация при онлайне (кнопка refresh и первый запуск)
  Future<void> _checkConnectionAndInit() async {
    if (_checking) return;
    setState(() => _checking = true);
    try {
      final online = await NetworkUtils.hasConnection();
      if (!mounted) return;

      setState(() => _isOffline = !online);

      // if (online) {
      //   await HiveService.initAllHive();
      // }
    } on SocketException {
      if (!mounted) return;
      setState(() => _isOffline = true);
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    const bg = Color(0xFFF6F7FB);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 48,
        leadingWidth: 0,
        leading: const SizedBox(),
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 6),
            Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                'assets/svg_icons/train_logo.svg',
                width: 26,
                height: 26,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.hello_name(userName.isNotEmpty ? ', ' + userName : ''),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _checkConnectionAndInit,
            icon: _checking
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : SvgPicture.asset(
                    'assets/svg_icons/refresh_dot.svg',
                    width: 26,
                    height: 26,
                  ),
            color: const Color(0xFF111827),
            tooltip: l10n.check_connection,
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Картинка-шапка
                AspectRatio(
                  aspectRatio: 18 / 6.8,
                  child: Image.asset(
                    'assets/images/train_image.png',
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),

                // Индикатор оффлайна
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(
                      14, _isOffline ? 12 : 0, 14, _isOffline ? 12 : 0),
                  color:
                      _isOffline ? const Color(0xFFFFF3F3) : Colors.transparent,
                  child: _isOffline
                      ? Row(
                          children: [
                            const Icon(Icons.cloud_off,
                                color: Color(0xFFB91C1C), size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                l10n.offline_banner,
                                style: const TextStyle(
                                  color: Color(0xFFB91C1C),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),

                GestureDetector(
                    onTap: currentRouteSheet != null
                        ? () => showRouteSheetModal(context,
                            route: currentRouteSheet!)
                        : null,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E61C6),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: _HeaderInfo(
                        routeTitle: routeTitle,
                        carNumber: wagonNumber,
                        statusText: _routeStarted
                            ? l10n.route_started
                            : l10n.route_not_started,
                      ),
                    )),

                const SizedBox(height: 12),

                // Заголовок блока действий
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.choose_action,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Карточки действий
                _ActionCard(
                  iconBg: const Color(0xFFE9F2FF),
                  iconColor: const Color(0xFF1E6AF2),
                  icon: Icons.support_agent,
                  title: l10n.reporting_title,
                  subtitle: l10n.services_subtitle,
                  // onTap: () => widget.onTap(2),
                  onTap: () => {},
                  svgPath: 'assets/svg_icons/train.svg',
                  isCompact: true,
                  // disabled: true,
                ),
                _ActionCard(
                  iconBg: const Color(0xFFFFF0D4),
                  iconColor: const Color(0xFFFB8C00),
                  icon: Icons.receipt_long,
                  title: l10n.faceid_card_title,
                  subtitle: '',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>  FaceIdInfoScreen(),
                      ),
                    );
                  },
                  svgPath: 'assets/svg_icons/tickets.svg',
                  isCompact: true,
                ),
                _ActionCard(
                  iconBg: const Color(0xFFFFE7E6),
                  iconColor: const Color(0xFFE53935),
                  icon: Icons.qr_code_scanner,
                  title: l10n.working_title,
                  subtitle: '',
                  // onTap: () => widget.onTap(1),
                 onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>  HoursNormsScreen(),
                      ),
                    );
                  },
                  svgPath: 'assets/svg_icons/payment_red.svg',
                  isCompact: true,
                  // disabled: true,
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderInfo extends StatelessWidget {
  const _HeaderInfo({
    required this.routeTitle,
    required this.carNumber,
    required this.statusText,
  });

  final String routeTitle;
  final String carNumber;
  final String statusText;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (routeTitle.isNotEmpty)
          Center(
            child: Text(
              routeTitle,
              style: textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                height: 1.2,
                fontSize: 20,
              ),
            ),
          ),
        if (routeTitle.isNotEmpty) const SizedBox(height: 8),
        if (carNumber.isNotEmpty)
          Center(
            child: Text(
              l10n.wagon_number_label_alt + ' ' + carNumber,
              style: textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        if (carNumber.isNotEmpty) const SizedBox(height: 8),
        if (statusText.isNotEmpty)
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.status_label,
                  style: textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusText == l10n.route_not_started
                        ? const Color.fromARGB(255, 216, 14, 0)
                        : const Color.fromARGB(255, 13, 211, 72),
                    borderRadius: BorderRadius.circular(699),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    statusText,
                    style: textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.iconBg,
    required this.iconColor,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.svgPath,
    this.isCompact = false,
    this.disabled = false,
  });

  final Color iconBg;
  final Color iconColor;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? svgPath;
  final bool isCompact;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final double iconSize = isCompact ? 24 : 28;
    final double iconContainerSize = isCompact ? 48 : 56;
    final double horizontalPadding = isCompact ? 12 : 16;
    final double verticalPadding = isCompact ? 12 : 16;
    final double titleFontSize = isCompact ? 14 : 16;
    final double subtitleFontSize = isCompact ? 12 : 14;
    final double spacingBetweenTexts = isCompact ? 2 : 4;

    return Opacity(
        opacity: disabled ? 0.4 : 1.0,
        child: Semantics(
            button: true,
            enabled: !disabled,
            label: title,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding / 2,
              ),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                elevation: 0,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A000000),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: verticalPadding,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: iconContainerSize,
                          height: iconContainerSize,
                          decoration: BoxDecoration(
                            color: iconBg,
                            shape: BoxShape.circle,
                          ),
                          child: svgPath != null
                              ? SvgPicture.asset(
                                  svgPath!,
                                  width: iconSize,
                                  height: iconSize,
                                )
                              : Icon(icon, color: iconColor, size: iconSize),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF111827),
                                  fontSize: titleFontSize,
                                ),
                              ),
                              SizedBox(height: spacingBetweenTexts),
                              Text(
                                subtitle,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF6B7280),
                                  fontSize: subtitleFontSize,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(CupertinoIcons.right_chevron,
                            color: Color(0xFF9CA3AF)),
                      ],
                    ),
                  ),
                ),
              ),
            )));
  }
}
