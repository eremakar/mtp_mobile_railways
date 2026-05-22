import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:passflow_app/data/models/documents/documents_model.dart';
import 'package:passflow_app/data/repositories/documents_repo.dart';
import 'package:passflow_app/data/repositories/files_repo.dart';
import 'package:passflow_app/widgets/custom_loader.dart';

class DocumentsListScreen extends StatefulWidget {
  final String title;
  final int documentTypeId;
  final int ownerId;

  const DocumentsListScreen({
    super.key,
    required this.title,
    required this.documentTypeId,
    required this.ownerId,
  });

  @override
  State<DocumentsListScreen> createState() => _DocumentsListScreenState();
}

class _DocumentsListScreenState extends State<DocumentsListScreen> {
  final _repo = DocumentsRepository();
  late final Future<DocumentsSearchResponse?> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.searchDocuments(
      ownerId: widget.ownerId,
      documentTypeId: widget.documentTypeId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        title: Text(
          widget.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: FutureBuilder<DocumentsSearchResponse?>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: DotCircleLoader());
          }
          if (snap.hasError) {
            return Center(child: Text('Ошибка: ${snap.error}'));
          }
          final data = snap.data;
          if (data == null) {
            return const Center(child: Text('Данные не пришли (null)'));
          }
          if (data.result.isEmpty) {
            return const Center(child: Text('Нет документов'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: data.result.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _DocCard(doc: data.result[index]),
          );
        },
      ),
    );
  }
}

class _DocCard extends StatefulWidget {
  final DocumentItem doc;
  const _DocCard({required this.doc});

  @override
  State<_DocCard> createState() => _DocCardState();
}

class _DocCardState extends State<_DocCard> {
  final _filesRepo = FilesRepository();
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final d = widget.doc;
    final title = (d.name?.trim().isNotEmpty ?? false)
        ? d.name!.trim()
        : 'Документ #${d.id}';
    final number = (d.number ?? '').trim();
    final docTypeName = (d.documentType?.name ?? '').trim();
    final categoryName = (d.documentCategory?.name ?? '').trim();
    final isExpired = d.isExpired == true;
    final cs = Theme.of(context).colorScheme;
    final cardBg = Theme.of(context).cardColor;
    final divider = Theme.of(context).dividerColor;
    return Material(
      color: cardBg,
      borderRadius: BorderRadius.circular(20),
      elevation: 0.8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
          trailing: const SizedBox.shrink(),
          onExpansionChanged: (v) {
            if (!mounted) return;
            setState(() => _expanded = v);
          },
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _badge(
                    (docTypeName.isNotEmpty ? docTypeName : 'ДОКУМЕНТ')
                        .toUpperCase(),
                    bg: cs.surface,
                    fg: cs.onSurface.withAlpha((0.8 * 255).round()),
                  ),
                  const SizedBox(width: 10),
                  _badge(
                    isExpired ? 'ИСТЁК' : 'ДЕЙСТВУЕТ',
                    bg: isExpired ? cs.errorContainer : cs.primaryContainer,
                    fg: isExpired ? cs.onErrorContainer : cs.onPrimaryContainer,
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: AnimatedRotation(
                      turns: _expanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeInOut,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 28,
                        color: cs.onSurface.withAlpha((0.55 * 255).round()),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                  color: cs.onSurface,
                ),
              ),
              if (number.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  '№ $number',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface.withAlpha((0.65 * 255).round()),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  if (docTypeName.isNotEmpty)
                    _tag('ТИП: ${docTypeName.toUpperCase()}', context),
                  if (categoryName.isNotEmpty)
                    _tag('КАТЕГОРИЯ: ${categoryName.toUpperCase()}', context),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _dateColumn(
                      context: context,
                      label: 'ВЫДАН',
                      value: _fmtDate(d.issueDate),
                      alignEnd: false,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 36,
                    color: divider,
                  ),
                  Expanded(
                    child: _dateColumn(
                      context: context,
                      label: 'ДЕЙСТВУЕТ ДО',
                      value: _fmtDate(d.expirationDate),
                      alignEnd: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
          children: [
            const SizedBox(height: 12),
            if (d.files.isNotEmpty) _filesSection(d.files) else _emptyFiles(),
          ],
        ),
      ),
    );
  }

  Widget _emptyFiles() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Text(
        'Файлов нет',
        style: TextStyle(
          fontSize: 13,
          height: 1.2,
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _filesSection(List<DocumentFile> files) {
    final children = <Widget>[];
    for (final f in files) {
      final key = (f.s3Path?.objectName ?? '').trim();
      final fileName = (f.name ?? '').trim().isNotEmpty
          ? f.name!.trim()
          : 'Файл #${f.id}';
      final sizeBytes = f.s3Path?.size ?? 0;
      children.add(
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      Icons.description_outlined,
                      size: 25,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fileName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (sizeBytes > 0)
                          Text(
                            'РАЗМЕР: ${_formatBytes(sizeBytes)}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withAlpha((0.65 * 255).round()),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () => _openFile(f),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Icon(
                        Icons.download_rounded,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              if (key.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'ЦИФРОВОЙ КЛЮЧ ДОСТУПА',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface.withAlpha((0.45 * 255).round()),
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: SelectableText(
                    key,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.2,
                      color: Theme.of(context).colorScheme.onSurface.withAlpha((0.75 * 255).round()),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _kvBlock(
                      context: context,
                      label: 'АВТОР',
                      value: _authorName(f),
                      alignEnd: false,
                    ),
                  ),
                  Expanded(
                    child: _kvBlock(
                      context: context,
                      label: 'ДАТА СОЗДАНИЯ',
                      value: _fmtDate(f.createdTime),
                      alignEnd: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
      children.add(const SizedBox(height: 12));
    }
    if (children.isNotEmpty) children.removeLast();
    return Column(children: children);
  }

  static Widget _badge(
    String text, {
    required Color bg,
    required Color fg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          height: 1,
          fontWeight: FontWeight.w900,
          color: fg,
        ),
      ),
    );
  }

  static Widget _tag(String text, BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          height: 1.1,
          fontWeight: FontWeight.w800,
          color: cs.onSurface,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  static Widget _dateColumn({
    required BuildContext context,
    required String label,
    required String value,
    required bool alignEnd,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: cs.onSurface.withAlpha((0.45 * 255).round()),
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }

  static Widget _kvBlock({
    required BuildContext context,
    required String label,
    required String value,
    required bool alignEnd,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: cs.onSurface.withAlpha((0.45 * 255).round()),
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: cs.onSurface.withAlpha((0.85 * 255).round()),
          ),
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
        ),
      ],
    );
  }

  static String _authorName(DocumentFile f) {
    final a = f.author;
    if (a == null) return '-';
    final parts = <String>[];
    final ln = (a.lastName ?? '').trim();
    final fn = (a.firstName ?? '').trim();
    final mn = (a.fatherName ?? '').trim();
    if (ln.isNotEmpty) parts.add(ln);
    if (fn.isNotEmpty) parts.add(fn);
    if (mn.isNotEmpty) parts.add(mn);
    return parts.isEmpty ? '-' : parts.join(' ');
  }

  static String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const kb = 1024;
    const mb = 1024 * 1024;
    const gb = 1024 * 1024 * 1024;
    String fmt(num n) {
      final s = n.toStringAsFixed(n >= 10 ? 0 : 1);
      return s.replaceAll('.0', '');
    }
    if (bytes >= gb) return '${fmt(bytes / gb)} GB';
    if (bytes >= mb) return '${fmt(bytes / mb)} MB';
    if (bytes >= kb) return '${fmt(bytes / kb)} KB';
    return '$bytes B';
  }

  Future<void> _openFile(DocumentFile f) async {
    final key = (f.s3Path?.objectName ?? '').trim();
    if (key.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нет ссылки на файл (objectName)')),
      );
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      const SnackBar(content: Text('Скачиваю файл...')),
    );
    try {
      final safeName = (f.name?.trim().isNotEmpty ?? false)
          ? f.name!.trim()
          : key.split('/').last;
      final file = await _filesRepo.downloadToTemp(
        key: key,
        fileName: safeName,
      );
      messenger.hideCurrentSnackBar();
      final result = await OpenFilex.open(file.path);
      if (result.type != ResultType.done && mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Не удалось открыть файл: ${result.message}')),
        );
      }
    } catch (e) {
      messenger.hideCurrentSnackBar();
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Ошибка открытия файла: $e')),
      );
    }
  }

  static String _fmtDate(String? iso) {
    if (iso == null || iso.isEmpty) return '-';
    try {
      final dt = DateTime.parse(iso).toLocal();
      String two(int n) => n.toString().padLeft(2, '0');
      return '${two(dt.day)}.${two(dt.month)}.${dt.year}';
    } catch (_) {
      return iso;
    }
  }
}
