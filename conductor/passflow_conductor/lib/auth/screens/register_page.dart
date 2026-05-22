import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:passflow_app/auth/bloc/auth_bloc.dart';
import 'package:passflow_app/auth/screens/register_pin_code_page.dart';
import 'package:passflow_app/widgets/custom_loader.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _iinCtrl = TextEditingController();
  final _tableNumberCtrl = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  static const bool _forceGoNextOnRegisterError = true;
  bool _alreadyNavigated = false;

  @override
  void dispose() {
    _iinCtrl.dispose();
    _tableNumberCtrl.dispose();
    super.dispose();
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

    context.read<AuthBloc>().add(
          RegisterSubmitted(
            tableNumber: _tableNumberCtrl.text.trim(),
            iin: _iinCtrl.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
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

          if (_forceGoNextOnRegisterError && !_alreadyNavigated && mounted) {
            _alreadyNavigated = true;
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<AuthBloc>(),
                  child: const RegisterPinCodePage(userId: 0),
                ),
              ),
            );
          }
        } else if (state is AuthRegisterCodeSent) {
          setState(() => _isLoading = false);
          _alreadyNavigated = true;

          final msg = (state.message ?? '').trim();
          if (msg.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg)),
            );
          }

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<AuthBloc>(),
                child: RegisterPinCodePage(userId: state.userId),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0,
            title: const Text('Регистрация'),
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
                              'Создайте аккаунт',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Введите ИИН и табельный номер',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 28),

                            TextFormField(
                              controller: _iinCtrl,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              decoration: _buildDecoration('ИИН'),
                              validator: (v) {
                                final value = (v ?? '').trim();
                                if (value.isEmpty) return 'Введите ИИН';
                                if (!RegExp(r'^[0-9]{12}$').hasMatch(value)) {
                                  return 'ИИН должен быть 12 цифр';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _tableNumberCtrl,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _submit(),
                              decoration: _buildDecoration('Табельный номер'),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Введите табельный номер'
                                  : null,
                            ),

                            const SizedBox(height: 28),

                            SizedBox(
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _submit,
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
                                  'Создать аккаунт',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
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

                            const SizedBox(height: 12),
                            Center(
                              child: TextButton(
                                onPressed:
                                    _isLoading ? null : () => Navigator.of(context).pop(),
                                child: const Text('Уже есть аккаунт? Войти'),
                              ),
                            ),
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