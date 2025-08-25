import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sonofy/presentation/blocs/player/player_cubit.dart';
import 'package:sonofy/presentation/blocs/songs/songs_cubit.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';
import 'package:sonofy/presentation/widgets/common/section_item.dart';
import 'package:sonofy/data/models/playlist.dart';

class PlayPlaylistOption extends StatelessWidget {
  final Playlist playlist;

  const PlayPlaylistOption({required this.playlist, super.key});

  @override
  Widget build(BuildContext context) {
    return SectionItem(
      icon: FontAwesomeIcons.lightPlay,
      title: context.tr('options.play_playlist'),
      onTap: () {
        context.pop();
        final songsCubit = context.read<SongsCubit>();
        final songs = songsCubit.getSongsByIds(playlist.songIds);

        if (songs.isNotEmpty) {
          context.read<PlayerCubit>().setPlayingSong(songs, songs.first, null);
        }
      },
    );
  }
}
