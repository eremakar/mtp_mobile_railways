import 'package:flutter/material.dart';
import 'package:passflow_app/data/models/services_model/vu8_remark_models.dart';
import 'package:passflow_app/data/repositories/vu8_repository.dart';
import 'package:passflow_app/widgets/page/vu8/category_select_breakdown.dart';

class AddRemarkPage extends StatefulWidget {
  final Vu8Repository? repository;

  final int? wagonId;
  final int? routeId;
  final int? routeSheetId;

  final int? employeeId;

  const AddRemarkPage({
    Key? key,
    this.repository,
    this.wagonId,
    this.routeId,
    this.routeSheetId,
    this.employeeId,
  }) : super(key: key);

  @override
  State<AddRemarkPage> createState() => _AddRemarkPageState();
}

class _AddRemarkPageState extends State<AddRemarkPage> {
  int currentTab = 0;
  String? category;
  int? categoryTypeId;
  String? categoryOther;
  final textCtrl = TextEditingController();

  bool _loadingHistory = false;
  String? _historyError;
  List<Vu8Remark> _history = const [];

  late final Vu8Repository _repo = widget.repository ?? Vu8Repository();

  bool _submitting = false;
  String? _submitError;
  String? _imageUrl;

  bool get _canSubmit {
    return !_submitting &&
        categoryTypeId != null &&
        textCtrl.text.trim().isNotEmpty &&
        widget.wagonId != null;
  }

  @override
  void initState() {
    super.initState();
    textCtrl.addListener(_onFormChanged);
    _loadHistory();
  }

  String _fmtDate(DateTime dt) {
    final d = dt.toLocal();

    if (d.year <= 1900) return '—';

    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    return '$dd.$mm.$yyyy';
  }

  void _onFormChanged() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _submitRemark() async {
    final typeId = categoryTypeId;
    final text = textCtrl.text.trim();

    if (typeId == null || text.isEmpty) return;

    final wagonId = widget.wagonId;
    final employeeId = widget.employeeId;
    final routeId = widget.routeId;
    final routeSheetId = widget.routeSheetId;

    if (wagonId == null) {
      setState(() {
        _submitError = 'Не указан wagonId — сохранить нельзя.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Не удалось сохранить: не указан wagonId')),
      );
      return;
    }

    setState(() {
      _submitting = true;
      _submitError = null;
    });

    try {
      await _repo.createRemark(
        text: text,
        wagonId: wagonId,
        typeId: typeId,
        employeeId: employeeId,
        routeId: routeId,
        routeSheetId: routeSheetId,
        imageUrl: (_imageUrl != null && _imageUrl!.trim().isNotEmpty)
            ? _imageUrl
            : null,
      );

      if (!mounted) return;

      setState(() {
        category = null;
        categoryTypeId = null;
        categoryOther = null;
        _imageUrl = null;
      });
      textCtrl.clear();

      setState(() => currentTab = 1);
      await _loadHistory();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Замечание сохранено')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitError = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось сохранить замечание')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _submitting = false;
      });
    }
  }

  Future<void> _loadHistory() async {
    if (widget.wagonId == null) return;

    setState(() {
      _loadingHistory = true;
      _historyError = null;
    });

    try {
      final res = await _repo.searchByWagon(
        wagonId: widget.wagonId!,
        routeId: widget.routeId,
        routeSheetId: widget.routeSheetId,
      );

      setState(() {
        _history = res?.result ?? const [];
      });
    } catch (e) {
      setState(() {
        _historyError = 'Не удалось загрузить историю';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingHistory = false;
        });
      }
    }
  }

  @override
  void dispose() {
    textCtrl.removeListener(_onFormChanged);
    textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF5F6F7);
    const blue = Color(0xFF1877F2);
    const lightBlue = Color(0xFFE8F2FF);
    const pillGrey = Color(0xFFEDEFF1);
    const fieldGrey = Color(0xFFF2F4F5);
    final borderRadius = BorderRadius.circular(18);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title:
            const Text('ВУ-8', style: TextStyle(fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistory,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  _pill(
                    label: 'Добавить замечание',
                    selected: currentTab == 0,
                    onTap: () => setState(() => currentTab = 0),
                    selectedColor: blue,
                  ),
                  const SizedBox(width: 10),
                  _pill(
                    label: 'История записей (${_history.length})',
                    selected: currentTab == 1,
                    onTap: () => setState(() => currentTab = 1),
                    selectedColor: blue,
                    unselectedBg: pillGrey,
                    selectedFg: Colors.white,
                  ),
                ],
              ),
            ),
            if (currentTab == 0)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Выберите категорию замечания и\nопишите подробнее причину',
                        style: TextStyle(
                          fontSize: 20,
                          height: 1.25,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () async {
                          final res = await Navigator.of(context)
                              .push<Map<String, String?>>(
                            MaterialPageRoute(
                              builder: (_) => SelectCategoryPage(
                                repo: _repo,
                                initial: category,
                              ),
                            ),
                          );

                          if (!mounted || res == null) return;

                          final other = (res['other'] ?? '').trim();
                          final typeName = (res['typeName'] ?? '').trim();
                          setState(() {
                            categoryTypeId =
                                int.tryParse((res['typeId'] ?? '').toString());
                            categoryOther = other.isNotEmpty ? other : null;
                            category = other.isNotEmpty ? other : typeName;
                          });
                        },
                        child: Container(
                          height: 64,
                          decoration: BoxDecoration(
                            color: fieldGrey,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  category ?? 'Категория',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: category == null
                                        ? Colors.grey[600]
                                        : Colors.black,
                                  ),
                                ),
                              ),
                              const Icon(Icons.chevron_right,
                                  color: Colors.grey),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Container(
                        decoration: BoxDecoration(
                          color: fieldGrey,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: textCtrl,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Ваш текст',
                          ),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),

                      const SizedBox(height: 16),

                      InkWell(
                        borderRadius: BorderRadius.circular(22),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Добавление фото пока не реализовано')),
                          );
                        },
                        child: Container(
                          height: 64,
                          decoration: BoxDecoration(
                            color: lightBlue,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.photo_camera_outlined,
                                  color: Color(0xFF1671E6)),
                              SizedBox(width: 8),
                              Text(
                                'Добавить фото',
                                style: TextStyle(
                                  color: Color(0xFF1671E6),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Bottom buttons
                      // Save
                      InkWell(
                        borderRadius: borderRadius,
                        onTap: _canSubmit ? _submitRemark : null,
                        child: Container(
                          height: 64,
                          decoration: BoxDecoration(
                            color: _canSubmit ? blue : const Color(0xFFE2E5E7),
                            borderRadius: borderRadius,
                          ),
                          alignment: Alignment.center,
                          child: _submitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(
                                  'Сохранить',
                                  style: TextStyle(
                                    color: _canSubmit
                                        ? Colors.white
                                        : Colors.grey[600],
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),

                      if (_submitError != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          _submitError!,
                          style: const TextStyle(
                              color: Colors.redAccent, fontSize: 14),
                        ),
                      ],

                      const SizedBox(height: 12),

                      InkWell(
                        borderRadius: borderRadius,
                        onTap: () => Navigator.of(context).maybePop(),
                        child: Container(
                          height: 64,
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: borderRadius,
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Отменить',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadHistory,
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
                          children: [
                            if (widget.wagonId == null)
                              const Padding(
                                padding: EdgeInsets.fromLTRB(16, 40, 16, 0),
                                child: Center(
                                  child: Text(
                                    'Не указан wagonId — историю загрузить нельзя.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.black54, fontSize: 16),
                                  ),
                                ),
                              )
                            else if (_loadingHistory)
                              const Padding(
                                padding: EdgeInsets.fromLTRB(16, 40, 16, 0),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              )
                            else if (_historyError != null)
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 40, 16, 0),
                                child: Center(
                                  child: Text(
                                    _historyError!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: Colors.black54, fontSize: 16),
                                  ),
                                ),
                              )
                            else if (_history.isEmpty)
                              const Padding(
                                padding: EdgeInsets.fromLTRB(16, 40, 16, 0),
                                child: Center(
                                  child: Text(
                                    'Пока нет замечаний',
                                    style: TextStyle(
                                        color: Colors.black54, fontSize: 16),
                                  ),
                                ),
                              )
                            else
                              ..._history.expand((item) {
                                final isDone = (item.completedText ?? '')
                                    .trim()
                                    .isNotEmpty;
                                final statusText =
                                    isDone ? 'Исправлено' : 'Создано';
                                final statusColor = isDone
                                    ? const Color(0xFF2E7D32)
                                    : const Color(0xFF1671E6);

                                final title =
                                    item.type?.name ?? 'Без категории';
                                final author = item.employee?.shortName ?? '—';
                                final date = _fmtDate(item.createdTime);

                                const attachments = <_Attach>[];

                                return [
                                  _RemarkHistoryItem(
                                    title: title,
                                    text: item.text,
                                    statusText: statusText,
                                    statusColor: statusColor,
                                    rightAvatar: _Avatar(
                                      url: null,
                                      initials:
                                          (item.employee?.initials.isNotEmpty ??
                                                  false)
                                              ? item.employee!.initials
                                              : 'A',
                                    ),
                                    author: author,
                                    date: date,
                                    borderColor: statusColor,
                                    attachments: attachments,
                                    onEdit: () {
                                      //
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                ];
                              }),
                          ],
                        ),
                      ),
                    ),
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 26, 20),
                        child: SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: blue,
                              shape: const StadiumBorder(),
                            ),
                            onPressed: () {
                              setState(() => currentTab = 0);
                            },
                            child: const Text(
                              'Добавить замечание',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _pill({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    Color selectedColor = Colors.black,
    Color unselectedBg = const Color(0xFFEDEFF1),
    Color selectedFg = Colors.white,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? selectedColor : unselectedBg,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? selectedFg : Colors.black87.withOpacity(0.75),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final String title;
  final String text;
  final String statusText;
  final Color statusColor;
  final String author;
  final String date;
  final Color borderColor;
  final List<_Attach> attachments;

  const _HistoryCard({
    required this.title,
    required this.text,
    required this.statusText,
    required this.statusColor,
    required this.author,
    required this.date,
    required this.borderColor,
    this.attachments = const [],
  });

  @override
  Widget build(BuildContext context) {
    const cardBg = Color(0xFFF6F8FA);
    const cardRadius = 18.0;
    const stripeWidth = 4.0;
    const dividerColor = Color(0xFFEAEAEA);
    const statusLabelWeight = FontWeight.w700;
    const statusFontSize = 16.0;
    const titleFontSize = 18.0;
    const titleWeight = FontWeight.w700;
    const textFontSize = 15.0;
    const textColor = Color(0xDE000000);
    const textSecondaryColor = Color(0x99000000);
    const attachIconColor = Color(0xFF1877F2);

    const double _topPad = 12;
    final double _bottomPad = attachments.isEmpty ? 12 : 10;
    const double _sidePad = 16;
    final borderRadius = BorderRadius.circular(cardRadius);

    return ClipRRect(
      borderRadius: borderRadius,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Container(color: cardBg),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                margin: const EdgeInsets.only(left: 12),
                padding: EdgeInsets.fromLTRB(
                    _sidePad, _topPad, _sidePad, _bottomPad),
                decoration: const BoxDecoration(
                  color: Color(0xFFF2F4F5),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(cardRadius - 6),
                    bottomLeft: Radius.circular(cardRadius - 6),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: titleWeight,
                        color: textColor,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      text,
                      style: const TextStyle(
                        fontSize: textFontSize,
                        color: textSecondaryColor,
                        height: 1.3,
                      ),
                      overflow: TextOverflow.visible,
                      softWrap: true,
                    ),
                    const SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                            fontSize: statusFontSize, color: textColor),
                        children: [
                          const TextSpan(
                              text: 'Статус: ',
                              style: TextStyle(fontWeight: statusLabelWeight)),
                          TextSpan(
                            text: statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (attachments.isNotEmpty) ...[
                const Divider(height: 1, thickness: 1, color: dividerColor),
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(_sidePad, 10, _sidePad, 12),
                  child: Row(
                    children: [
                      const Icon(Icons.attach_file,
                          size: 22, color: attachIconColor),
                      const SizedBox(width: 12),
                      ...attachments.map(
                        (a) => Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              a.thumbUrl,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  width: 56,
                                  height: 56,
                                  alignment: Alignment.center,
                                  color: Colors.black12,
                                  child: const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 56,
                                  height: 56,
                                  color: Colors.black12,
                                  alignment: Alignment.center,
                                  child:
                                      const Icon(Icons.broken_image, size: 18),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            child: Container(width: stripeWidth, color: borderColor),
          ),
        ],
      ),
    );
  }
}

class _AvatarContainer extends StatelessWidget {
  final Widget child;
  const _AvatarContainer({required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 44, 125, 255),
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? url;
  final String initials;
  const _Avatar({
    this.url,
    required this.initials,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 15,
      backgroundColor: Colors.transparent,
      backgroundImage: url != null ? NetworkImage(url!) : null,
      child: url == null
          ? Text(
              initials,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            )
          : null,
    );
  }
}

class _Attach {
  final String thumbUrl;
  const _Attach.thumb(this.thumbUrl);
}

/// История замечания с возможностью редактирования
class _RemarkHistoryItem extends StatelessWidget {
  final String title;
  final String text;
  final String statusText;
  final Color statusColor;
  final String author;
  final String date;
  final Color borderColor;
  final _Avatar? rightAvatar;
  final List<_Attach> attachments;
  final VoidCallback onEdit;

  const _RemarkHistoryItem({
    Key? key,
    required this.title,
    required this.text,
    required this.statusText,
    required this.statusColor,
    required this.author,
    required this.date,
    required this.borderColor,
    this.rightAvatar,
    this.attachments = const [],
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double _avatarReserve =
        rightAvatar != null ? (48 + 12).toDouble() : 0;

    return Padding(
      padding: EdgeInsets.fromLTRB(16 + _avatarReserve / 2, 0, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.only(right: _avatarReserve),
            child: _HistoryCard(
              title: title,
              text: text,
              statusText: statusText,
              statusColor: statusColor,
              author: author,
              date: date,
              borderColor: borderColor,
              attachments: attachments,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 50,
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        '$author - $date',
                        style: const TextStyle(
                          color: Color(0xFF556070),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                if (rightAvatar != null) ...[
                  const SizedBox(width: 8),
                  Transform.translate(
                    offset: const Offset(0, -6),
                    child: _AvatarContainer(child: rightAvatar!),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
