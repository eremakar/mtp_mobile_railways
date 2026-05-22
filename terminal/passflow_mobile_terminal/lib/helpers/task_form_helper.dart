import 'package:hive/hive.dart';
import 'package:passflow_app/data/models/user_model.dart';

class TaskFormHelper {
  static Future<String> replacePlaceholders(String input) async {
    final box = Hive.box<UserModel>('userBox');
    final user = box.get('currentUser');

     if (user == null) return input;

    // Предполагаем, что name = "Имя Фамилия" (например, "Айгуль Жумирова")
    final nameParts = user.name.trim().split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
    final lastNameFirstLetter =
        (nameParts.length > 1 && nameParts[1].isNotEmpty) ? nameParts[1][0] : '';

    return input
        .replaceAll('{cur_firstName}', firstName)
        .replaceAll('{cur_lastName.firstLetter}', lastNameFirstLetter);
  }
}
