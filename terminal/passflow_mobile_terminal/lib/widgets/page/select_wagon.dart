import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TrainRoute {
  final String name;
  TrainRoute(this.name);
}

class SelectWagon extends StatefulWidget {
  final List<TrainRoute> routes;
  const SelectWagon({Key? key, required this.routes}) : super(key: key);

  @override
  State<SelectWagon> createState() => _SelectWagonState();
}

class _SelectWagonState extends State<SelectWagon> {
  // final List<TrainRoute> routes = [
  //   TrainRoute('004Ц'),
  //   TrainRoute('010Ц'),
  //   TrainRoute('102Ц'),
  // ];

  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Маршруты',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context, null);
            }),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              // TODO: переключение языка
            },
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Выберите поезд',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: widget.routes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final route = widget.routes[index];
                  final isSelected = selectedIndex == index;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            isSelected ? const Color(0xFF0864D4) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF0864D4),
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(
                                      color: const Color(0xFF0864D4), width: 4)
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: SvgPicture.asset(
                              'assets/svg_icons/vagon.svg',
                              color: isSelected
                                  ? const Color(0xFF0864D4)
                                  : Colors.white,
                              width: 24,
                              height: 24,
                              fit: BoxFit.contain,
                              alignment: Alignment.center,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            route.name,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.chevron_right,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade400,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: selectedIndex != null
                    ? () {
                        final selectedRoute = widget.routes[selectedIndex!];
                        Navigator.pop(context, selectedRoute.name);
                        print('Selected route: ${selectedRoute.name}');
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0864D4),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                ),
                child: const Text(
                  'Продолжить',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
