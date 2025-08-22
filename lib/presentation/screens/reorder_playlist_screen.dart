import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:sonofy/core/extensions/color_extensions.dart';
import 'package:sonofy/core/extensions/theme_extensions.dart';
import 'package:sonofy/core/utils/duration_minutes.dart';
import 'package:sonofy/presentation/blocs/playlists/playlists_cubit.dart';
import 'package:sonofy/presentation/blocs/playlists/playlists_state.dart';
import 'package:sonofy/presentation/blocs/songs/songs_cubit.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';

class ReorderPlaylistScreen extends StatefulWidget {
  static const String routeName = 'reorder-playlist';
  
  const ReorderPlaylistScreen({
    required this.playlistId,
    super.key,
  });

  final String playlistId;

  @override
  State<ReorderPlaylistScreen> createState() => _ReorderPlaylistScreenState();
}

class _ReorderPlaylistScreenState extends State<ReorderPlaylistScreen> {
  List<SongModel> orderedSongs = [];
  bool hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadPlaylistSongs();
  }

  void _loadPlaylistSongs() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final playlistsState = context.read<PlaylistsCubit>().state;
      final songsState = context.read<SongsCubit>().state;
      
      final playlist = playlistsState.getPlaylistById(widget.playlistId);
      if (playlist != null) {
        final songs = songsState.songs.where((song) {
          final songIdAsString = song.id.toString();
          return playlist.songIds.contains(songIdAsString);
        }).toList();
        
        // Ordenar las canciones según el orden en la playlist
        final orderedList = <SongModel>[];
        for (final songId in playlist.songIds) {
          final song = songs.where((s) => s.id.toString() == songId).firstOrNull;
          if (song != null) {
            orderedList.add(song);
          }
        }
        
        setState(() {
          orderedSongs = orderedList;
        });
      }
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = orderedSongs.removeAt(oldIndex);
      orderedSongs.insert(newIndex, item);
      hasChanges = true;
    });
  }

  Future<void> _saveChanges() async {
    if (!hasChanges) return;
    
    final newOrder = orderedSongs.map((song) => song.id.toString()).toList();
    
    try {
      await context.read<PlaylistsCubit>().reorderSongsInPlaylist(
        widget.playlistId,
        newOrder,
      );
      
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('common.error_occurred')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _discardChanges() {
    if (hasChanges) {
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(context.tr('common.discard_changes')),
            content: Text(context.tr('reorder.discard_changes_message')),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(context.tr('common.cancel')),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.pop();
                },
                child: Text(context.tr('common.discard')),
              ),
            ],
          );
        },
      );
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaylistsCubit, PlaylistsState>(
      builder: (context, playlistsState) {
        final playlist = playlistsState.getPlaylistById(widget.playlistId);
        
        return Scaffold(
          appBar: AppBar(
            title: Text(
              context.tr('reorder.title'),
              style: TextStyle(
                fontSize: context.scaleText(24),
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: IconButton(
              icon: const Icon(FontAwesomeIcons.lightXmark),
              onPressed: _discardChanges,
            ),
            actions: [
              TextButton(
                onPressed: hasChanges ? _saveChanges : null,
                child: Text(
                  context.tr('common.save'),
                  style: TextStyle(
                    fontSize: context.scaleText(16),
                    fontWeight: FontWeight.bold,
                    color: hasChanges
                        ? Theme.of(context).primaryColor
                        : context.musicLightGrey,
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                if (playlist != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.lightMusic,
                          color: context.musicLightGrey,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            playlist.title,
                            style: TextStyle(
                              fontSize: context.scaleText(16),
                              color: context.musicLightGrey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          context.tr('reorder.songs_count', namedArgs: {
                            'count': orderedSongs.length.toString(),
                          }),
                          style: TextStyle(
                            fontSize: context.scaleText(14),
                            color: context.musicLightGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                const Divider(height: 1),
                Expanded(
                  child: orderedSongs.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 16.0,
                            children: [
                              Icon(
                                FontAwesomeIcons.lightMusic,
                                size: 64,
                                color: Theme.of(context).iconTheme.color,
                              ),
                              Text(
                                context.tr('playlist.empty'),
                                style: TextStyle(
                                  fontSize: context.scaleText(18),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ReorderableListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: orderedSongs.length,
                          onReorder: _onReorder,
                          itemBuilder: (context, index) {
                            final song = orderedSongs[index];
                            
                            return Card(
                              key: ValueKey(song.id),
                              margin: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  spacing: 12,
                                  children: [
                                    Icon(
                                      FontAwesomeIcons.lightGripVertical,
                                      color: context.musicLightGrey,
                                      size: 16,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        spacing: 4,
                                        children: [
                                          Text(
                                            song.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: context.scaleText(16),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            song.artist ?? song.composer ?? 'Desconocido',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: context.scaleText(12),
                                              color: context.musicLightGrey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      DurationMinutes.format(song.duration ?? 0),
                                      style: TextStyle(
                                        fontSize: context.scaleText(12),
                                        color: context.musicLightGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}