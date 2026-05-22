import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localization/localization.dart';

typedef PinValidator = Future<bool> Function(String pin);

class PinCodeDialog {
  static Future<bool> show(
    BuildContext context, {
    String? title,
    int length = 4,
    required PinValidator validator,
  }) async {
    final controller = TextEditingController();
    final focus = FocusNode();
    bool success = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          contentPadding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title ?? 'pin-confirm-title'.i18n(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 24),
              _PinDots(
                length: length,
                listen: controller,
              ),
              const SizedBox(height: 16),
              _HiddenField(
                controller: controller,
                focusNode: focus,
                length: length,
                onComplete: (pin) async {
                  HapticFeedback.lightImpact();
                  success = await validator(pin);
                  if (success && context.mounted) Navigator.of(context).pop();
                  if (!success) {
                    controller.clear();
                    focus.requestFocus();
                  }
                },
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('cancel'.i18n()),
              ),
            ],
          ),
        );
      },
    );

    return success;
  }
}

class _HiddenField extends StatefulWidget {
  const _HiddenField({
    required this.controller,
    required this.focusNode,
    required this.length,
    required this.onComplete,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final int length;
  final ValueChanged<String> onComplete;

  @override
  State<_HiddenField> createState() => _HiddenFieldState();
}

class _HiddenFieldState extends State<_HiddenField> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.focusNode.requestFocus());
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      maxLength: widget.length,
      keyboardType: TextInputType.number,
      obscureText: true,
      autofocus: true,
      onChanged: (v) {
        if (v.length == widget.length) widget.onComplete(v);
      },
      decoration: const InputDecoration(counterText: ''),
    );
  }
}

class _PinDots extends StatefulWidget {
  final int length;
  final TextEditingController listen;
  const _PinDots({required this.length, required this.listen});

  @override
  State<_PinDots> createState() => _PinDotsState();
}

class _PinDotsState extends State<_PinDots> {
  int filled = 0;

  @override
  void initState() {
    super.initState();
    widget.listen.addListener(_onChange);
  }

  void _onChange() {
    setState(() => filled = widget.listen.text.length);
  }

  @override
  void dispose() {
    widget.listen.removeListener(_onChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.length, (i) {
        final isFilled = i < filled;
        return Container(
          width: 40,
          height: 40,
          margin: EdgeInsets.only(right: i == widget.length - 1 ? 0 : 16),
          decoration: const BoxDecoration(
            color: Color(0xFFEFF3F6),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: isFilled ? const Color(0xFF0B74F0) : const Color(0xFFC9CDD4),
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      }),
    );
  }
}