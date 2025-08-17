import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sonofy/core/constants/app_constants.dart';
import 'package:sonofy/presentation/blocs/player/player_cubit.dart';
import 'package:sonofy/presentation/blocs/player/player_state.dart';
import 'package:sonofy/presentation/views/modal_view.dart';
import 'package:sonofy/presentation/widgets/library/song_card.dart';

class PlaylistModal extends StatelessWidget {
  const PlaylistModal({super.key});

  static void show(BuildContext context) {
    modalView(
      context,
      title: context.tr('player.playlist'),
      maxHeight: 0.85,
      showPlayer: true,
      children: [const PlaylistModal()],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocBuilder<PlayerCubit, PlayerState>(
        builder: (context, state) => ListView.builder(
          itemCount: state.playlist.length + 1,
          itemBuilder: (context, index) {
            if (index == state.playlist.length) {
              return const SizedBox(height: AppSpacing.bottomSheetHeight);
            }

            return SongCard(
              playlist: state.playlist,
              song:
                  state.playlist[(index + state.currentIndex) %
                      state.playlist.length],
              onTap: () => context.pop(),
            );
          },
        ),
      ),
    );
  }
}
