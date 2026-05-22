import 'package:flutter/material.dart';

class HoursNormsScreen extends StatelessWidget {
  HoursNormsScreen({
    super.key,
    this.periodTitle = '01 Mar 25 - 15 Mar 25',
    this.workedHours = 48,
    this.plannedHours = 150,
    this.normHours = 184,
    this.wagonTypeTitle = 'Плацкартный (54)',
    DateTime? validFrom,
    DateTime? validTo,
    this.workTrip = 41.17,
    this.guard = 8.22,
    this.workTotal = 55.08,
    this.restTime = 23.38,
    this.grandTotal = 78.47,
    this.onDownloadTnk,
    this.onRefresh,
  })  : validFrom = validFrom ?? DateTime(2025, 12, 14),
        validTo = validTo ?? DateTime(2025, 12, 20);

  final String periodTitle; 
  final double workedHours; 
  final double plannedHours;
  final double normHours;

  final String wagonTypeTitle; 
  final DateTime validFrom; 
  final DateTime validTo;   

  final double workTrip;  
  final double guard;     
  final double workTotal; 
  final double restTime;  
  final double grandTotal;

  final VoidCallback? onDownloadTnk;
  final VoidCallback? onRefresh;

  String _fmtDate(DateTime dt) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(dt.day)}.${two(dt.month)}.${dt.year}';
  }

  String _fmtNum(double v) => v.toStringAsFixed(2).replaceAll('.00', '');

  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFFF3F5F7);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Нормы часов'),
        actions: [
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _StatsCard(
            periodTitle: periodTitle,
            workedHours: workedHours,
            plannedHours: plannedHours,
            normHours: normHours,
          ),
          const SizedBox(height: 14),
          _NormsCard(
            wagonTypeTitle: wagonTypeTitle,
            validFrom: _fmtDate(validFrom),
            validTo: _fmtDate(validTo),
            workTrip: _fmtNum(workTrip),
            guard: _fmtNum(guard),
            workTotal: _fmtNum(workTotal),
            restTime: _fmtNum(restTime),
            grandTotal: _fmtNum(grandTotal),
          ),
          const SizedBox(height: 14),
          _ActionTile(
            icon: Icons.description_outlined,
            iconBg: const Color(0xFFFFB300),
            title: 'Скачать ТНК',
            onTap: onDownloadTnk,
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.periodTitle,
    required this.workedHours,
    required this.plannedHours,
    required this.normHours,
  });

  final String periodTitle;
  final double workedHours;
  final double plannedHours;
  final double normHours;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 8),
            color: Colors.black.withValues(alpha:0.06),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Статистика',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                periodTitle,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.withValues(alpha:0.85),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatItem(title: 'Отработано', value: '${workedHours.toInt()} ч'),
              const SizedBox(width: 10),
              _StatItem(title: 'План', value: '${plannedHours.toInt()} ч'),
              const SizedBox(width: 10),
              _StatItem(title: 'Норма', value: '${normHours.toInt()} ч'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F9FB),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.blue.withValues(alpha:0.85),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _NormsCard extends StatelessWidget {
  const _NormsCard({
    required this.wagonTypeTitle,
    required this.validFrom,
    required this.validTo,
    required this.workTrip,
    required this.guard,
    required this.workTotal,
    required this.restTime,
    required this.grandTotal,
  });

  final String wagonTypeTitle;
  final String validFrom;
  final String validTo;

  final String workTrip;
  final String guard;
  final String workTotal;
  final String restTime;
  final String grandTotal;

  @override
  Widget build(BuildContext context) {
    TextStyle h = const TextStyle(fontSize: 20, fontWeight: FontWeight.w800);
    TextStyle row = const TextStyle(fontSize: 16, fontWeight: FontWeight.w600);

    Widget kv(String k, String v) {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: RichText(
          text: TextSpan(
            style: row.copyWith(color: Colors.black),
            children: [
              TextSpan(text: '$k '),
              TextSpan(
                text: v,
                style: row.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      );
    }

    Widget plainLine(String text) {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text(text, style: row),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 8),
            color: Colors.black.withValues(alpha:0.06),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Нормы часов', style: h),
          kv('Тип вагона:', wagonTypeTitle),
          kv('Действует с:', validFrom),
          kv('Действует по:', validTo),

          const SizedBox(height: 14),
          Center(
            child: Text(
              'Рабочее время',
              style: row.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 6),

          plainLine('за рейс $workTrip'),
          plainLine('охрана $guard'),
          const SizedBox(height: 8),

          plainLine('время работы $workTotal'),
          plainLine('Время отдыха $restTime'),
          plainLine('Итого $grandTotal'),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.iconBg,
    required this.title,
    this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(18);

    return InkWell(
      borderRadius: r,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: r,
          boxShadow: [
            BoxShadow(
              blurRadius: 18,
              offset: const Offset(0, 8),
              color: Colors.black.withValues(alpha:0.06),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.black.withValues(alpha:0.35)),
          ],
        ),
      ),
    );
  }
}
