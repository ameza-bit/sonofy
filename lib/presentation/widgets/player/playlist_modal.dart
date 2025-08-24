import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:sonofy/core/constants/app_constants.dart';
import 'package:sonofy/presentation/blocs/player/player_cubit.dart';
import 'package:sonofy/presentation/blocs/player/player_state.dart';
import 'package:sonofy/presentation/views/modal_view.dart';
import 'package:sonofy/presentation/widgets/library/song_card.dart';
import 'package:sonofy/presentation/widgets/options/options_modal.dart';

/// Modal que muestra la cola de reproducción actual.
/// 
/// Funcionalidades:
/// - Muestra canciones según modo de repetición y estado de shuffle
/// - Auto-scroll a canción actual cuando cambie
/// - Preserva lista shuffle al seleccionar canciones
/// - Orden adaptativo según RepeatMode
class PlaylistModal extends StatefulWidget {
  const PlaylistModal({super.key});

  /// Muestra el modal de playlist.
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
  State<PlaylistModal> createState() => _PlaylistModalState();
}

class _PlaylistModalState extends State<PlaylistModal> {
  final ScrollController _scrollController = ScrollController();
  int _lastCurrentIndex = -1;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentSong(int currentIndex, int itemCount) {
    if (_scrollController.hasClients && currentIndex != _lastCurrentIndex) {
      _lastCurrentIndex = currentIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        const targetIndex = 0; // La canción actual siempre está en índice 0
        _scrollController.animateTo(
          targetIndex * 80.0, // Altura estimada de cada item
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  /// Obtiene las canciones a mostrar según el modo de repetición.
  /// 
  /// Lógica por RepeatMode:
  /// - RepeatMode.one: Solo la canción actual
  /// - RepeatMode.none: Desde canción actual hasta el final
  /// - RepeatMode.all: Toda la playlist con canción actual al inicio
  List<SongModel> _getDisplayedSongs(PlayerState state) {
    final activePlaylist = state.activePlaylist;
    if (activePlaylist.isEmpty) return [];

    switch (state.repeatMode) {
      case RepeatMode.one:
        // Solo mostrar la canción actual
        return [activePlaylist[state.currentIndex]];

      case RepeatMode.none:
        // Mostrar desde la canción actual hasta el final
        return activePlaylist.sublist(state.currentIndex);

      case RepeatMode.all:
        // Mostrar toda la playlist reordenada con canción actual al inicio
        final reorderedPlaylist = <SongModel>[];
        for (int i = 0; i < activePlaylist.length; i++) {
          final songIndex = (i + state.currentIndex) % activePlaylist.length;
          reorderedPlaylist.add(activePlaylist[songIndex]);
        }
        return reorderedPlaylist;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocBuilder<PlayerCubit, PlayerState>(
        builder: (context, state) {
          final displayedSongs = _getDisplayedSongs(state);
          _scrollToCurrentSong(state.currentIndex, displayedSongs.length);

          return ListView.builder(
            controller: _scrollController,
            itemCount: displayedSongs.length + 1,
            itemBuilder: (context, index) {
              if (index == displayedSongs.length) {
                return const SizedBox(height: AppSpacing.bottomSheetHeight);
              }

              final song = displayedSongs[index];

              return SongCard(
                playlist: state.playlist,
                shuffledPlaylist: state.shufflePlaylist,
                song: song,
                onTap: () => context.pop(),
                onLongPress: () => OptionsModal(context).songPlayerListContext(
                  song,
                  state.playlist,
                  state.shufflePlaylist,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
