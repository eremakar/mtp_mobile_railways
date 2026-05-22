import 'dart:io';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:passflow_app/core/services/logger.dart';

class BioAuthService {
  final LocalAuthentication _auth;
  final bool faceRequired;

  BioAuthService({LocalAuthentication? auth, this.faceRequired = false})
      : _auth = auth ?? LocalAuthentication();

  Future<bool> isDeviceSupported() => _auth.isDeviceSupported();

  Future<List<BiometricType>> availableTypes() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException {
      return <BiometricType>[];
    }
  }

  Future<bool> canUseBiometric() async {
    try {
      final supported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      final types = await _auth.getAvailableBiometrics();
      final hasFace = types.contains(BiometricType.face);
      final anyBio = types.isNotEmpty;

      logger.i('[BioAuth] supported=$supported canCheck=$canCheck types=$types faceRequired=$faceRequired');

      if (!supported) return false;

      if (faceRequired) {
        if (hasFace) return canCheck; 
        if (Platform.isAndroid) {
          return canCheck || anyBio; 
        }
        return false; 
      }

      return canCheck || anyBio;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> authenticate({String? reason}) async {
    try {
      if (faceRequired) {
        final types = await _auth.getAvailableBiometrics();
        if (!types.contains(BiometricType.face)) {
          throw PlatformException(code: 'face_unavailable', message: 'Сканер лица недоступен');
        }
      }

      return await _auth.authenticate(
        localizedReason: reason ?? 'Подтвердите личность',
        options: AuthenticationOptions(
          biometricOnly: faceRequired,    
          stickyAuth: true,
          useErrorDialogs: true,
          sensitiveTransaction: false,
        ),
        authMessages: const [
          AndroidAuthMessages(
            signInTitle: 'Требуется аутентификация!',
            cancelButton: 'Отмена',
            biometricHint: '\u200B',
            biometricNotRecognized: 'Не распознано. Попробуйте снова.',
            goToSettingsButton: '\u200B',
          ),
        ],
      );
    } on PlatformException catch (e) {
      if (e.code == 'NotAvailable' ||
          e.code == 'notAvailable' ||
          e.code == 'face_unavailable') {
        return false;
      }
      rethrow;
    }
  }

  Future<bool> authenticatePreferFace({String? reason}) async {
    try {
      final types = await _auth.getAvailableBiometrics();
      final hasFace = types.contains(BiometricType.face);
      if (hasFace) {
        final ok = await authenticate(reason: reason ?? 'Войдите с Face ID');
        if (ok) return true;
      }
    } catch (_) {
    }

    if (Platform.isAndroid) {
      try {
        final supported = await _auth.isDeviceSupported();
        final canCheck = await _auth.canCheckBiometrics;
        if (supported && canCheck) {
          await _openAndroidFaceSettingsBestEffort();
        }
      } catch (_) {}
    }

    try {
      final ok = await _auth.authenticate(
        localizedReason: reason ?? 'Подтвердите личность',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
        authMessages: const [
          AndroidAuthMessages(
            signInTitle: 'Требуется аутентификация!',
            cancelButton: 'Отмена',
            biometricHint: '\u200B',
            biometricNotRecognized: 'Не распознано. Попробуйте снова.',
            goToSettingsButton: '\u200B',
          ),
        ],
      );
      return ok;
    } catch (_) {
      return false;
    }
  }

  Future<void> cancel() async {
    try {
      await _auth.stopAuthentication();
    } catch (_) {}
  }

  Future<void> _openAndroidFaceSettingsBestEffort() async {
    final intents = <AndroidIntent>[
      const AndroidIntent(action: 'android.settings.BIOMETRIC_ENROLL'),
      const AndroidIntent(action: 'android.settings.SECURITY_SETTINGS'),
      const AndroidIntent(action: 'android.settings.LOCK_SCREEN_SETTINGS'),
      const AndroidIntent(
        action: 'android.intent.action.MAIN',
        package: 'com.android.settings',
        componentName: 'com.android.settings/.biometrics.face.FaceSettings',
      ),
      const AndroidIntent(
        action: 'android.intent.action.MAIN',
        package: 'com.android.settings',
        componentName: 'com.android.settings/.Settings\$FaceSettingsActivity',
      ),
      const AndroidIntent(
        action: 'android.intent.action.MAIN',
        package: 'com.miui.securitycenter',
      ),
    ];

    for (final intent in intents) {
      try {
        await intent.launch();
        return; 
      } catch (_) {
      }
    }
  }
}