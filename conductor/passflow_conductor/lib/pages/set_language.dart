import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

import '../main.dart';
import 'user_agreement.dart';

class SetLanguage extends StatefulWidget {
  const SetLanguage({super.key});

  @override
  State<SetLanguage> createState() => _SetLanguageState();
}

class _SetLanguageState extends State<SetLanguage> {
  String _selectedLang = 'ru';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final current = Localizations.localeOf(context);
    setState(() => _selectedLang = current.languageCode);
  }

  void _applySelection(String code) {
    setState(() => _selectedLang = code);

    final locale = code == 'kk'
        ? const Locale('kk', 'KZ')
        : code == 'en'
            ? const Locale('en', 'US')
            : const Locale('ru', 'RU');

    PassflowAppState.setGlobalLocale(locale);
  }

  Future<void> _continue() async {
    final nav = Navigator.of(context);

    final prefs = await SharedPreferences.getInstance();

    final locale = _selectedLang == 'kk'
        ? const Locale('kk', 'KZ')
        : _selectedLang == 'en'
            ? const Locale('en', 'US')
            : const Locale('ru', 'RU');

    await prefs.setString('app_language', locale.toString());
    await prefs.setString('selected_lang', _selectedLang);
    await prefs.setBool('language_chosen', true);

    if (!mounted) return;

    nav.pushReplacement(
      MaterialPageRoute(builder: (_) => const UserAgreementPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scale = (size.width / 375).clamp(0.85, 1.2);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),

                // Логотип
                SizedBox(
                  height: (size.height * 0.26).clamp(160, 260),
                  child: const Image(
                    image: AssetImage('assets/images/logo_screen.png'),
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 32),

                // Заголовок
                Text(
                  'choose-language-title'.i18n(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: (32 * scale).clamp(24, 34),
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 12),

                // Подзаголовок
                Text(
                  'choose-language-subtitle'.i18n(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: (16 * scale).clamp(14, 18),
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),

                const SizedBox(height: 32),

                // Выбор языка
                _LangTile(
                  title: 'language-kazakh'.i18n(),
                  selected: _selectedLang == 'kk',
                  onTap: () => _applySelection('kk'),
                ),
                const SizedBox(height: 8),
                _LangTile(
                  title: 'language-russian'.i18n(),
                  selected: _selectedLang == 'ru',
                  onTap: () => _applySelection('ru'),
                ),
                const SizedBox(height: 8),
                _LangTile(
                  title: 'language-english'.i18n(),
                  selected: _selectedLang == 'en',
                  onTap: () => _applySelection('en'),
                ),

                SizedBox(height: (size.height * 0.10).clamp(16, 48)),

                // Кнопка "Продолжить"
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: SizedBox(
                    height: (56 * scale).clamp(48, 64),
                    child: ElevatedButton(
                      onPressed: _continue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        shape: const StadiumBorder(),
                      ),
                      child: Text(
                        'continue'.i18n(),
                        style: TextStyle(
                          fontSize: (18 * scale).clamp(16, 20),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LangTile extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _LangTile({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scale = (MediaQuery.of(context).size.width / 375).clamp(0.85, 1.2);
    return InkWell(
      onTap: onTap,
      child: Container(
        height: (56 * scale).clamp(48, 64),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: (18 * scale).clamp(16, 20),
                fontWeight: FontWeight.w500,
                color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            if (selected)
              Icon(Icons.check_rounded, color: Theme.of(context).colorScheme.primary),
          ],
        ),
      ),
    );
  }
}
