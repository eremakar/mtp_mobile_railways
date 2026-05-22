import 'package:flutter/material.dart';
import 'package:passflow_app/helpers/parse_helper.dart';
import 'package:passflow_app/pages/boardings_list/widgets/passenger_action.dart';

class PassengerActionPage extends StatefulWidget {
  final String title; // ФИО
  final Map<String, dynamic>? passenger;
  final PassengerAction initial;
  final VoidCallback? onCancel;
  final ValueChanged<PassengerAction>? onSave;

  const PassengerActionPage({
    Key? key,
    required this.title,
    this.passenger,
    this.initial = PassengerAction.boarding,
    this.onCancel,
    this.onSave,
  }) : super(key: key);

  @override
  State<PassengerActionPage> createState() => _PassengerActionPageState();
}

class _PassengerActionPageState extends State<PassengerActionPage> {
  late PassengerAction _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
  }

  Widget build(BuildContext context) {
    const blue = Color(0xFF0A5ED7);
    const lightGray = Color(0xFFF2F4F7);
    const divider = Color(0xFFE6E8EB);

    return FractionallySizedBox(
      heightFactor: 0.5, // ровно половина экрана
      child: SafeArea(
        top: true,
        bottom: false, // низ обрабатываем отдельно через SafeArea ниже
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              const SizedBox(height: 4),
              // граббер
              Container(
                width: 56,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9DCE1),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 5),
              // заголовок + X
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ParseHelper.abbreviateFullName(widget.title),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      height: 1.1,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (widget.onCancel != null) {
                        widget.onCancel!();
                      } else {
                        Navigator.of(context).maybePop();
                      }
                    },
                    child: Icon(Icons.close, size: 24, color: Colors.black),
                  )
                ],
              ),
              const SizedBox(height: 10),

              // список опций должен занимать всё доступное пространство и скроллиться при нехватке высоты
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _OptionTile(
                      label: 'Посадка',
                      selected: _selected == PassengerAction.boarding,
                      onTap: () =>
                          setState(() => _selected = PassengerAction.boarding),
                    ),
                    // const Divider(height: 1, color: divider),
                    // _OptionTile(
                    //   label: 'Отказ',
                    //   selected: _selected == PassengerAction.refuse,
                    //   onTap: () =>
                    //       setState(() => _selected = PassengerAction.refuse),
                    // ),
                    const Divider(height: 1, color: divider),
                    _OptionTile(
                      label: 'Высадка',
                      selected: _selected == PassengerAction.disembark,
                      onTap: () =>
                          setState(() => _selected = PassengerAction.disembark),
                    ),
                  ],
                ),
              ),

              // блок кнопок внизу с учётом вырезов экрана
              SafeArea(
                top: false,
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          if (widget.onSave != null)
                            widget.onSave?.call(_selected);
                          else
                            Navigator.of(context).pop(_selected);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Отправить',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF0A5ED7);
    const ring = Color(0xFFCFD4DA);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            // текст слева
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.w300),
              ),
            ),
            // радиокнопка справа
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? blue : ring,
                  width: selected ? 2.5 : 2,
                ),
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: selected ? blue : Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
