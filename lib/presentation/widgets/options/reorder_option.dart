import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sonofy/presentation/blocs/playlists/playlists_cubit.dart';
import 'package:sonofy/presentation/screens/reorder_playlist_screen.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';
import 'package:sonofy/presentation/widgets/common/section_item.dart';

class ReorderOption extends StatelessWidget {
  const ReorderOption({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionItem(
      icon: FontAwesomeIcons.lightArrowDownArrowUp,
      title: context.tr('options.reorder'),
      onTap: () {
        final playlistsCubit = context.read<PlaylistsCubit>();
        final selectedPlaylist = playlistsCubit.state.selectedPlaylist;
        
        if (selectedPlaylist != null && selectedPlaylist.isNotEmpty) {
          context.pop();
          context.pushNamed(
            ReorderPlaylistScreen.routeName,
            pathParameters: {'playlistId': selectedPlaylist.id},
          );
        }
      },
    );
  }
}
