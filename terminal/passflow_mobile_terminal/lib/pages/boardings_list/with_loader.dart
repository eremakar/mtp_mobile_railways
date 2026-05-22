import 'package:flutter/material.dart';
import 'package:passflow_app/widgets/custom_loader.dart';

/// Показать оверлей‑лоадер на время выполнения [task].
Future<T?> withLoader<T>(BuildContext context, Future<T> Function() task) async {
  final navigator = Navigator.of(context, rootNavigator: true);

  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'loading',
    barrierColor: Colors.black26,
    transitionDuration: const Duration(milliseconds: 120),
    pageBuilder: (_, __, ___) => const Center(child: ExactDotsLoader()),
  );

  await Future.delayed(const Duration(milliseconds: 16));

  try {
    final res = await task();
    return res;
  } catch (e) {
    debugPrint('withLoader error: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
    rethrow;
  } finally {
    if (navigator.canPop()) {
      navigator.pop();
    }
  }
}