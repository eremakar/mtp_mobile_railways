import 'package:flutter/material.dart';

class EquipmentMainPageV2 extends StatelessWidget {
  const EquipmentMainPageV2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFEF4444);
    const green = Color(0xFF10B981);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Экипировка (ФИУ-11)',
            style: TextStyle(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),

            // Верхний блок
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _CardBlock(children: [
                _RowItem(
                  icon: Icons.dashboard_outlined,
                  title: 'Съёмное имущество',
                  badge: const _Badge(text: '46', color: green),
                  onTap: () {},
                ),
                const Divider(height: 1, color: Color(0xFFECEFF3)),
                _RowItem(
                  icon: Icons.credit_card_outlined,
                  title: 'Имущество',
                  badge: const _Badge(text: '0', color: red),
                  onTap: () {},
                ),
                const Divider(height: 1, color: Color(0xFFECEFF3)),
                _RowItem(
                  icon: Icons.error_outline,
                  title: 'Акт учета имущества',
                  badge: const _Badge(text: '0', color: red),
                  onTap: () {},
                ),
              ]),
            ),

            const SizedBox(height: 14),

            // Нижний блок
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _CardBlock(children: const [
                _RowItem(
                  icon: Icons.history,
                  title: 'История учета',
                  badge: _Badge(text: '5', color: green),
                ),
              ]),
            ),

            const Spacer(),

            // Кнопка "Отправить" (disabled)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E5E7),
                  borderRadius: BorderRadius.circular(28),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Отправить',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardBlock extends StatelessWidget {
  final List<Widget> children;
  const _CardBlock({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(children: children),
      ),
    );
  }
}

class _RowItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? badge;
  final VoidCallback? onTap;
  const _RowItem({
    required this.icon,
    required this.title,
    this.badge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 20, color: Colors.black87),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            if (badge != null) badge!,
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}