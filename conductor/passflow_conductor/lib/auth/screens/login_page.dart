import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passflow_app/auth/screens/register_page.dart';
import 'package:passflow_app/widgets/custom_loader.dart';
import 'package:passflow_app/widgets/main_scaffold.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:passflow_app/auth/bloc/auth_bloc.dart';
import 'package:passflow_app/auth/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _loginCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final bool _obscure = true;
  bool _isLoading = false;
  bool _loginInProgress = false;
  String? _errorMessage;

  @override
  void dispose() {
    _loginCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loginInProgress = true;
      _isLoading = true;
      _errorMessage = null;
    });

    final login = _loginCtrl.text.trim();
    final password = _passCtrl.text;
    context.read<AuthBloc>().add(LoginSubmitted(login, password));
  }

  InputDecoration _buildDecoration(String label) => InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.outlineVariant,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool obscureText = false,
    TextInputAction? textInputAction,
    void Function(String)? onFieldSubmitted,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      decoration: _buildDecoration(hint).copyWith(),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (prev, curr) =>
          curr is AuthLoading ||
          curr is AuthFailure ||
          curr is AuthLoginSucceeded ||
          curr is AuthUnauthenticated,
      listener: (context, state) async {
        if (!mounted) return;

        if (state is AuthLoading) {
          if (_loginInProgress) {
            setState(() {
              _isLoading = true;
              _errorMessage = null;
            });
          }
          return;
        }

        if (_isLoading) {
          setState(() => _isLoading = false);
        }

        if (state is AuthFailure) {
          _loginInProgress = false;
          setState(() => _errorMessage = state.message);
        } else if (state is AuthLoginSucceeded) {
          _loginInProgress = false;

          final userProvider = Provider.of<UserProvider>(context, listen: false);
          final nav = Navigator.of(context);

          final prefs = await SharedPreferences.getInstance();
          final userName = prefs.getString('user_name') ?? _loginCtrl.text.trim();

          if (!mounted) return;
          userProvider.login(userName);
          nav.pushReplacement(
            MaterialPageRoute(builder: (_) => const MainScaffold()),
          );
        } else if (state is AuthUnauthenticated) {
          _loginInProgress = false;
          if (mounted) setState(() => _isLoading = false);
        } else {
          _loginInProgress = false;
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: Stack(
            children: [
              SafeArea(
                child: Stack(
                  children: [
                    Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 24),
                                Text(
                                  'Авторизация',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Для авторизации введите\nлогин и пароль',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                _buildTextField(
                                  controller: _loginCtrl,
                                  hint: 'Табельный номер',
                                  textInputAction: TextInputAction.next,
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                          ? 'Введите Табельный номер'
                                          : null,
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _passCtrl,
                                  hint: 'Пароль',
                                  obscureText: _obscure,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _handleLogin(),
                                  validator: (v) => (v == null || v.isEmpty)
                                      ? 'Введите пароль'
                                      : null,
                                ),
                                const SizedBox(height: 48),
                                SizedBox(
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _handleLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                      elevation: 2,
                                      shadowColor:
                                          Theme.of(context).colorScheme.shadow,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(40),
                                      ),
                                    ),
                                    child: Text(
                                      'Продолжить',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Center(
                                  child: TextButton(
                                    onPressed: _isLoading
                                        ? null
                                        : () async {
                                            final createdUser =
                                                await Navigator.of(context)
                                                    .push<String?>(
                                              MaterialPageRoute(
                                                  builder: (_) =>
                                                      const RegisterPage()),
                                            );
                                            if (createdUser != null &&
                                                mounted) {
                                              _loginCtrl.text = createdUser;
                                            }
                                          },
                                    child:
                                        const Text('Нет аккаунта? Регистрация'),
                                  ),
                                ),
                                if (_errorMessage != null) ...[
                                  const SizedBox(height: 16),
                                  Text(
                                    _errorMessage!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.error,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.language, size: 24),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
              if (_isLoading)
                Container(
                  color: Theme.of(context)
                      .colorScheme
                      .surface
                      .withValues(alpha: 0.05),
                  child: const Center(child: DotCircleLoader()),
                ),
            ],
          ),
        );
      },
    );
  }
}




///////Авторизация с ИИН/////////




// import 'package:localization/localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:passflow_app/auth/bloc/auth_bloc.dart';
// import 'package:passflow_app/feature/pin/pin_create_flow_page.dart';
// import 'package:passflow_app/pages/confrimation_entered.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({Key? key}) : super(key: key);

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final _loginCtrl = TextEditingController();
//   final _passCtrl = TextEditingController();
//   final _formKey = GlobalKey<FormState>();
//   bool _isLoading = false;
//   String? _errorMessage;

//   @override
//   void dispose() {
//     _loginCtrl.dispose();
//     _passCtrl.dispose();
//     super.dispose();
//   }

//   void _handleLogin() async {
//     if (!_formKey.currentState!.validate()) return;
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     final login = _loginCtrl.text.trim();
//     final password = _passCtrl.text;

//     context.read<AuthBloc>().add(LoginSubmitted(login, password));
//   }

//   InputDecoration _buildDecoration(String label) => InputDecoration(
//         labelText: label,
//         floatingLabelBehavior: FloatingLabelBehavior.never,
//         labelStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
//         filled: true,
//         fillColor: Theme.of(context).colorScheme.surface,
//         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(24),
//           borderSide: BorderSide.none,
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(24),
//           borderSide: const BorderSide(color: Colors.red),
//         ),
//         focusedErrorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(24),
//           borderSide: const BorderSide(color: Colors.red),
//         ),
//       );

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String hint,
//     bool obscureText = false,
//     TextInputAction? textInputAction,
//     void Function(String)? onFieldSubmitted,
//     String? Function(String?)? validator,
//   }) {
//     return TextFormField(
//       controller: controller,
//       obscureText: obscureText, 
//       textInputAction: textInputAction,
//       onFieldSubmitted: onFieldSubmitted,
//       onChanged: (_) => setState(() {}),
//       decoration: _buildDecoration(hint).copyWith(
//         suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
//         suffixIcon: controller.text.isNotEmpty
//             ? IconButton(
//                 icon: Container(
//                   decoration: BoxDecoration(
//                     color: Theme.of(context).brightness == Brightness.dark
//                         ? Colors.grey.shade700
//                         : Colors.grey.shade300,
//                     shape: BoxShape.circle,
//                   ),
//                   padding: const EdgeInsets.all(4),
//                   child: Icon(
//                     Icons.close_rounded,
//                     size: 18,
//                     color: Theme.of(context).iconTheme.color?.withValues(alpha:0.6),
//                   ),
//                 ),
//                 onPressed: () {
//                   controller.clear();
//                   setState(() {});
//                 },
//               )
//             : null,
//       ),
//       validator: validator,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<AuthBloc, AuthState>(
//   listener: (context, state) async {
//     if (state is AuthLoginSucceeded) {
//       if (!mounted) return;
//       setState(() => _isLoading = false);

//       final otpOK = await Navigator.of(context).push<bool>(
//         MaterialPageRoute(builder: (_) => const OtpCodePage()),
//       );

//       if (otpOK != true) return;

//       final installed = await Navigator.of(context).push<bool>(
//         MaterialPageRoute(builder: (_) => const PinCreateFlowPage()),
//       );
//       if (installed != true) return;

//       if (!mounted) return;
//       Navigator.of(context).pushReplacementNamed('/');
//     } else if (state is AuthFailure) {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//           _errorMessage = state.message;
//         });
//       }
//     } else if (state is AuthUnauthenticated) {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   },
//   child: Scaffold(
//         backgroundColor: Theme.of(context).colorScheme.surface,
//         body: Stack(
//           children: [
//             SafeArea(
//               child: Stack(
//                 children: [
//                   Center(
//                     child: SingleChildScrollView(
//                       padding: const EdgeInsets.all(24),
//                       child: ConstrainedBox(
//                         constraints: const BoxConstraints(maxWidth: 420),
//                         child: Form(
//                           key: _formKey,
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.stretch,
//                             children: [
//                               const SizedBox(height: 24),
//                               Text(
//                                 'login-title'.i18n(),
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                   fontSize: 34,
//                                   fontWeight: FontWeight.w700,
//                                   color: Theme.of(context).colorScheme.onSurface,
//                                 ),
//                               ),
//                               const SizedBox(height: 12),
//                               Text(
//                                 'login-subtitle'.i18n(),
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   color: Theme.of(context).textTheme.bodyMedium?.color,
//                                 ),
//                               ),
//                               const SizedBox(height: 32),
//                               _buildTextField(
//                                 controller: _loginCtrl,
//                                 hint: 'iin'.i18n(),
//                                 textInputAction: TextInputAction.next,
//                                 validator: (v) => (v == null || v.trim().isEmpty) ? 'error-enter-iin'.i18n() : null,
//                               ),
//                               const SizedBox(height: 16),
//                               _buildTextField(
//                                 controller: _passCtrl,
//                                 hint: 'staff-number'.i18n(),
//                                 textInputAction: TextInputAction.done,
//                                 onFieldSubmitted: (_) => _handleLogin(),
//                                 validator: (v) => (v == null || v.isEmpty) ? 'error-enter-staff-number'.i18n() : null,
//                               ),
//                               const SizedBox(height: 48),
//                               SizedBox(
//                                 height: 56,
//                                 child: ElevatedButton(
//                                   onPressed: _isLoading ? null : _handleLogin,
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Theme.of(context).colorScheme.primary,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(40),
//                                     ),
//                                   ),
//                                   child: Text(
//                                     'continue'.i18n(),
//                                     style: TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.w700,
//                                       color: Theme.of(context).colorScheme.onPrimary,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               if (_errorMessage != null) ...[
//                                 const SizedBox(height: 16),
//                                 Text(
//                                   _errorMessage!,
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(color: Theme.of(context).colorScheme.error),
//                                 ),
//                               ],
//                               const SizedBox(height: 24),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   Positioned(
//                     top: 8,
//                     right: 8,
//                     child: IconButton(
//                       icon: const Icon(Icons.language, size: 24),
//                       onPressed: () {},
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             if (_isLoading)
//               Container(
//                 color: Theme.of(context).colorScheme.background.withValues(alpha:0.05),
//                 child: const Center(child: DotCircleLoader()),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }