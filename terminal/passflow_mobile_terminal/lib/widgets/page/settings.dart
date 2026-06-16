import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:passflow_app/auth/logout_flow.dart';
import 'package:passflow_app/core/services/language_service.dart';
import 'package:passflow_app/l10n/app_localizations.dart';
import 'package:passflow_app/main.dart';
import 'package:passflow_app/pages/splash_screen.dart';
import 'package:passflow_app/widgets/page/about.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

class TerminalSettingsPage extends StatefulWidget {
  const TerminalSettingsPage({
    Key? key,
    this.currentTheme,
    this.onChangeTheme,
    this.onOpenAbout,
    this.onRefresh,
  }) : super(key: key);

  final String? currentTheme;
  final VoidCallback? onChangeTheme;
  final VoidCallback? onOpenAbout;
  final VoidCallback? onRefresh;

  @override
  State<TerminalSettingsPage> createState() => _TerminalSettingsPageState();
}

class _TerminalSettingsPageState extends State<TerminalSettingsPage> {
  String _version = '…';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      setState(() => _version = '${info.version}+${info.buildNumber}');
    } catch (_) {
      setState(() => _version = '0.0.1');
    }
  }

  Future<void> _showLanguageDialog(BuildContext context) async {
    final outer = navigatorKey.currentContext ?? context;
    final l10n = AppLocalizations.of(context)!;

    await showDialog<void>(
      context: outer,
      barrierDismissible: true,
      builder: (ctx) {
        String selectedCode =
            context.watch<LanguageService>().currentLocale.languageCode;
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.white,
              elevation: 0,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 6),
                    Text(
                      l10n.chooseLanguage,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    _LangTile(
                      title: l10n.lang_ru,
                      subtitle: 'ru',
                      selected: selectedCode == 'ru',
                      onTap: () => setState(() => selectedCode = 'ru'),
                    ),
                    const SizedBox(height: 8),
                    _LangTile(
                      title: l10n.lang_kk,
                      subtitle: 'kk',
                      selected: selectedCode == 'kk',
                      onTap: () => setState(() => selectedCode = 'kk'),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () async {
                          await context
                              .read<LanguageService>()
                              .setLanguage(selectedCode);
                          Navigator.of(context, rootNavigator: true).pop();
                          // Приложение пересобирается через notifyListeners(), переход на SplashScreen не нужен
                        },
                        child: Text(l10n.done),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _applyLanguage(
      BuildContext context, String code, String title) async {
    // Persist selection
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', code);

    // Close the picker
    Navigator.of(context, rootNavigator: true).pop();

    // Rebuild app by navigating to SplashScreen with selected language
    final nav = navigatorKey.currentState;
    if (nav != null) {
      nav.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => SplashScreen(languageCode: code)),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const textMain = TextStyle(
        fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF111827));
    const textSub = TextStyle(
        fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF));
    final bg = const Color(0xFFF6F7FB);
    final l10n = AppLocalizations.of(context)!;
    final currentLangLabel =
        context.watch<LanguageService>().currentLocale.languageCode == 'kk'
            ? l10n.lang_kk
            : l10n.lang_ru;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(l10n.terminalSettings,
            style: const TextStyle(
                fontWeight: FontWeight.w800, color: Color(0xFF111827))),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Color(0xFF111827)),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            onPressed: widget.onRefresh,
            icon: SvgPicture.asset('assets/svg_icons/refresh.svg',
                width: 20, height: 20),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _Card(
            children: [
              _Item(
                title: l10n.appLanguage,
                subtitle: currentLangLabel,
                onTap: () => _showLanguageDialog(context),
              ),
              const _Divider(),
              _Item(
                title: l10n.themeInterface,
                subtitle: widget.currentTheme ?? l10n.light,
                onTap: widget.onChangeTheme,
              ),
              const _Divider(),
              _Item(
                title: l10n.aboutAppTerminal,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AboutPage()),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Text(
                  l10n.appVersion(_version),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Center(
            child: TextButton(
              onPressed: () => confirmAndLogout(context),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF6B7280),
                textStyle:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              child: Text(l10n.logoutApp),
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
              color: Color(0x1A000000), blurRadius: 18, offset: Offset(0, 10)),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.title, this.subtitle, this.onTap});
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const titleStyle = TextStyle(
        fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF111827));
    const subStyle = TextStyle(
        fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: titleStyle),
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(subtitle!, style: subStyle),
                  ],
                ],
              ),
            ),
            const Icon(CupertinoIcons.right_chevron, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, thickness: 1, color: Color(0x0F111827));
}

class _LangTile extends StatelessWidget {
  const _LangTile(
      {required this.title,
      required this.subtitle,
      required this.onTap,
      this.selected = false});
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
                color: Color(0x12000000), blurRadius: 10, offset: Offset(0, 4)),
          ],
          border: Border.all(
              color:
                  selected ? const Color(0xFF6796F6) : const Color(0x0F111827)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827))),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF9CA3AF))),
                ],
              ),
            ),
            if (selected)
              const Icon(CupertinoIcons.check_mark_circled_solid,
                  size: 22, color: Color(0xFF6796F6))
          ],
        ),
      ),
    );
  }
}
