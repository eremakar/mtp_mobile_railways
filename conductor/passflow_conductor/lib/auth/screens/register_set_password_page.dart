import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passflow_app/auth/bloc/auth_bloc.dart';
import 'package:passflow_app/widgets/custom_loader.dart';

class RegisterSetPasswordPage extends StatefulWidget {
  final int userId;
  final String registrationToken;

  const RegisterSetPasswordPage({
    super.key,
    required this.userId,
    required this.registrationToken,
  });

  @override
  State<RegisterSetPasswordPage> createState() => _RegisterSetPasswordPageState();
}

class _RegisterSetPasswordPageState extends State<RegisterSetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passCtrl = TextEditingController();
  final _passRepeatCtrl = TextEditingController();

  bool _obscurePass = true;
  bool _obscurePassRepeat = true;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passCtrl.dispose();
    _passRepeatCtrl.dispose();
    super.dispose();
  }

  String _abbr(String s, {int head = 6, int tail = 4}) {
    if (s.isEmpty) return '';
    if (s.length <= head + tail) return s;
    return '${s.substring(0, head)}...${s.substring(s.length - tail)}';
  }

  String _mask(String s) {
    if (s.isEmpty) return '';
    return List.filled(s.length, '*').join();
  }

  InputDecoration _buildDecoration(String label) => InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        ),
      );

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final payload = <String, dynamic>{
      'userId': widget.userId,
      'registrationToken': widget.registrationToken,
      'password': _mask(_passCtrl.text),
    };

    debugPrint(
      '[RegisterSetPasswordPage] submit payload => ${jsonEncode(payload)} | token=${_abbr(widget.registrationToken)} | passLen=${_passCtrl.text.length}',
    );

    context.read<AuthBloc>().add(
          RegisterSetPasswordSubmitted(
            userId: widget.userId,
            registrationToken: widget.registrationToken,
            password: _passCtrl.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        debugPrint('[RegisterSetPasswordPage] state => ${state.runtimeType}');

        if (state is AuthLoading) {
          setState(() {
            _isLoading = true;
            _errorMessage = null;
          });
        } else if (state is AuthFailure) {
          setState(() {
            _isLoading = false;
            _errorMessage = state.message;
          });

          final msg = state.message.trim();
          if (msg.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg)),
            );
          }
        } else if (state is AuthRegisterSucceededFinal) {
          setState(() => _isLoading = false);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Пароль установлен. Теперь можно войти.')),
          );
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0,
            title: const Text('Пароль'),
          ),
          body: Stack(
            children: [
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 12),
                            Text(
                              'Задайте пароль',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Этот пароль будет использоваться для входа (username = ИИН)',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 28),
                            TextFormField(
                              controller: _passCtrl,
                              obscureText: _obscurePass,
                              textInputAction: TextInputAction.next,
                              decoration: _buildDecoration('Пароль').copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePass ? Icons.visibility_off : Icons.visibility,
                                  ),
                                  onPressed: () => setState(() => _obscurePass = !_obscurePass),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Введите пароль';
                                if (v.length < 6) return 'Минимум 6 символов';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passRepeatCtrl,
                              obscureText: _obscurePassRepeat,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _submit(),
                              decoration: _buildDecoration('Повторите пароль').copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassRepeat ? Icons.visibility_off : Icons.visibility,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscurePassRepeat = !_obscurePassRepeat,
                                  ),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Повторите пароль';
                                if (v != _passCtrl.text) return 'Пароли не совпадают';
                                return null;
                              },
                            ),
                            const SizedBox(height: 28),
                            SizedBox(
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  elevation: 2,
                                  shadowColor: Theme.of(context).colorScheme.shadow,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                ),
                                child: Text(
                                  'Сохранить пароль',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                            ),
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 16),
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (_isLoading)
                Container(
                  color: Theme.of(context).colorScheme.surface.withValues(alpha:0.05),
                  child: const Center(child: DotCircleLoader()),
                ),
            ],
          ),
        );
      },
    );
  }
}