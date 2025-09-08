import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lrc/lrc.dart';
import 'package:sonofy/core/extensions/theme_extensions.dart';
import 'package:sonofy/data/models/song_metadata.dart';
import 'package:sonofy/presentation/blocs/player/player_cubit.dart';
import 'package:sonofy/presentation/blocs/player/player_state.dart';
import 'package:sonofy/presentation/views/modal_view.dart';

class LyricsModal extends StatelessWidget {
  const LyricsModal({super.key});

  static void show(BuildContext context) {
    modalView(
      context,
      title: context.tr('player.lyrics'),
      maxHeight: 0.85,
      showPlayer: true,
      children: [const LyricsModal()],
    );
  }

  String fixLrc(String input) {
    // Expresión para detectar etiquetas [xxx:...]
    final tagExp = RegExp(r'\[([a-zA-Z]+):.*?\]');

    return input.replaceAllMapped(tagExp, (match) {
      final tag = match.group(1)!.toLowerCase();

      // Lista de etiquetas válidas en tu regex
      const allowedTags = [
        'ti',
        'ar',
        'al',
        'by',
        're',
        've',
        'length',
        'offset',
        'la',
      ];

      if (allowedTags.contains(tag)) {
        return match.group(0)!; // se conserva
      } else {
        return ''; // se elimina la etiqueta no válida
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocBuilder<PlayerCubit, PlayerState>(
        buildWhen: (previous, current) =>
            previous.currentSong != current.currentSong,
        builder: (context, state) {
          final song = state.currentSong;
          if (song == null) {
            return Center(
              child: Text(
                context.tr('player.no_lyrics'),
                style: TextStyle(fontSize: context.scaleText(16)),
              ),
            );
          }

          final lyrics = SongMetadata.fromSongModel(song).lyrics;
          if (lyrics.isEmpty) {
            return Center(
              child: Text(
                context.tr('player.no_lyrics'),
                style: TextStyle(fontSize: context.scaleText(16)),
              ),
            );
          }

          final fixedLrc = fixLrc(lyrics);
          if (!fixedLrc.isValidLrc) {
            return Center(
              child: Text(
                context.tr('player.no_lyrics'),
                style: TextStyle(fontSize: context.scaleText(16)),
              ),
            );
          }

          final Lrc parsedLrc = Lrc.parse(fixedLrc);
          return StreamBuilder<int>(
            stream: context.watch<PlayerCubit>().getCurrentSongPosition(),
            builder: (context, snapshot) {
              final currentPosition = Duration(
                milliseconds: snapshot.data ?? 0,
              );

              return Center(
                child: Text(
                  parsedLrc.lyrics.reversed
                      .firstWhere(
                        (line) => line.timestamp <= currentPosition,
                        orElse: () => LrcLine(
                          timestamp: Duration.zero,
                          lyrics: context.tr('player.no_lyrics'),
                          type: LrcTypes.simple,
                        ),
                      )
                      .lyrics,
                  style: TextStyle(fontSize: context.scaleText(16)),
                ),
              );

              // return ListView(
              //   children: [
              //     for (int i = 0; i < parsedLrc.lyrics.length; i++) ...[
              //       ListTile(
              //         title: Text(
              //           parsedLrc.lyrics[i].lyrics,
              //           textAlign: TextAlign.center,
              //           style: TextStyle(fontSize: context.scaleText(16)),
              //         ),
              //         onTap: () {
              //           // Handle lyric tap
              //         },
              //       ),
              //     ],
              //   ],
              // );
            },
          );
        },
      ),
    );
  }
}
