import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sonofy/presentation/screens/settings_screen.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';
import 'package:sonofy/presentation/widgets/common/section_item.dart';

class SettingsOption extends StatelessWidget {
  const SettingsOption({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionItem(
      icon: FontAwesomeIcons.lightGear,
      title: context.tr('options.settings'),
      onTap: () {
        context.pop();
        context.pushNamed(SettingsScreen.routeName);
      },
    );
  }
}
