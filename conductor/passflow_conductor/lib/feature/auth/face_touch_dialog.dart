import 'package:flutter/material.dart';
import 'bio_auth_service.dart';

class FaceTouchDialog {
  static Future<bool> show(
    BuildContext context, {
    required BioAuthService bio,
    String title = 'Войдите с Face ID / Touch ID',
  }) async {
    try {
      final ok = await bio.authenticate(reason: title);
      return ok;
    } catch (e) {
      return false;
    }
  }
}