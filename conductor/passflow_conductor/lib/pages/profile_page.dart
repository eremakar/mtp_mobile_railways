import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:passflow_app/core/di/service_locator.dart';
import 'package:passflow_app/data/models/employee_profile_model.dart';
import 'package:passflow_app/data/models/user_model.dart';
import 'package:passflow_app/data/repositories/employee_repository.dart';
import 'package:passflow_app/pages/settings.dart';
import 'package:localization/localization.dart';
import 'package:passflow_app/widgets/custom_loader.dart';
import 'package:passflow_app/widgets/page/documents_menu/documents_menu_screen.dart';

double _sp(BuildContext context, double base) {
  final w = MediaQuery.of(context).size.width;
  final scaled = base * (w / 375.0);
  return scaled.clamp(base * 0.85, base * 1.25);
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final EmployeeRepository _employeeRepo;

  int? _employeeId;

  bool _loadingProfile = false;
  String? _profileError;
  EmployeeProfile? _profile;

  @override
  void initState() {
    super.initState();
    _employeeRepo = sl<EmployeeRepository>();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loadingProfile = true;
      _profileError = null;
    });

    try {
      if (!Hive.isBoxOpen('userBox')) {
        await Hive.openBox<UserModel>('userBox');
      }
      final currentUser = Hive.box<UserModel>('userBox').get('currentUser');
      final employeeId = currentUser?.employeeId ?? 0;

      if (employeeId <= 0) {
        throw Exception('employeeId not found in Hive userBox[currentUser]');
      }

      final profile = await _employeeRepo.getEmployeeProfile(
        employeeId: employeeId,
      );

      if (!mounted) return;
      setState(() {
        _employeeId = employeeId;
        _profile = profile;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _profileError = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingProfile = false;
        });
      }
    }
  }

  Future<void> _refreshProfile() => _loadProfile();

  String? _avatarUrl() {
    final v = _profile?.s3Photo?.trim();
    if (v == null || v.isEmpty) return null;
    final uri = Uri.parse(v);
    if (uri.hasScheme) return v;
    return Uri.parse('http://185.47.167.26').resolve(v).toString();
  }

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).colorScheme.surface;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'profile-title'.i18n(),
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: _sp(context, 20),
          ),
        ),
        leading: IconButton(
          icon: Icon(CupertinoIcons.back,
              color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
            icon: Icon(Icons.settings_outlined,
                color: Theme.of(context).iconTheme.color),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProfile,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 8),
              // Аватар
              Builder(
                builder: (context) {
                  final url = _avatarUrl();
                  const radius = 64.0;

                  if (url == null) {
                    return CircleAvatar(
                      radius: radius,
                      backgroundColor: bg,
                      child: Icon(
                        Icons.person_outline,
                        size: 100,
                        color: Colors.grey.shade400,
                      ),
                    );
                  }

                  return Container(
                    width: radius * 2,
                    height: radius * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: bg,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.person_outline,
                            size: 100,
                            color: Colors.grey.shade400,
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: DotCircleLoader(),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),
              Text(
                (_profile?.fullName ?? (_loadingProfile ? '...' : '-')),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: _sp(context, 20),
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),

              // Карточка с данными
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
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
                    if (_loadingProfile)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: const [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: DotCircleLoader(),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Загрузка...',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_profileError != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                size: 18, color: Colors.redAccent),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _profileError!,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    _InfoBlock(
                      title: 'profile-field-iin'.i18n(),
                      value: _profile?.iin ?? '-',
                      canCopy: true,
                    ),
                    Divider(height: 1, color: Theme.of(context).dividerColor),
                    _InfoBlock(
                      title: 'profile-field-staff-number'.i18n(),
                      value: _profile?.tableNumber ?? '-',
                    ),
                    Divider(height: 1, color: Theme.of(context).dividerColor),
                    _InfoBlock(
                      title: 'profile-field-category'.i18n(),
                      value: '-',
                      showTrailing: false,
                    ),
                    Divider(height: 1, color: Theme.of(context).dividerColor),
                    _InfoBlock(
                      title: 'profile-field-position'.i18n(),
                      value: _profile?.position ?? '-',
                      showTrailing: false,
                    ),
                    Divider(height: 1, color: Theme.of(context).dividerColor),
                    _InfoBlock(
                      title: 'profile-field-brigade'.i18n(),
                      value: _profile?.brigade ?? '-',
                      showTrailing: false,
                    ),
                    Divider(height: 1, color: Theme.of(context).dividerColor),
                    _InfoBlock(
                      title: 'profile-field-branch'.i18n(),
                      value: _profile?.branch ?? '-',
                      showTrailing: false,
                    ),
                    Divider(height: 1, color: Theme.of(context).dividerColor),
                    _InfoBlock(
                      title: 'profile-field-phone'.i18n(),
                      value: _profile?.phone ?? '-',
                      canEdit: true,
                    ),
                     Divider(height: 1, color: Theme.of(context).dividerColor),
                    _InfoBlock(
                      title: 'Документы'.i18n(),
                      showArrow: true,
                      onTap: () {
                        final ownerId = _employeeId;
                        if (ownerId == null || ownerId <= 0) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DocumentsMenuScreen(ownerId: ownerId),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              Text(
                'profile-note'.i18n(),
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({
    required this.title,
    this.value = '',
    this.canCopy = false,
    this.canEdit = false,
    this.showTrailing = true,
    this.onTap,
    this.showArrow = false,
  });

  final String title;
  final String value;
  final bool canCopy;
  final bool canEdit;
  final bool showTrailing;
  final VoidCallback? onTap;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      fontSize: _sp(context, 15),
      fontWeight: FontWeight.w800,
      color: Theme.of(context).colorScheme.onSurface,
    );

    final hintStyle = TextStyle(
      fontSize: _sp(context, 14),
      color: Theme.of(context).textTheme.bodySmall?.color,
      fontWeight: FontWeight.w700,
    );

    final hasValue = value.trim().isNotEmpty;

    return InkWell(
      onTap: onTap,
      child: Padding(
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
                    Text(title, style: hintStyle),
                  ] else ...[
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
                      tooltip: 'profile-tooltip-copy'.i18n(),
                      icon: Icon(CupertinoIcons.doc_on_doc,
                          size: 22,
                          color: Theme.of(context)
                              .iconTheme
                              .color
                              ?.withValues(alpha:0.7)),
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: value));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('profile-snackbar-copied'.i18n())),
                          );
                        }
                      },
                    ),
                  if (canEdit)
                    IconButton(
                      tooltip: 'profile-tooltip-edit'.i18n(),
                      icon: Icon(CupertinoIcons.pencil,
                          size: 22,
                          color: Theme.of(context)
                              .iconTheme
                              .color
                              ?.withValues(alpha:0.7)),
                      onPressed: () {},
                    ),
                  if (showArrow)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Icon(
                        CupertinoIcons.chevron_right,
                        size: 18,
                        color: Theme.of(context)
                            .iconTheme
                            .color
                            ?.withValues(alpha:0.5),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
