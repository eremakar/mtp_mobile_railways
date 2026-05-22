import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:passflow_app/core/di/service_locator.dart';
import 'package:passflow_app/data/models/employee_profile_model.dart';
import 'package:passflow_app/data/models/user_model.dart';
import 'package:passflow_app/data/repositories/employee_repository.dart';
import 'package:passflow_app/pages/ai_chatbot/ai_chat_webview.dart';
import 'package:passflow_app/pages/profile_page.dart';
import 'package:passflow_app/widgets/page/faceidscreen.dart';
import 'package:localization/localization.dart';
import 'package:hive/hive.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({
    super.key,
    this.onTapProfile,
    this.onTapChangeRoute,
    this.onTapTerminalSettings,
    this.onTapKnowledgeBase,
    this.onTapReportBug,
    this.onTapSupport,
    this.onRefresh,
    this.onTapStatistics,
    this.onTapVacation,
    this.onTapSickLeave,
  });

  final VoidCallback? onTapProfile;
  final VoidCallback? onTapChangeRoute;
  final VoidCallback? onTapTerminalSettings;
  final VoidCallback? onTapKnowledgeBase;
  final VoidCallback? onTapReportBug;
  final VoidCallback? onTapSupport;
  final VoidCallback? onRefresh;
  final VoidCallback? onTapStatistics;
  final VoidCallback? onTapVacation;
  final VoidCallback? onTapSickLeave;

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String fullName = '';
  bool _loadingFullName = false;
  late final EmployeeRepository _employeeRepo;
  int? employeeId;

  @override
  void initState() {
    super.initState();
    _employeeRepo = sl<EmployeeRepository>();
    _loadHeader();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _loadHeader() async {
    int? id;
    String localName = '';

    try {
      if (!Hive.isBoxOpen('userBox')) {
        await Hive.openBox<UserModel>('userBox');
      }
      final currentUser = Hive.box<UserModel>('userBox').get('currentUser');
      id = currentUser?.employeeId;
      localName = currentUser?.name ?? '';

      if (id != null) {
        debugPrint('👤 MenuPage employeeId: $id');
      }
    } catch (e) {
      debugPrint('⚠️ MenuPage cannot read currentUser from Hive: $e');
    }

    if (!mounted) return;
    setState(() {
      employeeId = id;
      fullName = localName;
    });

    if (id == null || id <= 0) return;

    try {
      if (!mounted) return;
      setState(() => _loadingFullName = true);

      final EmployeeProfile profile =
          await _employeeRepo.getEmployeeProfile(employeeId: id);

      if (!mounted) return;
      setState(() {
        fullName = profile.fullName;
      });
    } catch (e) {
      debugPrint('⚠️ MenuPage cannot load employee profile: $e');
    } finally {
      if (mounted) {
        setState(() => _loadingFullName = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'menu-title'.i18n(),
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        // leading: IconButton(
        //   icon: const Icon(CupertinoIcons.back, color: Color(0xFF111827)),
        //   onPressed: () => Navigator.of(context).maybePop(),
        // ),
        actions: [
          IconButton(
            onPressed: widget.onRefresh,
            icon: SvgPicture.asset(
              'assets/svg_icons/refresh.svg',
              width: 20,
              height: 20,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _GroupTitle.i18n('menu-section-profile-settings'),
            _MenuCard(items: [
              _MenuItem(
                title: _loadingFullName
                    ? '...'
                    : (fullName.trim().isNotEmpty ? fullName : '-'),
                leading: Icon(
                  CupertinoIcons.person_circle,
                  size: 26,
                  color: Theme.of(context).iconTheme.color,
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfilePage()),
                  );
                },
              ),
            ]),
            const SizedBox(height: 16),
            const _GroupTitle.i18n('menu-section-support'),
            _MenuCard(items: [
              _MenuItem(
                title: 'menu-knowledge-base'.i18n(),
                leading: Icon(CupertinoIcons.book,
                    size: 24, color: Theme.of(context).iconTheme.color),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ChatWebViewPage()),
                  );
                },
              ),
              _MenuItem(
                title: 'menu-report-bug'.i18n(),
                leading: Icon(CupertinoIcons.exclamationmark_circle,
                    size: 24, color: Theme.of(context).iconTheme.color),
                onTap: widget.onTapReportBug,
              ),
              _MenuItem(
                title: 'menu-app-support'.i18n(),
                leading: Icon(CupertinoIcons.headphones,
                    size: 24, color: Theme.of(context).iconTheme.color),
                onTap: widget.onTapSupport,
              ),
              _MenuItem(
                title: 'Информация FaceID'.i18n(),
                leading: Icon(
                  CupertinoIcons.smiley,
                  size: 24,
                  color: Theme.of(context).iconTheme.color,
                ),
                onTap: () {
                  final now = DateTime.now();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => FaceIdInfoScreen(
                        plannedArrival: now,
                        factArrival: now,
                        employeeId: employeeId,
                        onRefresh: widget.onRefresh,
                      ),
                    ),
                  );
                },
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _GroupTitle extends StatelessWidget {
  final String? text; // direct text (legacy)
  final String? textKey; // i18n key

  const _GroupTitle(this.text) : textKey = null;
  const _GroupTitle.i18n(this.textKey) : text = null;

  @override
  Widget build(BuildContext context) {
    final value = text ?? (textKey != null ? textKey!.i18n() : '');
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
      child: Text(
        value,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.items});

  final List<_MenuItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final boxShadow = isDark
        ? const <BoxShadow>[]
        : const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ];

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        boxShadow: boxShadow,
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i != 0)
              Divider(
                  height: 1,
                  thickness: 1,
                  color: Theme.of(context).dividerColor),
            items[i],
          ],
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
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
            leading,
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
            Icon(CupertinoIcons.right_chevron,
                color: Theme.of(context).iconTheme.color?.withValues(alpha:0.6)),
          ],
        ),
      ),
    );
  }
}
