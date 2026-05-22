import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passflow_app/feature/auth/bio_auth_service.dart';
import 'package:passflow_app/feature/auth/pin_code_model.dart';
import 'package:localization/localization.dart';

class PinUnlockPage extends StatefulWidget {
  const PinUnlockPage({super.key, this.length = 4});
  final int length;

  @override
  State<PinUnlockPage> createState() => _PinUnlockPageState();
}

class _PinUnlockPageState extends State<PinUnlockPage> {
  String _current = '';
  bool _verifying = false;
  bool _isError = false;

  Future<void> _onFilled() async {
    if (_verifying) return;
    setState(() => _verifying = true);
    await Future.delayed(const Duration(milliseconds: 80));
    final ok = await PinCodeModel.verify(_current);
    if (!mounted) return;
    setState(() => _verifying = false);

    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      if (!mounted) return;
      setState(() {
        _current = '';
        _isError = true;
      });
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() => _isError = false);
    }
  }

  void _onDigit(int n) {
    if (_current.length >= widget.length || _verifying) return;
    HapticFeedback.selectionClick();
    setState(() => _current += n.toString());
    if (_current.length == widget.length) _onFilled();
  }

  void _onBackspace({bool all = false}) {
    if (_current.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() => _current = all ? '' : _current.substring(0, _current.length - 1));
  }

  Future<void> _tryBiometric() async {
    final bio = BioAuthService(faceRequired: false);
    final can = await bio.canUseBiometric();
    if (!mounted) return;
    if (!can) {
      return;
    }
    final ok = await bio.authenticate(reason: 'biometric-auth-title'.i18n());
    if (!mounted) return;
    if (ok) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Text(
                  'pin-confirm-title'.i18n(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.15,
                  ),
                ),
                if (_isError) ...[
                  const SizedBox(height: 12),
                  Text(
                    'pin-wrong'.i18n(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const SizedBox(height: 80),
                _Dots(length: widget.length, filled: _current.length, isError: _isError),
                const Spacer(),
                _Keypad(
                  onNum: _onDigit,
                  onBack: () => _onBackspace(),
                  onBackLong: () => _onBackspace(all: true),
                  onBiometric: _tryBiometric,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.length, required this.filled, this.isError = false});
  final int length;
  final int filled;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (i) {
        final isFilled = i < filled;
        return Container(
          width: 40,
          height: 40,
          margin: EdgeInsets.only(right: i == length - 1 ? 0 : 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: isError
                    ? Theme.of(context).colorScheme.error
                    : (isFilled ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor),
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({
    required this.onNum,
    required this.onBack,
    required this.onBackLong,
    required this.onBiometric,
  });

  final ValueChanged<int> onNum;
  final VoidCallback onBack;
  final VoidCallback onBackLong;
  final VoidCallback onBiometric;

  Widget _num(BuildContext context, int n) => _key(
        Text('$n', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
        onTap: () => onNum(n),
      );

  Widget _key(Widget child, {VoidCallback? onTap, VoidCallback? onLongPress}) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      onLongPress: onLongPress,
      child: SizedBox(height: 68, child: Center(child: child)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [Expanded(child: _num(context, 1)), Expanded(child: _num(context, 2)), Expanded(child: _num(context, 3))]),
      Row(children: [Expanded(child: _num(context, 4)), Expanded(child: _num(context, 5)), Expanded(child: _num(context, 6))]),
      Row(children: [Expanded(child: _num(context, 7)), Expanded(child: _num(context, 8)), Expanded(child: _num(context, 9))]),
      Row(children: [
        Expanded(
          child: _key(
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(child: Icon(Icons.tag_faces_outlined, size: 22, color: Theme.of(context).iconTheme.color)),
            ),
            onTap: onBiometric,
          ),
        ),
        Expanded(child: _num(context, 0)),
        Expanded(
          child: _key(
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: Icon(Icons.close, size: 18, color: Theme.of(context).iconTheme.color)),
            ),
            onTap: onBack,
            onLongPress: onBackLong,
          ),
        ),
      ]),
      const SizedBox(height: 24),
    ]);
  }
}