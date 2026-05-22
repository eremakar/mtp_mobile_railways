import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localization/localization.dart';

class CargoCalcPage extends StatefulWidget {
  const CargoCalcPage({super.key});

  @override
  State<CargoCalcPage> createState() => _CargoCalcPageState();
}

class _CargoCalcPageState extends State<CargoCalcPage> {
  final _formKey = GlobalKey<FormState>();
  final _weightCtrl = TextEditingController();
  bool _submitted = false;

  List<String> _stations = const [];
  Map<String, Map<String, int>> _distances = const {};
  bool _loading = true;

  String? _from;
  String? _to;
  int? _distanceKm;
  int? _roundedWeight;
  double? _result;
  String? _calcError;

  @override
  void dispose() {
    _weightCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadStationsAndDistances();
  }

  Future<void> _loadStationsAndDistances() async {
    try {
      final raw = await rootBundle.loadString('assets/json/route.json');
      final data = jsonDecode(raw) as Map<String, dynamic>;

      final stations = (data['stations'] as List).cast<String>();
      final distRaw = data['distances'] as Map<String, dynamic>;

      final distances = distRaw.map((from, toMap) {
        final inner = (toMap as Map).map(
          (to, v) => MapEntry(to.toString(), (v as num).toInt()),
        );
        return MapEntry(from, Map<String, int>.from(inner));
      });

      setState(() {
        _stations = stations;
        _distances = Map<String, Map<String, int>>.from(distances);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _stations = const [];
        _distances = const {};
        _loading = false;
        _calcError = 'Не удалось загрузить таблицу дистанций';
      });
    }
  }

  void _showWeightInfo() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Информация о весе'),
        content: const Text(
          'Вес вводится целыми числами и округляется в большую сторону до ближайшего десятка (например: 23 кг - 30 кг).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }

  void _calculate() {
    if (!_submitted) setState(() => _submitted = true);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final weight = int.parse(_weightCtrl.text.trim());
    final roundedWeight = ((weight + 9) ~/ 10) * 10;

    final distance = _distances[_from!]?[_to!];
    if (distance == null) {
      setState(() {
        _calcError = 'Дистанция для выбранного маршрута не найдена';
        _result = null;
        _distanceKm = null;
        _roundedWeight = null;
      });
      return;
    }

    final cost = distance * roundedWeight * 0.85 * 1.12;

    setState(() {
      _calcError = null;
      _distanceKm = distance;
      _roundedWeight = roundedWeight;
      _result = cost.ceilToDouble();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'menu-calc'.i18n(),
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          color: theme.cardColor,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            child: Form(
              key: _formKey,
              autovalidateMode: _submitted
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _LabelRequired(text: 'Маршрут'),
                  if (_loading) ...[
                    const SizedBox(height: 10),
                    const LinearProgressIndicator(minHeight: 2),
                  ],
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _from,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Откуда',
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                          ),
                          hint: const Text('Выберите пункт'),
                          items: _stations
                              .map((p) => DropdownMenuItem(
                                    value: p,
                                    child: Text(p,
                                        overflow: TextOverflow.ellipsis),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _from = value;
                              if (_to == value) _to = null;
                            });
                          },
                          validator: (v) =>
                              v == null ? 'Выберите пункт отправления' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _to,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Куда',
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                          ),
                          hint: const Text('Выберите пункт'),
                          items: _stations
                              .where((p) => p != _from)
                              .map((p) => DropdownMenuItem(
                                    value: p,
                                    child: Text(p,
                                        overflow: TextOverflow.ellipsis),
                                  ))
                              .toList(),
                          onChanged: (value) => setState(() => _to = value),
                          validator: (v) =>
                              v == null ? 'Выберите пункт назначения' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      const Expanded(
                        child:
                            _LabelRequired(text: 'Общий вес грузобагажа (кг)'),
                      ),
                      IconButton(
                        onPressed: _showWeightInfo,
                        icon: const Icon(Icons.help_outline, size: 22),
                        color: Colors.redAccent,
                        tooltip: 'Правила округления веса',
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _weightCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      hintText: '0',
                      border: OutlineInputBorder(),
                      isDense: true,
                      suffixText: 'кг',
                    ),
                    validator: (value) {
                      final text = (value ?? '').trim();
                      if (text.isEmpty) return 'Введите вес';
                      final num = int.tryParse(text);
                      if (num == null) return 'Только целые числа';
                      if (num <= 0) return 'Вес должен быть больше 0';
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: (!_loading &&
                            _stations.isNotEmpty &&
                            _from != null &&
                            _to != null)
                        ? _calculate
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1DB954),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Рассчитать стоимость',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ),
                  if (_calcError != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _calcError!,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  if (_result != null) ...[
                    const SizedBox(height: 26),
                    const _ResultHeader(title: 'Результат'),
                    const SizedBox(height: 14),
                    _ResultCard(
                      from: _from ?? '—',
                      to: _to ?? '—',
                      distanceKm: _distanceKm,
                      roundedWeight: _roundedWeight,
                      cost: _result!.toStringAsFixed(0),
                    ),
                    const SizedBox(height: 18),
                    const _RulesBox(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LabelRequired extends StatelessWidget {
  const _LabelRequired({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        children: [
          TextSpan(text: text),
          const TextSpan(
            text: ' *',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _ResultHeader extends StatelessWidget {
  const _ResultHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: cs.outlineVariant.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 1,
            color: cs.outlineVariant.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.from,
    required this.to,
    required this.cost,
    this.distanceKm,
    this.roundedWeight,
  });

  final String from;
  final String to;
  final String cost;
  final int? distanceKm;
  final int? roundedWeight;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget row(String label, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 130,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface.withValues(alpha: 0.65),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 10),
            color: Colors.black.withValues(alpha: 0.06),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Маршрут',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$from → $to',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: cs.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Стоимость',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$cost ₸',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: cs.outlineVariant.withValues(alpha: 0.7)),
          const SizedBox(height: 8),
          if (distanceKm != null) row('Дистанция', '$distanceKm км'),
          if (roundedWeight != null) row('Вес (округл.)', '$roundedWeight кг'),
        ],
      ),
    );
  }
}

class _RulesBox extends StatelessWidget {
  const _RulesBox();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bodyColor =
        isDark ? const Color(0xFF334155) : cs.onSurface.withValues(alpha: 0.75);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6FFF5),
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: const Color(0xFF8BC34A).withValues(alpha: 0.7)),
      ),
      child: DefaultTextStyle(
        style: TextStyle(
          fontSize: 14,
          height: 1.4,
          color: bodyColor,
          fontWeight: FontWeight.w500,
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '*Краткая информация о правилах перевозки багажа и грузобагажа:',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF2E7D32),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'При наличии проездного документа предоставляется 50% скидка к стоимости отправки грузобагажа.',
            ),
            SizedBox(height: 10),
            Text(
              'Для перевозки багажа в багажном вагоне максимально допустимый вес 200 кг, при отправке свыше 200 кг часть веса (допустимая норма) оплачивается по тарифу багажа, а оставшаяся часть веса оплачивается по тарифу грузобагажа.',
            ),
            SizedBox(height: 10),
            Text(
              'Плата за перевозку багажа, принятого багажным отделением к перевозке, взимается на станции отправления багажа при оформлении перевозочных документов.',
            ),
            SizedBox(height: 10),
            Text(
              'Расчёт стоимости является предварительным без учёта дополнительных сборов. Для определения точной стоимости Вы можете обратиться в багажное отделение при его наличии в Вашем городе, либо обратиться по телефонам.',
            ),
          ],
        ),
      ),
    );
  }
}
