import 'package:flutter/material.dart';
import 'package:passflow_app/widgets/page/documents_menu/documents_list_screen.dart';
import 'package:passflow_app/widgets/page/documents_menu/other_documents_menu_screen.dart';

class DocumentsMenuScreen extends StatelessWidget {
  const DocumentsMenuScreen({
    super.key,
    required this.ownerId,
  });

  final int ownerId;

  static const int docTypeIdCertificateInfo = 7;
  static const int docTypeIdServiceCertificateInfo = 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        title: const Text(
          'Документы',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _BigMenuTile(
            title: 'Информация об удостоверении',
            icon: Icons.badge_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DocumentsListScreen(
                    title: 'Информация об удостоверении',
                    documentTypeId: docTypeIdCertificateInfo,
                    ownerId: ownerId,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _BigMenuTile(
            title: 'Информация о служебном удостоверении',
            icon: Icons.verified_user_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DocumentsListScreen(
                    title: 'Информация о служебном удостоверении',
                    documentTypeId: docTypeIdServiceCertificateInfo,
                    ownerId: ownerId,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _BigMenuTile(
            title: 'Прочие документы',
            icon: Icons.folder_copy_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OtherDocumentsMenuScreen(
                    ownerId: ownerId,
                  ),
                ),
              );
            },
            visualEnabled: true,
          ),
        ],
      ),
    );
  }
}

class _BigMenuTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final bool? visualEnabled;

  const _BigMenuTile({
    required this.title,
    required this.icon,
    this.onTap,
    this.visualEnabled,
  });

  bool get _tapEnabled => onTap != null;
  bool get _enabledStyle => visualEnabled ?? _tapEnabled;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(20);

    return Material(
      color: cs.surface,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.7)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: 24,
                  color: _enabledStyle
                      ? cs.primary
                      : cs.onSurface.withValues(alpha:0.45),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    color: _enabledStyle
                        ? cs.onSurface
                        : cs.onSurface.withValues(alpha:0.55),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (_enabledStyle)
                Icon(
                  Icons.chevron_right,
                  size: 26,
                  color: cs.onSurface,
                )
              else
                const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}