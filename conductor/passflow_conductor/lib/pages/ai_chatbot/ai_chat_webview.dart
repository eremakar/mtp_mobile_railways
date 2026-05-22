import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:passflow_app/data/models/user_model.dart';
import 'package:passflow_app/widgets/custom_loader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ChatWebViewPage extends StatefulWidget {
  const ChatWebViewPage({super.key});

  @override
  State<ChatWebViewPage> createState() => _ChatWebViewPageState();
}

class _ChatWebViewPageState extends State<ChatWebViewPage> {
  WebViewController? _controller; 
  String lang = 'kz';
  int userId = 0;
  bool _isReloading = false;

  String _normalizeLang(String? code) {
    final c = (code ?? '').toLowerCase();
    if (c.startsWith('kk') || c == 'kz') return 'kz';
    if (c.startsWith('ru')) return 'ru';
    return 'ru'; 
  }

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final prefs = await SharedPreferences.getInstance();
    final user = Hive.box<UserModel>('userBox').get('currentUser');
    if (user == null || (user.userId ?? 0) == 0) {
      if (mounted) {
        setState(() {
          _controller = null;
        });
      }
      return;
    }

    lang = _normalizeLang(prefs.getString('selected_lang'));
    userId = user.userId ?? 0;

    final url = 'https://ai.jobro.pro/?userId=$userId&lang=$lang';
debugPrint('Loading URL: $url');
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(url));

    if (mounted) {
      setState(() {
        _controller = controller;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reloadIfLanguageChanged();
  }

  Future<void> _reloadIfLanguageChanged() async {
    final prefs = await SharedPreferences.getInstance();
    final newLang = _normalizeLang(prefs.getString('selected_lang'));
    if (newLang != lang && _controller != null) {
      setState(() => _isReloading = true);
      lang = newLang;
      final url = 'https://ai.jobro.pro/?userId=$userId&lang=$lang';
      debugPrint('Loading URL: $url');
      await _controller!.loadRequest(Uri.parse(url));
      if (mounted) setState(() => _isReloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Чат')),
     body: Stack(
        children: [
          _controller == null
              ? const Center(child: DotCircleLoader())
              : WebViewWidget(controller: _controller!),
          if (_isReloading)
            Container(
              color: Colors.black45,
              child: const Center(child: DotCircleLoader()),
                  ),
              ],
            ),
    );
  }
}