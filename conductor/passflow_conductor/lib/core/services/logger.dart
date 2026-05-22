import 'package:logger/logger.dart';

// Использование именованного конструктора с PrettyPrinter
final logger = Logger(printer: PrettyPrinter());

void main() {
  logger.i("This is an info log");
  logger.d("This is a debug log");
  logger.e("This is an error log");
}
