import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:passflow_app/auth/logout_flow.dart';
import 'package:passflow_app/l10n/app_localizations.dart';
import 'package:passflow_app/widgets/page/profile.dart';
import 'package:passflow_app/widgets/page/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({
    Key? key,
    this.onTapProfile,
    this.onTapChangeRoute,
    this.onTapTerminalSettings,
    this.onTapKnowledgeBase,
    this.onTapReportBug,
    this.onTapSupport,
    this.onRefresh,
  }) : super(key: key);

  final VoidCallback? onTapProfile;
  final VoidCallback? onTapChangeRoute;
  final VoidCallback? onTapTerminalSettings;
  final VoidCallback? onTapKnowledgeBase;
  final VoidCallback? onTapReportBug;
  final VoidCallback? onTapSupport;
  final VoidCallback? onRefresh;

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? '';
    if (mounted) {
      setState(() {
        userName = name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const bg = Color(0xFFF6F7FB);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          l10n.menu,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
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
            _GroupTitle(l10n.my_profile),
            _MenuCard(items: [
              _MenuItem(
                title: userName,
                leading: const Icon(
                  CupertinoIcons.person_circle,
                  size: 26,
                  color: Color(0xFF111827),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfilePage()),
                  );
                },
              ),
            ]),
            const SizedBox(height: 16),
            _GroupTitle(l10n.route_change),
            _MenuCard(items: [
              _MenuItem(
                title: l10n.choose_route,
                leading: const Icon(CupertinoIcons.train_style_one,
                    size: 24, color: Color(0xFF111827)),
                onTap: widget.onTapChangeRoute,
              ),
            ]),
            const SizedBox(height: 16),
            _GroupTitle(l10n.settings_notifications),
            _MenuCard(items: [
              _MenuItem(
                title: l10n.terminalSettings,
                leading: const Icon(CupertinoIcons.gear_alt_fill,
                    size: 24, color: Color(0xFF111827)),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const TerminalSettingsPage()),
                  );
                },
              ),
            ]),
            const SizedBox(height: 16),
            _GroupTitle(l10n.help_support),
            _MenuCard(items: [
              _MenuItem(
                title: l10n.knowledge_base,
                leading: const Icon(CupertinoIcons.book,
                    size: 24, color: Color(0xFF111827)),
                onTap: widget.onTapKnowledgeBase,
              ),
              _MenuItem(
                title: l10n.report_error,
                leading: const Icon(CupertinoIcons.exclamationmark_circle,
                    size: 24, color: Color(0xFF111827)),
                onTap: widget.onTapReportBug,
              ),
              _MenuItem(
                title: l10n.tech_support,
                leading: const Icon(CupertinoIcons.headphones,
                    size: 24, color: Color(0xFF111827)),
                onTap: widget.onTapSupport,
              ),
            ]),
            const SizedBox(height: 16),
            _MenuCard(items: [
              _MenuItem(
                title: l10n.confirmLogout,
                leading: const Icon(
                  Icons.logout,
                  size: 24,
                  color: Color(0xFFDC2626),
                ),
                titleColor: const Color(0xFFDC2626),
                showChevron: false,
                onTap: () => confirmAndLogout(context),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _GroupTitle extends StatelessWidget {
  const _GroupTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF6B7280),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i != 0)
              const Divider(height: 1, thickness: 1, color: Color(0x0F111827)),
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
    this.titleColor,
    this.showChevron = true,
  });

  final String title;
  final Widget leading;
  final VoidCallback? onTap;
  final Color? titleColor;
  final bool showChevron;

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
                  color: titleColor ?? const Color(0xFF111827),
                ),
              ),
            ),
            if (showChevron)
              const Icon(CupertinoIcons.right_chevron, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}
