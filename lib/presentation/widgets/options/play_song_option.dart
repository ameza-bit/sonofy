import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:sonofy/presentation/blocs/player/player_cubit.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';
import 'package:sonofy/presentation/widgets/common/section_item.dart';

class PlaySongOption extends StatelessWidget {
  const PlaySongOption({
    required this.song,
    required this.playlist,
    super.key,
  });

  final SongModel song;
  final List<SongModel> playlist;

  @override
  Widget build(BuildContext context) {
    return SectionItem(
      icon: FontAwesomeIcons.solidPlay,
      title: context.tr('options.play_song'),
      onTap: () {
        context.pop();
        context.read<PlayerCubit>().setPlayingSong(playlist, song);
      },
    );
  }
}