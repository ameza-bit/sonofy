import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:sonofy/core/utils/toast.dart';
import 'package:sonofy/presentation/blocs/player/player_cubit.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';
import 'package:sonofy/presentation/widgets/common/section_item.dart';

class PlayNextOption extends StatelessWidget {
  const PlayNextOption({
    required this.song,
    super.key,
  });

  final SongModel song;

  @override
  Widget build(BuildContext context) {
    return SectionItem(
      icon: FontAwesomeIcons.lightForward,
      title: context.tr('options.play_next'),
      onTap: () {
        context.pop();
        final playerCubit = context.read<PlayerCubit>();
        if (!playerCubit.state.hasSelectedSong) {
          Toast.show(context.tr('player.no_song_selected'));
          return;
        }
        playerCubit.insertSongNext(song);
        Toast.show(context.tr('options.song_added_next'));
      },
    );
  }
}