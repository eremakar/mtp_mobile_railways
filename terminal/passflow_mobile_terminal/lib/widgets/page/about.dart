import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:passflow_app/l10n/app_localizations.dart';
import 'package:passflow_app/widgets/terminal_imei_screen.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({Key? key, this.onOpenPrivacy, this.onOpenTerminalInfo})
      : super(key: key);

  final VoidCallback? onOpenPrivacy;
  final VoidCallback? onOpenTerminalInfo;

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
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

  @override
  Widget build(BuildContext context) {
    const gray = Color(0xFF6B7280);
    const bg = Color(0xFFF6F7FB);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.aboutAppTerminal,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              fontWeight: FontWeight.w800, color: Color(0xFF111827)),
        ),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Color(0xFF111827)),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            onPressed: _loadVersion,
            icon: SvgPicture.asset('assets/svg_icons/refresh.svg',
                width: 20, height: 20),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          const SizedBox(height: 38),
          Column(
            children: [
              SvgPicture.asset(
                'assets/svg_icons/train_logo.svg',
                width: 120,
                height: 120,
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.appName,
                style: const TextStyle(
                  color: Color(0xFF1663D6),
                  fontWeight: FontWeight.w900,
                  fontSize: 32,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  AppLocalizations.of(context)!.appDescription,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16, height: 1.35, color: Color(0xFF111827)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Карточка с пунктами
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 18,
                    offset: Offset(0, 10)),
              ],
            ),
            child: Column(
              children: [
                _AboutItem(
                  title: AppLocalizations.of(context)!.privacyPolicy,
                  onTap: widget.onOpenPrivacy ??
                      () {
                        // TODO: открыть webview/экран с политикой
                      },
                ),
                const Divider(
                    height: 1, thickness: 1, color: Color(0x0F111827)),
                _AboutItem(
                  title: AppLocalizations.of(context)!.terminalInfo,
                  onTap: widget.onOpenTerminalInfo ??
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const TerminalImeiScreen()),
                        );
                      },
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),
          Center(
            child: Text(
              AppLocalizations.of(context)!.appVersion(_version),
              style: const TextStyle(color: gray),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutItem extends StatelessWidget {
  const _AboutItem({required this.title, this.onTap});
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
            ),
            const Icon(CupertinoIcons.right_chevron, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}
