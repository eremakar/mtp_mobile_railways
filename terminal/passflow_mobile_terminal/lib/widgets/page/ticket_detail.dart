import 'package:flutter/material.dart';
import 'package:passflow_app/pages/boardings_detail/ticket_pdf_native.dart';
import 'package:passflow_app/pages/boardings_list/widgets/passenger_action.dart';
import 'package:passflow_app/pages/boardings_list/widgets/passenger_row.dart';
import 'package:passflow_app/pages/boardings_list/with_loader.dart';
import 'package:passflow_app/widgets/page/boarding_select_breakdown.dart';
import 'package:passflow_app/widgets/page/ktz_ticket_pdf.dart'
    show printKtzTicketSunmiMock;
import 'package:passflow_app/widgets/page/refusal_signed_page.dart';
import 'package:passflow_app/widgets/page/disembark_signed_page.dart';
import 'package:passflow_app/widgets/page/sunmi_printer_service.dart';
import 'package:printing/printing.dart';

class TicketDetailScreen extends StatefulWidget {
  final PassengerAction? passengerAction;
  final PassengerRow passengerRow;

  /// Вызывается при смене статуса на экране.
  final ValueChanged<PassengerAction>? onStatusChanged;

  /// Если true (по умолчанию) — экран закроется и вернёт новый статус через Navigator.pop.
  final bool popOnStatusChange;

  const TicketDetailScreen({
    Key? key,
    required this.passengerAction,
    required this.passengerRow,
    this.onStatusChanged,
    this.popOnStatusChange = true,
  }) : super(key: key);

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  Future<void> _openPreview() async {
    try {
      final bytes = await withLoader(
        context,
        () => buildTicketPdfNative([widget.passengerRow]),
      );
      if (!mounted || bytes == null) return;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(
              title: const Text('Предпросмотр'),
              centerTitle: true,
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    children: [
                      // Left: Print to Sunmi (text-only)
                      FilledButton.icon(
                        onPressed: () async {
                          try {
                            await SunmiPrinterService.printTicket(
                                widget.passengerRow, context);
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Ошибка печати: $e')),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.print),
                        label: const Text('Печать'),
                      ),
                      const Spacer(),
                      // Right: Share PDF
                      FilledButton.icon(
                        onPressed: () async {
                          try {
                            await Printing.sharePdf(
                              bytes: bytes,
                              filename: 'ticket_detail.pdf',
                            );
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Не удалось поделиться: $e')),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.share),
                        label: const Text('Поделиться'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: PdfPreview(
                    build: (format) async => bytes,
                    canChangeOrientation: false,
                    canChangePageFormat: false,
                    allowPrinting: false,
                    allowSharing: false,
                    actions: const [],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось подготовить PDF: $e')),
      );
    }
  }

  void _safePop<T extends Object?>([T? result]) {
    final nav = Navigator.of(context);
    if (nav.canPop()) {
      nav.pop<T>(result);
    } else {
      // no-op
    }
  }

  late PassengerAction? _action;

  // Отображаемые данные
  late String _passengerName;
  late String _ticketNumber;
  late String _seat;
  late String _documentNumber;
  late String _departureStation;
  late String _arrivalStation;
  late String _departureDateTime;
  late String _arrivalDateTime;

  // Вкладки и статусы
  late int _selectedTabIndex;
  late String _statusText;

  // Счётчики
  int _ticketsCount = 1;
  int _refusedCount = 0;
  int _disembarkedCount = 0;

  // Отказ — выбранная причина
  String _selectedReason = 'Причина отказа';

  @override
  void initState() {
    super.initState();

    _action = widget.passengerAction;

    final row = widget.passengerRow;

    _passengerName = row.fullName;
    _ticketNumber = '${row.ticketNumber}';
    _seat = '${row.seat}';
    _documentNumber = '${row.doc}';
    _departureStation = row.ticket.deparute?.name ?? '—';
    _arrivalStation = (row.station.isEmpty) ? '—' : row.station;
    _departureDateTime = _fmtDate(row.ticket.departure);
    _arrivalDateTime = ''; // если появится — подставь

    _applyAction(_action);
  }

  String _fmtDate(dynamic v) {
    if (v == null) return '—';
    if (v is DateTime) return v.toLocal().toString();
    return v.toString();
  }

  void _applyAction(PassengerAction? action) {
    _action = action;
    _ticketsCount = 1;
    switch (action) {
      case PassengerAction.boarding:
        _statusText = 'Посажен';
        _selectedTabIndex = 0;
        _refusedCount = 0;
        _disembarkedCount = 0;
        break;
      case PassengerAction.refuse:
        _statusText = 'Отказ';
        _selectedTabIndex = 1;
        _refusedCount = 1;
        _disembarkedCount = 0;
        break;
      case PassengerAction.disembark:
        _statusText = 'Высажен';
        _selectedTabIndex = 2;
        _refusedCount = 0;
        _disembarkedCount = 1;
        break;
      default:
        _statusText = 'Неизвестный статус';
        _selectedTabIndex = 0;
        _refusedCount = 0;
        _disembarkedCount = 0;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_passengerName),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => _safePop<void>(),
        ),
        actions: this._action == PassengerAction.boarding
            ? [
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.black),
                  tooltip: 'Предпросмотр',
                  onPressed: _openPreview,
                ),
              ]
            : null,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTab('Талон', _ticketsCount, index: 0),
                _buildTab('Отказ', _refusedCount, index: 1),
                _buildTab('Высадка', _disembarkedCount, index: 2),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(child: _buildTabContent()),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int count, {required int index}) {
    final bool isDisabled = count == 0 && index != 0; // "Талон" активна всегда
    final bool selected = _selectedTabIndex == index;

    return GestureDetector(
      onTap: isDisabled
          ? null
          : () {
              setState(() {
                _selectedTabIndex = index;
              });
            },
      child: Opacity(
        opacity: isDisabled ? 0.6 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF0864D4) : const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$label ($count)',
                style: TextStyle(
                  color: selected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildTicketInfo();
      case 1:
        return _buildRefusalContent();
      case 2:
        return DisembarkSignedPage(
          passengerName: _passengerName,
          ticketsCount: _ticketsCount,
          refusedCount: _refusedCount,
          disembarkedCount: _disembarkedCount,
          embedded: true,
          onChangeTab: (i) => setState(() => _selectedTabIndex = i),
          signerName: _passengerName,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTicketInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(Icons.person_outline, _statusText, 'Статус'),
          _buildInfoRow(Icons.confirmation_number_outlined,
              '$_ticketNumber / $_seat', '№ билета / место'),
          _buildInfoRow(Icons.badge_outlined, _passengerName, 'ФИО'),
          _buildInfoRow(
              Icons.credit_card_outlined, _documentNumber, '№ документа'),
          _buildInfoRow(Icons.train, _departureStation, 'Станция отправления'),
          _buildInfoRow(Icons.bed_outlined, 'Нет', 'Постельное'),
          _buildInfoRow(
              Icons.calendar_today, _departureDateTime, 'Дата отправления'),
          _buildInfoRow(Icons.train_outlined, _arrivalStation, 'Прибытие'),
          _buildInfoRow(
              Icons.calendar_today_outlined, _arrivalDateTime, 'Дата прибытия'),
          const SizedBox(height: 24),

          // Изменить статус
          ElevatedButton(
            onPressed: () async {
              final action = await showModalBottomSheet<PassengerAction>(
                context: context,
                useRootNavigator: true,
                isScrollControlled: true,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (_) => PassengerActionPage(title: _passengerName),
              );

              if (action == null) return;

              setState(() {
                _applyAction(action);
              });

              widget.onStatusChanged?.call(action);

              if (widget.popOnStatusChange) {
                _safePop<PassengerAction>(action);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007AFF),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text('Изменить статус'),
          ),
          const SizedBox(height: 12),

          // Печать талона
          if (this._action == PassengerAction.boarding)
            ElevatedButton(
              onPressed: () async {
                await SunmiPrinterService.printTicket(
                    widget.passengerRow, context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF2F2F2),
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Печатать талон'),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFF2F2F2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF0864D4)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style:
                        const TextStyle(fontSize: 13, color: Colors.black54)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRefusalContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          const Text(
            'Выберите причину отказа и опишите ситуацию при наличии',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Причина
          GestureDetector(
            onTap: _showRefusalReasonsModal,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_selectedReason,
                      style:
                          const TextStyle(color: Colors.black54, fontSize: 16)),
                  const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.black54),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Комментарий
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 70,
            alignment: Alignment.topLeft,
            child: const TextField(
              maxLines: null,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Ваш текст',
                hintStyle: TextStyle(color: Colors.black45),
              ),
              style: TextStyle(fontSize: 16),
            ),
          ),
          const Spacer(),

          // Подписать отказ
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedTabIndex = 1;
                _applyAction(PassengerAction.refuse);
              });
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RefusalSignedPage(
                    passengerName: _passengerName,
                    signerName: _passengerName,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0864D4),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text('Подписать акт отказа'),
          ),
          const SizedBox(height: 12),

          // Отмена
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF2F2F2),
              foregroundColor: Colors.black,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text('Отменить'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showRefusalReasonsModal() {
    final reasons = [
      'Заболел пассажир',
      'Семейные обстоятельства',
      'Изменились планы / смена маршрута',
      'Пропущен поезд',
      'Задержка на работе / учёбе',
      'Утеря документов',
      'Ошибка при покупке билета',
      'Другое',
    ];

    String tempSelectedReason = _selectedReason;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateBottom) {
            return SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Expanded(
                          child: Text('Причина отказа',
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.w800)),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                          splashRadius: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...reasons.map((reason) {
                      final bool selected = tempSelectedReason == reason;
                      return InkWell(
                        onTap: () =>
                            setStateBottom(() => tempSelectedReason = reason),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  reason,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: selected
                                        ? const Color(0xFF007AFF)
                                        : Colors.black,
                                  ),
                                ),
                              ),
                              Radio<String>(
                                value: reason,
                                groupValue: tempSelectedReason,
                                onChanged: (value) {
                                  if (value != null) {
                                    setStateBottom(
                                        () => tempSelectedReason = value);
                                  }
                                },
                                activeColor: const Color(0xFF0A84FF),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 230, 230, 230),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      height: 56,
                      alignment: Alignment.centerLeft,
                      child: const TextField(
                        maxLines: 1,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Ваш текст',
                          hintStyle: TextStyle(color: Colors.black45),
                        ),
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedReason = tempSelectedReason;
                        });
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0864D4),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text('Выбрать'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
