import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sonofy/core/extensions/responsive_extensions.dart';
import 'package:sonofy/presentation/views/settings/appearance_section.dart';
import 'package:sonofy/presentation/views/settings/language_section.dart';
import 'package:sonofy/presentation/views/settings/security_section.dart';

class SettingsScreen extends StatelessWidget {
  static const String routeName = 'settings';
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('settings.title'))),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(context.contentPadding),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 20,
              children: [
                AppearanceSection(),
                LanguageSection(),
                SecuritySection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
