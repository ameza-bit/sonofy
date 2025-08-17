import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sonofy/core/utils/toast.dart';
import 'package:sonofy/presentation/blocs/player/player_cubit.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';
import 'package:sonofy/presentation/widgets/common/section_item.dart';

class ShareOption extends StatelessWidget {
  const ShareOption({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionItem(
      icon: FontAwesomeIcons.lightShareNodes,
      title: context.tr('options.share'),
      onTap: () {
        context.pop();
        _shareCurrentSong(context);
      },
    );
  }

  void _shareCurrentSong(BuildContext context) {
    final playerState = context.read<PlayerCubit>().state;
    if (!playerState.hasSelectedSong) {
      Toast.show(context.tr('player.no_song_selected'));
      return;
    }

    final currentSong = playerState.currentSong!;
    final shareText = context.tr('player.share_text', namedArgs: {
      'title': currentSong.title,
      'artist': currentSong.artist ?? context.tr('common.unknown_artist'),
      'album': currentSong.album ?? context.tr('common.unknown_album'),
    });

    // Copy to clipboard as a simple share implementation
    Clipboard.setData(ClipboardData(text: shareText));
    Toast.show(context.tr('player.song_copied_to_clipboard'));
  }
}
