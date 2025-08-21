import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sonofy/core/extensions/color_extensions.dart';
import 'package:sonofy/core/extensions/theme_extensions.dart';
import 'package:sonofy/data/models/playlist.dart';
import 'package:sonofy/presentation/blocs/playlists/playlists_cubit.dart';
import 'package:sonofy/presentation/blocs/songs/songs_cubit.dart';
import 'package:sonofy/presentation/screens/playlist_screen.dart';
import 'package:sonofy/presentation/widgets/library/playlist_cover_grid.dart';

class PlaylistCard extends StatelessWidget {
  final Playlist playlist;

  const PlaylistCard({required this.playlist, super.key});

  double get cardWidth => 150.0;

  @override
  Widget build(BuildContext context) {
    final songsCubit = context.read<SongsCubit>();
    final songs = songsCubit.getSongsByIds(playlist.songIds);

    return InkWell(
      onTap: () {
        context.read<PlaylistsCubit>().selectPlaylist(playlist.id);
        context.goNamed(PlaylistScreen.routeName);
      },
      child: Card(
        elevation: 2.0,
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Column(
          children: [
            SizedBox(
              width: cardWidth,
              height: cardWidth,
              child: PlaylistCoverGrid(
                songs,
                width: cardWidth,
                height: cardWidth,
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
