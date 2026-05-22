import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:passflow_app/pages/interface_theme.dart';
import 'package:passflow_app/pages/user_agreement_page.dart';
import 'package:localization/localization.dart';

class UserAgreementPage extends StatelessWidget {
  final VoidCallback? onAccepted;
  final String? termsRouteName;
  final String illustrationAsset;

  const UserAgreementPage({
    super.key,
    this.onAccepted,
    this.termsRouteName,
    this.illustrationAsset = 'assets/images/user_agreement.png',
  });

  Future<void> _accept(BuildContext context) async {
    final nav = Navigator.of(context);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('accepted_terms', true);

    if (!context.mounted) return;

    if (onAccepted != null) {
      onAccepted!.call();
    } else {
      nav.pushReplacement(
        MaterialPageRoute(builder: (_) => const InterfaceThemePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                color: theme.iconTheme.color,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
            const SizedBox(height: 58),
            SizedBox(
              height: 180,
              child: Image.asset(
                illustrationAsset,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 36),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'user-agreement-title'.i18n(),
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                  height: 1.15,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 20,
                    height: 1.45,
                  ),
                  children: [
                    TextSpan(
                      text: "user-agreement-text".i18n(),
                    ),
                    TextSpan(
                      text: "user-agreement-one".i18n(),
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.normal,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const UserAgreementPageScreen()),
                          );
                        },
                    ),
                    TextSpan(
                      text: "user-agreement-three".i18n(),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _accept(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    elevation: 0,
                    shape: const StadiumBorder(),
                  ),
                  child: Text(
                    'continue'.i18n(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
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