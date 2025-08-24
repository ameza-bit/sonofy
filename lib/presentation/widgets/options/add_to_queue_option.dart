import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:sonofy/core/utils/toast.dart';
import 'package:sonofy/presentation/blocs/player/player_cubit.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';
import 'package:sonofy/presentation/widgets/common/section_item.dart';

class AddToQueueOption extends StatelessWidget {
  const AddToQueueOption({
    required this.song,
    super.key,
  });

  final SongModel song;

  @override
  Widget build(BuildContext context) {
    return SectionItem(
      icon: FontAwesomeIcons.lightListCheck,
      title: context.tr('options.add_to_queue'),
      onTap: () {
        context.pop();
        context.read<PlayerCubit>().addToQueue(song);
        Toast.show(context.tr('options.song_added_to_queue'));
      },
    );
  }
}