import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
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
import 'package:sonofy/presentation/widgets/options/share_option.dart';
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

class OptionsModal {
  static void _show(BuildContext context, List<Widget> options) => modalView(
    context,
    isScrollable: true,
    title: context.tr('options.title'),
    children: [SectionCard(title: '', children: options)],
  );

  static void library(BuildContext context) => _show(context, [
    const SleepOption(),
    const OrderOption(),
    const CreatePlaylistOption(),
    const EqualizerOption(),
    const SettingsOption(),
  ]);

  static void playlist(BuildContext context) => _show(context, [
    const SleepOption(),
    const ReorderOption(),
    const RenamePlaylistOption(),
    const DeletePlaylistOption(),
    const EqualizerOption(),
    const SettingsOption(),
  ]);

  static void player(BuildContext context) => _show(context, [
    const SleepOption(),
    const AddPlaylistOption(),
    const RemovePlaylistOption(),
    const SpeedOption(),
    const ShareOption(),
    const EqualizerOption(),
    const SettingsOption(),
  ]);

  static void songContext(BuildContext context, SongModel song, List<SongModel> playlist) => _show(context, [
    PlaySongOption(song: song, playlist: playlist),
    PlayNextOption(song: song),
    AddToQueueOption(song: song),
    RemoveFromQueueOption(song: song),
    AddToPlaylistOption(song: song),
    RemoveFromPlaylistOption(song: song),
    SongInfoOption(song: song),
    const ShareOption(),
  ]);
}
