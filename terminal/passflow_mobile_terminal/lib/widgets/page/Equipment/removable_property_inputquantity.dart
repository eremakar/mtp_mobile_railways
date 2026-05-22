import 'package:flutter/material.dart';

class RemovableAssetsPage extends StatefulWidget {
  const RemovableAssetsPage({Key? key}) : super(key: key);

  @override
  State<RemovableAssetsPage> createState() => _RemovableAssetsPageState();
}

class _RemovableAssetsPageState extends State<RemovableAssetsPage> {
  final List<String> assets = [
    'Коврик диэлектрический',
    'Папка билетная',
    'Термометр',
    'Выберите имущество',
  ];

  final List<int> quantities = [2, 1, 1, 0];
  final List<String?> selectedAssets = [
    'Коврик диэлектрический',
    'Папка билетная',
    'Термометр',
    null,
  ];

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF1671E6);
    const greyBg = Color(0xFFF2F4F6);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Съемное имущество', style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Выберите наименование имущества и укажите количество',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: selectedAssets.length,
                itemBuilder: (context, i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: greyBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedAssets[i],
                                hint: Text('${i + 1}. Выберите имущество'),
                                items: assets.map((e) {
                                  return DropdownMenuItem(
                                    value: e,
                                    child: Text('${i + 1}. $e', overflow: TextOverflow.ellipsis),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    selectedAssets[i] = val;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: greyBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: quantities[i] > 0
                                    ? () => setState(() => quantities[i]--)
                                    : null,
                              ),
                              Text('${quantities[i]}'),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () => setState(() => quantities[i]++),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 56,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  onPressed: () {
                    Navigator.pop(context, {
                      for (int i = 0; i < selectedAssets.length; i++)
                        selectedAssets[i] ?? 'Не выбрано': quantities[i],
                    });
                  },
                  child: const Text('Сохранить', style: TextStyle(fontSize: 18)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}