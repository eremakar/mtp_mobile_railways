import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:passflow_app/l10n/app_localizations.dart';

class PaymentAcceptPage extends StatefulWidget {
  const PaymentAcceptPage({
    Key? key,
  }) : super(key: key);

  @override
  State<PaymentAcceptPage> createState() => _PaymentAcceptPageState();
}

class _PaymentAcceptPageState extends State<PaymentAcceptPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  String? _service;
  String? _bank;
  String? _amount;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF6F7FB);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.payment_accept,
          style: const TextStyle(
              fontWeight: FontWeight.w800, color: Color(0xFF111827)),
        ),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        // leading: IconButton(
        //   icon: const Icon(CupertinoIcons.back, color: Color(0xFF111827)),
        //   onPressed: () => Navigator.of(context).maybePop(),
        // ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(CupertinoIcons.refresh_thin,
                color: Color(0xFF111827)),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 12, right: 12),
            child: _SegmentedTabs(controller: _tab),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tab,
        physics: const ClampingScrollPhysics(),
        children: [
          _acceptTab(context),
          _historyTab(),
        ],
      ),
    );
  }

  Widget _acceptTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      children: [
        // Заглушка под QR
        Center(
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F7),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              'assets/svg_icons/Section.svg',
              width: 220,
              height: 220,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 24),

        _PickerTile(
          title: AppLocalizations.of(context)!.service_for_payment,
          value: _service,
          onTap: _pickService,
        ),
        const SizedBox(height: 12),

        _PickerTile(
          title: AppLocalizations.of(context)!.payment_amount,
          value: _amount,
          onTap: _pickAmount,
        ),
        const SizedBox(height: 12),

        _PickerTile(
          title: AppLocalizations.of(context)!.choose_bank,
          value: _bank,
          onTap: _pickBank,
        ),
        const SizedBox(height: 24),

        FilledButton(
          onPressed: (_service != null && _amount != null && _bank != null)
              ? _startPayment
              : null,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(AppLocalizations.of(context)!.generate_qr_start_payment,
              style: const TextStyle(fontWeight: FontWeight.w800)),
        )
      ],
    );
  }

  Widget _historyTab() {
    return ListView.separated(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: 2,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 6))
          ],
        ),
        child: Row(
          children: [
            const Icon(CupertinoIcons.creditcard, color: Color(0xFF111827)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(AppLocalizations.of(context)!.history_payment_item,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, color: Color(0xFF111827))),
            ),
            Text(
              i == 0
                  ? AppLocalizations.of(context)!.status_success
                  : AppLocalizations.of(context)!.status_cancel,
              style: TextStyle(
                color:
                    i == 0 ? const Color(0xFF16A34A) : const Color(0xFFE11D48),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickService() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => _BottomPicker(
        title: AppLocalizations.of(context)!.choose_service,
        children: [
          _sheetItem(AppLocalizations.of(context)!.service_tea_coffee),
          _sheetItem(AppLocalizations.of(context)!.service_bedding),
          _sheetItem(AppLocalizations.of(context)!.service_extra_baggage),
          _sheetItem(AppLocalizations.of(context)!.service_other),
        ],
      ),
    );
    if (selected != null) setState(() => _service = selected);
  }

  Future<void> _pickAmount() async {
    final controller = TextEditingController(text: _amount ?? '');
    final ok = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          left: 16,
          right: 16,
          top: 8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalizations.of(context)!.payment_amount,
                style:
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.enter_amount_hint,
                border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12))),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(AppLocalizations.of(context)!.done,
                  style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
    if (ok == true) setState(() => _amount = controller.text.trim());
  }

  Future<void> _pickBank() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => _BottomPicker(
        title: AppLocalizations.of(context)!.choose_bank,
        children: [
          _sheetItem(AppLocalizations.of(context)!.bank_kaspi),
          _sheetItem(AppLocalizations.of(context)!.bank_jusan),
          _sheetItem(AppLocalizations.of(context)!.bank_halyk),
          _sheetItem(AppLocalizations.of(context)!.bank_forte),
        ],
      ),
    );
    if (selected != null) setState(() => _bank = selected);
  }

  ListTile _sheetItem(String title) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      onTap: () => Navigator.pop(context, title),
    );
  }

  void _startPayment() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!
            .payment_started(_service ?? '', _amount ?? '', _bank ?? '')),
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({required this.title, this.value, this.onTap});
  final String title;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasValue = (value != null && value!.isNotEmpty);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF3F7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                hasValue ? value! : title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: hasValue ? FontWeight.w800 : FontWeight.w700,
                  color: const Color.fromARGB(255, 108, 108, 108),
                ),
              ),
            ),
            const Icon(CupertinoIcons.right_chevron, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}

class _SegmentedTabs extends StatefulWidget {
  const _SegmentedTabs({required this.controller});
  final TabController controller;

  @override
  State<_SegmentedTabs> createState() => _SegmentedTabsState();
}

class _SegmentedTabsState extends State<_SegmentedTabs> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.controller.index;
    widget.controller.addListener(_onTabChange);
  }

  @override
  void didUpdateWidget(covariant _SegmentedTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTabChange);
      _index = widget.controller.index;
      widget.controller.addListener(_onTabChange);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTabChange);
    super.dispose();
  }

  void _onTabChange() {
    if (!mounted) return;
    if (_index != widget.controller.index) {
      setState(() => _index = widget.controller.index);
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgGroup = Color(0x00FFFFFF); // прозрачный фон группы
    const bgUnselected = Color(0xFFEFF3F7);
    const bgSelected = Color(0xFF1E6AF2);

    Widget chip(String text, int idx) {
      final selected = _index == idx;
      return GestureDetector(
        onTap: () => widget.controller.animateTo(idx),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? bgSelected : bgUnselected,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFF111827),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
    }

    return Container(
      color: bgGroup,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          chip(AppLocalizations.of(context)!.payment_accept, 0),
          const SizedBox(width: 8),
          chip(AppLocalizations.of(context)!.payment_history, 1),
        ],
      ),
    );
  }
}

class _BottomPicker extends StatelessWidget {
  const _BottomPicker({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 12,
          top: 8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                title,
                style:
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 420),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemCount: children.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (ctx, i) => children[i],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
