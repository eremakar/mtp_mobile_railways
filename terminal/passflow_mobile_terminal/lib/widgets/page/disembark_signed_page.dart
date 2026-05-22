import 'package:flutter/material.dart';
import 'package:passflow_app/widgets/page/disembarkation_signed.dart';

class DisembarkSignedPage extends StatefulWidget {
  final String passengerName;
  final int ticketsCount;
  final int refusedCount;
  final int disembarkedCount;

  /// Встроенный режим: рендер без собственного AppBar/Scaffold
  final bool embedded;

  /// Колбэк для переключения вкладок родителя (0=Талон, 1=Отказ, 2=Высадка)
  final ValueChanged<int>? onChangeTab;

  /// Необязательное имя подписанта
  final String? signerName;

  const DisembarkSignedPage({
    Key? key,
    required this.passengerName,
    required this.ticketsCount,
    required this.refusedCount,
    required this.disembarkedCount,
    this.embedded = false,
    this.onChangeTab,
    this.signerName,
  }) : super(key: key);

  @override
  State<DisembarkSignedPage> createState() => _DisembarkSignedPageState();
}

class _DisembarkSignedPageState extends State<DisembarkSignedPage> {
  int? _selectedReason;
  int? _selectedStationIndex;
  final TextEditingController _otherReasonController = TextEditingController();
  String? _otherReasonText; // сохраняем текст, если выбрано «Другое»

  @override
Widget build(BuildContext context) {
  print('[DisembarkSignedPage] embedded=${widget.embedded} ...');
  final canSubmit = _selectedReason != null && _selectedStationIndex != null;

  // ⬇️ показываем локальные пилюли только когда НЕ embedded
  final Widget topTabs = widget.embedded
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _tabPill(label: 'Талон', count: widget.ticketsCount, index: 0, selectedIndex: 2),
              _tabPill(label: 'Отказ', count: widget.refusedCount, index: 1, selectedIndex: 2),
              _tabPill(label: 'Высадка', count: widget.disembarkedCount, index: 2, selectedIndex: 2),
            ],
          ),
        );

  final content = Column(
    children: [
      topTabs, // ⬅️ здесь вместо всегда видимых пилюль
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Выберите причину высадки и опишите ситуацию при наличии',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildSelectField('Причина высадки'),
                const SizedBox(height: 12),
                _buildSelectField('Станция высадки'),
                const SizedBox(height: 12),
                _buildTextField(),
                const SizedBox(height: 12),
                // Кнопка "Подписать акт" активна только при выбранных причине и станции
                ElevatedButton(
                  onPressed: canSubmit
                      ? () {
                          // Считаем финальные тексты причины и станции
                          const reasons = [
                            'Нарушение общественного порядка',
                            'Агрессивное поведение',
                            'Распитие спиртных напитков',
                            'Заболел пассажир',
                            'Курение в поезде',
                            'Повреждение имущества поезда',
                            'Отсутствие билета',
                            'Другое',
                          ];
                          const stations = [
                            'Астана',
                            'Сары-Шаган',
                            'Берлик 2',
                            'Чемолган',
                            'Бурундай',
                            'Алматы-1',
                            'Алматы-2',
                          ];

                          final String reasonText = (_selectedReason != null)
                              ? ((reasons[_selectedReason!] == 'Другое' && (_otherReasonText?.isNotEmpty ?? false))
                                  ? _otherReasonText!
                                  : reasons[_selectedReason!])
                              : '';
                          final String stationText = (_selectedStationIndex != null)
                              ? stations[_selectedStationIndex!]
                              : '';

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => DisembarkationSigned(
                                passengerName: widget.passengerName,
                                signerName: widget.signerName ?? widget.passengerName,
                              ),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0864D4),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    disabledBackgroundColor: const Color(0xFFBFD4FB),
                    disabledForegroundColor: Colors.white,
                  ),
                  child: const Text('Подписать акт высадки'),
                ),
                const SizedBox(height: 12),
                _buildFlatButton(context, 'Отменить'),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );

    if (widget.embedded) {
      // Встроенный режим: без собственного AppBar/Scaffold
      return content;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.passengerName),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: content,
    );
  }

  /// Пилюля вкладки: при count == 0 — выглядит как обычная невыбранная, но НЕ кликается
  Widget _tabPill({
    required String label,
    required int count,
    required int index,
    required int selectedIndex,
  }) {
    final bool isSelected = selectedIndex == index;
    final bool isDisabled = count == 0;

    final bgColor = isSelected ? const Color(0xFF0864D4) : const Color(0xFFF2F2F2);
    final textColor = isSelected ? Colors.white : Colors.black;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isDisabled
    ? null
    : () {
        if (widget.embedded && widget.onChangeTab != null) {
          // Встроенный режим — переключаем вкладку родителя
          widget.onChangeTab!(index);
        } else {
          // Отдельный экран — отдадим наверх желаемую вкладку
          Navigator.of(context).pop({'switchToTab': index});
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '$label ($count)',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectField(String hint) {
    return InkWell(
      onTap: () async {
        final bool isReasonField = hint == 'Причина высадки';

        final List<String> items = isReasonField
            ? [
                'Нарушение общественного порядка',
                'Агрессивное поведение',
                'Распитие спиртных напитков',
                'Заболел пассажир',
                'Курение в поезде',
                'Повреждение имущества поезда',
                'Отсутствие билета',
                'Другое',
              ]
            : [
                'Астана',
                'Сары-Шаган',
                'Берлик 2',
                'Чемолган',
                'Бурундай',
                'Алматы-1',
                'Алматы-2',
              ];

        // локальные переменные для состояния модалки
        int? tempSelectedIndex = isReasonField ? _selectedReason : _selectedStationIndex;
        if (!isReasonField) {
          // очищаем контроллер, если это станция
          _otherReasonController.text = '';
        } else if (tempSelectedIndex != null && items[tempSelectedIndex] == 'Другое') {
          // подставим сохранённый текст, если уже введён
          _otherReasonController.text = _otherReasonText ?? '';
        } else {
          _otherReasonController.text = '';
        }

        final result = await showModalBottomSheet<Map<String, dynamic>>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (context) {
            return SafeArea(
              top: false,
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 12,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                  ),
                  child: StatefulBuilder(
                    builder: (context, setBottom) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // handle + header
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  hint,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(Icons.close),
                                splashRadius: 20,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // options
                          ...List.generate(items.length, (index) {
                            final bool selected = tempSelectedIndex == index;
                            return InkWell(
                              onTap: () {
                                setBottom(() {
                                  tempSelectedIndex = index;
                                  if (isReasonField && items[index] != 'Другое') {
                                    _otherReasonController.text = '';
                                  }
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 14.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        items[index],
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: selected
                                              ? const Color(0xFF0A84FF)
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                    Radio<int>(
                                      value: index,
                                      groupValue: tempSelectedIndex,
                                      onChanged: (v) {
                                        setBottom(() {
                                          tempSelectedIndex = v;
                                          if (isReasonField && items[v!] != 'Другое') {
                                            _otherReasonController.text = '';
                                          }
                                        });
                                      },
                                      activeColor: const Color(0xFF0A84FF),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),

                          // extra text for «Другое»
                          if (isReasonField && tempSelectedIndex != null && items[tempSelectedIndex!] == 'Другое') ...[
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2F4F5),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              height: 36,
                              alignment: Alignment.centerLeft,
                              child: TextField(
                                controller: _otherReasonController,
                                maxLines: 1,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Ваш текст',
                                  hintStyle: TextStyle(color: Colors.black45),
                                ),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],

                          const SizedBox(height: 16),
                          // Big blue capsule button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop({
                                  'index': tempSelectedIndex,
                                  'otherText': isReasonField && tempSelectedIndex != null && items[tempSelectedIndex!] == 'Другое'
                                      ? _otherReasonController.text.trim()
                                      : null,
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0A66FF),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                              child: const Text('Выбрать', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );

        if (result != null) {
          final int? idx = result['index'] as int?;
          final String? other = (result['otherText'] as String?)?.trim();
          setState(() {
            if (isReasonField) {
              _selectedReason = idx;
              _otherReasonText = (idx != null && idx >= 0 && idx < items.length && items[idx] == 'Другое' && (other?.isNotEmpty ?? false))
                  ? other
                  : null;
            } else {
              _selectedStationIndex = idx;
            }
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(20),
        ),
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // отображаем выбранное значение, «Другое» — с текстом пользователя
            Text(
              () {
                if (hint == 'Причина высадки') {
                  if (_selectedReason != null) {
                    const reasons = [
                      'Нарушение общественного порядка',
                      'Агрессивное поведение',
                      'Распитие спиртных напитков',
                      'Заболел пассажир',
                      'Курение в поезде',
                      'Повреждение имущества поезда',
                      'Отсутствие билета',
                      'Другое',
                    ];
                    final idx = _selectedReason!;
                    if (idx >= 0 && idx < reasons.length) {
                      final val = reasons[idx];
                      if (val == 'Другое' && (_otherReasonText?.isNotEmpty ?? false)) {
                        return _otherReasonText!;
                      }
                      return val;
                    }
                  }
                } else if (hint == 'Станция высадки') {
                  if (_selectedStationIndex != null) {
                    const stations = [
                      'Астана',
                      'Сары-Шаган',
                      'Берлик 2',
                      'Чемолган',
                      'Бурундай',
                      'Алматы-1',
                      'Алматы-2',
                    ];
                    final idx = _selectedStationIndex!;
                    if (idx >= 0 && idx < stations.length) {
                      return stations[idx];
                    }
                  }
                }
                return hint;
              }(),
              style: const TextStyle(color: Colors.black54, fontSize: 16),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black45),
          ],
        ),
      ),
    );
  }


  Widget _buildTextField() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const TextField(
        maxLines: null,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Ваш текст',
          hintStyle: TextStyle(color: Colors.black45),
        ),
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildFlatButton(BuildContext context, String text) {
    return ElevatedButton(
      onPressed: () {
        if (widget.embedded) {
          // В embedded-режиме ничего не закрываем: просто сбросим выбор
          setState(() {
            _selectedReason = null;
            _selectedStationIndex = null;
          });
        } else {
          Navigator.of(context).pop();
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF2F2F2),
        foregroundColor: Colors.black,
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(text),
    );
  }
  @override
  void dispose() {
    _otherReasonController.dispose();
    super.dispose();
  }  }