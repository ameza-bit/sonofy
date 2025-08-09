import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:samva/presentation/screens/settings_screen.dart';
import 'package:samva/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';

class LoginScreen extends StatelessWidget {
  static const String routeName = 'login';
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Login Screen'),
          actions: [
            IconButton(
              icon: const Icon(FontAwesomeIcons.lightGear),
              onPressed: () {
                context.pushNamed(SettingsScreen.routeName);
              },
            ),
          ],
        ),
        body: Center(
          child: Text(
            'Welcome to the ${context.tr("app.title")} Login Screen!',
          ),
        ),
      ),
    );
  }
}
