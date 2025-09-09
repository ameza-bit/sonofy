import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lrc/lrc.dart';
import 'package:sonofy/core/constants/app_constants.dart';
import 'package:sonofy/core/extensions/theme_extensions.dart';
import 'package:sonofy/data/models/song_metadata.dart';
import 'package:sonofy/presentation/blocs/player/player_cubit.dart';
import 'package:sonofy/presentation/blocs/player/player_state.dart';
import 'package:sonofy/presentation/blocs/settings/settings_cubit.dart';
import 'package:sonofy/presentation/blocs/settings/settings_state.dart';
import 'package:sonofy/presentation/views/modal_view.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';

class LyricsModal extends StatefulWidget {
  const LyricsModal({super.key});

  static void show(BuildContext context) {
    modalView(
      context,
      title: context.tr('player.lyrics.title'),
      maxHeight: 0.85,
      children: [const LyricsModal()],
    );
  }

  @override
  State<LyricsModal> createState() => _LyricsModalState();
}

class _LyricsModalState extends State<LyricsModal> {
  final ScrollController _scrollController = ScrollController();
  LrcLine? _lastCurrentLine;
  bool _userScrolling = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentLine(List<LrcLine> lines, LrcLine currentLine) {
    if (_userScrolling || !_scrollController.hasClients) return;

    if (_lastCurrentLine != currentLine) {
      _lastCurrentLine = currentLine;

      final currentIndex = lines.indexOf(currentLine);
      if (currentIndex != -1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            // Scroll to show the current line centered in viewport
            final viewportHeight = _scrollController.position.viewportDimension;
            final estimatedItemHeight =
                60.0; // More reasonable estimate for variable heights
            final targetOffset =
                (currentIndex * estimatedItemHeight) - (viewportHeight / 2);

            _scrollController.animateTo(
              targetOffset.clamp(
                0.0,
                _scrollController.position.maxScrollExtent,
              ),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    }
  }

  void _onUserScroll() {
    _userScrolling = true;
    // Reset user scrolling flag after a delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _userScrolling = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        final primaryColor = settingsState.settings.primaryColor;

        return Expanded(
          child: BlocBuilder<PlayerCubit, PlayerState>(
            buildWhen: (previous, current) =>
                previous.currentSong != current.currentSong,
            builder: (context, state) {
              final song = state.currentSong;
              if (song == null) {
                return _buildEmptyState(
                  context,
                  FontAwesomeIcons.lightMusic,
                  context.tr('player.lyrics.no_song'),
                  primaryColor,
                );
              }

              final lyrics = SongMetadata.fromSongModel(song).lyrics;
              if (lyrics.isEmpty) {
                return _buildEmptyState(
                  context,
                  FontAwesomeIcons.lightFileLines,
                  context.tr('player.lyrics.no_lyrics'),
                  primaryColor,
                );
              }

              final fixedLrc = fixLrc(lyrics);
              if (!fixedLrc.isValidLrc) {
                return _buildEmptyState(
                  context,
                  FontAwesomeIcons.lightTriangleExclamation,
                  context.tr('player.lyrics.invalid_lyrics'),
                  primaryColor,
                );
              }

              final Lrc parsedLrc = Lrc.parse(fixedLrc);
              return StreamBuilder<int>(
                stream: context.watch<PlayerCubit>().getCurrentSongPosition(),
                builder: (context, snapshot) {
                  final currentPosition = Duration(
                    milliseconds: snapshot.data ?? 0,
                  );

                  final currentLine = parsedLrc.lyrics.reversed.firstWhere(
                    (line) => line.timestamp <= currentPosition,
                    orElse: () => parsedLrc.lyrics.first,
                  );

                  _scrollToCurrentLine(parsedLrc.lyrics, currentLine);

                  return Stack(
                    children: [
                      NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (notification is ScrollStartNotification) {
                            _onUserScroll();
                          }
                          return false;
                        },
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.lg,
                          ),
                          itemCount: parsedLrc.lyrics.length + 1,
                          itemBuilder: (context, index) {
                            if (index == parsedLrc.lyrics.length) {
                              return const SizedBox(
                                height: AppSpacing.bottomSheetHeight,
                              );
                            }

                            final line = parsedLrc.lyrics[index];
                            final isCurrentLine = line == currentLine;

                            return _buildLyricLine(
                              context,
                              line,
                              isCurrentLine,
                              primaryColor,
                              () => _seekToLine(context, line),
                            );
                          },
                        ),
                      ),
                      _buildCenterButton(
                        context,
                        primaryColor,
                        parsedLrc.lyrics,
                        currentLine,
                      ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    IconData icon,
    String message,
    Color primaryColor,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: primaryColor.withValues(alpha: 0.6)),
          const SizedBox(height: AppSpacing.lg),
          Text(
            message,
            style: TextStyle(
              fontSize: context.scaleText(16),
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLyricLine(
    BuildContext context,
    LrcLine line,
    bool isCurrentLine,
    Color primaryColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs / 2),
        decoration: BoxDecoration(
          color: isCurrentLine
              ? primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppBorderRadius.button),
        ),
        child: Text(
          line.lyrics.trim(),
          style: TextStyle(
            fontSize: context.scaleText(16),
            fontWeight: isCurrentLine ? FontWeight.w600 : FontWeight.normal,
            color: isCurrentLine
                ? primaryColor
                : Theme.of(context).textTheme.bodyMedium?.color,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildCenterButton(
    BuildContext context,
    Color primaryColor,
    List<LrcLine> lines,
    LrcLine currentLine,
  ) {
    return Positioned(
      bottom: AppSpacing.lg,
      right: AppSpacing.lg,
      child: Material(
        color: primaryColor,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            _userScrolling = false;
            _scrollToCurrentLine(lines, currentLine);
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
            child: const Icon(
              FontAwesomeIcons.lightLocationArrow,
              size: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _seekToLine(BuildContext context, LrcLine line) {
    final playerCubit = context.read<PlayerCubit>();
    playerCubit.seekTo(line.timestamp);
  }

  String fixLrc(String input) {
    // Expresión para detectar etiquetas [xxx:...]
    final tagExp = RegExp(r'\[([a-zA-Z]+):.*?\]');

    return input.replaceAllMapped(tagExp, (match) {
      final tag = match.group(1)!.toLowerCase();

      // Lista de etiquetas válidas en el regex
      const allowedTags = [
        'ar',
        'al',
        'ti',
        've',
        'au',
        'length',
        'by',
        're',
        'offset',
      ];

      if (allowedTags.contains(tag)) {
        return match.group(0)!; // se conserva
      } else {
        return ''; // se elimina la etiqueta no válida
      }
    });
  }
}
