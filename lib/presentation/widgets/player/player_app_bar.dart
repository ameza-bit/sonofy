import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sonofy/core/extensions/color_extensions.dart';
import 'package:sonofy/core/extensions/theme_extensions.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';

class PlayerAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PlayerAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: context.musicWhite,
      actionsPadding: const EdgeInsets.only(right: 12.0),
      leading: IconButton(
        icon: const Icon(FontAwesomeIcons.lightChevronLeft, size: 20.0),
        onPressed: () => context.pop(),
      ),
      title: Text(
        context.tr('player.now_playing'),
        style: TextStyle(
          fontSize: context.scaleText(16),
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(FontAwesomeIcons.lightHeart, size: 20.0),
          onPressed: () {
            // Show more options
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
