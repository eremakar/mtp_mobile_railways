import 'package:flutter/material.dart';

class SelectAssetsPage extends StatefulWidget {
  const SelectAssetsPage({Key? key, 
    
    this.items = const [
      'Коврик диэлектрический',
      'Папка билетная',
      'Термометр',
      'Таз д/посуды',
      'Скребок',
      'Киянка',
      'Аптека',
      'Аварийная аптечка',
      'Инвалидная коляска',
      'Носилки медицинские',
      'Ложка',
    ],
    this.initialSelected = const ['Коврик диэлектрический','Папка билетная','Термометр'],
    this.title = 'Выберите имущество',
  }) : super(key: key);

  final List<String> items;
  final List<String> initialSelected;
  final String title;

  /// Использование:
  /// final selected = await Navigator.push<List<String>>(
  ///   context, MaterialPageRoute(builder: (_) => const SelectAssetsPage()),
  /// );
  @override
  State<SelectAssetsPage> createState() => _SelectAssetsPageState();
}

class _SelectAssetsPageState extends State<SelectAssetsPage> {
  late final Set<String> _selected = widget.initialSelected.toSet();

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF1671E6);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                itemCount: widget.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (context, i) {
                  final label = widget.items[i];
                  final checked = _selected.contains(label);
                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => setState(() {
                      checked ? _selected.remove(label) : _selected.add(label);
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: checked ? blue : Colors.black,
                              ),
                            ),
                          ),
                          IgnorePointer(
                            child: Checkbox(
                              value: checked,
                              onChanged: (_) {},
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              side: const BorderSide(color: Color(0xFFCFD4DA), width: 2),
                              activeColor: blue,
                              checkColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selected.isEmpty
                        ? null
                        : () => Navigator.pop(context, _selected.toList()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blue,
                      disabledBackgroundColor: const Color(0xFFE2E5E7),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                    child: Text(
                      'Добавить',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _selected.isEmpty ? Colors.grey[600] : Colors.white,
                      ),
                    ),
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