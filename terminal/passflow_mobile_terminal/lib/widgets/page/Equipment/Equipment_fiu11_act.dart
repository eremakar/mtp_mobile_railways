import 'package:flutter/material.dart';

class AssetActPage extends StatelessWidget {
  const AssetActPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF1671E6);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text('Акт учета имущества',
            style: TextStyle(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Большой заголовок
                    const Text(
                      'Акт учета имущества',
                      style: TextStyle(
                        fontSize: 32,
                        height: 1.05,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '№ 0001123 от «01» июля 2025 г.',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.55),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 18),

                    const Text(
                      '1. Правила учёта имущества вагона',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Пункты (буллиты)
                    const _Bullet(
                      'Учёт имущества пассажирского вагона проводится в обязательном порядке. '
                      'Проверка проводится по утверждённой инвентарной ведомости.',
                    ),
                    const _Bullet(
                      'Каждая единица имущества проверяется на наличие, целостность и пригодность к использованию.',
                    ),
                    const _Bullet(
                      'Все выявленные несоответствия (недостача, повреждение, загрязнение, поломка) '
                      'фиксируются в акте учёта имущества, с обязательным указанием.',
                    ),
                    const _Bullet(
                      'В случае значительной недостачи или порчи имущества акт передаётся в бухгалтерию и '
                      'отдел безопасности для последующего рассмотрения.',
                    ),
                    const _Bullet(
                      'Ответственный проводник несёт материальную ответственность за сохранность имущества '
                      'в соответствии с действующим законодательством и внутренними регламентами.',
                    ),

                    const SizedBox(height: 90), // отступ под кнопку
                  ],
                ),
              ),
            ),

            // Нижняя кнопка
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    onPressed: () {
                      // TODO: подпись/подтверждение
                    },
                    child: const Text(
                      'Подписать акт',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700,color: Colors.white),
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

/// Виджет строки с буллитом
class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 7),
            child: _Dot(),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        color: Colors.black87,
        shape: BoxShape.circle,
      ),
    );
  }
}