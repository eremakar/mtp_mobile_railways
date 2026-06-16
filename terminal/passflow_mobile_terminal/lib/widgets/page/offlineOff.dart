import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:passflow_app/widgets/page/main_scaffold/main_scaffold.dart';
import 'package:passflow_app/data/models/boarding_model.dart';
import 'package:passflow_app/utils/network_utils.dart';

class OfflineScreen extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback onRetry;

  const OfflineScreen({
    Key? key,
    required this.onContinue,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.language),
                onPressed: () {
                  // TODO: implement language change
                },
              ),
            ),
            Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 90,
                      backgroundColor: const Color(0xFFF2F4F7),
                      child: SvgPicture.asset(
                        'assets/svg_icons/internetoff.svg',
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Офлайн режим',
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Вы можете нажать «Продолжить»,\nчтобы выбрать рейс и вагон вручную,\nили обновить страницу, если уверены,\nчто подключение есть.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 160),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          backgroundColor:
                              const Color.fromARGB(255, 40, 103, 172),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        onPressed: () async {
                          await NetworkUtils.setForceOffline(true);
                          final offlineModel = TicketsSearchModel(
                              departure: DateTime.now().toIso8601String(),
                              train: 'offline',
                              departureDate: DateTime.now().toIso8601String());
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MainScaffold(
                                isOnline: false,
                                initialIndex: 0,
                                offlineTickets: offlineModel,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'Продолжить',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          backgroundColor: Color(0xFFF2F4F7),
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        onPressed: onRetry,
                        child: const Text(
                          'Обновить страницу',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
