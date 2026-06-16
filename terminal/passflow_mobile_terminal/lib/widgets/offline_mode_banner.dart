import 'package:flutter/material.dart';
import 'package:passflow_app/l10n/app_localizations.dart';
import 'package:passflow_app/utils/network_utils.dart';

class OfflineModeBanner extends StatelessWidget {
  const OfflineModeBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!NetworkUtils.forceOffline) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;

    return Material(
      elevation: 1,
      color: const Color(0xFFFFF7ED),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFED7AA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off,
                        color: Color(0xFFC2410C), size: 16),
                    const SizedBox(width: 4),
                    Text(
                      l10n.offline_mode,
                      style: const TextStyle(
                        color: Color(0xFF9A3412),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.offline_mode_active,
                  style: const TextStyle(
                    color: Color(0xFF9A3412),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
