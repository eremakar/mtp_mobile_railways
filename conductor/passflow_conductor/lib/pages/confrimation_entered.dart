import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localization/localization.dart';

class OtpCodePage extends StatefulWidget {
  const OtpCodePage({
    super.key,
    this.phoneMasked = '+7(700)xxx-xx-00',
    this.codeLength = 4,
    this.resendSeconds = 35,
    this.onVerified,
  });

  final String phoneMasked;
  final int codeLength;
  final int resendSeconds;
  final VoidCallback? onVerified;

  @override
  State<OtpCodePage> createState() => _OtpCodePageState();
}

class _OtpCodePageState extends State<OtpCodePage> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _nodes;

  Timer? _timer;
  late int _left;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.codeLength, (_) => TextEditingController());
    _nodes = List.generate(widget.codeLength, (_) => FocusNode());
    _left = widget.resendSeconds;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_nodes.isNotEmpty) _nodes.first.requestFocus();
    });

    _startTimer();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _left = widget.resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _left--;
        if (_left <= 0) {
          _left = 0;
          _timer?.cancel();
        }
      });
    });
  }

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      _controllers[index].text = value.characters.take(1).toString();
      _controllers[index].selection = TextSelection.collapsed(offset: 1);
    }

    if (value.isNotEmpty) {
      if (index < widget.codeLength - 1) {
        _nodes[index + 1].requestFocus();
      } else {
        _nodes[index].unfocus();
        _tryValidate();
      }
    }
  }

  KeyEventResult _onKey(int index, KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _nodes[index - 1].requestFocus();
        _controllers[index - 1].clear();
      }
    }
    return KeyEventResult.ignored;
    }

  void _tryValidate() {
    final code = _controllers.map((c) => c.text).join();
    if (code.length == widget.codeLength) {
      if (widget.onVerified != null) {
        widget.onVerified!();
      } else {
        Navigator.of(context).maybePop(true);
      }
    }
  }

  String _formatLeft(int s) {
    final mm = (s ~/ 60).toString().padLeft(2, '0');
    final ss = (s % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w800,
      height: 1.1,
      color: Theme.of(context).colorScheme.onSurface,
    );
    final subStyle = TextStyle(
      fontSize: 18,
      height: 1.35,
      color: Theme.of(context).colorScheme.onSurface,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          const SizedBox(height: 8),
          Text('otp-title'.i18n(), style: titleStyle, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(
            'otp-subtitle'.i18n([widget.phoneMasked]),
            style: subStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 36),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.codeLength, (i) {
              return Padding(
                padding: EdgeInsets.only(right: i == widget.codeLength - 1 ? 0 : 16),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: KeyboardListener(
                        focusNode: FocusNode(skipTraversal: true),
                        onKeyEvent: (e) => _onKey(i, e),
                        child: TextField(
                          controller: _controllers[i],
                          focusNode: _nodes[i],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          keyboardType: TextInputType.number,
                          textInputAction: i == widget.codeLength - 1 ? TextInputAction.done : TextInputAction.next,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(1)],
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            counterText: '',
                          ),
                          onChanged: (v) => _onChanged(i, v),
                          onSubmitted: (_) => _tryValidate(),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 40),

          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: _left == 0
                  ? () {
                      _startTimer();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('otp-resent'.i18n())),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surface,
                disabledBackgroundColor: Theme.of(context).colorScheme.surface,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: Text(
                _left == 0
                    ? 'otp-resend-button'.i18n()
                    : 'otp-resend-button-timer'.i18n([_formatLeft(_left)]),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}