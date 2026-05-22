import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passflow_app/feature/auth/pin_code_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:localization/localization.dart';

class PinCreateFlowPage extends StatefulWidget {
  const PinCreateFlowPage({super.key, this.length = 4});

  final int length;

  @override
  State<PinCreateFlowPage> createState() => _PinCreateFlowPageState();
}

enum _Step { create, confirm }

class _PinCreateFlowPageState extends State<PinCreateFlowPage> {
  _Step step = _Step.create;
  String first = '';
  String current = '';
  bool isError = false;

  void _onDigit(int n) {
    if (current.length >= widget.length) return;
    HapticFeedback.selectionClick();
    setState(() => current += n.toString());
    if (current.length == widget.length) _onFilled();
  }

  void _onBackspace({bool all = false}) {
    HapticFeedback.selectionClick();
    setState(() => current = all
        ? ''
        : (current.isNotEmpty ? current.substring(0, current.length - 1) : ''));
  }

  Future<void> _onFilled() async {
    await Future.delayed(const Duration(milliseconds: 80));
    if (step == _Step.create) {
      setState(() {
        first = current;
        current = '';
        step = _Step.confirm;
      });
      return;
    }

    // step == confirm
    if (current == first) {
      await PinCodeModel.savePin(current);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('skip_unlock_once', true);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } else {
      if (!mounted) return;
      setState(() {
        current = '';
        isError = true;
      });
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() => isError = false);
      }
    }
  }

@override
Widget build(BuildContext context) {
  final title = step == _Step.create ? 'pin-create-title'.i18n() : 'pin-confirm-title'.i18n();
  return Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    appBar: AppBar(
    ),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 35, 16, 24),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Text(
              title,
              style:
                    const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              if (isError) ...[
                const SizedBox(height: 12),
                Text(
                  'pin-wrong'.i18n(),
                  style: const TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
              const SizedBox(height: 80),
              _Dots(length: widget.length, filled: current.length, isError: isError),
              const Spacer(),
              _Keypad(
                onNum: _onDigit,
                onBack: () => _onBackspace(),
                onBackLong: () => _onBackspace(all: true),
              ),
            ],
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
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF2B2B2B)
                : const Color(0xFFEFF3F6),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: isError
                    ? Colors.red
                    : (isFilled
                        ? const Color(0xFF0B74F0)
                        : (Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF555555)
                            : const Color(0xFFC9CDD4))),
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
  const _Keypad(
      {required this.onNum, required this.onBack, required this.onBackLong});

  final ValueChanged<int> onNum;
  final VoidCallback onBack;
  final VoidCallback onBackLong;

  Widget _num(int n) => _key(
      Text('$n',
          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w600)),
      onTap: () => onNum(n));

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
      Row(children: [
        Expanded(child: _num(1)),
        Expanded(child: _num(2)),
        Expanded(child: _num(3))
      ]),
      Row(children: [
        Expanded(child: _num(4)),
        Expanded(child: _num(5)),
        Expanded(child: _num(6))
      ]),
      Row(children: [
        Expanded(child: _num(7)),
        Expanded(child: _num(8)),
        Expanded(child: _num(9))
      ]),
      Row(children: [
        const Expanded(child: SizedBox(height: 68)),
        Expanded(child: _num(0)),
        Expanded(
          child: _key(
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF3A3A3A)
                    : const Color(0xFFEFF1F4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                  child: Icon(Icons.close, size: 18, color: Color(0xFF111827))),
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
