import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:passflow_app/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

double _sp(BuildContext context, double base) {
  final w = MediaQuery.of(context).size.width;
  final scaled = base * (w / 375.0);
  return scaled.clamp(base * 0.85, base * 1.25);
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? '1';
    setState(() {
      userName = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFFF6F7FB);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.profilePageTitle,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF111827),
            fontSize: _sp(context, 20),
          ),
        ),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Color(0xFF111827)),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset(
              'assets/svg_icons/refresh.svg',
              width: 20,
              height: 20,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 8),
            // Аватар
            CircleAvatar(
              radius: 64,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person_outline,
                size: 100,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {},
              child: Text(
                AppLocalizations.of(context)!.changePhoto,
                style: TextStyle(
                  color: const Color(0xFF1663D6),
                  fontWeight: FontWeight.w700,
                  fontSize: _sp(context, 16),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              userName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: _sp(context, 20),
                fontWeight: FontWeight.w800,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 16),

            // Карточка с данными
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 10,
                      offset: Offset(0, 6)),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
              child: Column(
                children: [
                  _InfoBlock(
                    title: AppLocalizations.of(context)!.iin,
                    value: '-',
                    canCopy: true,
                  ),
                  const Divider(height: 1, color: Color(0x0F111827)),
                  _InfoBlock(
                    title: AppLocalizations.of(context)!.tabNumber,
                    value: '-',
                  ),
                  const Divider(height: 1, color: Color(0x0F111827)),
                  _InfoBlock(
                    title: '-',
                    subtitle: AppLocalizations.of(context)!.category,
                    value: '',
                    showTrailing: false,
                  ),
                  const Divider(height: 1, color: Color(0x0F111827)),
                  _InfoBlock(
                    title: '-',
                    subtitle: AppLocalizations.of(context)!.position,
                    value: '',
                    showTrailing: false,
                  ),
                  const Divider(height: 1, color: Color(0x0F111827)),
                  _InfoBlock(
                    title: '-',
                    subtitle: AppLocalizations.of(context)!.brigade,
                    value: '',
                    showTrailing: false,
                  ),
                  const Divider(height: 1, color: Color(0x0F111827)),
                  _InfoBlock(
                    title: '-',
                    subtitle: AppLocalizations.of(context)!.branch,
                    value: '',
                    showTrailing: false,
                  ),
                  const Divider(height: 1, color: Color(0x0F111827)),
                  _InfoBlock(
                    title: '-',
                    subtitle: AppLocalizations.of(context)!.email,
                    value: '',
                    canEdit: true,
                  ),
                  const Divider(height: 1, color: Color(0x0F111827)),
                  _InfoBlock(
                    title: '-',
                    subtitle: AppLocalizations.of(context)!.phone,
                    value: '',
                    canEdit: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.notificationInfo,
              textAlign: TextAlign.left,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({
    required this.title,
    required this.value,
    this.subtitle,
    this.canCopy = false,
    this.canEdit = false,
    this.showTrailing = true,
  });

  final String title;
  final String value;
  final String? subtitle;
  final bool canCopy;
  final bool canEdit;
  final bool showTrailing;

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      fontSize: _sp(context, 15),
      fontWeight: FontWeight.w800,
      color: const Color(0xFF111827),
    );

    final hintStyle = TextStyle(
      fontSize: _sp(context, 14),
      color: const Color(0xFF6B7280),
      fontWeight: FontWeight.w700,
    );

    final hasValue = value.trim().isNotEmpty;
    final hasSubtitle = subtitle != null && subtitle!.trim().isNotEmpty;
    final labelText = hasSubtitle ? subtitle!.trim() : title;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasValue) ...[
                  Text(value, style: titleStyle),
                  const SizedBox(height: 6),
                  Text(labelText, style: hintStyle),
                ] else if (hasSubtitle) ...[
                  Text(title, style: titleStyle),
                  const SizedBox(height: 6),
                  Text(subtitle!, style: hintStyle),
                ] else ...[
                  // Только заголовок без подписи
                  Text(title, style: titleStyle),
                ],
              ],
            ),
          ),
          if (showTrailing)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (canCopy)
                  IconButton(
                    tooltip: AppLocalizations.of(context)!.copy,
                    icon: const Icon(CupertinoIcons.doc_on_doc,
                        size: 22, color: Color(0xFF6B7280)),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text(AppLocalizations.of(context)!.copied)),
                      );
                    },
                  ),
                if (canEdit)
                  IconButton(
                    tooltip: AppLocalizations.of(context)!.edit,
                    icon: const Icon(CupertinoIcons.pencil,
                        size: 22, color: Color(0xFF6B7280)),
                    onPressed: () {},
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
