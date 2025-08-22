import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sonofy/presentation/views/modal_view.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';
import 'package:sonofy/presentation/widgets/common/section_item.dart';
import 'package:sonofy/presentation/widgets/common/section_card.dart';
import 'package:sonofy/data/models/playlist.dart';
import 'package:sonofy/presentation/blocs/songs/songs_cubit.dart';

class PlaylistInfoOption extends StatelessWidget {
  final Playlist playlist;
  
  const PlaylistInfoOption({required this.playlist, super.key});

  void _showPlaylistInfo(BuildContext context) {
    final songsCubit = context.read<SongsCubit>();
    final songs = songsCubit.getSongsByIds(playlist.songIds);
    final totalDuration = songs.fold<int>(0, (sum, song) => sum + (song.duration ?? 0));
    final hours = totalDuration ~/ 3600000;
    final minutes = (totalDuration % 3600000) ~/ 60000;
    
    String durationText;
    if (hours > 0) {
      durationText = '${hours}h ${minutes}m';
    } else {
      durationText = '${minutes}m';
    }

    modalView(
      context,
      title: context.tr('options.playlist_info'),
      maxHeight: 0.50,
      children: [
        SectionCard(
          title: '',
          children: [
            ListTile(
              leading: const Icon(FontAwesomeIcons.lightMusic),
              title: Text(context.tr('playlist.name')),
              subtitle: Text(playlist.title),
            ),
            ListTile(
              leading: const Icon(FontAwesomeIcons.lightListMusic),
              title: Text(context.tr('playlist.songs_count')),
              subtitle: Text('${playlist.songCount} ${context.tr('playlist.songs')}'),
            ),
            ListTile(
              leading: const Icon(FontAwesomeIcons.lightClock),
              title: Text(context.tr('playlist.duration')),
              subtitle: Text(durationText),
            ),
            ListTile(
              leading: const Icon(FontAwesomeIcons.lightCalendar),
              title: Text(context.tr('playlist.created')),
              subtitle: Text(playlist.createdAt.toString().split(' ')[0]),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SectionItem(
      icon: FontAwesomeIcons.lightCircleInfo,
      title: context.tr('options.playlist_info'),
      onTap: () {
        context.pop();
        _showPlaylistInfo(context);
      },
    );
  }
}