import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';
import 'package:sonofy/presentation/widgets/common/section_item.dart';

class SpeedOption extends StatelessWidget {
  const SpeedOption({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionItem(
      icon: FontAwesomeIcons.lightGauge,
      title: context.tr('options.player_speed'),
      onTap: () {
        context.pop();
        // TODO(Armando): Implement speed adjustment functionality
      },
    );
  }
}
