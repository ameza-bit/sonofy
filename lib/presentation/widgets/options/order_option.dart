import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sonofy/core/utils/toast.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';
import 'package:sonofy/presentation/widgets/common/section_item.dart';

class OrderOption extends StatelessWidget {
  const OrderOption({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionItem(
      icon: FontAwesomeIcons.lightArrowDownShortWide,
      title: context.tr('options.order_by'),
      onTap: () {
        context.pop();
        // TODO(Armando): Implement song sorting options (by title, artist, album, date)
        Toast.show(context.tr('common.feature_coming_soon'));
      },
    );
  }
}
