import 'package:flutter/material.dart';
import 'package:passflow_app/pages/styles/app_text_styles.dart';
import 'package:hive/hive.dart';
import 'package:passflow_app/data/models/user_model.dart';

class CustomAppBarText extends StatelessWidget {
  const CustomAppBarText({super.key});

  @override
  Widget build(BuildContext context) {
    final userName = Hive.box<UserModel>('userBox').get('currentUser')?.name ?? '';

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            'Здравствуйте, $userName!',
            style: AppTextStyles.greeting,
            overflow: TextOverflow.visible,
            softWrap: true,
          ),
        ),
      ],
    );
  }
}
