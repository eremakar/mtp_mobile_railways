import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:passflow_app/pages/privacy_policy_page.dart';
import 'package:passflow_app/pages/user_agreement_page.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key, this.onOpenPrivacy, this.onOpenTerminalInfo});

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
    final gray = Theme.of(context).textTheme.bodySmall?.color;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'О приложении и терминале',
          overflow: TextOverflow.ellipsis,
          style:
              TextStyle(fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface),
        ),
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: Theme.of(context).iconTheme.color),
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
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 8),
              Text(
                'passflow',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 42,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  'Мобильное приложение для проводников пассажирских поездов, созданное для упрощения рабочих процессов, повышения эффективности и улучшения качества обслуживания пассажиров.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16, height: 1.35, color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Карточка с пунктами
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
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
                  title: 'Политика конфиденциальности',
                  onTap: widget.onOpenPrivacy ??
                      () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const UserAgreementPageScreen(),
                          ),
                        );
                      },
                ),
                Divider(
                    height: 1, thickness: 1, color: Theme.of(context).dividerColor),
                _AboutItem(
                  title: 'Информация о терминале',
                  onTap: widget.onOpenTerminalInfo ??
                      () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PrivacyPolicyPage(),
                          ),
                        );
                      },
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),
          Center(
            child: Text(
              'Версия приложения: $_version',
              style: TextStyle(color: gray),
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
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            Icon(CupertinoIcons.right_chevron, color: Theme.of(context).iconTheme.color?.withValues(alpha:0.6)),
          ],
        ),
      ),
    );
  }
}
