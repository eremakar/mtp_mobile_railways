import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:passflow_app/auth/auth_provider.dart';
import 'package:passflow_app/auth/auth_service.dart';
import 'package:passflow_app/auth/bloc/auth_bloc.dart';
import 'package:passflow_app/auth/screens/login_page.dart';
import 'package:passflow_app/data/models/user_model.dart';
import 'package:passflow_app/l10n/app_localizations.dart';
import 'package:passflow_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> confirmAndLogout(BuildContext context) async {
  final rootContext = navigatorKey.currentContext ?? context;

  final confirmed = await showDialog<bool>(
        context: rootContext,
        useRootNavigator: true,
        barrierDismissible: true,
        barrierColor: const Color(0x99000000),
        builder: (ctx) => const LogoutConfirmDialog(),
      ) ??
      false;

  if (!confirmed) return;

  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('auth_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_profile');
    await prefs.remove('user_name');

    await AuthService.clearToken();

    final userBox = Hive.box<UserModel>('userBox');
    await userBox.delete('currentUser');

    if (rootContext.mounted) {
      await rootContext.read<UserProvider>().logout();
    }
  } finally {
    _navigateToLogin(rootContext);
  }
}

void _navigateToLogin(BuildContext context) {
  final loginRoute = MaterialPageRoute<void>(
    builder: (_) => BlocProvider(
      create: (_) => AuthBloc()..add(AppStarted()),
      child: const LoginPage(),
    ),
  );

  final nav = navigatorKey.currentState;
  if (nav != null) {
    nav.pushAndRemoveUntil(loginRoute, (_) => false);
    return;
  }

  if (context.mounted) {
    Navigator.of(context, rootNavigator: true)
        .pushAndRemoveUntil(loginRoute, (_) => false);
  }
}

class LogoutConfirmDialog extends StatelessWidget {
  const LogoutConfirmDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const titleStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w800,
      color: Color(0xFF111827),
    );
    const descStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Color(0xFF6B7280),
      height: 1.35,
    );

    return Dialog(
      backgroundColor: Colors.white,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F111827),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child:
                  const Icon(Icons.logout, size: 32, color: Color(0xFF111827)),
            ),
            const SizedBox(height: 16),
            Text(l10n.logoutDialogTitle,
                style: titleStyle, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              l10n.logoutDialogMessage,
              style: descStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: Color(0xFF9CA3AF), width: 1.2),
                      foregroundColor: const Color(0xFF111827),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(l10n.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 103, 150, 246),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(l10n.confirmLogout),
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
