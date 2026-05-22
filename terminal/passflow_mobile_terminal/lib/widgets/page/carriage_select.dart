import 'package:flutter/material.dart';

Future<String?> showWagonSelectionModal(BuildContext context,
    {required List<String?> wagonNumbers}) {
  // final List<String> wagonNumbers = [
  //   '01П', '02П', '03П', '04П',
  //   '05К', '06К', '07К', '08К',
  //   '09К', '10К', '11К', '12К',
  //   '13О', '14О', '15О', '16О',
  //   '17С', '18С', '19С', '20С',
  // ];

  String? selectedWagon;

  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          // Create a cleaned & numerically sorted list of wagon numbers
          final List<String> _sortedWagons = wagonNumbers
              .whereType<String>()
              .toList()
            ..sort((a, b) {
              int extractNum(String s) {
                final m = RegExp(r'\d+').firstMatch(s);
                return m != null ? int.parse(m.group(0)!) : 1 << 30; // non-numeric last
              }
              final na = extractNum(a);
              final nb = extractNum(b);
              if (na != nb) return na.compareTo(nb);
              return a.compareTo(b); // tie-breaker
            });
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Выберите номер вагона',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 20),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  ],
                ),
                const SizedBox(height: 24),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _sortedWagons.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.7,
                  ),
                  itemBuilder: (context, index) {
                    final wagon = _sortedWagons[index];
                    final isSelected = selectedWagon == wagon;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedWagon = wagon;
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF0864D4)
                              : const Color(0xFFF1F2F4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          wagon ?? '',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: selectedWagon != null
                        ? () {
                            Navigator.of(context).pop(selectedWagon);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0864D4),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const Text(
                      'Сохранить и продолжить',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      );
    },
  );
}
