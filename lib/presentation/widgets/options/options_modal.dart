import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sonofy/presentation/blocs/player/player_state.dart';
import 'package:sonofy/presentation/blocs/songs/songs_state.dart';
import 'package:sonofy/presentation/views/modal_view.dart';
import 'package:sonofy/presentation/widgets/common/section_card.dart';
import 'package:sonofy/presentation/widgets/options/add_playlist_option.dart';
import 'package:sonofy/presentation/widgets/options/create_playlist_option.dart';
import 'package:sonofy/presentation/widgets/options/delete_playlist_option.dart';
import 'package:sonofy/presentation/widgets/options/equalizer_option.dart';
import 'package:sonofy/presentation/widgets/options/order_option.dart';
import 'package:sonofy/presentation/widgets/options/remove_playlist_option.dart';
import 'package:sonofy/presentation/widgets/options/rename_playlist_option.dart';
import 'package:sonofy/presentation/widgets/options/reorder_option.dart';
import 'package:sonofy/presentation/widgets/options/settings_option.dart';
import 'package:sonofy/presentation/widgets/options/sleep_option.dart';
import 'package:sonofy/presentation/widgets/options/speed_option.dart';
import 'package:sonofy/presentation/widgets/options/play_song_option.dart';
import 'package:sonofy/presentation/widgets/options/play_next_option.dart';
import 'package:sonofy/presentation/widgets/options/add_to_queue_option.dart';
import 'package:sonofy/presentation/widgets/options/remove_from_queue_option.dart';
import 'package:sonofy/presentation/widgets/options/song_info_option.dart';
import 'package:sonofy/presentation/widgets/options/add_to_playlist_option.dart';
import 'package:sonofy/presentation/widgets/options/remove_from_playlist_option.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonofy/presentation/blocs/player/player_cubit.dart';
import 'package:sonofy/presentation/blocs/songs/songs_cubit.dart';

class OptionsModal {
  BuildContext context;

  OptionsModal(this.context);

  void _show(List<Widget> options) => modalView(
    context,
    isScrollable: true,
    title: context.tr('options.title'),
    children: [SectionCard(title: '', children: options)],
  );

  void library() => _show([
    const SleepOption(),
    const OrderOption(),
    const CreatePlaylistOption(),
    const EqualizerOption(),
    const SettingsOption(),
  ]);

  void playlist() => _show([
    const SleepOption(),
    const ReorderOption(),
    const RenamePlaylistOption(),
    const DeletePlaylistOption(),
    const EqualizerOption(),
    const SettingsOption(),
  ]);

  void player() {
    final playerState = context.read<PlayerCubit>().state;
    final songsState = context.read<SongsCubit>().state;

    final options = <Widget>[
      const SleepOption(),
      const AddPlaylistOption(),
      // Solo mostrar RemovePlaylistOption si estamos reproduciendo desde una playlist
      // (no desde la biblioteca general que incluye todas las canciones)
      if (_isPlayingFromPlaylist(playerState, songsState))
        const RemovePlaylistOption(),
      const SpeedOption(),
      const EqualizerOption(),
      const SettingsOption(),
    ];
    _show(options);
  }

  static bool _isPlayingFromPlaylist(
    PlayerState playerState,
    SongsState songsState,
  ) {
    // Si no hay canción seleccionada, no estamos reproduciendo desde playlist
    if (!playerState.hasSelectedSong) return false;

    // Si la cantidad de canciones en la playlist actual es menor que
    // el total de canciones en la biblioteca, estamos en una playlist específica
    final playlistLength = playerState.playlist.length;
    final totalSongsLength = songsState.songs.length;

    return playlistLength < totalSongsLength;
  }

  void songLibraryContext(SongModel song, List<SongModel> playlist) {
    final playerState = context.read<PlayerCubit>().state;
    final options = <Widget>[
      PlaySongOption(song: song, playlist: playlist),
      if (playerState.hasSelectedSong) ...[
        PlayNextOption(song: song),
        AddToQueueOption(song: song),
      ],
      AddToPlaylistOption(song: song),
      SongInfoOption(song: song),
    ];
    _show(options);
  }

  void songPlaylistContext(SongModel song, List<SongModel> playlist) {
    final playerState = context.read<PlayerCubit>().state;
    final options = <Widget>[
      PlaySongOption(song: song, playlist: playlist),
      if (playerState.hasSelectedSong) ...[
        PlayNextOption(song: song),
        AddToQueueOption(song: song),
      ],
      AddToPlaylistOption(song: song),
      RemoveFromPlaylistOption(song: song),
      SongInfoOption(song: song),
    ];
    _show(options);
  }

  void songPlayerListContext(SongModel song, List<SongModel> playlist) {
    final playerState = context.read<PlayerCubit>().state;
    final options = <Widget>[
      PlaySongOption(song: song, playlist: playlist),
      if (playerState.hasSelectedSong) ...[
        PlayNextOption(song: song),
        AddToQueueOption(song: song),
      ],
      RemoveFromQueueOption(song: song),
      AddToPlaylistOption(song: song),
      SongInfoOption(song: song),
    ];
    _show(options);
  }
}
