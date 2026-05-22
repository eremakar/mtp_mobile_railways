import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:passflow_app/pages/image_constant.dart';

class WagonServicesCounters {
  final int sanitaryDone;
  final int sanitaryTotal;

  final int technicalDone;
  final int technicalTotal;

  final int equipmentDone;
  final int equipmentTotal;

  final int lu72Done;
  final int lu72Total;

  final int vu8Count;

  const WagonServicesCounters({
    this.sanitaryDone = 0,
    this.sanitaryTotal = 0,
    this.technicalDone = 0,
    this.technicalTotal = 0,
    this.equipmentDone = 0,
    this.equipmentTotal = 0,
    this.lu72Done = 0,
    this.lu72Total = 0,
    this.vu8Count = 0,
  });
}

class WagonServicesPage extends StatelessWidget {
  final int wagonId;
  final WagonServicesCounters counters;

  /// Переходы (передай свои роуты/логика навигации)
  final VoidCallback? onOpenSanitary;
  final VoidCallback? onOpenTechnical;
  final VoidCallback? onOpenEquipment;
  final VoidCallback? onOpenLU72;
  final VoidCallback? onOpenVU8;

  final Future<void> Function()? onRefresh;

  const WagonServicesPage({
    Key? key,
    required this.wagonId,
    required this.counters,
    this.onOpenSanitary,
    this.onOpenTechnical,
    this.onOpenEquipment,
    this.onOpenLU72,
    this.onOpenVU8,
    this.onRefresh,
  }) : super(key: key);

  Color get _chipRed => const Color(0xFFF44336);
  Color get _chipGreen => const Color(0xFF22C55E);
  Color get _cardBg => Colors.white;
  Color get _groupTitle => const Color(0xFF9AA3AE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Сервисы по вагону',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: SvgPicture.asset(ImageConstant.refresh, width: 20, height: 20), 
            onPressed: () async {
              if (onRefresh != null) await onRefresh!();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _GroupTitle('Приемка вагона', color: _groupTitle),
            _CardContainer(
              child: Column(
                children: [
                  _ServiceRow(
                    icon: SvgPicture.asset(ImageConstant.wand_sparkles, width: 20, height: 20), 
                    title: 'Санитарное состояние',
                    trailing: _CounterChip(
                      value: '${counters.sanitaryDone}/${counters.sanitaryTotal}',
                      color: _chipRed,
                    ),
                    onTap: onOpenSanitary,
                  ),
                  const _DividerInset(),
                  _ServiceRow(
                    icon: SvgPicture.asset(ImageConstant.wrench, width: 20, height: 20), 
                    title: 'Техническое состояние',
                    trailing: _CounterChip(
                      value: '${counters.technicalDone}/${counters.technicalTotal}',
                      color: _chipRed,
                    ),
                    onTap: onOpenTechnical,
                  ),
                  const _DividerInset(),
                  _ServiceRow(
                    icon: SvgPicture.asset(ImageConstant.shapes, width: 20, height: 20), 
                    title: 'Экипировка (ФИУ-11)',
                    trailing: _CounterChip(
                      value: '${counters.equipmentDone}/${counters.equipmentTotal}',
                      color: _chipRed,
                    ),
                    onTap: onOpenEquipment,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _GroupTitle('Постельное белье и учет', color: _groupTitle),
            _CardContainer(
              child: _ServiceRow(
                 icon: SvgPicture.asset(ImageConstant.shell_2, width: 20, height: 20), // условная пиктограмма для ЛУ-72
                title: 'ЛУ-72',
                trailing: _CounterChip(
                  value: '${counters.lu72Done}/${counters.lu72Total}',
                  color: _chipGreen,
                ),
                onTap: onOpenLU72,
              ),
            ),
            const SizedBox(height: 16),

            _GroupTitle('Замечания по вагону', color: _groupTitle),
            _CardContainer(
              child: _ServiceRow(
                 icon: SvgPicture.asset(ImageConstant.triangle_alert, width: 20, height: 20), 
                title: 'ВУ-8',
                trailing: _CounterChip(
                  value: '${counters.vu8Count}',
                  color: _chipGreen,
                ),
                onTap: onOpenVU8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupTitle extends StatelessWidget {
  final String text;
  final Color? color;
  const _GroupTitle(this.text, {this.color});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 8),
      child: Text(
        text,
        style: TextStyle(
          color: color ?? Colors.black54,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

class _CardContainer extends StatelessWidget {
  final Widget child;
  const _CardContainer({required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ServiceRow extends StatelessWidget {
  final Widget icon;
  final String title;
  final Widget trailing;
  final VoidCallback? onTap;

  const _ServiceRow({
    required this.icon,
    required this.title,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: icon,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _CounterChip extends StatelessWidget {
  final String value;
  final Color color;
  const _CounterChip({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _DividerInset extends StatelessWidget {
  const _DividerInset();
  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      indent: 62, 
      endIndent: 12,
      color: Color(0xFFE8ECEF),
    );
  }
}