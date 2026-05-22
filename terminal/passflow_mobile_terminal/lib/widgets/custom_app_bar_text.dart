import 'package:flutter/material.dart';
import 'package:passflow_app/auth/auth_provider.dart';
import 'package:passflow_app/styles/app_text_styles.dart';
import 'package:provider/provider.dart';

class CustomAppBarText extends StatelessWidget {
  const CustomAppBarText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userName = context.watch<UserProvider>().userName;

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
