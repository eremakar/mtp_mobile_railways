import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passflow_app/auth/auth_provider.dart';
import 'package:passflow_app/main.dart';
import 'package:passflow_app/pages/about.dart';
import 'package:passflow_app/pages/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';
import 'package:passflow_app/core/theme/theme_provider.dart';
import 'package:passflow_app/core/theme/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}
class _LogoutConfirmDialog extends StatelessWidget {
  const _LogoutConfirmDialog();

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w800,
      color: Theme.of(context).colorScheme.onSurface,
    );
    final descStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Theme.of(context).textTheme.bodyMedium?.color ?? const Color(0xFF6B7280),
      height: 1.35,
    );

    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top icon in soft circle
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha:0.08),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Color(0x0F111827), blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              alignment: Alignment.center,
              child: Icon(Icons.logout, size: 32, color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(height: 16),
            Text('exit-app-title'.i18n(), style: titleStyle, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              'exit-app-message'.i18n(),
              style: descStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Theme.of(context).dividerColor, width: 1.2),
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('cancel'.i18n()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text('exit-from-app'.i18n()),
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

class _SettingsScreenState extends State<SettingsScreen> {
  bool smsEnabled = true;
  bool pushEnabled = true;
  bool biometricsEnabled = true;

  /// Stores regional language code like 'ru_RU' | 'kk_KZ' | 'en_US'
  String currentLanguage = 'ru_RU';
  String currentTheme = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      biometricsEnabled = prefs.getBool('biometrics_enabled') ?? true;
      final saved = prefs.getString('app_language');
      if (saved != null && saved.isNotEmpty) {
        // expect regional code like 'kk_KZ'
        currentLanguage = saved;
      } else {
        // derive from current locale
        final loc = Localizations.localeOf(context);
        if (loc.languageCode == 'kk') {
          currentLanguage = 'kk_KZ';
        } else if (loc.languageCode == 'en') {
          currentLanguage = 'en_US';
        } else {
          currentLanguage = 'ru_RU';
        }
      }
      final savedTheme = prefs.getString('app_theme');
      if (savedTheme != null && savedTheme.isNotEmpty) {
        if (savedTheme == 'light' || savedTheme == 'theme-light'.i18n()) {
          currentTheme = 'theme-light'.i18n();
        } else if (savedTheme == 'dark' || savedTheme == 'theme-dark'.i18n()) {
          currentTheme = 'theme-dark'.i18n();
        } else if (savedTheme == 'accessibility' || savedTheme == 'theme-accessibility'.i18n()) {
          currentTheme = 'theme-accessibility'.i18n();
        } else {
          currentTheme = 'theme-light'.i18n();
        }
      } else {
        currentTheme = 'theme-light'.i18n();
      }
    });
  }

  Locale _localeFromCode(String code) {
    final parts = code.split('_');
    if (parts.length == 2) return Locale(parts[0], parts[1]);
    switch (code) {
      case 'kk':
      case 'kk_KZ':
        return const Locale('kk', 'KZ');
      case 'en':
      case 'en_US':
        return const Locale('en', 'US');
      case 'ru':
      case 'ru_RU':
      default:
        return const Locale('ru', 'RU');
    }
  }

  /// Localized label for a regional code
  String _labelFromCode(BuildContext context, String code) {
    final lang = code.split('_').first;
    switch (lang) {
      case 'kk':
        return 'language-kazakh'.i18n();
      case 'en':
        return 'language-english'.i18n();
      case 'ru':
      default:
        return 'language-russian'.i18n();
    }
  }

  Future<String?> _showLanguagePicker(BuildContext context, String currentCode) async {
    final Color primary = AppColors.accentBlue;
    final Color textColor = Theme.of(context).colorScheme.onSurface;
    final Color secondary = Theme.of(context).textTheme.bodySmall?.color ?? AppColors.lightSecondaryText;

    final options = <String>['kk_KZ', 'ru_RU', 'en_US'];

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          bottom: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'language-application'.i18n(),
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: textColor),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 26, color: textColor),
                      onPressed: () => Navigator.of(ctx).pop(),
                      tooltip: 'language-close'.i18n(),
                    )
                  ],
                ),
                const SizedBox(height: 8),

                for (final code in options) ...[
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    onTap: () => Navigator.of(ctx).pop(code),
                    title: Text(
                      _labelFromCode(context, code),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: code == currentCode ? primary : textColor,
                      ),
                    ),
                    trailing: code == currentCode
                        ? Icon(Icons.check_rounded, color: primary)
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 8),
                ],

                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: secondary,
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    child: Text('cancel'.i18n()),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Future<String?> _showThemePicker(BuildContext context, String current) async {
    final Color primary = AppColors.accentBlue;
    final Color textColor = Theme.of(context).colorScheme.onSurface;
    final Color secondary = Theme.of(context).textTheme.bodySmall?.color ?? AppColors.lightSecondaryText;

    final options = <String>["theme-light".i18n(), "theme-dark".i18n(),"theme-accessibility".i18n(),];

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          bottom: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'section-theme'.i18n(),
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: textColor),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 26, color: textColor),
                      onPressed: () => Navigator.of(ctx).pop(),
                      tooltip: 'language-close'.i18n(),
                    )
                  ],
                ),
                const SizedBox(height: 8),

                for (final theme in options) ...[
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    onTap: () => Navigator.of(ctx).pop(theme),
                    title: Text(
                      theme,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: theme == current ? primary : textColor,
                      ),
                    ),
                    trailing: theme == current
                        ? Icon(Icons.check_rounded, color: primary)
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 8),
                ],

                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: secondary,
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    child: Text('cancel'.i18n()),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        centerTitle: true,
        title: Text('settings'.i18n(), style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).appBarTheme.titleTextStyle?.color ?? Theme.of(context).colorScheme.onSurface)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: const [
          _BellWithDot(),
          SizedBox(width: 12),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _SectionHeader('section-notifications'.i18n()),
          _CardBlock(children: [
            _SwitchTile(
              title: 'section-sms-notifications'.i18n(),
              value: smsEnabled,
              onChanged: (v) => setState(() => smsEnabled = v),
            ),
            _SwitchTile(
              title: 'push-notification'.i18n(),
              value: pushEnabled,
              onChanged: (v) => setState(() => pushEnabled = v),
            ),
          ]),
          const SizedBox(height: 16),
          _SectionHeader('section-login'.i18n()),
          _CardBlock(children: [
            _SwitchTile(
              title: 'section-biometric'.i18n(),
              value: biometricsEnabled,
              onChanged: (v) async {
                setState(() => biometricsEnabled = v);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('biometrics_enabled', v);
              },
            ),
          ]),
          const SizedBox(height: 16),
          _SectionHeader('section-other'.i18n()),
          _CardBlock(children: [
            _NavTile(
              title: "language-application".i18n(),
              subtitle: _labelFromCode(context, currentLanguage),
              onTap: () async {
                final picked = await _showLanguagePicker(context, currentLanguage);
                if (picked != null && picked.isNotEmpty && picked != currentLanguage) {
                  setState(() => currentLanguage = picked);
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('app_language', picked); // save code
                  await prefs.setString('selected_lang', picked.split('_').first); // short code for compatibility

                  // Apply locale immediately
                  PassflowAppState.setGlobalLocale(_localeFromCode(picked));
                }
              },
            ),
            _NavTile(
              title: 'section-theme'.i18n(),
              subtitle: currentTheme,
              onTap: () async {
                final provider = context.read<ThemeProvider>();
                final picked = await _showThemePicker(context, currentTheme);
                if (!mounted) return;
                if (picked != null && picked.isNotEmpty && picked != currentTheme) {
                  setState(() => currentTheme = picked);
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('app_theme', picked);
                  // применить тему немедленно через ThemeProvider
                  if (picked == "theme-light".i18n()) {
                    provider.setTheme(ThemeMode.light);
                  } else if (picked == "theme-dark".i18n()) {
                    provider.setTheme(ThemeMode.dark);
                  } else {
                    provider.setTheme(ThemeMode.system);
                  }
                }
              },
            ),
            _NavTile(
              title: 'section-about'.i18n(),
              onTap: () {
                Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const AboutPage(),
      ),
                );
              },
            ),
          ]),
          const SizedBox(height: 28),
          Center(
            child: TextButton(
              onPressed: () async {
                // Use a stable outer context for the dialog
                final outer = navigatorKey.currentContext ?? context;

                final confirmed = await showDialog<bool>(
                      context: outer,
                      barrierDismissible: true,
                      barrierColor: const Color(0x99000000),
                      builder: (ctx) => const _LogoutConfirmDialog(),
                    ) ??
                    false;

                if (!confirmed) return;

                // 1) Clear auth-related storage
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('token');
                await prefs.remove('auth_token');
                await prefs.remove('refresh_token');
                await prefs.remove('user_profile');

                // 1.1) Also clear local PIN so next session won’t prompt with old PIN
                await prefs.remove('pin_code');
                await prefs.setBool('is_pin_enabled', false);
                await prefs.remove('skip_unlock_once');

                // 2) Update provider state using a safe/global context
                if (context.mounted) {
  try {
    context.read<UserProvider>().setLoggedIn(false);
  } catch (_) {
  }
}

                // 3) Navigate to auth with robust fallback
                final short = currentLanguage.split('_').first; // 'ru'|'kk'|'en'
                final langCode = (short == 'kk') ? 'kk' : (short == 'en' ? 'en' : 'ru');
                final nav = navigatorKey.currentState;

                bool pushed = false;
                try {
                  nav?.pushNamedAndRemoveUntil('/auth', (route) => false);
                  pushed = true;
                } catch (_) {
                  pushed = false;
                }

                if (!pushed && nav != null) {
                  nav.pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => SplashScreen(languageCode: langCode)),
                    (route) => false,
                  );
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.secondary,
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              child: Text('button-exit-app'.i18n()),
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------- UI PARTS ----------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color ?? const Color(0xFF6B7280),
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _CardBlock extends StatelessWidget {
  const _CardBlock({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(children: children),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      title: Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
      trailing: _GreenSwitch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

class _GreenSwitch extends StatelessWidget {
  const _GreenSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    // Sizes tuned to look like the reference: compact pill with white knob
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeInOut,
        width: 48,
        height: 28,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: value ? AppColors.successGreen : Theme.of(context).dividerColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onPrimary,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1F000000),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({required this.title, this.subtitle, this.onTap});

  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      title: Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
      subtitle: subtitle == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(subtitle!, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color ?? const Color(0xFF6B7280))),
            ),
      trailing: Icon(Icons.chevron_right_rounded, color: Theme.of(context).iconTheme.color?.withValues(alpha:0.5) ?? const Color(0xFF98A2B3)),
    );
  }
}

class _BellWithDot extends StatelessWidget {
  const _BellWithDot();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_rounded),
        ),
        Positioned(
          right: 12,
          top: 12,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: AppColors.errorRed,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}