import 'package:flutter/material.dart';
import 'documents_list_screen.dart';

enum OtherDocType {
  certificates,
  orders,
  diplomas,
  awards,
  medicalBook,
}

extension OtherDocTypeX on OtherDocType {
  String get title {
    switch (this) {
      case OtherDocType.certificates:
        return 'Сертификаты';
      case OtherDocType.orders:
        return 'Приказы';
      case OtherDocType.diplomas:
        return 'Дипломы';
      case OtherDocType.awards:
        return 'Грамоты';
      case OtherDocType.medicalBook:
        return 'Медицинская книжка';
    }
  }

  int get documentTypeId {
    switch (this) {
      case OtherDocType.certificates:
        return 1;
      case OtherDocType.orders:
        return 2;
      case OtherDocType.diplomas:
        return 3;
      case OtherDocType.awards:
        return 6;
      case OtherDocType.medicalBook:
        return 5;
    }
  }

  IconData get icon {
    switch (this) {
      case OtherDocType.certificates:
        return Icons.workspace_premium_outlined;
      case OtherDocType.orders:
        return Icons.receipt_long_outlined;
      case OtherDocType.diplomas:
        return Icons.school_outlined;
      case OtherDocType.awards:
        return Icons.emoji_events_outlined;
      case OtherDocType.medicalBook:
        return Icons.medical_services_outlined;
    }
  }
}

class OtherDocumentsMenuScreen extends StatefulWidget {
  final int ownerId;

  const OtherDocumentsMenuScreen({
    super.key,
    required this.ownerId,
  });

  @override
  State<OtherDocumentsMenuScreen> createState() => _OtherDocumentsMenuScreenState();
}

class _OtherDocumentsMenuScreenState extends State<OtherDocumentsMenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Прочие документы',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: OtherDocType.values.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final type = OtherDocType.values[index];
            return _menuTile(context, type);
          },
        ),
      ),
    );
  }

  Widget _menuTile(BuildContext context, OtherDocType type) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DocumentsListScreen(
                title: type.title,
                documentTypeId: type.documentTypeId,
                ownerId: widget.ownerId,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Icon(type.icon, color: Theme.of(context).colorScheme.primary, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  type.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.chevron_right, size: 26, color: Theme.of(context).colorScheme.onSurface),
            ],
          ),
        ),
      ),
    );
  }
}