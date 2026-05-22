import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:passflow_app/core/theme/theme_provider.dart';
import 'package:passflow_app/pages/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class InterfaceThemePage extends StatefulWidget {
  final void Function(String themeKey)? onSelected;
  final String illustrationAsset;

  const InterfaceThemePage({
    super.key,
    this.onSelected,
    this.illustrationAsset = 'assets/images/interface_theme.png',
  });

  @override
  State<InterfaceThemePage> createState() => _InterfaceThemePageState();
}

class _InterfaceThemePageState extends State<InterfaceThemePage> {
  String _selected = 'light';

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('app_theme');
    if (saved == null) return;
    if (!mounted) return;
    setState(() => _selected = saved);
  }

  Future<void> _saveAndContinue() async {
    final provider = context.read<ThemeProvider>();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_theme', _selected);

    if (_selected == 'light') {
      provider.setTheme(ThemeMode.light);
    } else if (_selected == 'dark') {
      provider.setTheme(ThemeMode.dark);
    } else {
      provider.setTheme(ThemeMode.system);
    }

    if (!mounted) return;
    if (widget.onSelected != null) {
      widget.onSelected!.call(_selected);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SplashScreen(
              languageCode: prefs.getString('selected_lang') ?? 'ru'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: Theme.of(context).colorScheme.onSurface,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            SizedBox(
              height: 160,
              child: Image.asset(
                widget.illustrationAsset,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'interface-theme-title'.i18n(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'interface-theme-subtitle'.i18n(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.45,
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            const SizedBox(height: 24),

            _ThemeTile(
              title: 'theme-light'.i18n(),
              selected: _selected == 'light',
              onTap: () {
                setState(() => _selected = 'light');
                context.read<ThemeProvider>().setTheme(ThemeMode.light);
              },
            ),
            const SizedBox(height: 16),
            _ThemeTile(
              title: 'theme-dark'.i18n(),
              selected: _selected == 'dark',
              onTap: () {
                setState(() => _selected = 'dark');
                context.read<ThemeProvider>().setTheme(ThemeMode.dark);
              },
            ),
            const SizedBox(height: 16),
            _ThemeTile(
              title: 'theme-accessibility'.i18n(),
              selected: _selected == 'accessible',
              onTap: () {
                setState(() => _selected = 'accessible');
                context.read<ThemeProvider>().setTheme(ThemeMode.system);
              },
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveAndContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    elevation: 0,
                    shape: const StadiumBorder(),
                  ),
                  child: Text(
                    'continue'.i18n(),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeTile({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return InkWell(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            if (selected) Icon(Icons.check_rounded, color: Theme.of(context).colorScheme.primary),
          ],
        ),
      ),
    );
  }
}
