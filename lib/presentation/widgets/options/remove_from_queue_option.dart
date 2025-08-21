import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:sonofy/core/utils/toast.dart';
import 'package:sonofy/presentation/blocs/player/player_cubit.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';
import 'package:sonofy/presentation/widgets/common/section_item.dart';

class RemoveFromQueueOption extends StatelessWidget {
  const RemoveFromQueueOption({
    required this.song,
    super.key,
  });

  final SongModel song;

  @override
  Widget build(BuildContext context) {
    return SectionItem(
      icon: FontAwesomeIcons.lightList,
      title: context.tr('options.remove_from_queue'),
      onTap: () {
        context.pop();
        final playerCubit = context.read<PlayerCubit>();
        if (!playerCubit.state.playlist.any((s) => s.id == song.id)) {
          Toast.show(context.tr('options.song_not_in_queue'));
          return;
        }
        playerCubit.removeFromQueue(song);
        Toast.show(context.tr('options.song_removed_from_queue'));
      },
    );
  }
}