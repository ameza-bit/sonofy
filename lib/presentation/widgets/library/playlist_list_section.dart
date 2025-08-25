import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonofy/core/extensions/color_extensions.dart';
import 'package:sonofy/presentation/blocs/playlists/playlists_cubit.dart';
import 'package:sonofy/presentation/blocs/playlists/playlists_state.dart';
import 'package:sonofy/presentation/widgets/library/playlist_card.dart';
import 'package:sonofy/presentation/widgets/library/section_title.dart';

class PlaylistListSection extends StatelessWidget {
  const PlaylistListSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaylistsCubit, PlaylistsState>(
      builder: (context, playlistsState) {
        if (!playlistsState.hasPlaylists) {
          return const SizedBox();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionTitle(
              title: context.tr('library.playlists'),
              subtitle: context.tr(
                'playlist.playlists_count',
                namedArgs: {'count': '${playlistsState.playlistCount}'},
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: playlistsState.displayedPlaylists
                      .map((playlist) => PlaylistCard(playlist: playlist))
                      .toList(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Divider(thickness: 1.0, color: context.musicLightGrey),
            ),
          ],
        );
      },
    );
  }
}
