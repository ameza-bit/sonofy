import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sonofy/core/extensions/color_extensions.dart';
import 'package:sonofy/core/extensions/theme_extensions.dart';
import 'package:sonofy/data/models/playlist.dart';
import 'package:sonofy/presentation/blocs/songs/songs_cubit.dart';
import 'package:sonofy/presentation/blocs/songs/songs_state.dart';
import 'package:sonofy/presentation/screens/playlist_screen.dart';
import 'package:sonofy/presentation/widgets/library/playlist_cover_grid.dart';
import 'package:sonofy/presentation/widgets/options/options_modal.dart';

class PlaylistCard extends StatelessWidget {
  final Playlist playlist;

  const PlaylistCard({required this.playlist, super.key});

  double get cardWidth => 150.0;

  @override
  Widget build(BuildContext context) {
    final songsCubit = context.read<SongsCubit>();

    return InkWell(
      onTap: () => context.goNamed(
        PlaylistScreen.routeName,
        pathParameters: {'playlistId': playlist.id},
      ),
      onLongPress: () => OptionsModal(context).playlistCard(playlist),
      child: Card(
        elevation: 2.0,
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Column(
          children: [
            SizedBox(
              width: cardWidth,
              height: cardWidth,
              child: BlocBuilder<SongsCubit, SongsState>(
                builder: (context, songsState) {
                  final songs = songsCubit.getSongsByIds(playlist.songIds);

                  return PlaylistCoverGrid(
                    songs,
                    width: cardWidth,
                    height: cardWidth,
                  );
                },
              ),
            ),
            const SizedBox(height: 8.0),
            SizedBox(
              width: cardWidth,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8.0,
                  children: [
                    Text(
                      playlist.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: context.scaleText(16),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      context.tr(
                        'playlist.songs_count',
                        namedArgs: {'count': '${playlist.songCount}'},
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: context.scaleText(12),
                        color: context.musicLightGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
