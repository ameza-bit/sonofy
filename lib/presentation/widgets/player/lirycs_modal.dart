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
      title: context.tr('player.lyrics.title'),
      maxHeight: 0.85,
      showPlayer: true,
      children: [const LyricsModal()],
    );
  }

  String fixLrc(String input) {
    final tagExp = RegExp(r'\[([a-zA-Z]+):.*?\]');

    return input.replaceAllMapped(tagExp, (match) {
      final tag = match.group(1)!.toLowerCase();

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
        return match.group(0)!;
      } else {
        return '';
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
                context.tr('player.lyrics.no_song'),
                style: TextStyle(fontSize: context.scaleText(16)),
              ),
            );
          }

          final lyrics = SongMetadata.fromSongModel(song).lyrics;
          if (lyrics.isEmpty) {
            return Center(
              child: Text(
                context.tr('player.lyrics.no_lyrics'),
                style: TextStyle(fontSize: context.scaleText(16)),
              ),
            );
          }

          final fixedLrc = fixLrc(lyrics);
          if (!fixedLrc.isValidLrc) {
            return Center(
              child: Text(
                context.tr('player.lyrics.invalid_lyrics'),
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

              int currentIndex = 0;
              for (int i = parsedLrc.lyrics.length - 1; i >= 0; i--) {
                if (parsedLrc.lyrics[i].timestamp <= currentPosition) {
                  currentIndex = i;
                  break;
                }
              }

              return _LyricsListView(
                parsedLrc: parsedLrc,
                currentIndex: currentIndex,
              );
            },
          );
        },
      ),
    );
  }
}

class _LyricsListView extends StatefulWidget {
  final Lrc parsedLrc;
  final int currentIndex;

  const _LyricsListView({required this.parsedLrc, required this.currentIndex});

  @override
  State<_LyricsListView> createState() => _LyricsListViewState();
}

class _LyricsListViewState extends State<_LyricsListView> {
  late ScrollController _scrollController;
  int? _previousIndex;
  final List<GlobalKey> _itemKeys = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _previousIndex = widget.currentIndex;

    // Crear keys para cada item
    _itemKeys.clear();
    for (int i = 0; i < widget.parsedLrc.lyrics.length; i++) {
      _itemKeys.add(GlobalKey());
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentLine();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_LyricsListView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.currentIndex != _previousIndex) {
      _scrollToCurrentLine();
      _previousIndex = widget.currentIndex;
    }
  }

  void _scrollToCurrentLine() {
    if (_scrollController.hasClients && widget.currentIndex >= 0) {
      final previousLineIndex = widget.currentIndex > 0
          ? widget.currentIndex - 1
          : 0;

      // Usar ensureVisible para scroll preciso
      if (previousLineIndex < _itemKeys.length) {
        final context = _itemKeys[previousLineIndex].currentContext;
        if (context != null) {
          Scrollable.ensureVisible(
            context,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
          return;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: widget.parsedLrc.lyrics.length,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemBuilder: (context, index) {
        final line = widget.parsedLrc.lyrics[index];
        final isCurrentLine = index == widget.currentIndex;
        final isPastLine = index < widget.currentIndex;

        return InkWell(
          onTap: () => context.read<PlayerCubit>().seekTo(line.timestamp),
          child: AnimatedContainer(
            key: index < _itemKeys.length ? _itemKeys[index] : null,
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 20.0,
            ),
            decoration: BoxDecoration(
              color: isCurrentLine
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12.0),
              border: isCurrentLine
                  ? Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.3),
                    )
                  : null,
            ),
            child: Text(
              line.lyrics.isNotEmpty ? line.lyrics : '♪',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: context.scaleText(isCurrentLine ? 18 : 16),
                fontWeight: isCurrentLine ? FontWeight.bold : FontWeight.w400,
                color: isCurrentLine
                    ? Theme.of(context).colorScheme.primary
                    : isPastLine
                    ? Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withValues(alpha: 0.6)
                    : Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
          ),
        );
      },
    );
  }
}
