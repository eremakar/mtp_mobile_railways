import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passflow_app/l10n/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../imei_provider.dart';

class TerminalImeiScreen extends StatefulWidget {
  const TerminalImeiScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<TerminalImeiScreen> createState() => _TerminalImeiScreenState();
}

class _TerminalImeiScreenState extends State<TerminalImeiScreen> {
  Future<List<String>>? _future;
  bool _obscure = true;
  bool _denied = false;
  String? _altId;

  // === RAILWAY THEME ===
  static const _railRed = Color(0xFF1E6AF2);
  static const _railDark = Color(0xFF222222);
  static const _railSteel = Color(0xFF6E7B8B);
  static const _railSleeper = Color(0xFFB0B7BF);

  // Decorative track-like divider
  Widget _trackDivider(
      {double height = 10,
      EdgeInsets margin = const EdgeInsets.symmetric(vertical: 12)}) {
    return Container(
      margin: margin,
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final count = (constraints.maxWidth / 16).floor().clamp(6, 200);
          return Stack(
            children: [
              // rail line
              Align(
                alignment: Alignment.center,
                child: Container(height: 2, color: _railDark.withOpacity(0.35)),
              ),
              // sleepers
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  count,
                  (_) => Container(
                    width: 8,
                    height: height,
                    decoration: BoxDecoration(
                      color: _railSleeper.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  TextStyle _sectionTitleStyle(BuildContext context) =>
      Theme.of(context).textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          );

  Widget _sectionHeader(String title,
      {IconData icon = Icons.directions_railway_filled}) {
    return Row(
      children: [
        Icon(icon, color: const Color.fromARGB(255, 78, 126, 246)),
        const SizedBox(width: 8),
        Text(title, style: _sectionTitleStyle(context)),
      ],
    );
  }

  double _hPad(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 1000) return 48;
    if (w >= 600) return 32;
    return 16;
  }

  Widget _wrapContent(Widget child) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: child,
      ),
    );
  }

  TextStyle _titleStyle(BuildContext context) => Theme.of(context)
      .textTheme
      .titleMedium!
      .copyWith(fontWeight: FontWeight.w600);

  Future<void> _copyText(String text, {required String successMsg}) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(successMsg),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.blue,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _future = _load();
    _initAltId();
  }

  Future<List<String>> _load() async {
    if (!Platform.isAndroid) return [];
    try {
      final status = await Permission.phone.request();
      if (status.isGranted) {
        _denied = false;
        return await ImeiProvider.getImeis();
      } else {
        _denied = true;
        return [];
      }
    } catch (_) {
      _denied = false;
      return [];
    }
  }

  Future<void> _initAltId() async {
    String? id;
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final info = await deviceInfo.androidInfo;
        id = info.id; // ANDROID_ID
      } else if (Platform.isIOS) {
        final info = await deviceInfo.iosInfo;
        id = info.identifierForVendor; // iOS Vendor ID
      }
    } catch (_) {
      // ignore
    }
    if (!mounted) return;
    setState(() {
      _altId = id ?? 'Недоступно';
    });
  }

  String _mask(String s) {
    if (!_obscure) return s;
    if (s.length <= 4) return '••${s.substring(s.length - 2)}';
    return '${s.substring(0, 2)}••••••••${s.substring(s.length - 2)}';
  }

  Widget _altIdCard() {
    final value = _altId ?? 'Загрузка...';
    final unavailable =
        (_altId == null || _altId!.isEmpty || _altId == 'Недоступно');
    final l10n = AppLocalizations.of(context)!;
    return Card(
      color: const Color(0xFFF9F9F9),
      elevation: 1,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: _railSteel.withOpacity(0.25))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          leading: CircleAvatar(
            radius: 18,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: const Icon(Icons.perm_device_info, color: Colors.black87),
          ),
          title: Text(l10n.alt_id_device, style: _titleStyle(context)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
          trailing: unavailable
              ? null
              : IconButton(
                  tooltip: l10n.tooltip_copy,
                  icon: const Icon(Icons.copy, color: _railDark),
                  onPressed: () =>
                      _copyText(_altId!, successMsg: l10n.copied_id),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAndroid = Platform.isAndroid;

    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.terminal_title,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0x10CE1F2C), Color(0x106E7B8B)],
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: _obscure ? l10n.show_full : l10n.hide,
            icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8F9FA), Color(0xFFFFFFFF)],
          ),
        ),
        child: !isAndroid
            ? _wrapContent(ListView(
                padding:
                    EdgeInsets.fromLTRB(_hPad(context), 16, _hPad(context), 16),
                children: [
                  _sectionHeader(l10n.info_section),
                  _trackDivider(),
                  Card(
                    color: const Color(0xFFF9F9F9),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: _railSteel.withOpacity(0.2))),
                    child: ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: Text(l10n.ios_no_imei_title),
                      subtitle: Text(l10n.ios_no_imei_subtitle),
                    ),
                  ),
                ],
              ))
            : FutureBuilder<List<String>>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return _wrapContent(ListView(
                      padding: EdgeInsets.fromLTRB(
                          _hPad(context), 16, _hPad(context), 16),
                      children: const [
                        SizedBox(height: 200),
                        Center(child: CircularProgressIndicator()),
                      ],
                    ));
                  }

                  final imeis = snap.data ?? [];

                  if (snap.hasError) {
                    return _wrapContent(ListView(
                      padding: EdgeInsets.fromLTRB(
                          _hPad(context), 16, _hPad(context), 16),
                      children: [
                        _sectionHeader(l10n.error_section,
                            icon: Icons.warning_amber_rounded),
                        _trackDivider(),
                        Card(
                          color: const Color(0xFFF9F9F9),
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                  color: _railSteel.withOpacity(0.2))),
                          child: ListTile(
                            leading: const Icon(Icons.error_outline),
                            title: Text(l10n.error_update_failed),
                            subtitle: Text(l10n.error_update_retry),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _altIdCard(),
                      ],
                    ));
                  }

                  if (_denied) {
                    // пользователь отказал в разрешении
                    return _wrapContent(ListView(
                      padding: EdgeInsets.fromLTRB(
                          _hPad(context), 16, _hPad(context), 16),
                      children: [
                        _sectionHeader(l10n.denied_section,
                            icon: Icons.sim_card_alert),
                        _trackDivider(),
                        Card(
                          color: const Color(0xFFF9F9F9),
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                  color: _railSteel.withOpacity(0.2))),
                          child: ListTile(
                            leading: const Icon(Icons.sim_card_alert),
                            title: Text(l10n.denied_no_access_title),
                            subtitle: Text(l10n.denied_no_access_subtitle),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            FilledButton.icon(
                              onPressed: () async {
                                final status = await Permission.phone.request();
                                if (status.isGranted) {
                                  if (!mounted) return;
                                  setState(() {
                                    _denied = false;
                                    _future = ImeiProvider.getImeis();
                                  });
                                }
                              },
                              icon: const Icon(Icons.check_circle_outline),
                              label: Text(l10n.denied_allow_access),
                            ),
                            const SizedBox(width: 12),
                            TextButton.icon(
                              onPressed: openAppSettings,
                              icon: const Icon(Icons.settings_outlined),
                              label: Text(l10n.denied_open_settings),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _altIdCard(),
                      ],
                    ));
                  }

                  if (imeis.isEmpty) {
                    // разрешение есть, но IMEI всё равно недоступен (Android 10+)
                    return _wrapContent(ListView(
                      padding: EdgeInsets.fromLTRB(
                          _hPad(context), 16, _hPad(context), 16),
                      children: [
                        _sectionHeader(l10n.imei_unavailable_section),
                        _trackDivider(),
                        Card(
                          color: const Color(0xFFF9F9F9),
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                  color: _railSteel.withOpacity(0.2))),
                          child: ListTile(
                            leading: const Icon(Icons.info_outline),
                            title: Text(l10n.imei_unavailable_section),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _altIdCard(),
                      ],
                    ));
                  }

                  // IMEI получены
                  final uniqueImeis = <String>[];
                  for (final s in imeis) {
                    if (s.isNotEmpty && !uniqueImeis.contains(s))
                      uniqueImeis.add(s);
                  }
                  final bool hadDuplicate = imeis.length > uniqueImeis.length;
                  return _wrapContent(ListView(
                    padding: EdgeInsets.fromLTRB(
                        _hPad(context), 16, _hPad(context), 16),
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: _sectionHeader(l10n.imei_device_section)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                          height: 3,
                          width: 72,
                          decoration: const BoxDecoration(
                              color: _railRed,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(2)))),
                      _trackDivider(),
                      for (int i = 0; i < uniqueImeis.length; i++)
                        Card(
                          color: const Color(0xFFF9F9F9),
                          elevation: 0.5,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                  color: _railSteel.withOpacity(0.2))),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            leading: CircleAvatar(
                              radius: 18,
                              backgroundColor:
                                  const Color.fromARGB(255, 219, 219, 219),
                              child: Text('${i + 1}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                            ),
                            title: Text(l10n.imei_label(i + 1),
                                style: _titleStyle(context)),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(_mask(uniqueImeis[i])),
                            ),
                            trailing: IconButton(
                              tooltip: l10n.tooltip_copy,
                              icon: const Icon(Icons.copy, color: _railDark),
                              onPressed: () => _copyText(uniqueImeis[i],
                                  successMsg: l10n.copied_imei),
                            ),
                          ),
                        ),
                      if ((hadDuplicate || uniqueImeis.length == 1) &&
                          _altId != null &&
                          _altId!.isNotEmpty &&
                          _altId != 'Недоступно')
                        Card(
                          color: const Color(0xFFF9F9F9),
                          elevation: 0.5,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                  color: _railSteel.withOpacity(0.2))),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            leading: const CircleAvatar(
                              radius: 18,
                              backgroundColor:
                                  Color.fromARGB(255, 219, 219, 219),
                              child: Text('ALT',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w700)),
                            ),
                            title:
                                Text(l10n.alt_id, style: _titleStyle(context)),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(_mask(_altId!)),
                            ),
                            trailing: IconButton(
                              tooltip: l10n.tooltip_copy,
                              icon: const Icon(Icons.copy, color: _railDark),
                              onPressed: () => _copyText(_altId!,
                                  successMsg: l10n.copied_id),
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2F6),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: _railSteel.withOpacity(0.25)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline,
                                size: 18, color: _railSteel),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                l10n.note_android10,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black87,
                                    height: 1.2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ));
                },
              ),
      ),
    );
  }
}
