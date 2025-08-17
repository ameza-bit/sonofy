import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';
import 'package:sonofy/presentation/widgets/common/section_item.dart';

class AddPlaylistOption extends StatelessWidget {
  const AddPlaylistOption({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionItem(
      icon: FontAwesomeIcons.lightAlbumCollectionCirclePlus,
      title: context.tr('player.options.add_playlist'),
      onTap: () {
        context.pop();
        // TODO(Armando): Implement add to playlist functionality
      },
    );
  }
}
